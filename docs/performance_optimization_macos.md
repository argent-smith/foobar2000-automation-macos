# Оптимизация производительности - foobar2000 Automation для macOS

## Оптимизация для Apple Silicon

### Проверка нативной поддержки

```bash
# Проверить архитектуру установленных кодировщиков
file $(which flac)   # должно показывать arm64
file $(which lame)   # должно показывать arm64
file $(which opusenc) # должно показывать arm64

# Проверить архитектуру foobar2000
file /Applications/foobar2000.app/Contents/MacOS/foobar2000
```

### Переустановка в нативном режиме

```bash
# Удалить все кодировщики
brew uninstall flac lame opus-tools ffmpeg

# Убедиться, что используется нативный Homebrew
arch -arm64 brew install flac lame opus-tools ffmpeg

# Проверить результат
file $(which flac)  # должно быть: Mach-O 64-bit executable arm64
```

### Настройки кодирования для Apple Silicon

#### FLAC оптимизация

```bash
# Максимальная производительность
flac -3 -V input.wav -o output.flac

# Баланс скорости и сжатия
flac -5 -V input.wav -o output.flac

# Максимальное сжатие (медленнее)
flac -8 -V input.wav -o output.flac
```

#### MP3 оптимизация

```bash
# Быстрое кодирование высокого качества
lame -V 2 -h input.wav output.mp3

# Максимальное качество
lame -V 0 -h input.wav output.mp3

# Для пакетной обработки
lame -V 2 --preset fast standard input.wav output.mp3
```

#### Opus оптимизация

```bash
# Высокое качество для музыки
opusenc --bitrate 192 --application audio input.wav output.opus

# Оптимизировано для речи
opusenc --bitrate 64 --application voip input.wav output.opus

# Максимальная эффективность
opusenc --bitrate 128 --complexity 10 input.wav output.opus
```

## Оптимизация для Intel Mac

### Проверка совместимости

```bash
# Проверить использование Rosetta 2
ps aux | grep -E "(flac|lame|opus)" | grep -v grep

# Если видите (translated), значит используется Rosetta 2
```

### Оптимальные настройки для Intel

```bash
# Использовать меньшие уровни сжатия для лучшей производительности
flac -5 input.wav -o output.flac  # вместо -8

# Использовать быстрые пресеты
lame --preset fast standard input.wav output.mp3
```

## Многопоточная обработка

### Пакетное кодирование с GNU Parallel

```bash
# Установить GNU Parallel
brew install parallel

# Пакетное кодирование FLAC
find ~/Music -name "*.wav" | parallel flac -5 -V {} -o {.}.flac

# Пакетное кодирование MP3 с ограничением процессов
find ~/Music -name "*.wav" | parallel -j 4 lame -V 2 {} {.}.mp3
```

### Скрипт для оптимального использования CPU

```bash
#!/bin/bash
# scripts/optimization/parallel_encode.sh

# Определить количество ядер CPU
CPU_CORES=$(sysctl -n hw.ncpu)
OPTIMAL_JOBS=$((CPU_CORES - 1))  # Оставить одно ядро для системы

echo "Доступно ядер CPU: $CPU_CORES"
echo "Оптимальное количество параллельных задач: $OPTIMAL_JOBS"

# Функция пакетного кодирования
batch_encode() {
    local input_dir="$1"
    local output_dir="$2"
    local format="$3"
    
    mkdir -p "$output_dir"
    
    case "$format" in
        flac)
            find "$input_dir" -name "*.wav" | parallel -j $OPTIMAL_JOBS \
                flac -5 -V {} -o "$output_dir/{/.}.flac"
            ;;
        mp3)
            find "$input_dir" -name "*.wav" | parallel -j $OPTIMAL_JOBS \
                lame -V 2 {} "$output_dir/{/.}.mp3"
            ;;
        opus)
            find "$input_dir" -name "*.wav" | parallel -j $OPTIMAL_JOBS \
                opusenc --bitrate 192 {} "$output_dir/{/.}.opus"
            ;;
    esac
}

# Использование: ./parallel_encode.sh input_folder output_folder format
batch_encode "$1" "$2" "$3"
```

## Оптимизация памяти

### Мониторинг использования памяти

```bash
# Мониторинг процессов кодирования
top -pid $(pgrep -f "flac|lame|opus")

# Детальная информация о памяти
vm_stat | grep -E "(Pages free|Pages active|Pages inactive)"
```

### Настройки для больших файлов

```bash
# Для очень больших файлов (>1GB) используйте буферизацию
export FLAC_BUFFER_SIZE=32768

# Ограничить использование памяти FFmpeg
ffmpeg -i large_file.wav -bufsize 1M output.flac
```

## Оптимизация дискового пространства

### Настройка временных файлов

```bash
# Использовать быстрый SSD для временных файлов
export TMPDIR="/Volumes/FastSSD/temp"
mkdir -p "$TMPDIR"

# Или использовать RAM диск для очень быстрой обработки
diskutil erasevolume HFS+ "RAMDisk" `hdiutil attach -nomount ram://2048000`
export TMPDIR="/Volumes/RAMDisk"
```

### Оптимизация размера файлов

```bash
# FLAC с оптимальным сжатием
flac -8 -V -e -p --totally-silent input.wav

# MP3 с переменным битрейтом
lame -V 0 --vbr-new -q 0 input.wav output.mp3

# Opus с адаптивным битрейтом
opusenc --vbr --bitrate 128 input.wav output.opus
```

## Энергоэффективность (MacBook)

### Настройки для работы от батареи

```bash
#!/bin/bash
# scripts/optimization/battery_optimized.sh

# Проверить источник питания
if pmset -g ps | grep -q "Battery Power"; then
    echo "Работа от батареи - используем энергоэффективные настройки"
    
    # Меньшие уровни сжатия
    FLAC_LEVEL=3
    MP3_QUALITY=4
    PARALLEL_JOBS=2
else
    echo "Подключено зарядное устройство - используем максимальную производительность"
    
    # Максимальные уровни сжатия
    FLAC_LEVEL=8
    MP3_QUALITY=0
    PARALLEL_JOBS=$(sysctl -n hw.ncpu)
fi

# Экспорт переменных для использования в других скриптах
export FLAC_LEVEL MP3_QUALITY PARALLEL_JOBS
```

### Мониторинг энергопотребления

```bash
# Мониторинг энергопотребления процессов
sudo powermetrics --samplers cpu_power -n 10 -i 1000

# Проверка температуры (требует установки дополнительных утилит)
brew install osx-cpu-temp
osx-cpu-temp
```

## Настройки качества по использованию

### Для архивирования (максимальное качество)

```bash
# FLAC с максимальным сжатием
flac -8 -V -e -p --totally-silent input.wav

# MP3 без потерь (псевдо-lossless)
lame -V 0 --preset extreme input.wav output.mp3
```

### Для повседневного прослушивания

```bash
# FLAC быстрое сжатие
flac -5 -V input.wav

# MP3 стандартное качество
lame -V 2 input.wav output.mp3

# Opus оптимальное качество
opusenc --bitrate 128 input.wav output.opus
```

### Для мобильных устройств

```bash
# Компактные файлы
lame -V 4 input.wav output.mp3
opusenc --bitrate 96 input.wav output.opus
```

## Автоматизация оптимизации

### Скрипт автоматического выбора настроек

```bash
#!/bin/bash
# scripts/optimization/smart_encode.sh

detect_optimal_settings() {
    local cpu_type=$(uname -m)
    local cpu_cores=$(sysctl -n hw.ncpu)
    local battery_status=$(pmset -g ps | grep -c "Battery Power")
    
    if [[ "$cpu_type" == "arm64" ]]; then
        # Apple Silicon оптимизация
        FLAC_LEVEL=5
        MP3_QUALITY=2
        OPUS_BITRATE=192
        PARALLEL_JOBS=$((cpu_cores - 1))
    else
        # Intel оптимизация
        FLAC_LEVEL=3
        MP3_QUALITY=4
        OPUS_BITRATE=128
        PARALLEL_JOBS=$((cpu_cores / 2))
    fi
    
    # Снизить производительность при работе от батареи
    if [[ $battery_status -gt 0 ]]; then
        FLAC_LEVEL=$((FLAC_LEVEL - 2))
        MP3_QUALITY=$((MP3_QUALITY + 1))
        PARALLEL_JOBS=$((PARALLEL_JOBS / 2))
    fi
    
    echo "Оптимальные настройки:"
    echo "FLAC level: $FLAC_LEVEL"
    echo "MP3 quality: V$MP3_QUALITY"
    echo "Opus bitrate: $OPUS_BITRATE"
    echo "Parallel jobs: $PARALLEL_JOBS"
}

detect_optimal_settings
```

## Бенчмарки производительности

### Тестирование скорости кодирования

```bash
#!/bin/bash
# scripts/optimization/benchmark.sh

benchmark_encoding() {
    local test_file="test_audio.wav"
    
    echo "=== Бенчмарк кодирования ==="
    echo "Тестовый файл: $test_file"
    echo "Система: $(uname -m) на macOS $(sw_vers -productVersion)"
    echo ""
    
    # FLAC тест
    echo "FLAC уровни сжатия:"
    for level in 1 3 5 8; do
        echo -n "Уровень $level: "
        time flac -$level -V "$test_file" -o "test_flac_$level.flac" 2>/dev/null
        rm -f "test_flac_$level.flac"
    done
    
    echo ""
    
    # MP3 тест
    echo "MP3 качество:"
    for quality in 4 2 0; do
        echo -n "V$quality: "
        time lame -V $quality "$test_file" "test_mp3_v$quality.mp3" 2>/dev/null
        rm -f "test_mp3_v$quality.mp3"
    done
    
    echo ""
    
    # Opus тест
    echo "Opus битрейт:"
    for bitrate in 96 128 192; do
        echo -n "${bitrate}k: "
        time opusenc --bitrate $bitrate "$test_file" "test_opus_$bitrate.opus" 2>/dev/null
        rm -f "test_opus_$bitrate.opus"
    done
}

# Создать тестовый файл если не существует
if [[ ! -f "test_audio.wav" ]]; then
    # Создать 1-минутный тестовый WAV файл
    ffmpeg -f lavfi -i "sine=frequency=440:duration=60" -acodec pcm_s16le test_audio.wav
fi

benchmark_encoding
```

### Результаты бенчмарков (примерные)

**MacBook Pro M2 Max:**
- FLAC-8: ~15x realtime
- MP3 V0: ~25x realtime  
- Opus 192k: ~30x realtime

**MacBook Pro Intel i9:**
- FLAC-8: ~8x realtime
- MP3 V0: ~15x realtime
- Opus 192k: ~18x realtime

**MacBook Air M1:**
- FLAC-8: ~12x realtime
- MP3 V0: ~20x realtime
- Opus 192k: ~25x realtime

## Мониторинг производительности

### Скрипт мониторинга в реальном времени

```bash
#!/bin/bash
# scripts/optimization/monitor.sh

monitor_encoding() {
    while true; do
        clear
        echo "=== Мониторинг кодирования $(date) ==="
        echo ""
        
        # CPU использование
        echo "CPU:"
        top -l 1 -n 0 | grep "CPU usage"
        
        echo ""
        
        # Память
        echo "Memory:"
        vm_stat | grep -E "(Pages free|Pages active)" | head -2
        
        echo ""
        
        # Активные процессы кодирования
        echo "Активные кодировщики:"
        ps aux | grep -E "(flac|lame|opus|ffmpeg)" | grep -v grep
        
        echo ""
        
        # Температура (если доступно)
        if command -v osx-cpu-temp >/dev/null 2>&1; then
            echo "Температура CPU: $(osx-cpu-temp)"
        fi
        
        sleep 5
    done
}

monitor_encoding
```

---

**Рекомендации:**
- Используйте нативные ARM64 версии на Apple Silicon
- Ограничивайте параллельные процессы при работе от батареи  
- Мониторьте температуру при интенсивной обработке
- Используйте SSD для временных файлов при больших объемах