#!/bin/bash
#
# foobar2000 macOS Integration Setup
# Настройка интеграции с внешними кодировщиками и автоматизация
#

set -euo pipefail

# Константы
readonly FB2K_CONFIG_DIR="$HOME/Library/foobar2000-v2"
readonly HOMEBREW_PREFIX=$(brew --prefix)

# Цвета для вывода
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Создание интеграционного скрипта для конвертации
create_converter_script() {
    local script_file="$FB2K_CONFIG_DIR/convert_with_external.sh"
    
    cat > "$script_file" << 'EOF'
#!/bin/bash
# 
# Скрипт для конвертации аудиофайлов с использованием внешних кодировщиков
# Использование: ./convert_with_external.sh <input_file> <output_format> [quality]
#

set -euo pipefail

HOMEBREW_PREFIX=$(brew --prefix 2>/dev/null || echo "/opt/homebrew")

if [[ $# -lt 2 ]]; then
    echo "Использование: $0 <input_file> <output_format> [quality]"
    echo "Форматы: flac, mp3_v0, mp3_320, opus"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FORMAT="$2"
QUALITY="${3:-default}"

if [[ ! -f "$INPUT_FILE" ]]; then
    echo "Файл не найден: $INPUT_FILE"
    exit 1
fi

# Извлечение базового имени и директории
INPUT_DIR=$(dirname "$INPUT_FILE")
INPUT_NAME=$(basename "$INPUT_FILE")
INPUT_BASE="${INPUT_NAME%.*}"

case "$OUTPUT_FORMAT" in
    flac)
        OUTPUT_FILE="$INPUT_DIR/${INPUT_BASE}.flac"
        "$HOMEBREW_PREFIX/bin/flac" -8 -V -o "$OUTPUT_FILE" "$INPUT_FILE"
        ;;
    mp3_v0)
        OUTPUT_FILE="$INPUT_DIR/${INPUT_BASE}.mp3"
        "$HOMEBREW_PREFIX/bin/lame" -V 0 -h -m j --vbr-new "$INPUT_FILE" "$OUTPUT_FILE"
        ;;
    mp3_320)
        OUTPUT_FILE="$INPUT_DIR/${INPUT_BASE}.mp3"
        "$HOMEBREW_PREFIX/bin/lame" -b 320 -h -m j --cbr "$INPUT_FILE" "$OUTPUT_FILE"
        ;;
    opus)
        OUTPUT_FILE="$INPUT_DIR/${INPUT_BASE}.opus"
        "$HOMEBREW_PREFIX/bin/opusenc" --bitrate 192 "$INPUT_FILE" "$OUTPUT_FILE"
        ;;
    *)
        echo "Неподдерживаемый формат: $OUTPUT_FORMAT"
        exit 1
        ;;
esac

echo "Конвертация завершена: $OUTPUT_FILE"

# Открыть результат в foobar2000
osascript -e "tell application \"foobar2000\" to open POSIX file \"$OUTPUT_FILE\"" 2>/dev/null || true
EOF
    
    chmod +x "$script_file"
    log_success "Создан скрипт конвертации: $script_file"
}

# Создание Service для контекстного меню Finder
create_finder_service() {
    local service_dir="$HOME/Library/Services"
    local service_file="$service_dir/Convert with foobar2000.workflow"
    
    mkdir -p "$service_dir"
    
    # Создание Automator workflow
    cat > "$service_file/Contents/document.wflow" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>actions</key>
    <array>
        <dict>
            <key>action</key>
            <dict>
                <key>AMActionVersion</key>
                <string>2.1.1</string>
                <key>AMApplication</key>
                <array>
                    <string>Automator</string>
                </array>
                <key>AMParameterProperties</key>
                <dict/>
                <key>AMProvides</key>
                <dict>
                    <key>Container</key>
                    <string>List</string>
                    <key>Types</key>
                    <array>
                        <string>com.apple.cocoa.string</string>
                    </array>
                </dict>
                <key>ActionBundlePath</key>
                <string>/System/Library/Automator/Run Shell Script.action</string>
                <key>ActionName</key>
                <string>Run Shell Script</string>
                <key>ActionParameters</key>
                <dict>
                    <key>COMMAND_STRING</key>
                    <string>for f in "$@"; do
    "$HOME/Library/foobar2000-v2/convert_with_external.sh" "$f" flac
done</string>
                    <key>CheckedForUserDefaultShell</key>
                    <true/>
                    <key>inputMethod</key>
                    <integer>1</integer>
                    <key>shell</key>
                    <string>/bin/bash</string>
                    <key>source</key>
                    <string></string>
                </dict>
            </dict>
        </dict>
    </array>
    <key>connectors</key>
    <dict/>
    <key>workflowMetaData</key>
    <dict>
        <key>workflowTypeIdentifier</key>
        <string>com.apple.Automator.servicesMenu</string>
    </dict>
</dict>
</plist>
EOF
    
    log_success "Создан Finder Service для конвертации"
}

# Создание Quick Actions для конвертации
create_quick_actions() {
    local actions_dir="$HOME/Library/Services"
    mkdir -p "$actions_dir"
    
    # Quick Action для FLAC
    local flac_action="$actions_dir/Convert to FLAC.workflow"
    mkdir -p "$flac_action/Contents"
    
    cat > "$flac_action/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>NSServices</key>
    <array>
        <dict>
            <key>NSMenuItem</key>
            <dict>
                <key>default</key>
                <string>Convert to FLAC</string>
            </dict>
            <key>NSMessage</key>
            <string>runWorkflowAsService</string>
            <key>NSSendFileTypes</key>
            <array>
                <string>public.audio</string>
            </array>
            <key>NSRequiredContext</key>
            <array>
                <dict>
                    <key>NSApplicationIdentifier</key>
                    <string>com.apple.finder</string>
                </dict>
            </array>
        </dict>
    </array>
</dict>
</plist>
EOF
    
    log_success "Созданы Quick Actions для конвертации"
}

# Создание AppleScript приложения для интеграции
create_applescript_app() {
    local app_dir="$FB2K_CONFIG_DIR/foobar2000 Converter.app"
    mkdir -p "$app_dir/Contents/MacOS"
    mkdir -p "$app_dir/Contents/Resources"
    
    # Info.plist
    cat > "$app_dir/Contents/Info.plist" << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>foobar2000 Converter</string>
    <key>CFBundleIdentifier</key>
    <string>com.user.foobar2000converter</string>
    <key>CFBundleName</key>
    <string>foobar2000 Converter</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleDocumentTypes</key>
    <array>
        <dict>
            <key>CFBundleTypeExtensions</key>
            <array>
                <string>flac</string>
                <string>mp3</string>
                <string>m4a</string>
                <string>wav</string>
            </array>
            <key>CFBundleTypeName</key>
            <string>Audio File</string>
            <key>CFBundleTypeRole</key>
            <string>Editor</string>
        </dict>
    </array>
</dict>
</plist>
EOF
    
    # Исполняемый скрипт
    cat > "$app_dir/Contents/MacOS/foobar2000 Converter" << 'EOF'
#!/bin/bash
# Wrapper для AppleScript приложения

osascript << 'APPLESCRIPT'
on run argv
    repeat with arg in argv
        set filePath to POSIX path of arg
        do shell script "$HOME/Library/foobar2000-v2/convert_with_external.sh " & quoted form of filePath & " flac"
    end repeat
end run
APPLESCRIPT
EOF
    
    chmod +x "$app_dir/Contents/MacOS/foobar2000 Converter"
    log_success "Создано AppleScript приложение: $app_dir"
}

# Настройка интеграции с системными уведомлениями
setup_notifications() {
    local notifier_script="$FB2K_CONFIG_DIR/notify_conversion.sh"
    
    cat > "$notifier_script" << 'EOF'
#!/bin/bash
# Отправка системных уведомлений о завершении конвертации

MESSAGE="${1:-Конвертация завершена}"
TITLE="${2:-foobar2000}"

osascript -e "display notification \"$MESSAGE\" with title \"$TITLE\""
EOF
    
    chmod +x "$notifier_script"
    log_success "Настроены системные уведомления"
}

# Главная функция
main() {
    echo -e "${BLUE}=== Настройка интеграции foobar2000 с macOS ===${NC}"
    echo
    
    log_info "Создание интеграционных скриптов..."
    create_converter_script
    create_finder_service
    create_quick_actions
    create_applescript_app
    setup_notifications
    
    echo
    log_success "Интеграция настроена успешно!"
    echo
    echo "📋 Доступные возможности:"
    echo "   1. Скрипт конвертации: $FB2K_CONFIG_DIR/convert_with_external.sh"
    echo "   2. Quick Actions в Finder (правый клик на аудиофайлах)"
    echo "   3. AppleScript приложение для drag & drop"
    echo "   4. Системные уведомления о завершении"
    echo
    echo "🔧 Для активации Quick Actions:"
    echo "   System Settings > Extensions > Finder Extensions"
    echo
    echo "💡 Пример использования:"
    echo "   $FB2K_CONFIG_DIR/convert_with_external.sh ~/Music/track.wav flac"
}

main "$@"