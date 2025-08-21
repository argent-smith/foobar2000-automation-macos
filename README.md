# foobar2000 Automation для macOS

Система автоматизации для настройки foobar2000 на macOS с профессиональными требованиями для управления музыкальной библиотекой и создания цифровых релизов.

## Возможности

- **Автоматическая установка** через Homebrew всех необходимых кодировщиков
- **Профессиональная настройка** foobar2000 с оптимизацией для macOS
- **Интеграция с macOS** - Spotlight, QuickLook, медиа-клавиши, уведомления
- **Поддержка Apple Silicon** - нативная оптимизация для M1/M2/M3 чипов
- **Гибкость профилей** - от минимальной до профессиональной конфигурации
- **Массовая конвертация** - стабильная обработка больших коллекций файлов
- **Fish Shell интеграция** - интерактивные команды и меню

## ⚠️ Последние исправления (2025-08-21)

**Исправлены критические баги массовой конвертации:**
- ✅ Стабильная работа интерактивного меню массовой конвертации  
- ✅ Полный вывод прогресса LAME/FLAC/Opus при конвертации
- ✅ Batch режим без интерактивных запросов
- ✅ Обработка ошибок с graceful recovery

Подробности в [`BUGFIXES.md`](./BUGFIXES.md)

## Системные требования

- **macOS 11.0 Big Sur** или выше (рекомендуется macOS 13.0+)
- **Homebrew** для установки кодировщиков
- **2 GB** свободного места на диске
- **Apple Silicon** (M1/M2/M3) или **Intel** процессор
- Подключение к интернету для загрузки компонентов

## Быстрый старт

### Установка

1. **Установите Homebrew** (если еще не установлен):
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. **Клонируйте проект**:
```bash
git clone https://github.com/your-repo/foobar2000-automation-macos.git
cd foobar2000-automation-macos
```

3. **Запустите автоматическую установку**:
```bash
# Интерактивная установка (рекомендуется)
./scripts/install.sh --mode interactive

# Быстрая установка со стандартным профилем
./scripts/install.sh --profile standard --mode automatic
```

### Профили конфигурации

- **minimal** - Базовые кодировщики (FLAC, MP3)
- **standard** - Полный набор с Opus и утилитами анализа
- **professional** - Максимальная конфигурация с FFmpeg и автоматизацией
- **custom** - Пользовательские настройки

## Архитектура и совместимость

### Apple Silicon (M1/M2/M3)
- ✅ **Нативная поддержка ARM64**
- ✅ **Превосходная производительность** кодирования
- ✅ **Энергоэффективность**
- ✅ **Homebrew пути**: `/opt/homebrew/bin/`

### Intel Mac
- ✅ **Полная совместимость**
- ✅ **Rosetta 2** при необходимости
- ✅ **Homebrew пути**: `/usr/local/bin/`

## Структура проекта

```
foobar2000-automation-macos/
├── scripts/                    # Bash скрипты
│   ├── install.sh             # Основной установочный скрипт
│   ├── components-downloader.sh # Установка кодировщиков через Homebrew
│   ├── config-generator.sh    # Генерация конфигураций
│   └── validator.sh           # Проверка установки
├── configs/                   # Конфигурационные файлы
│   ├── presets/              # Пресеты кодировщиков для macOS
│   ├── scripts/              # Masstagger скрипты (адаптированы для macOS)
│   └── templates/            # Шаблоны интеграции с macOS
├── resources/                # Ресурсные файлы
│   ├── macos_components.json # Информация о компонентах Homebrew
│   └── compatibility_macos.json # Матрица совместимости macOS
└── docs/                     # Документация
    ├── troubleshooting_macos.md
    └── customization_macos.md
```

## Поддерживаемые форматы и кодировщики

### Lossless форматы
- **FLAC** - через `flac` (Homebrew)
  - Компрессия: уровни 0-8
  - Метаданные: Vorbis Comments, CUE поддержка
  - Unicode: полная поддержка

### Lossy форматы
- **MP3** - через `lame` (Homebrew)
  - Режимы: CBR, VBR (V0-V9), ABR
  - Теги: ID3v1, ID3v2.3, ID3v2.4
  - Качество: до 320 kbps

- **Opus** - через `opus-tools` (Homebrew)
  - Битрейт: 6-510 kbps
  - Режимы: VBR, CVBR, CBR
  - Оптимизация: речь, музыка, низкая задержка

- **AAC/ALAC** - через `ffmpeg` (Homebrew)
  - AAC: до 256 kbps
  - ALAC: lossless
  - Контейнер: M4A

## Использование скриптов

### Установка компонентов

```bash
# Установить все базовые кодировщики
./scripts/components-downloader.sh -c flac,lame,opus

# Установить все компоненты для профессионального использования
./scripts/components-downloader.sh -c all

# Показать доступные компоненты
./scripts/components-downloader.sh
```

### Генерация конфигурации

```bash
# Создать стандартную конфигурацию
./scripts/config-generator.sh --profile standard

# Профессиональная конфигурация с путями к библиотекам
./scripts/config-generator.sh --profile professional --library-paths ~/Music,~/FLAC

# Создать резервную копию перед изменениями
./scripts/config-generator.sh --profile standard --backup
```

### Проверка установки

```bash
# Базовая проверка
./scripts/validator.sh

# Детальная проверка с отчетом
./scripts/validator.sh --detailed --report validation-report.json

# Проверка конкретного профиля
./scripts/validator.sh --profile professional
```

## Интеграция с macOS

### Системные возможности
- **Файловые ассоциации** - автоматическая регистрация аудиоформатов
- **Spotlight** - индексирование метаданных для поиска
- **QuickLook** - предпросмотр аудиофайлов в Finder
- **Notification Center** - уведомления о смене треков
- **Медиа-клавиши** - управление через клавиатуру
- **Dock интеграция** - индикация прогресса и меню

### Пути конфигурации
```
~/Library/Application Support/foobar2000/     # Основная конфигурация
~/Library/Application Support/foobar2000/encoder_presets/   # Пресеты кодировщиков
~/Library/Application Support/foobar2000/masstagger_scripts/ # Скрипты тегирования
~/Library/Logs/foobar2000/                    # Логи приложения
```

## Masstagger скрипты для macOS

Специально адаптированы для особенностей macOS:

- **Unicode совместимость** - правильная обработка специальных символов
- **Файловая система** - совместимость с HFS+/APFS
- **Finder интеграция** - оптимизированные структуры папок

### Основные скрипты:
- `AUTOTRACKNUMBER_MACOS` - нумерация треков
- `GENRE_STANDARDIZE_MACOS` - стандартизация жанров
- `FILENAME_STRUCTURE_MACOS` - структура файлов и папок
- `REPLAYGAIN_AUTO_MACOS` - автоматический ReplayGain

## Пресеты кодировщиков

### Рекомендуемые настройки качества:

**Audiophile (максимальное качество):**
- FLAC: `-8 -V` (максимальное сжатие)
- MP3: `-V 0` (VBR ~245 kbps)
- Opus: `--bitrate 256`

**Standard (баланс):**
- FLAC: `-5 -V` (быстрое сжатие)
- MP3: `-V 2` (VBR ~190 kbps)
- Opus: `--bitrate 128`

**Portable (мобильные устройства):**
- FLAC: `-3` (быстрое)
- MP3: `-V 4` (VBR ~165 kbps)
- Opus: `--bitrate 96`

## Производительность

### Бенчмарки кодирования (примерные):

**Apple Silicon M2 Max:**
- FLAC level 8: ~15x realtime
- MP3 V0: ~25x realtime
- Opus 192k: ~30x realtime

**Intel Core i9:**
- FLAC level 8: ~8x realtime
- MP3 V0: ~15x realtime
- Opus 192k: ~18x realtime

## Устранение проблем

### Частые проблемы:

**Homebrew не найден:**
```bash
# Для Apple Silicon
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc

# Для Intel
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc
```

**Отказ в доступе к папкам:**
- Предоставьте права доступа в System Preferences → Security & Privacy → Privacy → Files and Folders

**Кодировщики не найдены:**
```bash
# Проверить установку
brew list flac lame opus-tools ffmpeg

# Переустановить если необходимо
brew reinstall flac lame opus-tools
```

## Автоматизация

### Создание горячих папок:
```bash
# Автоматический импорт
mkdir -p ~/Music/Import
# Файлы в этой папке будут автоматически добавлены в библиотеку

# Автоматическая конвертация
mkdir -p ~/Music/Convert
# Файлы будут сконвертированы согласно заданным пресетам
```

### Планировщик задач (cron):
```bash
# Автоматическое обновление компонентов каждое воскресенье в 2:00
0 2 * * 0 /opt/homebrew/bin/brew update && /opt/homebrew/bin/brew upgrade
```

## Обновление системы

```bash
# Обновить все Homebrew компоненты
brew update && brew upgrade

# Обновить foobar2000
brew upgrade --cask foobar2000

# Проверить устаревшие пакеты
brew outdated

# Очистить кэш
brew cleanup
```

## Резервное копирование

```bash
# Резервная копия конфигурации
cp -R ~/Library/Application\ Support/foobar2000 ~/Desktop/foobar2000-backup

# Резервная копия пресетов кодировщиков
tar -czf ~/Desktop/encoder-presets-backup.tar.gz -C ~/Library/Application\ Support/foobar2000 encoder_presets

# Восстановление
cp -R ~/Desktop/foobar2000-backup ~/Library/Application\ Support/foobar2000
```

## Кастомизация

### Создание собственных пресетов:
```bash
# Редактировать пресеты кодировщиков
nano ~/Library/Application\ Support/foobar2000/encoder_presets/my_custom.preset

# Создать собственные скрипты тегирования
nano ~/Library/Application\ Support/foobar2000/masstagger_scripts/MY_CUSTOM_SCRIPT.txt
```

### Интеграция с другими приложениями:
- **Automator** - создание workflow для обработки файлов
- **AppleScript** - автоматизация через системные скрипты
- **Shortcuts** - интеграция с приложением Shortcuts

## Поддержка и развитие

- **GitHub Issues** - сообщения об ошибках
- **Discussions** - вопросы по использованию
- **Wiki** - дополнительная документация

При создании issue укажите:
- Версию macOS
- Архитектуру процессора (Apple Silicon/Intel)
- Версию foobar2000
- Логи выполнения скриптов

## Лицензия

MIT License - свободное использование и модификация.

---

**Совместимость**: macOS 11.0+, Apple Silicon + Intel  
**Поддержка**: Актуальные версии macOS и foobar2000  
**Обновления**: Регулярные обновления совместимости