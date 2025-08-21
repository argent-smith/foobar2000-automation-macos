#!/bin/bash
#
# foobar2000 Directory Monitor для macOS (bash версия)
# Отслеживает папку ~/Music/Import и автоматически добавляет новые аудиофайлы в foobar2000
#

set -euo pipefail

# Цвета для вывода
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Конфигурация
readonly IMPORT_DIR="$HOME/Music/Import"
readonly LOG_DIR="$HOME/Library/foobar2000-v2/logs"
readonly LOG_FILE="$LOG_DIR/monitor.log"
readonly LOCK_FILE="$LOG_DIR/monitor.lock"

# Поддерживаемые аудиоформаты
readonly AUDIO_EXTENSIONS="flac mp3 wav m4a aac opus ogg wma"

# Создание необходимых директорий
mkdir -p "$IMPORT_DIR" "$LOG_DIR"

# Функции логирования
log_message() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

log_info() { log_message "INFO" "$@"; }
log_error() { log_message "ERROR" "$@"; }
log_warning() { log_message "WARNING" "$@"; }
log_success() { log_message "SUCCESS" "$@"; }

# Проверка, что foobar2000 запущен
check_foobar2000_running() {
    pgrep -q -f "foobar2000"
}

# Добавление файла в foobar2000 через AppleScript
add_to_foobar2000() {
    local file_path="$1"
    
    log_info "Добавление файла в foobar2000: $(basename "$file_path")"
    
    # Convert to absolute path for AppleScript compatibility
    local abs_path
    abs_path=$(realpath "$file_path" 2>/dev/null || echo "$(cd "$(dirname "$file_path")" 2>/dev/null && pwd)/$(basename "$file_path")")
    
    if osascript -e "tell application \"foobar2000\" to open POSIX file \"$abs_path\"" 2>/dev/null; then
        log_success "✓ Успешно добавлен: $(basename "$file_path")"
        return 0
    else
        log_error "✗ Ошибка добавления: $(basename "$file_path")"
        return 1
    fi
}

# Проверка, является ли файл аудиофайлом
is_audio_file() {
    local file="$1"
    local ext="${file##*.}"
    ext="${ext,,}" # в нижний регистр
    
    for audio_ext in $AUDIO_EXTENSIONS; do
        if [[ "$ext" == "$audio_ext" ]]; then
            return 0
        fi
    done
    return 1
}

# Ожидание завершения записи файла
wait_for_file_complete() {
    local file_path="$1"
    local timeout=30
    local check_interval=1
    local stable_count=0
    local required_stable=3
    local previous_size=-1
    
    log_info "Ожидание завершения записи: $(basename "$file_path")"
    
    while [[ $timeout -gt 0 ]]; do
        if [[ ! -f "$file_path" ]]; then
            sleep "$check_interval"
            ((timeout -= check_interval))
            continue
        fi
        
        local current_size
        current_size=$(stat -f%z "$file_path" 2>/dev/null || echo "0")
        
        if [[ "$current_size" == "$previous_size" ]]; then
            ((stable_count++))
            if [[ $stable_count -ge $required_stable ]]; then
                log_info "Файл готов: $(basename "$file_path")"
                return 0
            fi
        else
            stable_count=0
            previous_size="$current_size"
        fi
        
        sleep "$check_interval"
        ((timeout -= check_interval))
    done
    
    log_warning "Таймаут ожидания завершения записи: $(basename "$file_path")"
    return 1
}

# Обработка одного файла
process_file() {
    local file_path="$1"
    
    if [[ ! -f "$file_path" ]]; then
        return
    fi
    
    if ! is_audio_file "$file_path"; then
        return
    fi
    
    log_info "Обнаружен новый аудиофайл: $(basename "$file_path")"
    
    # Ожидание завершения записи
    if wait_for_file_complete "$file_path"; then
        # Добавление в foobar2000
        if add_to_foobar2000 "$file_path"; then
            # Запись в файл обработанных файлов
            echo "$file_path" >> "$LOG_DIR/processed_files.txt"
        fi
    fi
}

# Проверка уже обработанных файлов
is_file_processed() {
    local file_path="$1"
    local processed_file="$LOG_DIR/processed_files.txt"
    
    if [[ -f "$processed_file" ]]; then
        grep -Fxq "$file_path" "$processed_file" 2>/dev/null
    else
        return 1
    fi
}

# Сканирование существующих файлов
scan_existing_files() {
    log_info "Сканирование существующих файлов в папке импорта..."
    
    local count=0
    for ext in $AUDIO_EXTENSIONS; do
        while IFS= read -r -d '' file; do
            if [[ -f "$file" ]] && ! is_file_processed "$file"; then
                log_info "Найден существующий файл: $(basename "$file")"
                process_file "$file"
                ((count++))
            fi
        done < <(find "$IMPORT_DIR" -type f -name "*.$ext" -print0 2>/dev/null || true)
    done
    
    if [[ $count -eq 0 ]]; then
        log_info "Существующих аудиофайлов не найдено"
    else
        log_success "Обработано существующих файлов: $count"
    fi
}

# Мониторинг с использованием fswatch или polling
monitor_with_fswatch() {
    log_info "Используется fswatch для мониторинга"
    
    fswatch -0 -r -e ".*" -i "\\.($AUDIO_EXTENSIONS)$" "$IMPORT_DIR" | \
    while IFS= read -r -d '' file; do
        process_file "$file"
    done
}

# Простой polling мониторинг
monitor_with_polling() {
    log_info "Используется polling мониторинг (интервал: 5 секунд)"
    
    local last_scan_file="$LOG_DIR/last_scan.txt"
    
    while true; do
        local current_time=$(date +%s)
        
        # Ищем файлы, измененные за последние 10 секунд
        for ext in $AUDIO_EXTENSIONS; do
            while IFS= read -r -d '' file; do
                if [[ -f "$file" ]] && ! is_file_processed "$file"; then
                    local file_mtime
                    file_mtime=$(stat -f%m "$file" 2>/dev/null || echo "0")
                    
                    # Если файл изменен за последние 10 секунд
                    if [[ $((current_time - file_mtime)) -le 10 ]]; then
                        process_file "$file"
                    fi
                fi
            done < <(find "$IMPORT_DIR" -type f -name "*.$ext" -newermt @$((current_time - 10)) -print0 2>/dev/null || true)
        done
        
        sleep 5
    done
}

# Очистка при выходе
cleanup() {
    local exit_code=$?
    
    if [[ -f "$LOCK_FILE" ]]; then
        rm -f "$LOCK_FILE"
    fi
    
    log_info "=== Мониторинг остановлен ==="
    exit $exit_code
}

# Проверка уже запущенного процесса
check_already_running() {
    if [[ -f "$LOCK_FILE" ]]; then
        local pid
        pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
        
        if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
            echo -e "${RED}Мониторинг уже запущен (PID: $pid)${NC}"
            echo "Для остановки: kill $pid"
            exit 1
        else
            rm -f "$LOCK_FILE"
        fi
    fi
}

# Показать статус
show_status() {
    echo -e "\n${CYAN}=====================================${NC}"
    echo -e "${CYAN}  foobar2000 Directory Monitor       ${NC}"
    echo -e "${CYAN}=====================================${NC}"
    echo -e "${BLUE}Папка мониторинга:${NC} $IMPORT_DIR"
    echo -e "${BLUE}Лог файл:${NC} $LOG_FILE"
    echo -e "${BLUE}Поддерживаемые форматы:${NC} $AUDIO_EXTENSIONS"
    
    if check_foobar2000_running; then
        echo -e "${BLUE}foobar2000:${NC} ${GREEN}✓ Запущен${NC}"
    else
        echo -e "${BLUE}foobar2000:${NC} ${RED}✗ Не запущен${NC}"
    fi
    
    if command -v fswatch >/dev/null 2>&1; then
        echo -e "${BLUE}fswatch:${NC} ${GREEN}✓ Доступен${NC}"
    else
        echo -e "${BLUE}fswatch:${NC} ${YELLOW}○ Не установлен (будет использоваться polling)${NC}"
    fi
    
    echo -e "${CYAN}=====================================${NC}\n"
}

# Главная функция
main() {
    trap cleanup EXIT INT TERM
    
    log_info "=== Запуск мониторинга foobar2000 ==="
    
    # Показать статус
    show_status
    
    # Проверка уже запущенного процесса
    check_already_running
    
    # Создание lock файла
    echo $$ > "$LOCK_FILE"
    
    # Проверка директории импорта
    if [[ ! -d "$IMPORT_DIR" ]]; then
        log_error "Папка не найдена: $IMPORT_DIR"
        exit 1
    fi
    
    # Предупреждение если foobar2000 не запущен
    if ! check_foobar2000_running; then
        log_warning "foobar2000 не запущен, но мониторинг продолжается"
        log_info "Файлы будут добавлены при запуске foobar2000"
    else
        log_info "foobar2000 обнаружен и запущен"
    fi
    
    # Сканирование существующих файлов
    scan_existing_files
    
    log_info "✓ Мониторинг запущен. Нажмите Ctrl+C для остановки."
    echo -e "${GREEN}Мониторинг активен. Добавляйте файлы в папку: $IMPORT_DIR${NC}"
    
    # Выбор метода мониторинга
    if command -v fswatch >/dev/null 2>&1; then
        monitor_with_fswatch
    else
        log_warning "fswatch не найден, используется polling режим"
        log_info "Для лучшей производительности установите: brew install fswatch"
        monitor_with_polling
    fi
}

# Обработка аргументов командной строки
case "${1:-}" in
    --status|-s)
        show_status
        if [[ -f "$LOCK_FILE" ]]; then
            local pid
            pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
            if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
                echo -e "${GREEN}Мониторинг запущен (PID: $pid)${NC}"
            else
                echo -e "${YELLOW}Lock файл найден, но процесс не активен${NC}"
                rm -f "$LOCK_FILE"
            fi
        else
            echo -e "${YELLOW}Мониторинг не запущен${NC}"
        fi
        ;;
    --stop)
        if [[ -f "$LOCK_FILE" ]]; then
            local pid
            pid=$(cat "$LOCK_FILE" 2>/dev/null || echo "")
            if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
                echo -e "${YELLOW}Остановка мониторинга (PID: $pid)...${NC}"
                kill "$pid"
                sleep 2
                if kill -0 "$pid" 2>/dev/null; then
                    kill -KILL "$pid"
                fi
                echo -e "${GREEN}Мониторинг остановлен${NC}"
            else
                echo -e "${YELLOW}Мониторинг не запущен${NC}"
                rm -f "$LOCK_FILE"
            fi
        else
            echo -e "${YELLOW}Мониторинг не запущен${NC}"
        fi
        ;;
    --help|-h)
        echo "foobar2000 Directory Monitor для macOS"
        echo
        echo "Использование: $0 [ОПЦИЯ]"
        echo
        echo "Опции:"
        echo "  (без аргументов)  Запуск мониторинга"
        echo "  --status, -s      Показать статус"
        echo "  --stop            Остановить мониторинг"
        echo "  --help, -h        Показать эту справку"
        echo
        ;;
    *)
        main
        ;;
esac