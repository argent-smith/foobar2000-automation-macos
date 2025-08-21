# Альтернативы мониторинга файлов foobar2000

## Bash скрипт (рекомендуется)

**Файл:** `scripts/foobar_monitor.sh`

### Преимущества:
- Не требует Python зависимостей
- Работает из коробки на любом macOS
- Два режима работы: fswatch и polling
- Встроенное логирование
- Управление через командную строку

### Использование:
```bash
# Запуск мониторинга
bash ~/Library/foobar2000-v2/foobar_monitor.sh

# Проверка статуса
bash ~/Library/foobar2000-v2/foobar_monitor.sh --status

# Остановка
bash ~/Library/foobar2000-v2/foobar_monitor.sh --stop
```

### Режимы работы:

1. **С fswatch (рекомендуется):**
   ```bash
   brew install fswatch
   ```
   - Мгновенная реакция на изменения
   - Минимальное потребление ресурсов
   - Использует системные события macOS

2. **Polling режим:**
   - Не требует дополнительных установок
   - Проверка каждые 5 секунд
   - Больше нагрузки на систему

## Python скрипт (альтернативный)

**Файл:** `scripts/foobar_monitor.py`

### Требования:
```bash
pip3 install --user watchdog
```

### Преимущества:
- Более продвинутая обработка событий
- Лучшее управление исключениями
- Гибкие настройки

### Использование:
```bash
python3 ~/Library/foobar2000-v2/foobar_monitor.py
```

## Другие альтернативы

### 1. launchd + Folder Actions

Автоматический запуск через системные службы macOS:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.foobar2000.monitor</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/username/Library/foobar2000-v2/foobar_monitor.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/Users/username/Library/foobar2000-v2/logs/launchd.log</string>
</dict>
</plist>
```

### 2. AppleScript + Folder Actions

Создание Folder Action для автоматической обработки:

```applescript
on adding folder items to this_folder after receiving added_items
    repeat with this_item in added_items
        set item_path to POSIX path of this_item
        
        -- Проверка аудиоформата
        if item_path ends with ".flac" or item_path ends with ".mp3" or ¬
           item_path ends with ".wav" or item_path ends with ".m4a" then
            
            tell application "foobar2000"
                open this_item
            end tell
            
        end if
    end repeat
end adding folder items to
```

### 3. Hazel (коммерческое решение)

Если установлен Hazel:
- Создать правило для папки `~/Music/Import`
- Условие: файл соответствует аудиоформатам
- Действие: открыть в foobar2000

### 4. Automator Workflow

Создание Automator workflow:
1. Новый "Folder Action"
2. Выбрать папку `~/Music/Import`
3. Добавить действие "Filter Finder Items" (аудиофайлы)
4. Добавить действие "Open Finder Items" (в foobar2000)

## Сравнение решений

| Решение | Установка | Ресурсы | Скорость | Надежность |
|---------|-----------|---------|----------|------------|
| Bash + fswatch | ★★★★☆ | ★★★★★ | ★★★★★ | ★★★★★ |
| Bash polling | ★★★★★ | ★★★☆☆ | ★★★☆☆ | ★★★★☆ |
| Python | ★★★☆☆ | ★★★★☆ | ★★★★★ | ★★★★★ |
| launchd | ★★☆☆☆ | ★★★★★ | ★★★★★ | ★★★★★ |
| Folder Actions | ★★★☆☆ | ★★★★☆ | ★★★★☆ | ★★★☆☆ |
| Hazel | ★★★★★ | ★★★★☆ | ★★★★★ | ★★★★★ |
| Automator | ★★★★☆ | ★★★★☆ | ★★★★☆ | ★★★☆☆ |

## Рекомендация

Для большинства пользователей рекомендуется **bash скрипт** с установкой fswatch:

```bash
# Установка fswatch
brew install fswatch

# Запуск мониторинга
bash ~/Library/foobar2000-v2/foobar_monitor.sh
```

Это обеспечивает оптимальный баланс между простотой установки, производительностью и надежностью.