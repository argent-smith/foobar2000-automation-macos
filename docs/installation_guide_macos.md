# Руководство по установке - foobar2000 Automation для macOS

## Предварительные требования

### Системные требования

- **macOS 11.0 Big Sur** или выше (рекомендуется macOS 13.0+)
- **2 GB** свободного места на диске
- **Apple Silicon** (M1/M2/M3) или **Intel** процессор
- Подключение к интернету для загрузки компонентов
- Права администратора для установки Homebrew

### Проверка системы

```bash
# Проверить версию macOS
sw_vers

# Проверить архитектуру процессора
uname -m
# arm64 = Apple Silicon
# x86_64 = Intel

# Проверить свободное место на диске
df -h /
```

## Шаг 1: Установка Homebrew

### Для систем без Homebrew

```bash
# Установить Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Добавить Homebrew в PATH
# Для Apple Silicon
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc

# Для Intel Mac
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc

# Перезагрузить shell
source ~/.zshrc

# Проверить установку
brew --version
```

### Проверка существующей установки Homebrew

```bash
# Проверить статус Homebrew
brew doctor

# Обновить Homebrew
brew update
```

## Шаг 2: Получение проекта

### Клонирование репозитория

```bash
# Клонировать проект
git clone https://github.com/your-repo/foobar2000-automation-macos.git

# Перейти в папку проекта
cd foobar2000-automation-macos

# Проверить структуру проекта
ls -la
```

### Установка прав доступа

```bash
# Сделать скрипты исполняемыми
chmod +x scripts/*.sh

# Проверить права
ls -la scripts/
```

## Шаг 3: Выбор типа установки

### Интерактивная установка (рекомендуется)

```bash
./scripts/install.sh --mode interactive
```

**Преимущества:**
- Пошаговая настройка
- Выбор компонентов
- Настройка путей к библиотекам
- Создание резервных копий

### Автоматическая установка

```bash
# Стандартный профиль
./scripts/install.sh --profile standard --mode automatic

# Минимальный профиль
./scripts/install.sh --profile minimal --mode automatic

# Профессиональный профиль
./scripts/install.sh --profile professional --mode automatic
```

## Шаг 4: Профили установки

### Минимальный профиль

**Компоненты:**
- foobar2000 (Homebrew cask)
- FLAC кодировщик
- LAME MP3 кодировщик
- jq для обработки JSON

**Размер:** ~50MB  
**Время установки:** 2-5 минут

```bash
./scripts/install.sh --profile minimal
```

### Стандартный профиль

**Компоненты:**
- Все из минимального
- Opus кодировщик
- MediaInfo для анализа файлов
- wget для загрузок
- Базовые пресеты кодировщиков

**Размер:** ~200MB  
**Время установки:** 5-10 минут

```bash
./scripts/install.sh --profile standard
```

### Профессиональный профиль

**Компоненты:**
- Все из стандартного
- FFmpeg мультимедиа фреймворк
- tag для редактирования метаданных
- Расширенные пресеты кодировщиков
- Masstagger скрипты
- Автоматизация и интеграция с macOS

**Размер:** ~500MB+  
**Время установки:** 10-20 минут

```bash
./scripts/install.sh --profile professional
```

## Шаг 5: Настройка путей к библиотекам

### Во время интерактивной установки

Скрипт предложит указать пути к вашим музыкальным библиотекам:

```
Укажите пути к музыкальным библиотекам (разделенные запятой):
Пример: ~/Music,~/FLAC,/Volumes/MusicDrive
```

### Ручная настройка после установки

```bash
./scripts/config-generator.sh --profile standard --library-paths ~/Music,~/FLAC
```

## Шаг 6: Проверка установки

### Базовая проверка

```bash
./scripts/validator.sh
```

### Детальная проверка

```bash
./scripts/validator.sh --detailed --report validation-report.json
```

### Проверка конкретного профиля

```bash
./scripts/validator.sh --profile professional
```

## Решение проблем при установке

### Ошибка: "brew: command not found"

```bash
# Добавить Homebrew в PATH
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

# Или переустановить Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Ошибка: "Permission denied"

```bash
# Исправить права доступа для Homebrew
sudo chown -R $(whoami) $(brew --prefix)/*

# Сделать скрипты исполняемыми
chmod +x scripts/*.sh
```

### Ошибка: "Architecture mismatch"

```bash
# Для Apple Silicon - переустановить в native режиме
arch -arm64 brew install flac lame opus-tools

# Для Intel - использовать x86_64
arch -x86_64 brew install flac lame opus-tools
```

### Проблемы с правами доступа macOS

1. **Системные настройки → Безопасность и конфиденциальность → Конфиденциальность**
2. **Доступ к полному диску** - добавить Terminal.app
3. **Файлы и папки** - разрешить доступ к Music, Documents

## Постустановочная настройка

### Интеграция с macOS

```bash
# Настроить файловые ассоциации
brew install duti
duti -s org.foobar2000.foobar2000 .mp3 all
duti -s org.foobar2000.foobar2000 .flac all

# Перезапустить Launch Services
/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain system -domain user
```

### Создание резервной копии

```bash
# Резервная копия конфигурации
./scripts/config-generator.sh --backup

# Ручная резервная копия
cp -R ~/Library/foobar2000-v2 ~/Desktop/foobar2000-backup
```

### Настройка автоматических обновлений

```bash
# Добавить в crontab для еженедельных обновлений
crontab -e

# Добавить строку:
0 2 * * 0 /opt/homebrew/bin/brew update && /opt/homebrew/bin/brew upgrade
```

## Проверка результата

### Запуск foobar2000

```bash
# Запустить из командной строки
open /Applications/foobar2000.app

# Или через Finder
```

### Проверка кодировщиков

```bash
# Проверить доступность кодировщиков
which flac lame opusenc ffmpeg

# Тест кодирования
flac --version
lame --version
```

### Проверка конфигурации

```bash
# Просмотр созданных конфигураций
ls -la ~/Library/foobar2000-v2/

# Проверка пресетов кодировщиков
ls -la ~/Library/foobar2000-v2/encoder_presets/
```

## Обновление системы

### Обновление компонентов

```bash
# Обновить все Homebrew пакеты
brew update && brew upgrade

# Обновить foobar2000
brew upgrade --cask foobar2000

# Очистить кэш
brew cleanup
```

### Обновление конфигурации

```bash
# Пересоздать конфигурацию с новыми компонентами
./scripts/config-generator.sh --profile standard --backup
```

## Деинсталляция

### Удаление foobar2000

```bash
# Удалить приложение
brew uninstall --cask foobar2000

# Удалить конфигурационные файлы
rm -rf ~/Library/foobar2000-v2
```

### Удаление кодировщиков

```bash
# Удалить все установленные кодировщики
brew uninstall flac lame opus-tools ffmpeg mediainfo tag jq wget
```

### Полная очистка

```bash
# Удалить все следы проекта
rm -rf ~/Library/foobar2000-v2
rm -rf ~/Library/Logs/foobar2000
rm -rf foobar2000-automation-macos
```

---

**Время установки:** 5-20 минут в зависимости от профиля  
**Поддерживаемые архитектуры:** Apple Silicon, Intel  
**Минимальная версия macOS:** 11.0 Big Sur