# Кастомизация - foobar2000 Automation для macOS

## Создание собственных профилей

### Определение нового профиля

Отредактируйте файл `scripts/install.sh`, функцию `get_profile_configuration`:

```bash
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
        # Добавить свой профиль
        audiophile)
            echo "flac,lame,opus,ffmpeg,mediainfo,tag"
            ;;
        podcast)
            echo "lame,opus,ffmpeg"
            ;;
        *)
            echo ""
            ;;
    esac
}
```

### Использование пользовательского профиля

```bash
# Установка с новым профилем
./scripts/install.sh --profile audiophile --mode interactive

# Валидация нового профиля  
./scripts/validator.sh --profile audiophile
```

## Добавление новых кодировщиков

### Шаг 1: Обновление components-downloader.sh

Добавьте новый кодировщик в функцию `get_component_info`:

```bash
get_component_info() {
    local component="$1"
    
    case "$component" in
        # ... существующие компоненты ...
        
        wavpack)
            echo "homebrew:wavpack:WavPack lossless кодировщик"
            ;;
        musepack)
            echo "homebrew:musepack:Musepack аудио кодировщик"
            ;;
        *)
            echo "unknown:$component:Неизвестный компонент"
            ;;
    esac
}
```

### Шаг 2: Создание пресета кодировщика

Добавьте в `configs/presets/encoder_presets_macos.cfg`:

```ini
# WavPack Lossless
[wavpack_lossless]
name=WavPack Lossless (macOS)
description=WavPack lossless кодирование с высокой компрессией
encoder_path_arm64=/opt/homebrew/bin/wavpack
encoder_path_intel=/usr/local/bin/wavpack
extension=wv
parameters=-hh -x3 -m "%artist%" -n "%title%" -a "%album%" -y "%date%" -g "%genre%" -t "%tracknumber%=%totaltracks%" -o "%output%" "%input%"
format=WavPack
quality=lossless
compression_level=high
```

### Шаг 3: Обновление validator.sh

Добавьте проверку нового кодировщика:

```bash
check_audio_encoders() {
    local encoders=(
        "flac:FLAC кодировщик"
        "lame:LAME MP3 кодировщик" 
        "opusenc:Opus кодировщик"
        "ffmpeg:FFmpeg мультимедиа фреймворк"
        "wavpack:WavPack кодировщик"  # новый кодировщик
    )
    
    # ... остальная логика проверки ...
}
```

## Создание пользовательских пресетов

### Высококачественный пресет для Apple Silicon

```ini
# Оптимизированный для Apple Silicon M2/M3
[apple_silicon_optimized]
name=Apple Silicon Optimized
description=Оптимизированные настройки для чипов Apple Silicon
encoder_path_arm64=/opt/homebrew/bin/flac
extension=flac
parameters=-8 -V -e -p --totally-silent -T "ARTIST=%artist%" -T "TITLE=%title%" -T "ALBUM=%album%" -o "%output%" -
format=FLAC
quality=lossless
optimization=apple_silicon
multi_threading=auto
```

### Пресет для подкастов

```ini
[podcast_optimized]
name=Podcast Optimized
description=Оптимизировано для речи и подкастов
encoder_path_arm64=/opt/homebrew/bin/opusenc
extension=opus
parameters=--bitrate 64 --framesize 60 --application voip --artist "%artist%" --title "%title%" --album "%album%" - "%output%"
format=Opus
quality=64kbps
application=speech
```

### Пресет для DJ миксов

```ini
[dj_mix_preset]
name=DJ Mix Preset
description=Для длинных DJ сетов и миксов
encoder_path_arm64=/opt/homebrew/bin/lame
extension=mp3
parameters=-b 320 -h -m j --cbr --add-id3v2 --tt "%title%" --ta "%artist%" --tl "%album%" - "%output%"
format=MP3
quality=320kbps_cbr
continuous_audio=true
```

## Настройка интеграции с macOS

### Создание Automator Workflow

1. Откройте Automator
2. Создайте новый Quick Action
3. Добавьте "Run Shell Script":

```bash
#!/bin/bash
# Автоматическая конвертация выбранных файлов

for file in "$@"; do
    if [[ "$file" == *.wav ]] || [[ "$file" == *.aiff ]]; then
        output="${file%.*}.flac"
        /opt/homebrew/bin/flac -8 -V "$file" -o "$output"
        
        # Удалить исходный файл после конвертации (опционально)
        # rm "$file"
    fi
done

# Уведомление о завершении
osascript -e 'display notification "Конвертация завершена" with title "foobar2000 Automation"'
```

### Интеграция с Shortcuts (macOS 12+)

Создайте Shortcut для быстрого кодирования:

```applescript
-- AppleScript для Shortcuts
tell application "Finder"
    set selectedFiles to selection as alias list
end tell

repeat with thisFile in selectedFiles
    set filePath to POSIX path of thisFile
    set fileName to name of (info for thisFile)
    set baseName to text 1 thru -5 of fileName -- убираем .wav
    
    do shell script "/opt/homebrew/bin/flac -5 -V " & quoted form of filePath & " -o ~/Music/Converted/" & quoted form of baseName & ".flac"
end repeat

display notification "Файлы сконвертированы" with title "Audio Conversion"
```

### Создание пользовательских AppleScript

```applescript
-- scripts/applescript/batch_converter.scpt
-- Пакетный конвертер через AppleScript

on run
    set inputFolder to choose folder with prompt "Выберите папку с аудиофайлами:"
    set outputFolder to choose folder with prompt "Выберите папку для сохранения:"
    
    tell application "Finder"
        set audioFiles to every file of inputFolder whose name extension is in {"wav", "aiff", "flac"}
    end tell
    
    repeat with audioFile in audioFiles
        set inputPath to POSIX path of audioFile
        set fileName to name of (info for audioFile)
        set baseName to text 1 thru -5 of fileName
        set outputPath to POSIX path of outputFolder & baseName & ".mp3"
        
        do shell script "/opt/homebrew/bin/lame -V 0 " & quoted form of inputPath & " " & quoted form of outputPath
    end repeat
    
    display notification "Пакетная конвертация завершена" with title "foobar2000 Automation"
end run
```

## Создание пользовательских Masstagger скриптов

### Скрипт для классической музыки

```javascript
// CLASSICAL_MUSIC_MACOS.txt
// Специальный скрипт для классической музыки

// Обработка композитора как основного артиста
$if($and(%composer%,$strchr(%genre%,classical)),
    $set(albumartist,%composer%)
    $set(artist,$if(%performer%,%performer%,%artist%))
)

// Специальное форматирование для классики
$if($strchr(%genre%,classical),
    // Формат: Композитор - Произведение [Исполнитель]
    $set(album,$if(%composer%,%composer% - ,)%album%$if(%performer%, [%performer%],))
)

// Нумерация частей произведения
$if($and(%movement%,%movementtotal%),
    $set(tracknumber,%movement%)
    $set(totaltracks,%movementtotal%)
)

// Структура папок для классики
$set(_classical_structure,%composer%/%album%/%tracknumber%. %title%)
$set(filename_template,%_classical_structure%)
```

### Скрипт для подкастов

```javascript  
// PODCAST_MACOS.txt
// Скрипт для организации подкастов

// Определение подкаста по жанру
$if($or($strchr(%genre%,podcast),$strchr(%genre%,Podcast)),
    // Использовать albumartist как название подкаста
    $set(_podcast_name,%albumartist%)
    
    // Дата как номер эпизода если номер трека отсутствует
    $if($not(%tracknumber%),
        $set(tracknumber,$replace(%date%,-,))
    )
    
    // Специальная структура для подкастов
    $set(_podcast_structure,Podcasts/%_podcast_name%/[%date%] %title%)
    $set(filename_template,%_podcast_structure%)
)
```

### Скрипт для музыки из игр

```javascript
// GAME_MUSIC_MACOS.txt  
// Скрипт для саундтреков из игр

// Обработка игровой музыки
$if($or($strchr(%genre%,game),$strchr(%genre%,Game),$strchr(%genre%,soundtrack)),
    // Определение игры из альбома
    $set(_game_name,$replace(%album%, Soundtrack,))
    $set(_game_name,$replace(%_game_name%, OST,))
    $set(_game_name,$trim(%_game_name%))
    
    // Структура: Game Music/Игра/Трек
    $set(_game_structure,Game Music/%_game_name%/%tracknumber%. %title%)
    $set(filename_template,%_game_structure%)
)
```

## Автоматизация и скрипты обслуживания

### Скрипт автоматического резервного копирования

```bash
#!/bin/bash
# scripts/maintenance/backup_config.sh
# Автоматическое резервное копирование конфигурации

BACKUP_DIR="$HOME/Music/foobar2000-backups"
DATE=$(date '+%Y%m%d_%H%M%S')
BACKUP_NAME="foobar2000_backup_$DATE"

# Создать папку для бэкапов
mkdir -p "$BACKUP_DIR"

# Резервное копирование конфигурации
tar -czf "$BACKUP_DIR/$BACKUP_NAME.tar.gz" \
    -C "$HOME/Library/Application Support" \
    foobar2000

# Резервное копирование пресетов из проекта
cp -R configs/presets "$BACKUP_DIR/${BACKUP_NAME}_presets"

# Очистка старых бэкапов (оставить последние 10)
cd "$BACKUP_DIR"
ls -t *.tar.gz | tail -n +11 | xargs rm -f

echo "Резервная копия создана: $BACKUP_DIR/$BACKUP_NAME.tar.gz"

# Уведомление через Notification Center
osascript -e "display notification \"Резервная копия foobar2000 создана\" with title \"Backup Complete\""
```

### Скрипт мониторинга hot folders

```bash
#!/bin/bash
# scripts/automation/hot_folder_monitor.sh
# Мониторинг hot folders для автоматической обработки

HOT_FOLDER="$HOME/Music/Import"
PROCESSED_FOLDER="$HOME/Music/Processed"
ERROR_FOLDER="$HOME/Music/Import_Errors"

# Создать папки если не существуют
mkdir -p "$HOT_FOLDER" "$PROCESSED_FOLDER" "$ERROR_FOLDER"

# Мониторинг с помощью fswatch (установить: brew install fswatch)
fswatch -o "$HOT_FOLDER" | while read num; do
    echo "Обнаружены изменения в $HOT_FOLDER"
    
    # Найти новые аудиофайлы
    find "$HOT_FOLDER" -type f \( -name "*.wav" -o -name "*.aiff" -o -name "*.flac" \) | while read file; do
        filename=$(basename "$file")
        echo "Обрабатываю: $filename"
        
        # Конвертировать в FLAC если не FLAC
        if [[ "$file" != *.flac ]]; then
            output="$PROCESSED_FOLDER/${filename%.*}.flac"
            
            if /opt/homebrew/bin/flac -8 -V "$file" -o "$output"; then
                echo "Успешно сконвертирован: $filename"
                rm "$file"  # Удалить исходный файл
            else
                echo "Ошибка конвертации: $filename"
                mv "$file" "$ERROR_FOLDER/"
            fi
        else
            # Просто переместить FLAC файл
            mv "$file" "$PROCESSED_FOLDER/"
        fi
    done
done
```

### Скрипт обновления системы

```bash
#!/bin/bash
# scripts/maintenance/update_system.sh
# Автоматическое обновление всех компонентов

echo "🔄 Обновление foobar2000 Automation системы..."

# Обновить Homebrew
echo "📦 Обновление Homebrew..."
brew update
brew upgrade

# Проверить здоровье Homebrew
echo "🏥 Проверка состояния Homebrew..."
brew doctor

# Обновить foobar2000
echo "🎵 Проверка обновлений foobar2000..."
brew upgrade --cask foobar2000

# Очистка кэшей
echo "🧹 Очистка кэшей..."
brew cleanup

# Проверить статус компонентов
echo "✅ Проверка компонентов..."
./scripts/validator.sh --detailed

# Создать резервную копию после обновления
echo "💾 Создание резервной копии..."
./scripts/maintenance/backup_config.sh

echo "✨ Обновление завершено!"

# Уведомление
osascript -e 'display notification "Система foobar2000 обновлена" with title "Update Complete"'
```

## Интеграция с облачными сервисами

### Синхронизация с iCloud Drive

```bash
#!/bin/bash
# scripts/cloud/icloud_sync.sh
# Синхронизация конфигурации через iCloud Drive

ICLOUD_DIR="$HOME/Library/Mobile Documents/com~apple~CloudDocs/foobar2000-config"
CONFIG_DIR="$HOME/Library/Application Support/foobar2000"

# Создать папку в iCloud Drive
mkdir -p "$ICLOUD_DIR"

# Функция синхронизации
sync_to_icloud() {
    echo "📤 Синхронизация в iCloud Drive..."
    
    # Копировать конфигурации
    rsync -av --delete "$CONFIG_DIR/" "$ICLOUD_DIR/"
    
    # Копировать пользовательские пресеты
    cp -R configs/presets "$ICLOUD_DIR/user_presets"
    
    echo "✅ Синхронизация завершена"
}

# Функция восстановления
restore_from_icloud() {
    echo "📥 Восстановление из iCloud Drive..."
    
    if [[ -d "$ICLOUD_DIR" ]]; then
        rsync -av "$ICLOUD_DIR/" "$CONFIG_DIR/"
        echo "✅ Восстановление завершено"
    else
        echo "❌ Данные в iCloud Drive не найдены"
    fi
}

# Выбор действия
case "${1:-sync}" in
    sync)
        sync_to_icloud
        ;;
    restore)
        restore_from_icloud
        ;;
    *)
        echo "Использование: $0 [sync|restore]"
        ;;
esac
```

### Создание дополнительного инструментария

```bash
#!/bin/bash
# scripts/tools/audio_analyzer.sh
# Анализ аудиофайлов с детальными метриками

analyze_file() {
    local file="$1"
    echo "🔍 Анализ файла: $(basename "$file")"
    
    # Базовая информация
    echo "📊 Базовая информация:"
    mediainfo --Inform="Audio;Format: %Format%\nBitrate: %BitRate% bps\nSample Rate: %SamplingRate% Hz\nChannels: %Channels%\nDuration: %Duration/String3%" "$file"
    
    # Анализ динамического диапазона (если доступен)
    if command -v ffmpeg >/dev/null 2>&1; then
        echo -e "\n🎚️ Анализ динамики:"
        ffmpeg -i "$file" -af "astats=metadata=1:reset=1" -f null - 2>&1 | grep -E "(Dynamic_range|Peak_level|RMS_level)"
    fi
    
    # ReplayGain информация
    if command -v metaflac >/dev/null 2>&1 && [[ "$file" == *.flac ]]; then
        echo -e "\n🔊 ReplayGain информация:"
        metaflac --show-tag=REPLAYGAIN_TRACK_GAIN "$file" 2>/dev/null
        metaflac --show-tag=REPLAYGAIN_TRACK_PEAK "$file" 2>/dev/null
    fi
}

# Пакетный анализ
if [[ $# -eq 0 ]]; then
    echo "Выберите папку для анализа:"
    read -r folder
    
    find "$folder" -type f \( -name "*.flac" -o -name "*.mp3" -o -name "*.m4a" \) | while read file; do
        analyze_file "$file"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━"
    done
else
    for file in "$@"; do
        analyze_file "$file"
    done
fi
```

## Создание пользовательских тем

### Темная тема для Terminal

Создайте файл `~/.zshrc_foobar2000_theme`:

```bash
# foobar2000 Automation Theme для Terminal
# Добавить в ~/.zshrc: source ~/.zshrc_foobar2000_theme

# Цвета для логов
export FOOBAR_COLOR_SUCCESS='\033[0;32m'
export FOOBAR_COLOR_WARNING='\033[1;33m'
export FOOBAR_COLOR_ERROR='\033[0;31m'
export FOOBAR_COLOR_INFO='\033[0;34m'
export FOOBAR_COLOR_RESET='\033[0m'

# Алиасы для быстрого доступа
alias fb2k-install='~/foobar2000-automation-macos/scripts/install.sh'
alias fb2k-components='~/foobar2000-automation-macos/scripts/components-downloader.sh'
alias fb2k-config='~/foobar2000-automation-macos/scripts/config-generator.sh'
alias fb2k-validate='~/foobar2000-automation-macos/scripts/validator.sh'

# Функция для быстрого кодирования
fb2k-encode() {
    local format="${1:-flac}"
    local quality="${2:-8}"
    
    case "$format" in
        flac)
            /opt/homebrew/bin/flac -$quality -V "$3" -o "${3%.*}.flac"
            ;;
        mp3)
            /opt/homebrew/bin/lame -V $quality "$3" "${3%.*}.mp3"
            ;;
        opus)
            /opt/homebrew/bin/opusenc --bitrate $quality "$3" "${3%.*}.opus"
            ;;
        *)
            echo "Поддерживаемые форматы: flac, mp3, opus"
            ;;
    esac
}

# Функция статуса системы
fb2k-status() {
    echo -e "${FOOBAR_COLOR_INFO}=== foobar2000 Automation Status ===${FOOBAR_COLOR_RESET}"
    
    # Проверить foobar2000
    if [[ -d "/Applications/foobar2000.app" ]]; then
        echo -e "${FOOBAR_COLOR_SUCCESS}✓ foobar2000 установлен${FOOBAR_COLOR_RESET}"
    else
        echo -e "${FOOBAR_COLOR_ERROR}✗ foobar2000 не найден${FOOBAR_COLOR_RESET}"
    fi
    
    # Проверить кодировщики
    for encoder in flac lame opusenc ffmpeg; do
        if command -v $encoder >/dev/null 2>&1; then
            echo -e "${FOOBAR_COLOR_SUCCESS}✓ $encoder${FOOBAR_COLOR_RESET}"
        else
            echo -e "${FOOBAR_COLOR_WARNING}⚠ $encoder не установлен${FOOBAR_COLOR_RESET}"
        fi
    done
}
```

## Документирование изменений

### Создание пользовательского changelog

```markdown
# CHANGELOG-custom.md
# Пользовательские изменения в foobar2000 Automation для macOS

## [Unreleased]
### Добавлено
- Поддержка WavPack кодировщика
- Профиль для подкастов
- Интеграция с iCloud Drive
- Темная тема для Terminal

### Изменено  
- Оптимизированы пресеты для Apple Silicon M3
- Улучшена обработка классической музыки

### Исправлено
- Проблема с Unicode символами в путях
- Ошибка определения архитектуры
```

---

**Советы по кастомизации**:
- Всегда тестируйте изменения на копии системы
- Документируйте все модификации  
- Используйте систему контроля версий (git)
- Создавайте резервные копии перед изменениями