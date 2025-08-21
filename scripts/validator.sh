#!/bin/bash
#
# Валидатор установки foobar2000 для macOS
# Проверяет корректность установки, конфигурации и функциональности
#
# Использование:
#   ./validator.sh [-f foobar_path] [-p profile] [-r report_path] [-d]
#
# Параметры:
#   -f, --foobar-path   Путь к foobar2000.app
#   -p, --profile       Профиль для проверки
#   -r, --report        Путь для сохранения отчета о валидации
#   -d, --detailed      Детальный отчет
#   -h, --help         Показать справку

set -euo pipefail

# Константы
readonly SCRIPT_VERSION="1.0.0"
readonly LOG_PATH="./validator.log"

# Переменные по умолчанию
FOOBAR_PATH=""
PROFILE=""
REPORT_PATH="./validation-report.json"
DETAILED=false

# Результаты валидации
declare -A VALIDATION_RESULTS
VALIDATION_RESULTS[success]="true"
VALIDATION_RESULTS[timestamp]=$(date -u '+%Y-%m-%dT%H:%M:%SZ')

declare -a ISSUES
declare -a WARNINGS
declare -A COMPONENTS_STATUS
declare -A CONFIG_STATUS
declare -A FUNCTIONALITY_STATUS

# Цвета для вывода
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Функции логирования
write_log() {
    local level="${1:-INFO}"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_PATH"
}

log_info() {
    write_log "INFO" "$1"
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    write_log "SUCCESS" "$1"
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    write_log "WARNING" "$1"
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    write_log "ERROR" "$1"
    echo -e "${RED}[ERROR]${NC} $1"
}

# Показать справку
show_help() {
    cat << 'EOF'
foobar2000 Validator для macOS v1.0.0

Комплексная проверка установки и конфигурации foobar2000 на macOS.

ИСПОЛЬЗОВАНИЕ:
    ./validator.sh [ОПЦИИ]

ОПЦИИ:
    -f, --foobar-path PATH   Путь к foobar2000.app
    -p, --profile PROFILE    Профиль для проверки
    -r, --report PATH        Путь для отчета JSON
    -d, --detailed          Детальный отчет
    -h, --help              Показать справку

ПРОФИЛИ:
    minimal        Базовые компоненты
    standard       Стандартная конфигурация
    professional   Профессиональная настройка

ПРИМЕРЫ:
    ./validator.sh
    ./validator.sh -f /Applications/foobar2000.app -p standard
    ./validator.sh -d -r detailed_report.json

ПРОВЕРКИ:
    • Установка foobar2000 и версия
    • Наличие и версии аудио кодировщиков
    • Конфигурационные файлы
    • Интеграция с macOS
    • Функциональность

EOF
}

# Парсинг аргументов
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--foobar-path)
                FOOBAR_PATH="$2"
                shift 2
                ;;
            -p|--profile)
                PROFILE="$2"
                shift 2
                ;;
            -r|--report)
                REPORT_PATH="$2"
                shift 2
                ;;
            -d|--detailed)
                DETAILED=true
                shift
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            *)
                log_error "Неизвестная опция: $1"
                echo "Используйте --help для получения справки"
                exit 1
                ;;
        esac
    done
}

# Добавление проблемы
add_issue() {
    local category="$1"
    local description="$2"
    local severity="${3:-Error}"
    
    if [[ "$severity" == "Error" ]]; then
        ISSUES+=("[$category] $description")
        VALIDATION_RESULTS[success]="false"
        echo -e "${RED}✗${NC} $description"
    else
        WARNINGS+=("[$category] $description")
        echo -e "${YELLOW}⚠${NC} $description"
    fi
}

# Добавление успеха
add_success() {
    local description="$1"
    echo -e "${GREEN}✓${NC} $description"
}

# Проверка базовой установки foobar2000
check_foobar_installation() {
    log_info "Проверка установки foobar2000"
    
    # Автоматический поиск если путь не указан
    if [[ -z "$FOOBAR_PATH" ]]; then
        local possible_paths=(
            "/Applications/foobar2000.app"
            "$HOME/Applications/foobar2000.app"
        )
        
        for path in "${possible_paths[@]}"; do
            if [[ -d "$path" ]]; then
                FOOBAR_PATH="$path"
                break
            fi
        done
    fi
    
    if [[ ! -d "$FOOBAR_PATH" ]]; then
        add_issue "Installation" "foobar2000 не найден"
        return 1
    fi
    
    # Проверка структуры приложения
    if [[ ! -d "$FOOBAR_PATH/Contents" ]]; then
        add_issue "Installation" "Некорректная структура приложения foobar2000"
        return 1
    fi
    
    # Получение версии
    local info_plist="$FOOBAR_PATH/Contents/Info.plist"
    if [[ -f "$info_plist" ]]; then
        local version
        version=$(plutil -extract CFBundleShortVersionString xml1 -o - "$info_plist" 2>/dev/null | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p' | head -n1)
        
        if [[ -n "$version" ]]; then
            VALIDATION_RESULTS[foobar_version]="$version"
            add_success "foobar2000 найден, версия: $version"
        else
            add_issue "Installation" "Не удалось определить версию foobar2000" "Warning"
        fi
    else
        add_issue "Installation" "Файл Info.plist не найден" "Warning"
    fi
    
    # Проверка исполняемого файла
    local executable="$FOOBAR_PATH/Contents/MacOS/foobar2000"
    if [[ ! -x "$executable" ]]; then
        add_issue "Installation" "Исполняемый файл foobar2000 не найден или не исполняем"
        return 1
    fi
    
    add_success "Базовая установка foobar2000 корректна"
    return 0
}

# Проверка аудио кодировщиков
check_audio_encoders() {
    log_info "Проверка аудио кодировщиков"
    
    local encoders=(
        "flac:FLAC кодировщик"
        "lame:LAME MP3 кодировщик"
        "opusenc:Opus кодировщик"
        "ffmpeg:FFmpeg мультимедиа фреймворк"
    )
    
    for encoder_info in "${encoders[@]}"; do
        IFS=':' read -ra ENCODER_PARTS <<< "$encoder_info"
        local encoder="${ENCODER_PARTS[0]}"
        local description="${ENCODER_PARTS[1]}"
        
        if command -v "$encoder" >/dev/null 2>&1; then
            local version
            case "$encoder" in
                flac)
                    version=$(flac --version 2>&1 | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
                    ;;
                lame)
                    version=$(lame --version 2>&1 | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
                    ;;
                ffmpeg)
                    version=$(ffmpeg -version 2>&1 | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
                    ;;
                opusenc)
                    version=$(opusenc --version 2>&1 | head -n1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1)
                    ;;
                *)
                    version="unknown"
                    ;;
            esac
            
            COMPONENTS_STATUS[$encoder]="installed:$version"
            add_success "$description найден (версия: $version)"
        else
            COMPONENTS_STATUS[$encoder]="missing"
            local severity="Error"
            
            # Для некоторых кодировщиков это предупреждение, а не ошибка
            if [[ "$encoder" == "opusenc" ]] && [[ "$PROFILE" == "minimal" ]]; then
                severity="Warning"
            fi
            
            add_issue "Encoders" "$description не найден" "$severity"
        fi
    done
}

# Проверка утилит
check_utilities() {
    log_info "Проверка дополнительных утилит"
    
    local utilities=(
        "mediainfo:MediaInfo анализатор"
        "tag:Tag редактор"
        "jq:JSON процессор"
        "wget:Загрузчик файлов"
    )
    
    for util_info in "${utilities[@]}"; do
        IFS=':' read -ra UTIL_PARTS <<< "$util_info"
        local util="${UTIL_PARTS[0]}"
        local description="${UTIL_PARTS[1]}"
        
        if command -v "$util" >/dev/null 2>&1; then
            local version
            version=$($util --version 2>&1 | head -n1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1 || echo "unknown")
            
            COMPONENTS_STATUS[$util]="installed:$version"
            add_success "$description найден (версия: $version)"
        else
            COMPONENTS_STATUS[$util]="missing"
            add_issue "Utilities" "$description не найден" "Warning"
        fi
    done
}

# Проверка конфигурационных файлов
check_configuration_files() {
    log_info "Проверка конфигурационных файлов"
    
    local config_dir="$HOME/Library/Application Support/foobar2000"
    
    if [[ ! -d "$config_dir" ]]; then
        add_issue "Configuration" "Конфигурационная папка не найдена: $config_dir"
        return 1
    fi
    
    local config_files=(
        "configuration.cfg:Основная конфигурация:required"
        "encoder_presets:Пресеты кодировщиков:directory"
        "masstagger_scripts:Скрипты тегирования:directory"
        "macos_integration.cfg:Интеграция с macOS:optional"
    )
    
    for file_info in "${config_files[@]}"; do
        IFS=':' read -ra FILE_PARTS <<< "$file_info"
        local file_name="${FILE_PARTS[0]}"
        local description="${FILE_PARTS[1]}"
        local file_type="${FILE_PARTS[2]}"
        
        local file_path="$config_dir/$file_name"
        
        if [[ "$file_type" == "directory" ]]; then
            if [[ -d "$file_path" ]]; then
                local file_count
                file_count=$(find "$file_path" -type f | wc -l | tr -d ' ')
                CONFIG_STATUS[$file_name]="present:$file_count files"
                add_success "$description найден ($file_count файлов)"
            else
                CONFIG_STATUS[$file_name]="missing"
                add_issue "Configuration" "$description не найден" "Warning"
            fi
        else
            if [[ -f "$file_path" ]]; then
                local file_size
                file_size=$(stat -f%z "$file_path" 2>/dev/null || echo "0")
                CONFIG_STATUS[$file_name]="present:$file_size bytes"
                add_success "$description найден ($file_size байт)"
            else
                CONFIG_STATUS[$file_name]="missing"
                local severity="Error"
                [[ "$file_type" == "optional" ]] && severity="Warning"
                add_issue "Configuration" "$description не найден" "$severity"
            fi
        fi
    done
}

# Проверка интеграции с macOS
check_macos_integration() {
    log_info "Проверка интеграции с macOS"
    
    # Проверка файловых ассоциаций
    local audio_extensions=(".mp3" ".flac" ".m4a" ".opus" ".wav" ".aiff")
    local associated_count=0
    
    for ext in "${audio_extensions[@]}"; do
        local handler
        handler=$(duti -x "$ext" 2>/dev/null | head -n1 | awk '{print $1}' || echo "")
        
        if [[ "$handler" == *"foobar2000"* ]]; then
            ((associated_count++))
        fi
    done
    
    if [[ $associated_count -gt 0 ]]; then
        add_success "Файловые ассоциации настроены ($associated_count из ${#audio_extensions[@]})"
        FUNCTIONALITY_STATUS[file_associations]="configured:$associated_count"
    else
        add_issue "Integration" "Файловые ассоциации не настроены" "Warning"
        FUNCTIONALITY_STATUS[file_associations]="not_configured"
    fi
    
    # Проверка Homebrew интеграции
    if command -v brew >/dev/null 2>&1; then
        add_success "Homebrew найден - интеграция доступна"
        FUNCTIONALITY_STATUS[homebrew]="available"
        
        # Проверка установки foobar2000 через Homebrew Cask
        if brew list --cask foobar2000 >/dev/null 2>&1; then
            add_success "foobar2000 установлен через Homebrew Cask"
            FUNCTIONALITY_STATUS[homebrew_cask]="installed"
        else
            add_issue "Integration" "foobar2000 не установлен через Homebrew Cask" "Warning"
            FUNCTIONALITY_STATUS[homebrew_cask]="not_installed"
        fi
    else
        add_issue "Integration" "Homebrew не найден" "Warning"
        FUNCTIONALITY_STATUS[homebrew]="missing"
    fi
    
    # Проверка разрешений на папки
    local test_dirs=("$HOME/Music" "$HOME/Downloads")
    
    for test_dir in "${test_dirs[@]}"; do
        if [[ -d "$test_dir" ]] && [[ -r "$test_dir" ]]; then
            add_success "Доступ к папке: $test_dir"
        else
            add_issue "Permissions" "Нет доступа к папке: $test_dir" "Warning"
        fi
    done
}

# Проверка функциональности
check_functionality() {
    log_info "Проверка функциональности"
    
    # Проверка запуска foobar2000
    if [[ -n "$FOOBAR_PATH" ]]; then
        local executable="$FOOBAR_PATH/Contents/MacOS/foobar2000"
        
        if [[ -x "$executable" ]]; then
            # Проверяем, что приложение может запуститься (не запускаем реально)
            if otool -L "$executable" >/dev/null 2>&1; then
                add_success "foobar2000 исполняем и библиотеки доступны"
                FUNCTIONALITY_STATUS[executable]="valid"
            else
                add_issue "Functionality" "Проблемы с зависимостями foobar2000" "Warning"
                FUNCTIONALITY_STATUS[executable]="dependency_issues"
            fi
        else
            add_issue "Functionality" "foobar2000 не исполняем"
            FUNCTIONALITY_STATUS[executable]="not_executable"
        fi
    fi
    
    # Проверка кодировщиков
    local encoding_test_passed=true
    
    if command -v flac >/dev/null 2>&1; then
        if flac --help >/dev/null 2>&1; then
            add_success "FLAC кодировщик функционален"
        else
            add_issue "Functionality" "FLAC кодировщик не работает корректно" "Warning"
            encoding_test_passed=false
        fi
    fi
    
    if command -v lame >/dev/null 2>&1; then
        if lame --help >/dev/null 2>&1; then
            add_success "LAME MP3 кодировщик функционален"
        else
            add_issue "Functionality" "LAME кодировщик не работает корректно" "Warning"
            encoding_test_passed=false
        fi
    fi
    
    FUNCTIONALITY_STATUS[encoding]=$([[ $encoding_test_passed == true ]] && echo "functional" || echo "issues")
}

# Проверка производительности
check_performance() {
    if [[ "$DETAILED" != true ]]; then
        return 0
    fi
    
    log_info "Проверка производительности системы"
    
    # Проверка доступной памяти
    local memory_gb
    memory_gb=$(sysctl -n hw.memsize | awk '{print int($1/1024/1024/1024)}')
    
    if [[ $memory_gb -ge 8 ]]; then
        add_success "Достаточно оперативной памяти: ${memory_gb}GB"
    elif [[ $memory_gb -ge 4 ]]; then
        add_issue "Performance" "Ограниченная память: ${memory_gb}GB" "Warning"
    else
        add_issue "Performance" "Недостаточно памяти: ${memory_gb}GB"
    fi
    
    # Проверка процессора
    local cpu_brand
    cpu_brand=$(sysctl -n machdep.cpu.brand_string 2>/dev/null || echo "Unknown")
    
    if [[ "$cpu_brand" == *"Apple"* ]]; then
        add_success "Процессор Apple Silicon: $cpu_brand"
        FUNCTIONALITY_STATUS[cpu_type]="apple_silicon"
    elif [[ "$cpu_brand" == *"Intel"* ]]; then
        add_success "Процессор Intel: $cpu_brand"
        FUNCTIONALITY_STATUS[cpu_type]="intel"
    else
        add_issue "Performance" "Неизвестный тип процессора: $cpu_brand" "Warning"
        FUNCTIONALITY_STATUS[cpu_type]="unknown"
    fi
    
    # Проверка свободного места
    local free_space_gb
    free_space_gb=$(df -H ~ | awk 'NR==2 {print int($4/1000000000)}')
    
    if [[ $free_space_gb -ge 10 ]]; then
        add_success "Достаточно свободного места: ${free_space_gb}GB"
    elif [[ $free_space_gb -ge 5 ]]; then
        add_issue "Performance" "Ограниченное место на диске: ${free_space_gb}GB" "Warning"
    else
        add_issue "Performance" "Мало места на диске: ${free_space_gb}GB"
    fi
}

# Создание детального отчета
create_detailed_report() {
    log_info "Создание детального отчета"
    
    local system_info
    system_info=$(cat << EOF
{
  "hostname": "$(hostname)",
  "username": "$(whoami)",
  "os_version": "$(sw_vers -productVersion)",
  "os_build": "$(sw_vers -buildVersion)",
  "architecture": "$(uname -m)",
  "kernel_version": "$(uname -r)"
}
EOF
    )
    
    local report_data
    report_data=$(cat << EOF
{
  "metadata": {
    "validation_timestamp": "${VALIDATION_RESULTS[timestamp]}",
    "script_version": "$SCRIPT_VERSION",
    "profile": "$PROFILE",
    "foobar_path": "$FOOBAR_PATH"
  },
  "system_info": $system_info,
  "validation_results": {
    "success": ${VALIDATION_RESULTS[success]},
    "foobar_version": "${VALIDATION_RESULTS[foobar_version]:-unknown}",
    "errors_count": ${#ISSUES[@]},
    "warnings_count": ${#WARNINGS[@]}
  },
  "components_status": $(printf '%s\n' "${COMPONENTS_STATUS[@]}" | jq -R 'split(":") | {(.[0]): .[1]}' | jq -s 'add // {}'),
  "config_status": $(printf '%s\n' "${CONFIG_STATUS[@]}" | jq -R 'split(":") | {(.[0]): .[1]}' | jq -s 'add // {}'),
  "functionality_status": $(printf '%s\n' "${FUNCTIONALITY_STATUS[@]}" | jq -R 'split(":") | {(.[0]): .[1]}' | jq -s 'add // {}'),
  "issues": $(printf '%s\n' "${ISSUES[@]}" | jq -R . | jq -s .),
  "warnings": $(printf '%s\n' "${WARNINGS[@]}" | jq -R . | jq -s .)
}
EOF
    )
    
    if command -v jq >/dev/null 2>&1; then
        echo "$report_data" | jq . > "$REPORT_PATH"
    else
        echo "$report_data" > "$REPORT_PATH"
        log_warning "jq не найден, JSON не отформатирован"
    fi
    
    log_success "Отчет сохранен: $REPORT_PATH"
}

# Главная функция валидации
main() {
    echo -e "${CYAN}=== foobar2000 Validator для macOS v$SCRIPT_VERSION ===${NC}"
    echo ""
    
    # Парсинг аргументов
    parse_arguments "$@"
    
    log_info "Запуск валидации установки foobar2000"
    [[ -n "$PROFILE" ]] && log_info "Профиль: $PROFILE"
    
    # Базовые проверки
    echo -e "${CYAN}Проверка установки foobar2000:${NC}"
    check_foobar_installation
    
    echo -e "\n${CYAN}Проверка аудио кодировщиков:${NC}"
    check_audio_encoders
    
    echo -e "\n${CYAN}Проверка утилит:${NC}"
    check_utilities
    
    echo -e "\n${CYAN}Проверка конфигурации:${NC}"
    check_configuration_files
    
    echo -e "\n${CYAN}Проверка интеграции с macOS:${NC}"
    check_macos_integration
    
    echo -e "\n${CYAN}Проверка функциональности:${NC}"
    check_functionality
    
    # Дополнительные проверки для детального режима
    if [[ "$DETAILED" == true ]]; then
        echo -e "\n${CYAN}Проверка производительности:${NC}"
        check_performance
    fi
    
    # Создание отчета
    if [[ -n "$REPORT_PATH" ]]; then
        create_detailed_report
    fi
    
    # Итоговая сводка
    echo -e "\n${CYAN}=== ИТОГИ ВАЛИДАЦИИ ===${NC}"
    
    if [[ "${VALIDATION_RESULTS[success]}" == "true" ]]; then
        echo -e "${GREEN}✓ Валидация пройдена успешно!${NC}"
    else
        echo -e "${RED}✗ Обнаружены критические проблемы!${NC}"
    fi
    
    local error_count=${#ISSUES[@]}
    local warning_count=${#WARNINGS[@]}
    
    echo -e "Ошибки: $error_count"
    echo -e "Предупреждения: $warning_count"
    
    if [[ $error_count -gt 0 ]]; then
        echo -e "\n${RED}Критические проблемы:${NC}"
        for issue in "${ISSUES[@]}"; do
            echo -e "  ${RED}•${NC} $issue"
        done
    fi
    
    if [[ $warning_count -gt 0 ]]; then
        echo -e "\n${YELLOW}Предупреждения:${NC}"
        for warning in "${WARNINGS[@]}"; do
            echo -e "  ${YELLOW}•${NC} $warning"
        done
    fi
    
    [[ -n "$REPORT_PATH" ]] && echo -e "\nДетальный отчет: $REPORT_PATH"
    
    # Возврат кода выхода
    if [[ "${VALIDATION_RESULTS[success]}" == "true" ]]; then
        exit 0
    else
        exit 1
    fi
}

# Обработка сигналов
cleanup() {
    log_info "Получен сигнал завершения, выполняется очистка..."
    exit 1
}

trap cleanup SIGINT SIGTERM

# Запуск основной функции
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi