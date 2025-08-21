#!/bin/bash
#
# Основной установочный скрипт для автоматизации настройки foobar2000 на macOS
# Автоматизирует установку компонентов и настройку foobar2000 в соответствии с профессиональными требованиями
#
# Использование:
#   ./install.sh [-p profile] [-m mode] [-b backup_path] [-c config_path] [-f]
#
# Параметры:
#   -p, --profile     Профиль конфигурации: minimal, standard, professional, custom
#   -m, --mode        Режим выполнения: interactive, automatic
#   -b, --backup      Путь для резервных копий (по умолчанию: ./backup)
#   -c, --config      Путь к конфигурационным файлам (по умолчанию: ../configs)
#   -f, --force       Принудительная установка
#   -h, --help        Показать справку

set -euo pipefail

# Константы
readonly FOOBAR_VERSION="2.1"  # macOS версия foobar2000
readonly SCRIPT_VERSION="1.0.0"
readonly LOG_PATH="./foobar2000-automation.log"

# Переменные по умолчанию
PROFILE="standard"
MODE="interactive"
BACKUP_PATH="./backup"
CONFIG_PATH="../configs"
FORCE=false

# Цвета для вывода
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

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
foobar2000 Automation для macOS v1.0.0

Автоматизированная установка и настройка foobar2000 для macOS с профессиональными настройками.

ИСПОЛЬЗОВАНИЕ:
    ./install.sh [ОПЦИИ]

ОПЦИИ:
    -p, --profile PROFILE    Профиль конфигурации (minimal|standard|professional|custom)
    -m, --mode MODE         Режим выполнения (interactive|automatic)
    -b, --backup PATH       Путь для резервных копий (по умолчанию: ./backup)
    -c, --config PATH       Путь к конфигурационным файлам (по умолчанию: ../configs)
    -f, --force            Принудительная установка
    -h, --help             Показать эту справку

ПРОФИЛИ:
    minimal        Базовые компоненты для работы с FLAC+CUE
    standard       Полная настройка с MusicBrainz и TagBox
    professional   Максимальная конфигурация с визуализацией
    custom         Пользовательские настройки (интерактивно)

ПРИМЕРЫ:
    ./install.sh -p standard -m interactive
    ./install.sh -p professional -m automatic -f
    ./install.sh --profile custom --mode interactive

СИСТЕМНЫЕ ТРЕБОВАНИЯ:
    - macOS 11.0 (Big Sur) или выше
    - Homebrew для установки зависимостей
    - foobar2000 для Mac (будет установлен автоматически)
    - 2 GB свободного места
    - Подключение к интернету

EOF
}

# Парсинг аргументов командной строки
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -p|--profile)
                PROFILE="$2"
                shift 2
                ;;
            -m|--mode)
                MODE="$2"
                shift 2
                ;;
            -b|--backup)
                BACKUP_PATH="$2"
                shift 2
                ;;
            -c|--config)
                CONFIG_PATH="$2"
                shift 2
                ;;
            -f|--force)
                FORCE=true
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

    # Валидация режима
    case "$MODE" in
        interactive|automatic) ;;
        *)
            log_error "Недопустимый режим: $MODE"
            echo "Доступные режимы: interactive, automatic"
            exit 1
            ;;
    esac
}

# Проверка системных требований
check_system_requirements() {
    log_info "Проверка системных требований"
    
    # Проверка версии macOS
    local os_version
    os_version=$(sw_vers -productVersion)
    local major_version
    major_version=$(echo "$os_version" | cut -d. -f1)
    
    if [[ "$major_version" -lt 11 ]]; then
        log_error "Требуется macOS 11.0 (Big Sur) или выше. Текущая версия: $os_version"
        exit 1
    fi
    
    log_success "Версия macOS совместима: $os_version"
    
    # Проверка архитектуры
    local arch
    arch=$(uname -m)
    log_info "Архитектура системы: $arch"
    
    # Проверка Homebrew
    if ! command -v brew &> /dev/null; then
        log_warning "Homebrew не установлен. Устанавливаю..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Добавление Homebrew в PATH для Apple Silicon
        if [[ "$arch" == "arm64" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        log_success "Homebrew найден"
    fi
    
    # Проверка свободного места
    local free_space_gb
    free_space_gb=$(df -H . | awk 'NR==2 {print int($4/1000000000)}')
    if [[ "$free_space_gb" -lt 2 ]]; then
        log_warning "Мало свободного места: ${free_space_gb}GB. Рекомендуется минимум 2GB"
    fi
    
    log_success "Системные требования выполнены"
}

# Установка зависимостей через Homebrew
install_dependencies() {
    log_info "Установка зависимостей"
    
    local deps=("jq" "wget" "ffmpeg")
    
    for dep in "${deps[@]}"; do
        if ! brew list "$dep" &>/dev/null; then
            log_info "Установка $dep..."
            brew install "$dep"
        else
            log_success "$dep уже установлен"
        fi
    done
    
    # Установка кодировщиков для аудио
    local audio_deps=("flac" "lame" "opus-tools")
    
    for dep in "${audio_deps[@]}"; do
        if ! brew list "$dep" &>/dev/null; then
            log_info "Установка $dep..."
            brew install "$dep"
        else
            log_success "$dep уже установлен"
        fi
    done
}

# Поиск установки foobar2000
find_foobar_installation() {
    log_info "Поиск установки foobar2000"
    
    local possible_paths=(
        "/Applications/foobar2000.app"
        "$HOME/Applications/foobar2000.app"
    )
    
    for path in "${possible_paths[@]}"; do
        if [[ -d "$path" ]]; then
            local version
            version=$(plutil -extract CFBundleShortVersionString xml1 -o - "$path/Contents/Info.plist" | sed -n 's/.*<string>\(.*\)<\/string>.*/\1/p')
            log_success "Найден foobar2000 версии $version по пути: $path"
            
            echo "$path"
            return 0
        fi
    done
    
    log_warning "foobar2000 не найден. Установка через Homebrew..."
    
    # Попытка установки через Homebrew Cask
    if brew list --cask foobar2000 &>/dev/null; then
        log_success "foobar2000 уже установлен через Homebrew"
    else
        log_info "Устанавливаю foobar2000 через Homebrew Cask..."
        brew install --cask foobar2000
    fi
    
    # Повторная проверка после установки
    for path in "${possible_paths[@]}"; do
        if [[ -d "$path" ]]; then
            log_success "foobar2000 установлен: $path"
            echo "$path"
            return 0
        fi
    done
    
    log_error "Не удалось найти или установить foobar2000"
    exit 1
}

# Создание резервной копии
create_backup() {
    local foobar_path="$1"
    
    log_info "Создание резервной копии конфигурации"
    
    local backup_dir="$BACKUP_PATH/$(date '+%Y%m%d_%H%M%S')"
    mkdir -p "$backup_dir"
    
    local config_dir="$HOME/Library/foobar2000-v2"
    
    if [[ -d "$config_dir" ]]; then
        cp -R "$config_dir" "$backup_dir/foobar2000_config" 2>/dev/null || true
        log_success "Резервная копия создана: $backup_dir"
    else
        log_info "Конфигурационная папка не найдена (первая установка)"
    fi
    
    echo "$backup_dir"
}

# Интерактивное меню выбора профиля
show_profile_menu() {
    echo ""
    echo -e "${CYAN}Выберите профиль конфигурации:${NC}"
    echo -e "1. ${GREEN}minimal${NC}     - Базовые компоненты для работы с FLAC+CUE"
    echo -e "2. ${BLUE}standard${NC}    - Полная настройка с MusicBrainz и TagBox"
    echo -e "3. ${YELLOW}professional${NC} - Максимальная конфигурация с визуализацией"
    echo -e "4. ${CYAN}custom${NC}      - Пользовательские настройки"
    echo ""
    
    while true; do
        read -r -p "Введите номер (1-4): " choice
        case $choice in
            1) echo "minimal"; return ;;
            2) echo "standard"; return ;;
            3) echo "professional"; return ;;
            4) echo "custom"; return ;;
            *) echo -e "${RED}Неверный выбор. Попробуйте снова.${NC}" ;;
        esac
    done
}

# Получение конфигурации профиля
get_profile_configuration() {
    local profile_name="$1"
    
    case "$profile_name" in
        minimal)
            echo "flac,lame"
            ;;
        standard)
            echo "flac,lame,opus,musicbrainz_integration"
            ;;
        professional)
            echo "flac,lame,opus,musicbrainz_integration,visualization,advanced_tagging"
            ;;
        custom)
            echo ""  # Будет определено интерактивно
            ;;
        *)
            log_error "Неизвестный профиль: $profile_name"
            exit 1
            ;;
    esac
}

# Настройка конфигурации foobar2000
configure_foobar() {
    local foobar_path="$1"
    local profile="$2"
    
    log_info "Настройка foobar2000 для профиля: $profile"
    
    local config_dir="$HOME/Library/foobar2000-v2"
    mkdir -p "$config_dir"
    
    # Создание базовой конфигурации
    create_base_config "$config_dir" "$profile"
    
    # Настройка пресетов кодировщиков
    setup_encoder_presets "$config_dir" "$profile"
    
    # Копирование Masstagger скриптов
    copy_masstagger_scripts "$config_dir"
    
    log_success "Конфигурация foobar2000 завершена"
}

# Создание базовой конфигурации
create_base_config() {
    local config_dir="$1"
    local profile="$2"
    
    local config_file="$config_dir/configuration.cfg"
    
    cat > "$config_file" << EOF
[General]
version=$FOOBAR_VERSION
profile=$profile
install_date=$(date '+%Y-%m-%d %H:%M:%S')

[Playback]
output_device=default
buffer_length=1000
gapless_enabled=1
crossfade_enabled=0

[Media Library]
auto_rescan=1
watch_folders=1
monitor_changes=1

[File Associations]
flac=1
mp3=1
m4a=1
opus=1
wav=1
aiff=1

[Advanced]
logging_enabled=1
crash_reports=1
update_check=1
EOF

    log_success "Базовая конфигурация создана"
}

# Настройка пресетов кодировщиков
setup_encoder_presets() {
    local config_dir="$1"
    local profile="$2"
    
    local presets_file="$config_dir/encoder_presets.cfg"
    
    cat > "$presets_file" << 'EOF'
[Encoder Presets]

# FLAC Lossless
[flac_lossless]
name=FLAC Lossless
encoder=/opt/homebrew/bin/flac
extension=flac
parameters=-8 -V -T ARTIST="%artist%" -T TITLE="%title%" -T ALBUM="%album%" -T DATE="%date%" -T GENRE="%genre%" -T TRACKNUMBER="%tracknumber%" -o "$output" -
format=FLAC

# MP3 320 CBR
[mp3_320]
name=MP3 320 kbps CBR
encoder=/opt/homebrew/bin/lame
extension=mp3
parameters=-b 320 -h -m j --cbr --add-id3v2 --tt "%title%" --ta "%artist%" --tl "%album%" --ty "%date%" --tg "%genre%" --tn "%tracknumber%" - "$output"
format=MP3

# MP3 V0 VBR
[mp3_v0]
name=MP3 V0 VBR
encoder=/opt/homebrew/bin/lame
extension=mp3
parameters=-V 0 -h -m j --vbr-new --add-id3v2 --tt "%title%" --ta "%artist%" --tl "%album%" --ty "%date%" --tg "%genre%" --tn "%tracknumber%" - "$output"
format=MP3

# Opus высокое качество
[opus_hq]
name=Opus High Quality
encoder=/opt/homebrew/bin/opusenc
extension=opus
parameters=--bitrate 192 --artist "%artist%" --title "%title%" --album "%album%" --date "%date%" --genre "%genre%" --comment "TRACKNUMBER=%tracknumber%" - "$output"
format=Opus
EOF

    log_success "Пресеты кодировщиков настроены"
}

# Копирование Masstagger скриптов
copy_masstagger_scripts() {
    local config_dir="$1"
    
    local scripts_dir="$config_dir/masstagger_scripts"
    mkdir -p "$scripts_dir"
    
    # Базовые скрипты для macOS
    create_masstagger_scripts "$scripts_dir"
    
    log_success "Masstagger скрипты скопированы"
}

# Создание Masstagger скриптов для macOS
create_masstagger_scripts() {
    local scripts_dir="$1"
    
    # Автоматическая нумерация треков
    cat > "$scripts_dir/AUTOTRACKNUMBER.txt" << 'EOF'
// Автоматическая нумерация треков для macOS
$set(tracknumber,%_tracknumber%)

// Форматирование с ведущими нулями
$if($greater(%totaltracks%,99),
    $set(tracknumber,$padleft(%_tracknumber%,3,'0')),
    $if($greater(%totaltracks%,9),
        $set(tracknumber,$padleft(%_tracknumber%,2,'0')),
        $set(tracknumber,%_tracknumber%)
    )
)
EOF

    # Стандартизация жанров
    cat > "$scripts_dir/GENRE_STANDARDIZE.txt" << 'EOF'
// Стандартизация жанров
$replace(%genre%,electronic,Electronic)
$replace(%genre%,rock,Rock)
$replace(%genre%,pop,Pop)
$replace(%genre%,jazz,Jazz)
$replace(%genre%,classical,Classical)
$replace(%genre%,ambient,Ambient)
$replace(%genre%,techno,Techno)
$replace(%genre%,house,House)
$replace(%genre%,trance,Trance)
EOF

    # Структура файлов для macOS
    cat > "$scripts_dir/FILENAME_STRUCTURE.txt" << 'EOF'
// Структура имен файлов для macOS
// Использует символы, совместимые с macOS файловой системой

$if(%albumartist%,
    $set(_folder_artist,%albumartist%),
    $set(_folder_artist,%artist%)
)

// Очистка недопустимых символов для macOS
$set(_folder_artist,$replace(%_folder_artist%,:, -))
$set(_folder_artist,$replace(%_folder_artist%,/,_))

$if(%date%,
    $set(_folder_year,$left(%date%,4)),
    $set(_folder_year,Unknown)
)

$set(_folder_album,$replace(%album%,:, -))
$set(_folder_album,$replace(%_folder_album%,/,_))

$set(_filename_template,%_folder_artist%/[%_folder_year%] %_folder_album%/%tracknumber%. %title%)
EOF
}

# Проверка установки
validate_installation() {
    local foobar_path="$1"
    local profile="$2"
    
    log_info "Проверка результатов установки"
    
    local config_dir="$HOME/Library/foobar2000-v2"
    local issues=()
    
    # Проверка наличия foobar2000
    if [[ ! -d "$foobar_path" ]]; then
        issues+=("foobar2000 не найден по пути: $foobar_path")
    fi
    
    # Проверка конфигурационных файлов
    if [[ ! -f "$config_dir/configuration.cfg" ]]; then
        issues+=("Основной файл конфигурации не найден")
    fi
    
    if [[ ! -f "$config_dir/encoder_presets.cfg" ]]; then
        issues+=("Файл пресетов кодировщиков не найден")
    fi
    
    # Проверка кодировщиков
    local encoders=("flac" "lame" "opusenc")
    for encoder in "${encoders[@]}"; do
        if ! command -v "$encoder" &> /dev/null; then
            issues+=("Кодировщик не найден: $encoder")
        fi
    done
    
    # Результат проверки
    if [[ ${#issues[@]} -eq 0 ]]; then
        log_success "Установка прошла успешно!"
        return 0
    else
        log_warning "Обнаружены проблемы при валидации:"
        for issue in "${issues[@]}"; do
            echo -e "  ${RED}✗${NC} $issue"
        done
        return 1
    fi
}

# Главная функция установки
main() {
    echo -e "${CYAN}=== foobar2000 Automation для macOS v$SCRIPT_VERSION ===${NC}"
    echo ""
    
    # Парсинг аргументов
    parse_arguments "$@"
    
    log_info "Запуск установки"
    log_info "Профиль: $PROFILE, Режим: $MODE"
    
    # Проверки системы
    check_system_requirements
    install_dependencies
    
    # Поиск или установка foobar2000
    local foobar_path
    foobar_path=$(find_foobar_installation)
    
    # Интерактивный режим
    if [[ "$MODE" == "interactive" ]]; then
        if [[ "$PROFILE" == "standard" ]]; then
            PROFILE=$(show_profile_menu)
        fi
        
        echo ""
        echo -e "${CYAN}Информация об установке:${NC}"
        echo -e "foobar2000: $foobar_path"
        echo -e "Профиль: $PROFILE"
        echo ""
        
        read -r -p "Продолжить установку? [Y/n]: " confirm
        if [[ "$confirm" =~ ^[Nn]$ ]]; then
            log_info "Установка отменена пользователем"
            exit 0
        fi
    fi
    
    # Создание резервной копии
    local backup_dir
    backup_dir=$(create_backup "$foobar_path")
    
    # Настройка конфигурации
    configure_foobar "$foobar_path" "$PROFILE"
    
    # Проверка результатов
    if validate_installation "$foobar_path" "$PROFILE"; then
        echo ""
        echo -e "${GREEN}✓ Установка завершена успешно!${NC}"
        echo -e "${CYAN}Профиль: $PROFILE${NC}"
        echo -e "${CYAN}Резервная копия: $backup_dir${NC}"
        echo ""
        echo -e "Для запуска foobar2000 используйте:"
        echo -e "${YELLOW}open '$foobar_path'${NC}"
        echo ""
    else
        echo ""
        echo -e "${YELLOW}⚠ Установка завершена с предупреждениями${NC}"
        echo -e "Проверьте лог файл: $LOG_PATH"
        if [[ -d "$backup_dir" ]]; then
            echo -e "Для восстановления используйте резервную копию: $backup_dir"
        fi
        exit 1
    fi
}

# Обработка сигналов
cleanup() {
    log_info "Получен сигнал завершения, выполняется очистка..."
    exit 1
}

trap cleanup SIGINT SIGTERM

# Запуск основной функции, если скрипт запущен напрямую
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi