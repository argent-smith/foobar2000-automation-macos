#!/bin/bash
#
# Генератор конфигурационных файлов для foobar2000 на macOS
# Создает и применяет конфигурационные файлы в соответствии с выбранным профилем
#
# Использование:
#   ./config-generator.sh [-p profile] [-f foobar_path] [-l library_paths] [-b]
#
# Параметры:
#   -p, --profile         Профиль конфигурации (minimal|standard|professional|custom)
#   -f, --foobar-path     Путь к foobar2000.app
#   -l, --library-paths   Пути к музыкальным библиотекам (разделенные запятыми)
#   -b, --backup          Создать резервную копию существующих конфигураций
#   -h, --help           Показать справку

set -euo pipefail

# Константы
readonly SCRIPT_VERSION="1.0.0"
readonly LOG_PATH="./config-generator.log"

# Переменные по умолчанию
PROFILE="standard"
FOOBAR_PATH=""
LIBRARY_PATHS=""
BACKUP_EXISTING=true

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
foobar2000 Config Generator для macOS v1.0.0

Создание конфигурационных файлов для foobar2000 на macOS с различными профилями.

ИСПОЛЬЗОВАНИЕ:
    ./config-generator.sh [ОПЦИИ]

ОПЦИИ:
    -p, --profile PROFILE       Профиль конфигурации
    -f, --foobar-path PATH      Путь к foobar2000.app
    -l, --library-paths PATHS   Пути к музыкальным библиотекам
    -b, --backup                Создать резервную копию
    -h, --help                  Показать эту справку

ПРОФИЛИ:
    minimal        Базовые настройки для FLAC и MP3
    standard       Полная настройка с расширенными возможностями
    professional   Профессиональная конфигурация с автоматизацией
    custom         Пользовательские настройки (интерактивно)

ПРИМЕРЫ:
    ./config-generator.sh -p standard
    ./config-generator.sh -p professional -f /Applications/foobar2000.app
    ./config-generator.sh -p custom -l ~/Music,~/FLAC -b

ПУТИ КОНФИГУРАЦИИ:
    - Основная конфигурация: ~/Library/Application Support/foobar2000/
    - Пресеты кодировщиков: ~/Library/Application Support/foobar2000/encoder_presets/
    - Скрипты тегирования: ~/Library/Application Support/foobar2000/masstagger_scripts/

EOF
}

# Парсинг аргументов
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--profile)
                PROFILE="$2"
                shift 2
                ;;
            -f|--foobar-path)
                FOOBAR_PATH="$2"
                shift 2
                ;;
            -l|--library-paths)
                LIBRARY_PATHS="$2"
                shift 2
                ;;
            -b|--backup)
                BACKUP_EXISTING=true
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

    # Валидация профиля
    case "$PROFILE" in
        minimal|standard|professional|custom) ;;
        *)
            log_error "Недопустимый профиль: $PROFILE"
            echo "Доступные профили: minimal, standard, professional, custom"
            exit 1
            ;;
    esac
}

# Поиск установки foobar2000
find_foobar_installation() {
    if [[ -n "$FOOBAR_PATH" ]] && [[ -d "$FOOBAR_PATH" ]]; then
        echo "$FOOBAR_PATH"
        return 0
    fi
    
    local possible_paths=(
        "/Applications/foobar2000.app"
        "$HOME/Applications/foobar2000.app"
    )
    
    for path in "${possible_paths[@]}"; do
        if [[ -d "$path" ]]; then
            echo "$path"
            return 0
        fi
    done
    
    log_error "foobar2000 не найден. Укажите путь с помощью -f"
    exit 1
}

# Создание резервной копии
backup_existing_configs() {
    if [[ "$BACKUP_EXISTING" != true ]]; then
        return 0
    fi
    
    local config_dir="$HOME/Library/Application Support/foobar2000"
    
    if [[ ! -d "$config_dir" ]]; then
        log_info "Конфигурационная папка не найдена (первая установка)"
        return 0
    fi
    
    local backup_dir="./backup_$(date '+%Y%m%d_%H%M%S')"
    mkdir -p "$backup_dir"
    
    cp -R "$config_dir" "$backup_dir/foobar2000_config" 2>/dev/null || {
        log_warning "Не удалось создать полную резервную копию"
        return 1
    }
    
    log_success "Резервная копия создана: $backup_dir"
    echo "$backup_dir"
}

# Получение путей к библиотекам интерактивно
get_library_paths_interactive() {
    echo -e "${CYAN}Настройка путей к музыкальным библиотекам:${NC}"
    echo "Введите пути к папкам с музыкой (пустая строка для завершения):"
    
    local paths=()
    local index=1
    
    while true; do
        read -r -p "Путь $index: " path
        
        if [[ -z "$path" ]]; then
            break
        fi
        
        # Расширение тильды
        path="${path/#\~/$HOME}"
        
        if [[ -d "$path" ]]; then
            paths+=("$path")
            echo -e "  ${GREEN}✓${NC} Добавлен: $path"
        else
            echo -e "  ${RED}✗${NC} Путь не найден: $path"
            read -r -p "Добавить несуществующий путь? [y/N]: " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                paths+=("$path")
            fi
        fi
        ((index++))
    done
    
    # Объединение путей запятыми
    local result=""
    if [ ${#paths[@]} -gt 0 ]; then
        result=$(IFS=','; echo "${paths[*]}")
    fi
    echo "$result"
}

# Создание основной конфигурации
create_main_config() {
    local config_dir="$1"
    local profile="$2"
    local library_paths="$3"
    
    log_info "Создание основной конфигурации для профиля: $profile"
    
    # Создание каталога конфигурации если не существует
    mkdir -p "$config_dir"
    
    local config_file="$config_dir/configuration.cfg"
    
    cat > "$config_file" << EOF
# foobar2000 Configuration для macOS
# Профиль: $profile
# Создано: $(date '+%Y-%m-%d %H:%M:%S')

[General]
version=2.1
profile=$profile
platform=macOS
install_date=$(date '+%Y-%m-%d %H:%M:%S')

[Playback]
output_device=default
buffer_length=1000
gapless_enabled=1
crossfade_enabled=0
replaygain_mode=track
replaygain_preamp=0.0

[Media Library]
auto_rescan=1
watch_folders=1
monitor_changes=1
EOF

    # Добавление путей к библиотекам
    if [[ -n "$library_paths" ]]; then
        echo "" >> "$config_file"
        echo "[Library Paths]" >> "$config_file"
        
        local index=0
        IFS=',' read -ra PATH_ARRAY <<< "$library_paths"
        for path in "${PATH_ARRAY[@]}"; do
            echo "path_$index=$path" >> "$config_file"
            ((index++))
        done
    fi
    
    # Профиль-специфичные настройки
    case "$profile" in
        professional)
            cat >> "$config_file" << 'EOF'

[Professional Settings]
metadata_writing=1
preserve_timestamps=1
use_utf8_tags=1
batch_processing=1
integrity_checking=1

[Advanced Tagging]
auto_tag_lookup=1
musicbrainz_enabled=1
discogs_enabled=1
EOF
            ;;
        standard)
            cat >> "$config_file" << 'EOF'

[Standard Settings]
metadata_writing=1
auto_tag_lookup=0
preserve_timestamps=1
EOF
            ;;
    esac
    
    cat >> "$config_file" << 'EOF'

[File Associations]
flac=1
mp3=1
m4a=1
opus=1
wav=1
aiff=1
ape=1

[UI Settings]
show_status_bar=1
show_toolbar=1
playlist_tabs=1

[Advanced]
logging_enabled=1
crash_reports=1
update_check=1
EOF

    log_success "Основная конфигурация создана"
}

# Создание пресетов кодировщиков
create_encoder_presets() {
    local config_dir="$1"
    local profile="$2"
    
    log_info "Создание пресетов кодировщиков"
    
    local presets_dir="$config_dir/encoder_presets"
    mkdir -p "$presets_dir"
    
    # Определение путей к кодировщикам
    local homebrew_prefix
    homebrew_prefix=$(brew --prefix)
    
    # FLAC пресет
    cat > "$presets_dir/flac_lossless.preset" << EOF
[FLAC Lossless]
name=FLAC Lossless
description=Максимальное сжатие FLAC с полными метаданными
encoder=$homebrew_prefix/bin/flac
extension=flac
parameters=-8 -V -T "ARTIST=%artist%" -T "TITLE=%title%" -T "ALBUM=%album%" -T "DATE=%date%" -T "GENRE=%genre%" -T "TRACKNUMBER=%tracknumber%" -T "ALBUMARTIST=%albumartist%" -o "\$output" -
format=FLAC
quality=lossless
EOF

    # MP3 320 пресет
    cat > "$presets_dir/mp3_320.preset" << EOF
[MP3 320 CBR]
name=MP3 320 kbps CBR
description=MP3 320 kbps постоянный битрейт для максимальной совместимости
encoder=$homebrew_prefix/bin/lame
extension=mp3
parameters=-b 320 -h -m j --cbr --add-id3v2 --id3v2-only --tt "%title%" --ta "%artist%" --tl "%album%" --ty "%date%" --tg "%genre%" --tn "%tracknumber%" - "\$output"
format=MP3
quality=320kbps_cbr
EOF

    # MP3 V0 пресет
    cat > "$presets_dir/mp3_v0.preset" << EOF
[MP3 V0 VBR]
name=MP3 V0 VBR
description=MP3 переменный битрейт высокого качества (~245 kbps)
encoder=$homebrew_prefix/bin/lame
extension=mp3
parameters=-V 0 -h -m j --vbr-new --add-id3v2 --id3v2-only --tt "%title%" --ta "%artist%" --tl "%album%" --ty "%date%" --tg "%genre%" --tn "%tracknumber%" - "\$output"
format=MP3
quality=v0_vbr
EOF

    # Opus пресет (если доступен в профиле)
    if [[ "$profile" != "minimal" ]]; then
        cat > "$presets_dir/opus_hq.preset" << EOF
[Opus High Quality]
name=Opus High Quality
description=Opus высокоэффективное кодирование (~192 kbps)
encoder=$homebrew_prefix/bin/opusenc
extension=opus
parameters=--bitrate 192 --artist "%artist%" --title "%title%" --album "%album%" --date "%date%" --genre "%genre%" --comment "TRACKNUMBER=%tracknumber%" - "\$output"
format=Opus
quality=192kbps
EOF
    fi
    
    log_success "Пресеты кодировщиков созданы"
}

# Создание скриптов для тегирования
create_tagging_scripts() {
    local config_dir="$1"
    local profile="$2"
    
    log_info "Создание скриптов для тегирования"
    
    local scripts_dir="$config_dir/masstagger_scripts"
    mkdir -p "$scripts_dir"
    
    # Автоматическая нумерация треков для macOS
    cat > "$scripts_dir/AUTOTRACKNUMBER_MACOS.txt" << 'EOF'
// Автоматическая нумерация треков для macOS
// Учитывает особенности файловой системы HFS+/APFS

$set(tracknumber,%_tracknumber%)

// Определение общего количества треков
$if($not(%totaltracks%),
    $set(totaltracks,%_total_tracks%)
)

// Форматирование номера трека с ведущими нулями
$if($greater(%totaltracks%,99),
    $set(tracknumber,$padleft(%_tracknumber%,3,'0')),
    $if($greater(%totaltracks%,9),
        $set(tracknumber,$padleft(%_tracknumber%,2,'0')),
        $set(tracknumber,%_tracknumber%)
    )
)

// Специальная обработка для мультидисковых релизов
$if(%discnumber%,
    $if($greater(%totaldiscs%,1),
        $set(tracknumber,%discnumber%.$padleft(%_tracknumber%,2,'0'))
    )
)
EOF

    # Стандартизация жанров
    cat > "$scripts_dir/GENRE_STANDARDIZE_MACOS.txt" << 'EOF'
// Стандартизация жанров для macOS
// Использует Unicode-совместимые названия

// Электронная музыка
$replace(%genre%,electronic,Electronic)
$replace(%genre%,Electronic Music,Electronic)
$replace(%genre%,ambient,Ambient)
$replace(%genre%,techno,Techno)
$replace(%genre%,house,House)
$replace(%genre%,trance,Trance)
$replace(%genre%,drum & bass,Drum & Bass)
$replace(%genre%,drum and bass,Drum & Bass)
$replace(%genre%,dubstep,Dubstep)

// Рок и альтернатива
$replace(%genre%,rock,Rock)
$replace(%genre%,alternative,Alternative)
$replace(%genre%,alternative rock,Alternative Rock)
$replace(%genre%,indie,Indie)
$replace(%genre%,punk,Punk)
$replace(%genre%,metal,Metal)

// Поп и мейнстрим
$replace(%genre%,pop,Pop)
$replace(%genre%,Pop Music,Pop)
$replace(%genre%,r&b,R&B)
$replace(%genre%,rnb,R&B)
$replace(%genre%,hip hop,Hip-Hop)
$replace(%genre%,hip-hop,Hip-Hop)
$replace(%genre%,rap,Rap)

// Классическая музыка
$replace(%genre%,classical,Classical)
$replace(%genre%,Classical Music,Classical)
$replace(%genre%,jazz,Jazz)
$replace(%genre%,blues,Blues)
$replace(%genre%,folk,Folk)
$replace(%genre%,country,Country)

// Удаление лишних пробелов и нормализация
$replace(%genre%, / ,/)
$replace(%genre%, /,/)
$replace(%genre%,/ ,/)
$trim(%genre%)
EOF

    # Структура файлов для macOS
    cat > "$scripts_dir/FILENAME_STRUCTURE_MACOS.txt" << 'EOF'
// Структура имен файлов для macOS
// Совместимость с HFS+/APFS и Finder

// Определение исполнителя альбома
$if(%albumartist%,
    $set(_folder_artist,%albumartist%),
    $set(_folder_artist,%artist%)
)

// Обработка различных артистов
$if($or($eql($lower(%_folder_artist%),various artists),$eql($lower(%_folder_artist%),va)),
    $set(_folder_artist,Various Artists)
)

// Очистка от символов, проблематичных в macOS
$set(_folder_artist,$replace(%_folder_artist%,:, -))
$set(_folder_artist,$replace(%_folder_artist%,/,∕))  // Unicode division slash
$set(_folder_artist,$replace(%_folder_artist%,\,∖)) // Unicode reverse solidus
$set(_folder_artist,$replace(%_folder_artist%,?,？)) // Unicode question mark

// Определение года
$if(%date%,
    $if($greater($len(%date%),4),
        $set(_folder_year,$left(%date%,4)),
        $set(_folder_year,%date%)
    ),
    $set(_folder_year,Unknown)
)

// Обработка названия альбома
$if(%album%,
    $set(_folder_album,%album%),
    $set(_folder_album,Unknown Album)
)

// Очистка названия альбома
$set(_folder_album,$replace(%_folder_album%,:, -))
$set(_folder_album,$replace(%_folder_album%,/,∕))
$set(_folder_album,$replace(%_folder_album%,\,∖))
$set(_folder_album,$replace(%_folder_album%,?,？))

// Обработка названия трека
$if(%title%,
    $set(_track_title,%title%),
    $set(_track_title,%filename%)
)

$set(_track_title,$replace(%_track_title%,:, -))
$set(_track_title,$replace(%_track_title%,/,∕))
$set(_track_title,$replace(%_track_title%,\,∖))
$set(_track_title,$replace(%_track_title%,?,？))

// Основная структура файлов
$if($eql(%_folder_artist%,Various Artists),
    $set(_filename_template,Compilations/[%_folder_year%] %_folder_album%/%tracknumber%. %artist% - %_track_title%),
    $set(_filename_template,%_folder_artist%/[%_folder_year%] %_folder_album%/%tracknumber%. %_track_title%)
)

// Проверка длины пути (macOS ограничение)
$if($greater($len(%_filename_template%),255),
    $set(_short_title,$left(%_track_title%,50))
    $set(_filename_template,%_folder_artist%/[%_folder_year%] %_folder_album%/%tracknumber%. %_short_title%)
)

$set(filename_template,%_filename_template%)
EOF

    # Профиль-специфичные скрипты
    if [[ "$profile" == "professional" ]]; then
        # Автоматическая обработка ReplayGain
        cat > "$scripts_dir/REPLAYGAIN_AUTO_MACOS.txt" << 'EOF'
// Автоматическая обработка ReplayGain для macOS
// Использует встроенные возможности macOS для анализа

$if($not(%replaygain_track_gain%),
    $set(_needs_replaygain,1)
    $set(_rg_priority,high)
)

$if($not(%replaygain_album_gain%),
    $set(_needs_album_rg,1)
)

// Группировка для пакетной обработки
$if(%_needs_replaygain%,
    $set(_rg_group,%albumartist% - %album%)
    $set(_rg_format,%_extension%)
)

// Проверка качества звука
$if($greater(%samplerate%,48000),
    $set(_high_quality_source,1)
)

$if($greater(%bitspersample%,16),
    $set(_high_resolution,1)
)
EOF
    fi
    
    log_success "Скрипты для тегирования созданы"
}

# Создание автоматизированных скриптов
create_automation_scripts() {
    local config_dir="$1"
    local profile="$2"
    
    if [[ "$profile" != "professional" ]]; then
        return 0
    fi
    
    log_info "Создание автоматизированных скриптов"
    
    local automation_dir="$config_dir/automation"
    mkdir -p "$automation_dir"
    
    # Скрипт автоматического импорта
    cat > "$automation_dir/auto_import.sh" << 'EOF'
#!/bin/bash
# Автоматический импорт новой музыки в foobar2000

WATCH_DIR="${1:-$HOME/Music/Import}"
CONFIG_DIR="$HOME/Library/Application Support/foobar2000"

if [[ ! -d "$WATCH_DIR" ]]; then
    echo "Папка для импорта не найдена: $WATCH_DIR"
    exit 1
fi

# Поиск новых аудиофайлов
find "$WATCH_DIR" -type f \( -name "*.flac" -o -name "*.mp3" -o -name "*.m4a" -o -name "*.opus" \) -newer "$CONFIG_DIR/last_import" 2>/dev/null | while read -r file; do
    echo "Обнаружен новый файл: $file"
    # Здесь можно добавить логику обработки файла
done

# Обновление метки времени
touch "$CONFIG_DIR/last_import"
EOF
    chmod +x "$automation_dir/auto_import.sh"
    
    # Скрипт проверки качества
    cat > "$automation_dir/quality_check.sh" << 'EOF'
#!/bin/bash
# Проверка качества аудиофайлов

check_file_quality() {
    local file="$1"
    
    if command -v mediainfo >/dev/null 2>&1; then
        local format=$(mediainfo --Inform="Audio;%Format%" "$file")
        local bitrate=$(mediainfo --Inform="Audio;%BitRate%" "$file")
        local samplerate=$(mediainfo --Inform="Audio;%SamplingRate%" "$file")
        
        echo "Файл: $(basename "$file")"
        echo "  Формат: $format"
        echo "  Битрейт: $bitrate"
        echo "  Частота дискретизации: $samplerate"
        
        # Проверки качества
        if [[ "$format" == "FLAC" ]] && [[ "$samplerate" -ge "44100" ]]; then
            echo "  ✓ Высокое качество"
        elif [[ "$format" == "MPEG Audio" ]] && [[ "$bitrate" -ge "320000" ]]; then
            echo "  ✓ Хорошее качество MP3"
        else
            echo "  ⚠ Возможно низкое качество"
        fi
    else
        echo "MediaInfo не установлен. Установите: brew install mediainfo"
    fi
}

export -f check_file_quality

if [[ $# -eq 0 ]]; then
    echo "Использование: $0 <файл_или_папка>"
    exit 1
fi

if [[ -f "$1" ]]; then
    check_file_quality "$1"
elif [[ -d "$1" ]]; then
    find "$1" -type f \( -name "*.flac" -o -name "*.mp3" -o -name "*.m4a" -o -name "*.opus" \) -exec bash -c 'check_file_quality "$0"' {} \;
fi
EOF
    chmod +x "$automation_dir/quality_check.sh"
    
    log_success "Автоматизированные скрипты созданы"
}

# Создание конфигурации интеграции
create_integration_config() {
    local config_dir="$1"
    local profile="$2"
    
    log_info "Создание конфигурации интеграции с macOS"
    
    local integration_file="$config_dir/macos_integration.cfg"
    
    cat > "$integration_file" << EOF
# Интеграция foobar2000 с macOS
# Профиль: $profile

[File Associations]
# Автоматические ассоциации файлов через macOS
auto_register=1
formats=flac,mp3,m4a,opus,wav,aiff,ape

[Notifications]
# Использование системы уведомлений macOS
use_notification_center=1
show_track_changes=1
show_errors=1

[Dock Integration]
# Интеграция с Dock
show_in_dock=1
dock_menu_enabled=1
show_progress_in_dock=1

[Menu Bar]
# Интеграция с Menu Bar
show_menu_bar_icon=0
compact_menu=1

[Spotlight Integration]
# Индексирование для Spotlight
enable_spotlight_metadata=1
export_playlists_metadata=1

[AppleScript Support]
# Поддержка AppleScript для автоматизации
enable_applescript=1
accept_remote_commands=1

[Media Keys]
# Обработка медиа-клавиш
handle_media_keys=1
exclusive_media_keys=0
EOF

    log_success "Конфигурация интеграции создана"
}

# Применение конфигурации
apply_configuration() {
    local config_dir="$1"
    local profile="$2"
    
    log_info "Применение конфигурации профиля: $profile"
    
    # Создание основных каталогов
    mkdir -p "$config_dir"
    mkdir -p "$config_dir/encoder_presets"
    mkdir -p "$config_dir/masstagger_scripts"
    
    if [[ "$profile" == "professional" ]]; then
        mkdir -p "$config_dir/automation"
    fi
    
    # Применение прав доступа macOS
    chmod -R 755 "$config_dir"
    chmod -R 644 "$config_dir"/*.cfg 2>/dev/null || true
    
    log_success "Конфигурация применена успешно"
}

# Главная функция генерации
main() {
    echo -e "${CYAN}=== foobar2000 Config Generator для macOS v$SCRIPT_VERSION ===${NC}"
    echo ""
    
    # Парсинг аргументов
    parse_arguments "$@"
    
    log_info "Запуск генерации конфигурации"
    log_info "Профиль: $PROFILE"
    
    # Поиск foobar2000
    local foobar_path
    foobar_path=$(find_foobar_installation)
    log_success "foobar2000 найден: $foobar_path"
    
    # Получение путей к библиотекам
    if [[ -z "$LIBRARY_PATHS" ]] && [[ "$PROFILE" != "minimal" ]]; then
        LIBRARY_PATHS=$(get_library_paths_interactive)
    fi
    
    # Создание резервной копии
    local backup_dir
    backup_dir=$(backup_existing_configs)
    
    # Определение каталога конфигурации
    local config_dir="$HOME/Library/Application Support/foobar2000"
    
    # Создание конфигураций
    create_main_config "$config_dir" "$PROFILE" "$LIBRARY_PATHS"
    create_encoder_presets "$config_dir" "$PROFILE"
    create_tagging_scripts "$config_dir" "$PROFILE"
    create_integration_config "$config_dir" "$PROFILE"
    
    if [[ "$PROFILE" == "professional" ]]; then
        create_automation_scripts "$config_dir" "$PROFILE"
    fi
    
    # Применение конфигурации
    apply_configuration "$config_dir" "$PROFILE"
    
    # Итоговый отчет
    echo ""
    echo -e "${GREEN}✓ Генерация конфигурации завершена успешно!${NC}"
    echo -e "Профиль: ${CYAN}$PROFILE${NC}"
    echo -e "Конфигурация сохранена в: ${YELLOW}$config_dir${NC}"
    
    if [[ -n "$LIBRARY_PATHS" ]]; then
        echo -e "Музыкальные библиотеки: ${CYAN}$LIBRARY_PATHS${NC}"
    fi
    
    if [[ -n "$backup_dir" ]]; then
        echo -e "Резервная копия: ${YELLOW}$backup_dir${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}Созданные файлы:${NC}"
    echo "  • Основная конфигурация: configuration.cfg"
    echo "  • Пресеты кодировщиков: encoder_presets/"
    echo "  • Скрипты тегирования: masstagger_scripts/"
    echo "  • Интеграция с macOS: macos_integration.cfg"
    
    if [[ "$PROFILE" == "professional" ]]; then
        echo "  • Автоматизация: automation/"
    fi
    
    echo ""
    echo -e "${YELLOW}Для запуска foobar2000 с новой конфигурацией:${NC}"
    echo "open '$foobar_path'"
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