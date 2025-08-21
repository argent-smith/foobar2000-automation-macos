#!/bin/bash
#
# foobar2000 Integration Menu (Fish Shell Compatible)
# Простое меню для доступа ко всем функциям интеграции
#

set -euo pipefail

# Цвета
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

FB2K_CONFIG_DIR="$HOME/Library/foobar2000-v2"
CONVERT_SCRIPT="$FB2K_CONFIG_DIR/convert_with_external.sh"

show_header() {
    clear
    echo -e "${CYAN}=====================================${NC}"
    echo -e "${CYAN}   foobar2000 macOS Integration     ${NC}"
    echo -e "${CYAN}=====================================${NC}"
    echo
}

show_menu() {
    echo -e "${BLUE}Выберите действие:${NC}"
    echo
    echo -e "  ${GREEN}1.${NC} Конвертировать аудиофайл"
    echo -e "  ${GREEN}2.${NC} Запустить мониторинг импорта" 
    echo -e "  ${GREEN}3.${NC} Анализ качества файла"
    echo -e "  ${GREEN}4.${NC} Добавить файл в foobar2000"
    echo -e "  ${GREEN}5.${NC} Массовая конвертация папки"
    echo -e "  ${GREEN}6.${NC} Показать статистику"
    echo -e "  ${GREEN}7.${NC} Настройки и помощь"
    echo -e "  ${RED}0.${NC} Выход"
    echo
    echo -n "Ваш выбор: "
}

convert_file() {
    echo -e "${BLUE}=== Конвертация файла ===${NC}"
    echo
    
    read -r -p "Путь к исходному файлу: " input_file
    
    if [[ ! -f "$input_file" ]]; then
        echo -e "${RED}Файл не найден: $input_file${NC}"
        return 1
    fi
    
    echo
    echo "Выберите формат вывода:"
    echo "1) FLAC (lossless)"
    echo "2) MP3 V0 VBR (~245 kbps)"  
    echo "3) MP3 320 CBR"
    echo "4) MP3 192 CBR Commercial"
    echo "5) Opus (~192 kbps)"
    echo
    read -r -p "Формат (1-5): " format_choice
    
    case "$format_choice" in
        1) format="flac" ;;
        2) format="mp3_v0" ;;
        3) format="mp3_320" ;;
        4) format="mp3_commercial" ;;
        5) format="opus" ;;
        *) echo -e "${RED}Неверный выбор${NC}"; return 1 ;;
    esac
    
    echo
    echo "Выберите режим конвертации:"
    echo "1) Создать новый файл с суффиксом"
    echo "2) Заменить исходный файл (через временные файлы)" 
    echo "3) Интерактивный режим"
    echo
    read -r -p "Режим (1-3): " mode_choice
    
    case "$mode_choice" in
        1) mode="suffix" ;;
        2) mode="replace" ;;
        3) mode="interactive" ;;
        *) echo -e "${RED}Неверный выбор${NC}"; return 1 ;;
    esac
    
    # Используем продвинутый конвертер
    local advanced_script="$FB2K_CONFIG_DIR/convert_with_external_advanced.sh"
    
    echo
    echo -e "${YELLOW}Конвертация $input_file в $format (режим: $mode)...${NC}"
    
    if "$advanced_script" "$input_file" "$format" "$mode"; then
        echo -e "${GREEN}✓ Конвертация завершена успешно${NC}"
        echo -e "${CYAN}Подробности в логе: $FB2K_CONFIG_DIR/logs/conversion.log${NC}"
    else
        echo -e "${RED}✗ Ошибка конвертации${NC}"
        echo -e "${YELLOW}Проверьте лог: $FB2K_CONFIG_DIR/logs/conversion.log${NC}"
    fi
}

start_monitoring() {
    echo -e "${BLUE}=== Мониторинг папки импорта ===${NC}"
    echo
    
    local import_dir="$HOME/Music/Import"
    mkdir -p "$import_dir"
    
    echo "Мониторинг папки: $import_dir"
    echo "Файлы будут автоматически добавляться в foobar2000"
    echo
    echo -e "${YELLOW}Нажмите Ctrl+C для остановки${NC}"
    echo
    
    python3 "$FB2K_CONFIG_DIR/foobar_monitor.py" || {
        echo -e "${RED}Ошибка запуска мониторинга${NC}"
        echo "Убедитесь, что установлен watchdog: pip3 install --user watchdog"
    }
}

analyze_quality() {
    echo -e "${BLUE}=== Анализ качества файла ===${NC}"
    echo
    
    read -r -p "Путь к файлу: " file_path
    
    if [[ ! -f "$file_path" ]]; then
        echo -e "${RED}Файл не найден: $file_path${NC}"
        return 1
    fi
    
    if command -v mediainfo >/dev/null 2>&1; then
        echo -e "${YELLOW}Анализ файла: $(basename "$file_path")${NC}"
        echo
        
        mediainfo --Inform="General;Имя файла: %FileName%\nФормат: %Format%\nРазмер: %FileSize/String4%\nДлительность: %Duration/String3%\n\nAudio;Аудио формат: %Format%\nБитрейт: %BitRate/String%\nЧастота: %SamplingRate/String% Hz\nКаналов: %Channel(s)%\nБиты: %BitDepth% bit\nКомпрессия: %Compression_Mode%" "$file_path"
        
        echo
        
        # Оценка качества
        local format
        format=$(mediainfo --Inform="Audio;%Format%" "$file_path")
        local bitrate
        bitrate=$(mediainfo --Inform="Audio;%BitRate%" "$file_path")
        
        echo -e "${CYAN}Оценка качества:${NC}"
        case "$format" in
            FLAC) echo -e "  ${GREEN}✓ Отличное (lossless)${NC}" ;;
            "MPEG Audio")
                if [[ "$bitrate" -ge 320000 ]]; then
                    echo -e "  ${GREEN}✓ Очень хорошее (320+ kbps)${NC}"
                elif [[ "$bitrate" -ge 200000 ]]; then
                    echo -e "  ${YELLOW}○ Хорошее (200-320 kbps)${NC}"
                else
                    echo -e "  ${RED}△ Среднее (<200 kbps)${NC}"
                fi
                ;;
            Opus) echo -e "  ${GREEN}✓ Отличное (современный кодек)${NC}" ;;
            *) echo -e "  ${YELLOW}○ Определить не удалось${NC}" ;;
        esac
    else
        echo -e "${RED}MediaInfo не установлен${NC}"
        echo "Установите: brew install mediainfo"
    fi
}

add_to_foobar() {
    echo -e "${BLUE}=== Добавить файл в foobar2000 ===${NC}"
    echo
    
    read -r -p "Путь к файлу или папке: " path
    
    if [[ ! -e "$path" ]]; then
        echo -e "${RED}Путь не найден: $path${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Добавление в foobar2000...${NC}"
    
    if osascript -e "tell application \"foobar2000\" to open POSIX file \"$path\"" 2>/dev/null; then
        echo -e "${GREEN}✓ Успешно добавлено${NC}"
    else
        echo -e "${RED}✗ Ошибка добавления${NC}"
        echo "Убедитесь, что foobar2000 запущен"
    fi
}

batch_convert() {
    echo -e "${BLUE}=== Массовая конвертация ===${NC}"
    echo
    
    read -r -p "Путь к папке: " folder_path
    
    if [[ ! -d "$folder_path" ]]; then
        echo -e "${RED}Папка не найдена: $folder_path${NC}"
        return 1
    fi
    
    echo
    echo "Выберите формат вывода:"
    echo "1) FLAC (lossless)"
    echo "2) MP3 V0 VBR"
    echo "3) MP3 320 CBR"
    echo "4) MP3 192 CBR Commercial"
    echo "5) Opus"
    echo
    read -r -p "Формат (1-5): " format_choice
    
    case "$format_choice" in
        1) format="flac" ;;
        2) format="mp3_v0" ;;
        3) format="mp3_320" ;;
        4) format="mp3_commercial" ;;
        5) format="opus" ;;
        *) echo -e "${RED}Неверный выбор${NC}"; return 1 ;;
    esac
    
    echo
    echo "Выберите режим конвертации:"
    echo "1) Создать новые файлы с суффиксами"
    echo "2) Заменить исходные файлы (через временные файлы)" 
    echo
    read -r -p "Режим (1-2): " mode_choice
    
    case "$mode_choice" in
        1) mode="suffix" ;;
        2) mode="replace" ;;
        *) echo -e "${RED}Неверный выбор${NC}"; return 1 ;;
    esac
    
    # Используем продвинутый конвертер
    local advanced_script="$FB2K_CONFIG_DIR/convert_with_external_advanced.sh"
    
    echo
    echo -e "${YELLOW}Поиск аудиофайлов в папке...${NC}"
    
    local count=0
    local converted=0
    local failed=0
    
    # Создаем массив файлов для обработки
    local files=()
    for ext in wav flac mp3 m4a aac; do
        # Безопасный поиск файлов
        set +e
        local find_result
        find_result=$(find "$folder_path" -name "*.$ext" -type f 2>/dev/null)
        set -e
        
        if [[ -n "$find_result" ]]; then
            # Обрабатываем результаты построчно
            while IFS= read -r file; do
                if [[ -f "$file" ]]; then
                    files+=("$file")
                fi
            done <<< "$find_result"
        fi
    done
    
    echo -e "${CYAN}Найдено файлов: ${#files[@]}${NC}"
    
    if [[ ${#files[@]} -eq 0 ]]; then
        echo -e "${YELLOW}Аудиофайлы не найдены${NC}"
        return 1
    fi
    
    # Подтверждение массовой конвертации
    if [[ "$mode" == "replace" ]]; then
        echo -e "${RED}ВНИМАНИЕ: Исходные файлы будут заменены!${NC}"
        read -r -p "Продолжить? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Операция отменена${NC}"
            return 0
        fi
        echo -e "${GREEN}Начинаем массовую конвертацию...${NC}"
    fi
    
    # Обработка каждого файла
    set +e
    for file in "${files[@]}"; do
        ((count++))
        echo
        echo -e "${CYAN}[$count/${#files[@]}] Конвертация: $(basename "$file")${NC}"
        
        if "$advanced_script" "$file" "$format" "$mode" --batch; then
            echo -e "${GREEN}✓ Готово${NC}"
            ((converted++))
        else
            local exit_code=$?
            echo -e "${RED}✗ Ошибка (код: $exit_code)${NC}"
            ((failed++))
        fi
    done
    set -e
    
    echo
    echo -e "${GREEN}=== Результаты массовой конвертации ===${NC}"
    echo -e "Всего файлов: $count"
    echo -e "Успешно: $converted"
    echo -e "Ошибок: $failed"
    echo -e "Подробности в логе: $FB2K_CONFIG_DIR/logs/conversion.log"
}

show_statistics() {
    echo -e "${BLUE}=== Статистика ===${NC}"
    echo
    
    local config_dir="$FB2K_CONFIG_DIR"
    
    echo -e "${CYAN}Конфигурация:${NC}"
    echo "  Папка конфигурации: $config_dir"
    echo "  Скрипт конвертации: $([ -x "$CONVERT_SCRIPT" ] && echo "✓ Доступен" || echo "✗ Не найден")"
    echo "  Мониторинг: $([ -f "$config_dir/foobar_monitor.py" ] && echo "✓ Настроен" || echo "✗ Не настроен")"
    echo
    
    echo -e "${CYAN}Кодировщики:${NC}"
    
    for encoder in flac lame opusenc ffmpeg; do
        if command -v "$encoder" >/dev/null 2>&1; then
            echo "  $encoder: ✓ Установлен ($(which "$encoder"))"
        else
            echo "  $encoder: ✗ Не найден"
        fi
    done
    
    echo
    echo -e "${CYAN}Инструменты анализа:${NC}"
    for tool in mediainfo tag; do
        if command -v "$tool" >/dev/null 2>&1; then
            echo "  $tool: ✓ Установлен"
        else
            echo "  $tool: ✗ Не установлен"
        fi
    done
    
    # Статистика папки импорта
    local import_dir="$HOME/Music/Import"
    if [[ -d "$import_dir" ]]; then
        local file_count=0
        
        # Подсчет файлов по расширениям
        for ext in flac mp3 m4a wav; do
            count_files=$(find "$import_dir" -type f -name "*.$ext" | wc -l)
            file_count=$((file_count + count_files))
        done
        
        echo
        echo -e "${CYAN}Папка импорта:${NC}"
        echo "  Путь: $import_dir"
        echo "  Аудиофайлов: $file_count"
    fi
}

show_help() {
    echo -e "${BLUE}=== Настройки и помощь ===${NC}"
    echo
    
    echo -e "${CYAN}Доступные команды:${NC}"
    echo "  $CONVERT_SCRIPT <файл> <формат>"
    echo "  python3 $FB2K_CONFIG_DIR/foobar_monitor.py"
    echo
    
    echo -e "${CYAN}Форматы конвертации:${NC}"
    echo "  flac    - FLAC lossless (-8 -V)"
    echo "  mp3_v0  - MP3 V0 VBR (~245 kbps)"
    echo "  mp3_320 - MP3 320 CBR"
    echo "  mp3_commercial - MP3 192 CBR Commercial"
    echo "  opus    - Opus 192 kbps"
    echo
    
    echo -e "${CYAN}Системная интеграция:${NC}"
    echo "  Launch Agent: ~/Library/LaunchAgents/com.user.foobar2000.monitor.plist"
    echo "  Services: ~/Library/Services/"
    echo "  AppleScript: $FB2K_CONFIG_DIR/applescript/"
    echo
    
    echo -e "${CYAN}Полезные папки:${NC}"
    echo "  Импорт: ~/Music/Import (автоматически отслеживается)"
    echo "  Конфигурация: $FB2K_CONFIG_DIR"
    echo "  Пресеты: $FB2K_CONFIG_DIR/converter_presets/"
    
    echo
    echo -e "${CYAN}Для Fish shell:${NC}"
    echo "  Этот скрипт адаптирован для совместимости с Fish"
    echo "  Запускайте через: bash $FB2K_CONFIG_DIR/foobar_menu_fish.sh"
}

main() {
    while true; do
        show_header
        show_menu
        
        read -r choice
        echo
        
        case "$choice" in
            1) convert_file ;;
            2) start_monitoring ;;
            3) analyze_quality ;;
            4) add_to_foobar ;;
            5) batch_convert ;;
            6) show_statistics ;;
            7) show_help ;;
            0) echo -e "${GREEN}Выход...${NC}"; exit 0 ;;
            *) echo -e "${RED}Неверный выбор. Попробуйте снова.${NC}" ;;
        esac
        
        echo
        read -r -p "Нажмите Enter для продолжения..."
    done
}

main "$@"