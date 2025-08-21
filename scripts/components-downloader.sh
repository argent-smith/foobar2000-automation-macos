#!/bin/bash
#
# Скрипт для скачивания и установки компонентов foobar2000 на macOS
# Безопасная загрузка и проверка кодировщиков и утилит
#
# Использование:
#   ./components-downloader.sh [-c components] [-d destination] [-s] [-f]
#
# Параметры:
#   -c, --components    Список компонентов для загрузки (разделенных запятыми)
#   -d, --destination   Путь для сохранения загруженных файлов
#   -s, --skip-verify   Пропустить проверку хешей (не рекомендуется)
#   -f, --force         Перезаписать существующие файлы
#   -h, --help          Показать справку

set -euo pipefail

# Константы
readonly SCRIPT_VERSION="1.0.0"
readonly LOG_PATH="./components-downloader.log"

# Переменные по умолчанию
COMPONENTS=""
DESTINATION_PATH="./downloads"
SKIP_VERIFICATION=false
FORCE=false

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
foobar2000 Components Downloader для macOS v1.0.0

Безопасная загрузка и установка аудио кодировщиков и утилит для macOS.

ИСПОЛЬЗОВАНИЕ:
    ./components-downloader.sh [ОПЦИИ]

ОПЦИИ:
    -c, --components COMPONENTS  Список компонентов (flac,lame,opus,ffmpeg)
    -d, --destination PATH       Путь для сохранения файлов
    -s, --skip-verify           Пропустить проверку хешей
    -f, --force                 Перезаписать существующие файлы
    -h, --help                  Показать эту справку

ДОСТУПНЫЕ КОМПОНЕНТЫ:
    flac        FLAC кодировщик (lossless)
    lame        LAME MP3 кодировщик
    opus        Opus кодировщик
    ffmpeg      FFmpeg мультимедиа фреймворк
    mediainfo   MediaInfo анализатор метаданных
    tag         Tag редактор командной строки
    jq          JSON процессор
    wget        Загрузчик файлов

ПРИМЕРЫ:
    ./components-downloader.sh -c flac,lame,opus
    ./components-downloader.sh --components ffmpeg --force
    ./components-downloader.sh -c all -d ~/Music/Tools

СИСТЕМНЫЕ ТРЕБОВАНИЯ:
    - macOS 11.0 или выше
    - Homebrew для установки компонентов
    - Подключение к интернету

EOF
}

# Парсинг аргументов
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--components)
                COMPONENTS="$2"
                shift 2
                ;;
            -d|--destination)
                DESTINATION_PATH="$2"
                shift 2
                ;;
            -s|--skip-verify)
                SKIP_VERIFICATION=true
                shift
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
}

# Конфигурация компонентов
get_component_info() {
    local component="$1"
    
    case "$component" in
        flac)
            echo "homebrew:flac:FLAC lossless кодировщик"
            ;;
        lame)
            echo "homebrew:lame:LAME MP3 кодировщик"
            ;;
        opus)
            echo "homebrew:opus-tools:Opus аудио кодировщик"
            ;;
        ffmpeg)
            echo "homebrew:ffmpeg:FFmpeg мультимедиа фреймворк"
            ;;
        mediainfo)
            echo "homebrew:mediainfo:MediaInfo анализатор файлов"
            ;;
        tag)
            echo "homebrew:tag:Tag редактор командной строки"
            ;;
        jq)
            echo "homebrew:jq:JSON процессор"
            ;;
        wget)
            echo "homebrew:wget:GNU Wget загрузчик файлов"
            ;;
        x264)
            echo "homebrew:x264:H.264 видео кодировщик"
            ;;
        x265)
            echo "homebrew:x265:H.265 видео кодировщик"
            ;;
        *)
            echo "unknown:$component:Неизвестный компонент"
            ;;
    esac
}

# Проверка доступности Homebrew
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        log_error "Homebrew не установлен. Установите его с https://brew.sh"
        echo "Для установки Homebrew выполните:"
        echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        exit 1
    fi
    
    log_success "Homebrew найден"
    
    # Обновление Homebrew
    log_info "Обновление Homebrew..."
    brew update &> /dev/null || log_warning "Не удалось обновить Homebrew"
}

# Установка компонента через Homebrew
install_homebrew_component() {
    local brew_name="$1"
    local description="$2"
    
    log_info "Проверка компонента: $description"
    
    if brew list "$brew_name" &>/dev/null; then
        local version
        version=$(brew list --versions "$brew_name" | head -n1 | awk '{print $2}')
        log_success "$description уже установлен (версия: $version)"
        
        if [[ "$FORCE" == true ]]; then
            log_info "Принудительная переустановка $description..."
            brew reinstall "$brew_name" || {
                log_error "Ошибка переустановки $brew_name"
                return 1
            }
        fi
        return 0
    fi
    
    log_info "Установка $description через Homebrew..."
    
    # Показать прогресс установки
    if brew install "$brew_name"; then
        local version
        version=$(brew list --versions "$brew_name" | head -n1 | awk '{print $2}' || echo "unknown")
        log_success "$description установлен успешно (версия: $version)"
        return 0
    else
        log_error "Ошибка установки $brew_name"
        return 1
    fi
}

# Проверка установленной версии
check_installed_version() {
    local component="$1"
    local brew_name="$2"
    
    if command -v "$component" &> /dev/null; then
        local version
        case "$component" in
            flac)
                version=$(flac --version 2>&1 | head -n1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)
                ;;
            lame)
                version=$(lame --version 2>&1 | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
                ;;
            ffmpeg)
                version=$(ffmpeg -version 2>&1 | head -n1 | grep -oE '[0-9]+\.[0-9]+' | head -n1)
                ;;
            *)
                version=$($component --version 2>&1 | head -n1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?' | head -n1 || echo "unknown")
                ;;
        esac
        
        echo "$version"
    else
        echo "not_installed"
    fi
}

# Создание символических ссылок для удобства
create_symlinks() {
    log_info "Создание символических ссылок в $DESTINATION_PATH/bin"
    
    local bin_dir="$DESTINATION_PATH/bin"
    mkdir -p "$bin_dir"
    
    # Общие расположения Homebrew
    local homebrew_bin
    if [[ -d "/opt/homebrew/bin" ]]; then
        homebrew_bin="/opt/homebrew/bin"  # Apple Silicon
    elif [[ -d "/usr/local/bin" ]]; then
        homebrew_bin="/usr/local/bin"     # Intel
    else
        log_warning "Не найден каталог Homebrew bin"
        return 1
    fi
    
    local tools=("flac" "lame" "opusenc" "opusdec" "ffmpeg" "mediainfo" "tag" "jq" "wget")
    
    for tool in "${tools[@]}"; do
        local source_path="$homebrew_bin/$tool"
        local link_path="$bin_dir/$tool"
        
        if [[ -x "$source_path" ]]; then
            if [[ "$FORCE" == true ]] || [[ ! -L "$link_path" ]]; then
                ln -sf "$source_path" "$link_path"
                log_success "Создана ссылка: $tool -> $source_path"
            else
                log_info "Ссылка уже существует: $tool"
            fi
        fi
    done
}

# Создание конфигурационного файла
create_config_file() {
    local config_file="$DESTINATION_PATH/components.json"
    
    log_info "Создание файла конфигурации: $config_file"
    
    local timestamp=$(date -u '+%Y-%m-%dT%H:%M:%SZ')
    local hostname=$(hostname)
    local username=$(whoami)
    local os_version=$(sw_vers -productVersion)
    
    cat > "$config_file" << EOF
{
  "metadata": {
    "created": "$timestamp",
    "hostname": "$hostname",
    "username": "$username",
    "os_version": "$os_version",
    "script_version": "$SCRIPT_VERSION"
  },
  "components": {
EOF

    local first=true
    IFS=',' read -ra COMPONENT_LIST <<< "$COMPONENTS"
    
    for component in "${COMPONENT_LIST[@]}"; do
        [[ -z "$component" ]] && continue
        
        local info
        info=$(get_component_info "$component")
        IFS=':' read -ra INFO_PARTS <<< "$info"
        
        local install_type="${INFO_PARTS[0]}"
        local brew_name="${INFO_PARTS[1]}"
        local description="${INFO_PARTS[2]}"
        
        if [[ "$install_type" == "homebrew" ]]; then
            local version
            version=$(check_installed_version "$component" "$brew_name")
            
            if [[ "$first" == true ]]; then
                first=false
            else
                echo "," >> "$config_file"
            fi
            
            cat >> "$config_file" << EOF
    "$component": {
      "name": "$brew_name",
      "description": "$description",
      "install_type": "$install_type",
      "version": "$version",
      "installed": $(if [[ "$version" != "not_installed" ]]; then echo "true"; else echo "false"; fi)
    }
EOF
        fi
    done
    
    cat >> "$config_file" << EOF

  },
  "paths": {
    "homebrew_bin": "$(brew --prefix)/bin",
    "destination": "$DESTINATION_PATH",
    "symlinks": "$DESTINATION_PATH/bin"
  }
}
EOF

    log_success "Файл конфигурации создан: $config_file"
}

# Проверка целостности установки
verify_installation() {
    log_info "Проверка целостности установки"
    
    local failed_components=()
    
    IFS=',' read -ra COMPONENT_LIST <<< "$COMPONENTS"
    
    for component in "${COMPONENT_LIST[@]}"; do
        [[ -z "$component" ]] && continue
        
        local info
        info=$(get_component_info "$component")
        IFS=':' read -ra INFO_PARTS <<< "$info"
        
        local brew_name="${INFO_PARTS[1]}"
        
        if ! brew list "$brew_name" &>/dev/null; then
            failed_components+=("$component")
        fi
    done
    
    if [[ ${#failed_components[@]} -eq 0 ]]; then
        log_success "Все компоненты установлены корректно"
        return 0
    else
        log_error "Проблемы с установкой следующих компонентов:"
        for comp in "${failed_components[@]}"; do
            echo -e "  ${RED}✗${NC} $comp"
        done
        return 1
    fi
}

# Показать список доступных компонентов
show_available_components() {
    echo -e "${CYAN}Доступные компоненты:${NC}"
    echo ""
    
    local components=("flac" "lame" "opus" "ffmpeg" "mediainfo" "tag" "jq" "wget" "x264" "x265")
    
    for component in "${components[@]}"; do
        local info
        info=$(get_component_info "$component")
        IFS=':' read -ra INFO_PARTS <<< "$info"
        
        local brew_name="${INFO_PARTS[1]}"
        local description="${INFO_PARTS[2]}"
        local version
        version=$(check_installed_version "$component" "$brew_name")
        
        if [[ "$version" != "not_installed" ]]; then
            echo -e "  ${GREEN}✓${NC} ${BLUE}$component${NC} - $description ${GREEN}(v$version)${NC}"
        else
            echo -e "  ${RED}✗${NC} ${BLUE}$component${NC} - $description"
        fi
    done
    echo ""
}

# Главная функция загрузки
main() {
    echo -e "${CYAN}=== foobar2000 Components Downloader для macOS v$SCRIPT_VERSION ===${NC}"
    echo ""
    
    # Парсинг аргументов
    parse_arguments "$@"
    
    # Если компоненты не указаны, показать доступные
    if [[ -z "$COMPONENTS" ]]; then
        show_available_components
        echo "Используйте -c для указания компонентов для установки"
        echo "Пример: ./components-downloader.sh -c flac,lame,opus"
        exit 0
    fi
    
    log_info "Запуск загрузки компонентов"
    log_info "Компоненты: $COMPONENTS"
    log_info "Путь назначения: $DESTINATION_PATH"
    
    # Создание каталога назначения
    mkdir -p "$DESTINATION_PATH"
    
    # Проверка Homebrew
    check_homebrew
    
    # Обработка специального значения "all"
    if [[ "$COMPONENTS" == "all" ]]; then
        COMPONENTS="flac,lame,opus,ffmpeg,mediainfo,tag,jq,wget"
        log_info "Установка всех базовых компонентов: $COMPONENTS"
    fi
    
    # Установка компонентов
    local success_count=0
    local total_count=0
    
    IFS=',' read -ra COMPONENT_LIST <<< "$COMPONENTS"
    
    echo -e "${CYAN}Начинаю установку компонентов...${NC}"
    echo ""
    
    for component in "${COMPONENT_LIST[@]}"; do
        [[ -z "$component" ]] && continue
        
        ((total_count++))
        
        local info
        info=$(get_component_info "$component")
        IFS=':' read -ra INFO_PARTS <<< "$info"
        
        local install_type="${INFO_PARTS[0]}"
        local brew_name="${INFO_PARTS[1]}"
        local description="${INFO_PARTS[2]}"
        
        if [[ "$install_type" == "homebrew" ]]; then
            if install_homebrew_component "$brew_name" "$description"; then
                ((success_count++))
            fi
        else
            log_warning "Неизвестный компонент: $component"
        fi
    done
    
    echo ""
    
    # Создание символических ссылок
    create_symlinks
    
    # Создание файла конфигурации
    create_config_file
    
    # Проверка установки
    if verify_installation; then
        echo ""
        echo -e "${GREEN}✓ Установка завершена успешно!${NC}"
        echo -e "Успешно установлено: $success_count из $total_count компонентов"
        echo -e "Путь к инструментам: $DESTINATION_PATH/bin"
        echo -e "Конфигурация: $DESTINATION_PATH/components.json"
        
        # Показать пути для добавления в PATH
        echo ""
        echo -e "${YELLOW}Для добавления инструментов в PATH добавьте в ~/.zshrc или ~/.bash_profile:${NC}"
        echo -e "export PATH=\"$DESTINATION_PATH/bin:\$PATH\""
        
        echo ""
        echo -e "${CYAN}Установленные компоненты:${NC}"
        show_available_components
    else
        echo ""
        echo -e "${RED}✗ Установка завершена с ошибками${NC}"
        echo "Проверьте лог файл: $LOG_PATH"
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