#!/bin/bash
#
# Простой скрипт конвертации для совместимости с fish-функциями
# Перенаправляет вызовы на продвинутый скрипт конвертации
#

set -euo pipefail

# Получаем директорию скрипта
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ADVANCED_SCRIPT="$SCRIPT_DIR/convert_with_external_advanced.sh"

# Проверка аргументов
if [[ $# -lt 2 ]]; then
    echo "Использование: $0 <input_file> <output_format>"
    echo
    echo "Форматы: flac, flac_commercial, flac_commercial_16-bit, mp3_v0, mp3_320, mp3_commercial, mp3_commercial_16-bit, opus"
    echo
    echo "Примеры:"
    echo "  $0 file.wav mp3_320"
    echo "  $0 file.mp3 flac"
    exit 1
fi

INPUT_FILE="$1"
OUTPUT_FORMAT="$2"

# Проверка существования продвинутого скрипта
if [[ ! -f "$ADVANCED_SCRIPT" ]]; then
    echo "Ошибка: Продвинутый скрипт конвертации не найден: $ADVANCED_SCRIPT"
    exit 1
fi

# Вызов продвинутого скрипта с режимом suffix по умолчанию
exec "$ADVANCED_SCRIPT" "$INPUT_FILE" "$OUTPUT_FORMAT" "suffix"