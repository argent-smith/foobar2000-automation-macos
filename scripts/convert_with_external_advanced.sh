#!/bin/bash
# 
# Продвинутый скрипт для конвертации аудиофайлов с использованием внешних кодировщиков
# Использование: ./convert_with_external_advanced.sh <input_file> <output_format> [mode] [suffix]
#
# Режимы:
#   suffix - добавить суффикс к имени файла (по умолчанию)
#   replace - заменить исходный файл через временные файлы
#   interactive - интерактивный режим выбора
#

set -euo pipefail

# Конфигурация
HOMEBREW_PREFIX=$(brew --prefix 2>/dev/null || echo "/opt/homebrew")
LOG_DIR="$HOME/Library/foobar2000-v2/logs"
LOG_FILE="$LOG_DIR/conversion.log"
TEMP_DIR="$HOME/Library/foobar2000-v2/temp"

# Создание необходимых директорий
mkdir -p "$LOG_DIR" "$TEMP_DIR"

# Функция логгирования
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

log_info() { log "INFO" "$@"; }
log_error() { log "ERROR" "$@"; }
log_warning() { log "WARNING" "$@"; }
log_success() { log "SUCCESS" "$@"; }

# Функция очистки временных файлов
cleanup_temp_files() {
    local temp_pattern="$1"
    log_info "Очистка временных файлов: $temp_pattern"
    
    if [[ -n "$temp_pattern" && "$temp_pattern" != "/" ]]; then
        if ls "$temp_pattern"* >/dev/null 2>&1; then
            rm -f "$temp_pattern"*
            log_success "Временные файлы удалены: $temp_pattern*"
        fi
    fi
}

# Обработчик сигналов для очистки
cleanup_on_exit() {
    local exit_code=$?
    if [[ -n "${TEMP_FILE_PREFIX:-}" ]]; then
        cleanup_temp_files "$TEMP_FILE_PREFIX"
    fi
    
    if [[ $exit_code -ne 0 ]]; then
        log_error "Скрипт завершен с ошибкой (код: $exit_code)"
    else
        log_success "Скрипт завершен успешно"
    fi
    
    exit $exit_code
}

trap cleanup_on_exit EXIT INT TERM

# Проверка аргументов
if [[ $# -lt 2 ]]; then
    echo "Использование: $0 <input_file> <output_format> [mode] [suffix] [--batch]"
    echo
    echo "Форматы: flac, flac_commercial, mp3_v0, mp3_320, mp3_commercial, opus"
    echo
    echo "Режимы:"
    echo "  suffix - добавить суффикс к имени файла (по умолчанию)"
    echo "  replace - заменить исходный файл через временные файлы"  
    echo "  interactive - интерактивный режим выбора"
    echo
    echo "Флаги:"
    echo "  --batch - неинтерактивный режим (автоматические ответы)"
    echo
    echo "Примеры:"
    echo "  $0 file.wav mp3_320 suffix"
    echo "  $0 file.mp3 mp3_commercial replace --batch"
    echo "  $0 file.flac opus interactive"
    exit 1
fi

# Парсинг аргументов
INPUT_FILE="$1"
OUTPUT_FORMAT="$2"
MODE="${3:-suffix}"
USER_SUFFIX="${4:-}"

# Проверка наличия флага --batch
BATCH_MODE=false
for arg in "$@"; do
    if [[ "$arg" == "--batch" ]]; then
        BATCH_MODE=true
        break
    fi
done

log_info "=== Начало конвертации ==="
log_info "Исходный файл: $INPUT_FILE"
log_info "Формат вывода: $OUTPUT_FORMAT"
log_info "Режим: $MODE"
log_info "Batch режим: $BATCH_MODE"

if [[ ! -f "$INPUT_FILE" ]]; then
    log_error "Файл не найден: $INPUT_FILE"
    exit 1
fi

# Извлечение информации о файле
INPUT_DIR=$(dirname "$INPUT_FILE")
INPUT_NAME=$(basename "$INPUT_FILE")
INPUT_BASE="${INPUT_NAME%.*}"
INPUT_EXT="${INPUT_NAME##*.}"

log_info "Директория: $INPUT_DIR"
log_info "Базовое имя: $INPUT_BASE"
log_info "Расширение: $INPUT_EXT"

# Определение расширения выходного файла
get_output_extension() {
    case "$1" in
        flac*) echo "flac" ;;
        mp3_*) echo "mp3" ;;
        opus) echo "opus" ;;
        *) echo "unknown" ;;
    esac
}

OUTPUT_EXT=$(get_output_extension "$OUTPUT_FORMAT")
log_info "Выходное расширение: $OUTPUT_EXT"

# Интерактивный режим
if [[ "$MODE" == "interactive" ]]; then
    echo
    echo "Выберите режим конвертации:"
    echo "1) Создать новый файл с суффиксом"
    echo "2) Заменить исходный файл (через временные файлы)"
    echo
    read -r -p "Режим (1-2): " mode_choice
    
    case "$mode_choice" in
        1) MODE="suffix" ;;
        2) MODE="replace" ;;
        *) log_error "Неверный выбор режима"; exit 1 ;;
    esac
    
    log_info "Выбран режим: $MODE"
fi

# Определение выходного файла
determine_output_file() {
    local format="$1"
    local mode="$2"
    local user_suffix="$3"
    
    case "$mode" in
        suffix)
            if [[ -n "$user_suffix" ]]; then
                suffix="$user_suffix"
            elif [[ "$mode" == "interactive" ]]; then
                read -r -p "Введите суффикс для имени файла (или Enter для автоматического): " suffix
                if [[ -z "$suffix" ]]; then
                    suffix="_${format}"
                fi
            else
                # Автоматический суффикс на основе формата
                case "$format" in
                    flac) suffix="_flac" ;;
                    flac_commercial) suffix="_flac_commercial" ;;
                    mp3_v0) suffix="_v0" ;;
                    mp3_320) suffix="_320" ;;
                    mp3_commercial) suffix="_commercial" ;;
                    opus) suffix="_opus" ;;
                    *) suffix="_${format}" ;;
                esac
            fi
            
            OUTPUT_FILE="$INPUT_DIR/${INPUT_BASE}${suffix}.${OUTPUT_EXT}"
            ;;
        replace)
            # Создание временного файла
            TEMP_FILE_PREFIX="$TEMP_DIR/${INPUT_BASE}_$(date +%s)"
            OUTPUT_FILE="${TEMP_FILE_PREFIX}_converted.${OUTPUT_EXT}"
            ;;
        *)
            log_error "Неизвестный режим: $mode"
            exit 1
            ;;
    esac
    
    log_info "Выходной файл: $OUTPUT_FILE"
}

determine_output_file "$OUTPUT_FORMAT" "$MODE" "$USER_SUFFIX"

# Проверка на перезапись
if [[ "$MODE" == "suffix" && -f "$OUTPUT_FILE" ]]; then
    log_warning "Файл уже существует: $OUTPUT_FILE"
    read -r -p "Перезаписать? (y/N): " overwrite
    if [[ ! "$overwrite" =~ ^[Yy]$ ]]; then
        log_info "Конвертация отменена пользователем"
        exit 0
    fi
fi

# Функция конвертации
perform_conversion() {
    local input="$1"
    local output="$2"
    local format="$3"
    
    log_info "Начало конвертации: $format"
    log_info "Из: $input"
    log_info "В: $output"
    
    case "$format" in
        flac)
            log_info "Команда: flac -8 -V --preserve-modtime --keep-foreign-metadata -o \"$output\" \"$input\""
            if "$HOMEBREW_PREFIX/bin/flac" -8 -V --preserve-modtime --keep-foreign-metadata -o "$output" "$input" 2>&1 | tee -a "$LOG_FILE"; then
                log_success "FLAC конвертация завершена"
                return 0
            else
                log_error "Ошибка FLAC конвертации"
                return 1
            fi
            ;;
        flac_commercial)
            log_info "Команда: flac -4 -V --force --sample-rate=44100 --bps=24 --preserve-modtime --keep-foreign-metadata -o \"$output\" \"$input\""
            if "$HOMEBREW_PREFIX/bin/flac" -4 -V --force --sample-rate=44100 --bps=24 --preserve-modtime --keep-foreign-metadata -o "$output" "$input" 2>&1 | tee -a "$LOG_FILE"; then
                log_success "FLAC Commercial конвертация завершена"
                return 0
            else
                log_error "Ошибка FLAC Commercial конвертации"
                return 1
            fi
            ;;
        mp3_v0)
            log_info "Команда: lame -V 0 -h -m j --vbr-new --add-id3v2 --id3v2-only --preserve-modtime \"$input\" \"$output\""
            if "$HOMEBREW_PREFIX/bin/lame" -V 0 -h -m j --vbr-new --add-id3v2 --id3v2-only --preserve-modtime "$input" "$output" 2>&1 | tee -a "$LOG_FILE"; then
                log_success "MP3 V0 конвертация завершена"
                return 0
            else
                log_error "Ошибка MP3 V0 конвертации"
                return 1
            fi
            ;;
        mp3_320)
            log_info "Команда: lame -b 320 -h -m j --cbr --add-id3v2 --id3v2-only --preserve-modtime \"$input\" \"$output\""
            if "$HOMEBREW_PREFIX/bin/lame" -b 320 -h -m j --cbr --add-id3v2 --id3v2-only --preserve-modtime "$input" "$output" 2>&1 | tee -a "$LOG_FILE"; then
                log_success "MP3 320 конвертация завершена"
                return 0
            else
                log_error "Ошибка MP3 320 конвертации"
                return 1
            fi
            ;;
        mp3_commercial)
            log_info "Команда: lame -b 192 -h -m j --cbr --resample 44.1 --bitwidth 24 --add-id3v2 --id3v2-only --preserve-modtime \"$input\" \"$output\""
            if "$HOMEBREW_PREFIX/bin/lame" -b 192 -h -m j --cbr --resample 44.1 --bitwidth 24 --add-id3v2 --id3v2-only --preserve-modtime "$input" "$output" 2>&1 | tee -a "$LOG_FILE"; then
                log_success "MP3 Commercial конвертация завершена"
                return 0
            else
                log_error "Ошибка MP3 Commercial конвертации"
                return 1
            fi
            ;;
        opus)
            log_info "Команда: opusenc --bitrate 192 --preserve-modtime \"$input\" \"$output\""
            if "$HOMEBREW_PREFIX/bin/opusenc" --bitrate 192 --preserve-modtime "$input" "$output" 2>&1 | tee -a "$LOG_FILE"; then
                log_success "Opus конвертация завершена"
                return 0
            else
                log_error "Ошибка Opus конвертации"
                return 1
            fi
            ;;
        *)
            log_error "Неподдерживаемый формат: $format"
            return 1
            ;;
    esac
}

# Выполнение конвертации
if perform_conversion "$INPUT_FILE" "$OUTPUT_FILE" "$OUTPUT_FORMAT"; then
    
    # Обработка режима замещения
    if [[ "$MODE" == "replace" ]]; then
        log_info "Режим замещения: создание резервной копии"
        
        # Создание резервной копии
        BACKUP_FILE="${INPUT_FILE}.backup_$(date +%s)"
        if cp "$INPUT_FILE" "$BACKUP_FILE"; then
            log_success "Резервная копия создана: $BACKUP_FILE"
            
            # Замещение исходного файла
            if mv "$OUTPUT_FILE" "$INPUT_FILE"; then
                log_success "Исходный файл заменен"
                
                # Удаление резервной копии после успешной замены
                # В неинтерактивном режиме (массовая конвертация) автоматически удаляем резервные копии
                if [[ "$BATCH_MODE" == "true" || ! -t 0 ]]; then
                    # Неинтерактивный режим или batch режим - автоматически удаляем резервные копии
                    rm -f "$BACKUP_FILE"
                    log_success "Резервная копия удалена автоматически: $BACKUP_FILE"
                else
                    # Интерактивный режим
                    read -r -p "Удалить резервную копию? (Y/n): " delete_backup
                    if [[ ! "$delete_backup" =~ ^[Nn]$ ]]; then
                        rm -f "$BACKUP_FILE"
                        log_success "Резервная копия удалена: $BACKUP_FILE"
                    else
                        log_info "Резервная копия сохранена: $BACKUP_FILE"
                    fi
                fi
                
                FINAL_OUTPUT="$INPUT_FILE"
            else
                log_error "Ошибка замещения файла"
                # Восстановление из резервной копии
                mv "$BACKUP_FILE" "$INPUT_FILE"
                log_info "Исходный файл восстановлен из резервной копии"
                exit 1
            fi
        else
            log_error "Ошибка создания резервной копии"
            exit 1
        fi
    else
        FINAL_OUTPUT="$OUTPUT_FILE"
    fi
    
    # Получение информации о результирующем файле
    if [[ -f "$FINAL_OUTPUT" ]]; then
        file_size=$(ls -lh "$FINAL_OUTPUT" | awk '{print $5}')
        log_success "Конвертация завершена успешно!"
        log_success "Результирующий файл: $FINAL_OUTPUT"
        log_success "Размер файла: $file_size"
        
        # Анализ качества если доступен mediainfo
        if command -v mediainfo >/dev/null 2>&1; then
            log_info "Анализ результирующего файла:"
            mediainfo --Inform="Audio;Формат: %Format%\nБитрейт: %BitRate/String%\nЧастота: %SamplingRate/String% Hz\nКаналов: %Channel(s)%" "$FINAL_OUTPUT" | tee -a "$LOG_FILE"
        fi
        
        echo
        echo "Конвертация завершена: $FINAL_OUTPUT"
        
        # Опциональное добавление в foobar2000
        if command -v osascript >/dev/null 2>&1; then
            if [[ "$BATCH_MODE" == "true" || ! -t 0 ]]; then
                # В неинтерактивном или batch режиме не добавляем автоматически
                log_info "Batch/неинтерактивный режим: файл не добавлен в foobar2000"
            else
                # Интерактивный режим
                read -r -p "Добавить результат в foobar2000? (Y/n): " add_to_fb2k
                if [[ ! "$add_to_fb2k" =~ ^[Nn]$ ]]; then
                    if osascript -e "tell application \"foobar2000\" to open POSIX file \"$FINAL_OUTPUT\"" 2>/dev/null; then
                        log_success "Файл добавлен в foobar2000"
                    else
                        log_warning "Не удалось добавить файл в foobar2000"
                    fi
                fi
            fi
        fi
        
    else
        log_error "Результирующий файл не найден: $FINAL_OUTPUT"
        exit 1
    fi
    
else
    log_error "Конвертация завершилась с ошибкой"
    exit 1
fi

log_info "=== Конец конвертации ==="