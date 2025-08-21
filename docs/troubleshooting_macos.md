# Устранение проблем - foobar2000 Automation для macOS

## Системные проблемы

### Проблемы с Homebrew

#### Ошибка: "brew: command not found"

**Причина**: Homebrew не установлен или не добавлен в PATH

**Решения**:
```bash
# 1. Установить Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Добавить в PATH для Apple Silicon
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc

# 3. Добавить в PATH для Intel Mac
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc

# 4. Проверить установку
brew --version
```

#### Ошибка: "Permission denied" при установке через Homebrew

**Решения**:
```bash
# Исправить права доступа для Homebrew
sudo chown -R $(whoami) $(brew --prefix)/*

# Переустановить Homebrew если проблема серьезная
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/uninstall.sh)"
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Ошибка: "Architecture mismatch"

**Причина**: Неправильная архитектура для Apple Silicon/Intel

**Решения**:
```bash
# Определить архитектуру
uname -m  # arm64 = Apple Silicon, x86_64 = Intel

# Для Apple Silicon - переустановить Homebrew в правильном месте
arch -arm64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Для Intel - использовать Rosetta 2 если необходимо
arch -x86_64 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Переустановить компоненты с правильной архитектурой
brew uninstall flac lame opus-tools
brew install flac lame opus-tools
```

### Проблемы с правами доступа macOS

#### Ошибка: "Operation not permitted" при доступе к файлам

**Причина**: macOS блокирует доступ к определенным папкам

**Решения**:
1. **Системные настройки → Безопасность и конфиденциальность → Конфиденциальность → Доступ к полному диску**
   - Добавить Terminal.app
   - Добавить foobar2000.app

2. **Для папок Music, Documents, Downloads**:
   ```bash
   # Проверить права доступа
   ls -la ~/Music
   
   # При необходимости сбросить права
   sudo chmod -R 755 ~/Music
   ```

#### Ошибка: Gatekeeper блокирует запуск

**Решения**:
```bash
# Разрешить запуск конкретного приложения
sudo spctl --add /Applications/foobar2000.app
sudo xattr -dr com.apple.quarantine /Applications/foobar2000.app

# Временно отключить Gatekeeper (не рекомендуется)
sudo spctl --master-disable
```

## Проблемы с foobar2000

### Проблемы установки

#### foobar2000 не найден после установки через Homebrew

**Проверка**:
```bash
# Проверить установку cask
brew list --cask foobar2000

# Найти приложение
find /Applications -name "foobar2000*" -type d 2>/dev/null
find ~/Applications -name "foobar2000*" -type d 2>/dev/null

# Переустановить если не найден
brew reinstall --cask foobar2000
```

#### Ошибка: "foobar2000.app is damaged and can't be opened"

**Решения**:
```bash
# Удалить карантинные атрибуты
sudo xattr -cr /Applications/foobar2000.app

# Проверить подпись приложения
codesign -dv /Applications/foobar2000.app

# Переустановить приложение
brew uninstall --cask foobar2000
brew install --cask foobar2000
```

### Проблемы с конфигурацией

#### Конфигурационные файлы не создаются

**Проверка и решение**:
```bash
# Проверить существование папки конфигурации
ls -la ~/Library/Application\ Support/

# Создать папку вручную если не существует
mkdir -p ~/Library/Application\ Support/foobar2000

# Проверить права доступа
chmod 755 ~/Library/Application\ Support/foobar2000

# Запустить генератор конфигурации повторно
./scripts/config-generator.sh --profile standard --backup
```

## Проблемы с кодировщиками

### Кодировщики не найдены

#### "flac: command not found"

**Решения**:
```bash
# Проверить установку
brew list flac

# Установить если отсутствует
brew install flac

# Проверить путь
which flac

# Добавить путь в переменную среды
export PATH="/opt/homebrew/bin:$PATH"  # Apple Silicon
export PATH="/usr/local/bin:$PATH"     # Intel
```

#### Кодировщики установлены, но скрипты их не находят

**Диагностика**:
```bash
# Определить используемые пути
echo $PATH

# Найти все установленные кодировщики
find /opt/homebrew/bin /usr/local/bin -name "flac" -o -name "lame" -o -name "opusenc" 2>/dev/null

# Проверить архитектуру бинарных файлов
file /opt/homebrew/bin/flac  # должно быть arm64 для Apple Silicon
file /usr/local/bin/flac     # должно быть x86_64 для Intel
```

**Решения**:
```bash
# Обновить PATH в скриптах
# Отредактировать ~/.zshrc или ~/.bash_profile
echo 'export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc

# Создать символические ссылки
sudo ln -sf /opt/homebrew/bin/flac /usr/local/bin/flac
sudo ln -sf /opt/homebrew/bin/lame /usr/local/bin/lame
```

### Проблемы с качеством кодирования

#### MP3 файлы создаются с некорректными тегами

**Проверка**:
```bash
# Проверить версию LAME
lame --version

# Тест кодирования
lame --preset standard input.wav output.mp3

# Проверить теги
mediainfo output.mp3
```

**Решение**:
```bash
# Обновить LAME до последней версии
brew upgrade lame

# Использовать корректные параметры кодирования
lame -V 0 --add-id3v2 --id3v2-only --tt "Title" --ta "Artist" input.wav output.mp3
```

## Проблемы производительности

### Медленное кодирование

#### На Apple Silicon производительность хуже ожидаемой

**Диагностика**:
```bash
# Проверить архитектуру процессов
ps aux | grep -E "(flac|lame|opus)" 
# Должны быть arm64, не x86_64

# Проверить использование ресурсов
top -pid $(pgrep flac)
```

**Решения**:
```bash
# Убедиться, что используются нативные ARM64 версии
brew uninstall flac lame opus-tools
arch -arm64 brew install flac lame opus-tools

# Проверить установку
file $(which flac)  # должно показывать arm64

# Оптимизировать параметры для Apple Silicon
# Использовать меньшие уровни сжатия для быстрой работы
flac -3 input.wav  # вместо -8
```

#### Высокое использование CPU

**Мониторинг**:
```bash
# Отслеживать процессы кодирования
sudo dtrace -n 'proc:::exec-success /execname == "flac"/ { printf("%s %s", execname, curpsinfo->pr_psargs); }'

# Activity Monitor для детального анализа
open -a "Activity Monitor"
```

**Оптимизация**:
```bash
# Ограничить количество параллельных процессов
export MAX_PARALLEL_JOBS=4

# Использовать nice для снижения приоритета
nice -n 10 flac -8 input.wav
```

## Проблемы интеграции с macOS

### Файловые ассоциации не работают

#### Аудиофайлы не открываются в foobar2000

**Диагностика**:
```bash
# Проверить текущие ассоциации
duti -x .mp3
duti -x .flac

# Проверить установленные обработчики
/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -dump | grep -i foobar
```

**Решения**:
```bash
# Установить duti для управления ассоциациями
brew install duti

# Зарегистрировать foobar2000 как обработчик
duti -s org.foobar2000.foobar2000 .mp3 all
duti -s org.foobar2000.foobar2000 .flac all
duti -s org.foobar2000.foobar2000 .m4a all

# Перезапустить Launch Services
/System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -kill -r -domain local -domain system -domain user
```

### Медиа-клавиши не работают

**Решения**:
```bash
# Проверить системные настройки
defaults read com.apple.symbolichotkeys

# Сбросить медиа-клавиши для foobar2000
# Системные настройки → Клавиатура → Сочетания клавиш → Медиа-клавиши
```

### Проблемы с уведомлениями

**Включить уведомления**:
1. Системные настройки → Уведомления и фокус
2. Найти foobar2000
3. Включить уведомления

## Проблемы со скриптами

### Ошибки в bash скриптах

#### "Permission denied" при запуске скрипта

**Решение**:
```bash
# Сделать скрипт исполняемым
chmod +x ./scripts/install.sh
chmod +x ./scripts/components-downloader.sh
chmod +x ./scripts/config-generator.sh
chmod +x ./scripts/validator.sh

# Проверить права
ls -la ./scripts/
```

#### Ошибки парсинга JSON

**Проверка и решение**:
```bash
# Установить jq если отсутствует
brew install jq

# Проверить валидность JSON файлов
jq . resources/macos_components.json
jq . resources/compatibility_macos.json

# Исправить ошибки синтаксиса JSON
```

## Специфичные проблемы macOS версий

### macOS Sonoma (14.0+)

**Известные проблемы**:
- Новые ограничения безопасности могут требовать дополнительных разрешений
- Некоторые Homebrew формулы могут быть несовместимы

**Решения**:
```bash
# Обновить Homebrew и формулы
brew update && brew upgrade

# Проверить совместимость
brew doctor
```

### macOS Ventura (13.0+)

**Проблемы**:
- Изменения в системе разрешений

**Решения**:
- Предоставить полные права доступа к диску для Terminal и foobar2000

### macOS Monterey (12.0+)

**Проблемы**:
- Возможны периодические вылеты с большими библиотеками

**Решения**:
```bash
# Ограничить размер обрабатываемых файлов за раз
# Использовать пакетную обработку небольшими группами
```

## Сбор диагностической информации

### Создание диагностического отчета

```bash
#!/bin/bash
# Создать полный диагностический отчет

echo "=== foobar2000 macOS Diagnostic Report ===" > diagnostic.txt
echo "Date: $(date)" >> diagnostic.txt
echo "" >> diagnostic.txt

echo "System Information:" >> diagnostic.txt
sw_vers >> diagnostic.txt
uname -a >> diagnostic.txt
echo "Architecture: $(uname -m)" >> diagnostic.txt
echo "" >> diagnostic.txt

echo "Homebrew Information:" >> diagnostic.txt
brew --version >> diagnostic.txt 2>&1
brew doctor >> diagnostic.txt 2>&1
echo "" >> diagnostic.txt

echo "Installed Components:" >> diagnostic.txt
brew list flac lame opus-tools ffmpeg mediainfo 2>&1 >> diagnostic.txt
echo "" >> diagnostic.txt

echo "Path Information:" >> diagnostic.txt
echo "PATH: $PATH" >> diagnostic.txt
which flac lame opusenc ffmpeg 2>&1 >> diagnostic.txt
echo "" >> diagnostic.txt

echo "foobar2000 Information:" >> diagnostic.txt
ls -la /Applications/foobar2000.app 2>&1 >> diagnostic.txt
ls -la ~/Library/Application\ Support/foobar2000/ 2>&1 >> diagnostic.txt
echo "" >> diagnostic.txt

echo "Recent System Logs:" >> diagnostic.txt
log show --predicate 'process == "foobar2000"' --last 1h 2>&1 >> diagnostic.txt

echo "Diagnostic report saved to diagnostic.txt"
```

## Получение помощи

### Где искать помощь

1. **Официальная документация foobar2000**
2. **Homebrew документация**: `brew help`
3. **GitHub Issues** проекта
4. **Форумы macOS** и **Reddit r/macOS**

### Информация для сообщений об ошибках

При создании issue укажите:

```bash
# Системная информация
sw_vers
uname -m

# Версии компонентов
brew --version
brew list --versions flac lame opus-tools

# Версия foobar2000
plutil -extract CFBundleShortVersionString xml1 -o - /Applications/foobar2000.app/Contents/Info.plist

# Логи ошибок
tail -50 ~/Library/Logs/foobar2000/debug.log
```

---

**Совет**: Большинство проблем решается обновлением Homebrew и переустановкой компонентов:
```bash
brew update && brew upgrade && brew doctor
```