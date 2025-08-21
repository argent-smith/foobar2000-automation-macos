# Fish functions for foobar2000 integration
# Добавьте эти функции в ~/.config/fish/config.fish или выполните source этого файла

function foobar-menu
    bash ~/Library/foobar2000-v2/foobar_menu_fish.sh
end

function foobar-convert
    if test (count $argv) -lt 2
        echo "Использование: foobar-convert <файл> <формат>"
        echo "Форматы: flac, mp3_v0, mp3_320, opus"
        return 1
    end
    
    bash ~/Library/foobar2000-v2/convert_with_external.sh $argv[1] $argv[2]
end

function foobar-monitor
    echo "Запуск мониторинга папки ~/Music/Import"
    echo "Нажмите Ctrl+C для остановки"
    python3 ~/Library/foobar2000-v2/foobar_monitor.py
end

function foobar-add
    if test (count $argv) -eq 0
        echo "Использование: foobar-add <путь_к_файлу_или_папке>"
        return 1
    end
    
    osascript -e "tell application \"foobar2000\" to open POSIX file \"$argv[1]\""
end

function foobar-quality
    if test (count $argv) -eq 0
        echo "Использование: foobar-quality <путь_к_файлу>"
        return 1
    end
    
    if not command -v mediainfo >/dev/null
        echo "MediaInfo не установлен. Установите: brew install mediainfo"
        return 1
    end
    
    mediainfo --Inform="General;Файл: %FileName%\nФормат: %Format%\nРазмер: %FileSize/String4%\nДлительность: %Duration/String3%\n\nAudio;Аудио формат: %Format%\nБитрейт: %BitRate/String%\nЧастота: %SamplingRate/String% Hz\nКаналов: %Channel(s)%\nБиты: %BitDepth% bit" $argv[1]
end

function foobar-batch-convert
    if test (count $argv) -lt 2
        echo "Использование: foobar-batch-convert <папка> <формат>"
        echo "Форматы: flac, mp3_v0, mp3_320, opus"
        return 1
    end
    
    set folder $argv[1]
    set format $argv[2]
    
    if not test -d "$folder"
        echo "Папка не найдена: $folder"
        return 1
    end
    
    echo "Конвертация файлов в папке: $folder"
    echo "Формат: $format"
    echo
    
    for ext in wav flac mp3 m4a
        for file in (find "$folder" -name "*.$ext" -type f)
            echo "Конвертация: "(basename "$file")
            bash ~/Library/foobar2000-v2/convert_with_external.sh "$file" "$format"
            echo
        end
    end
    
    echo "Массовая конвертация завершена"
end

# Алиасы для быстрого доступа
alias fb2k-menu='foobar-menu'
alias fb2k-convert='foobar-convert'
alias fb2k-monitor='foobar-monitor'
alias fb2k-add='foobar-add'
alias fb2k-quality='foobar-quality'

echo "foobar2000 Fish functions загружены!"
echo "Доступные команды:"
echo "  foobar-menu      - Интерактивное меню"
echo "  foobar-convert   - Конвертация файла"
echo "  foobar-monitor   - Мониторинг импорта"
echo "  foobar-add       - Добавить в foobar2000"
echo "  foobar-quality   - Анализ качества"
echo "  foobar-batch-convert - Массовая конвертация"
echo
echo "Алиасы: fb2k-menu, fb2k-convert, fb2k-monitor, fb2k-add, fb2k-quality"