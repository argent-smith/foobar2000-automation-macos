# Fish functions for foobar2000 integration
# Add these functions to ~/.config/fish/config.fish or source this file

function foobar-menu
    bash ~/Library/foobar2000-v2/foobar_menu_fish.sh
end

function foobar-convert
    if test (count $argv) -lt 2
        echo "Usage: foobar-convert <file> <format>"
        echo "Formats: flac, flac_commercial, mp3_v0, mp3_320, mp3_commercial, opus"
        return 1
    end
    
    bash ~/Library/foobar2000-v2/convert_with_external_advanced.sh $argv[1] $argv[2] suffix
end

function foobar-monitor
    echo "Starting monitoring of ~/Music/Import folder"
    echo "Press Ctrl+C to stop"
    bash ~/Library/foobar2000-v2/foobar_monitor.sh
end

function foobar-add
    if test (count $argv) -eq 0
        echo "Usage: foobar-add <path_to_file_or_folder>"
        return 1
    end
    
    osascript -e "tell application \"foobar2000\" to open POSIX file \"$argv[1]\""
end

function foobar-quality
    if test (count $argv) -eq 0
        echo "Usage: foobar-quality <path_to_file>"
        return 1
    end
    
    if not command -v mediainfo >/dev/null
        echo "MediaInfo not installed. Install with: brew install mediainfo"
        return 1
    end
    
    mediainfo --Inform="General;File: %FileName%\nFormat: %Format%\nSize: %FileSize/String4%\nDuration: %Duration/String3%\n\nAudio;Audio format: %Format%\nBitrate: %BitRate/String%\nSample rate: %SamplingRate/String% Hz\nChannels: %Channel(s)%\nBit depth: %BitDepth% bit" $argv[1]
end

function foobar-batch-convert
    if test (count $argv) -lt 2
        echo "Usage: foobar-batch-convert <folder> <format>"
        echo "Formats: flac, flac_commercial, mp3_v0, mp3_320, mp3_commercial, opus"
        return 1
    end
    
    set folder $argv[1]
    set format $argv[2]
    
    if not test -d "$folder"
        echo "Folder not found: $folder"
        return 1
    end
    
    echo "Converting files in folder: $folder"
    echo "Format: $format"
    echo
    
    for ext in wav flac mp3 m4a
        for file in (find "$folder" -name "*.$ext" -type f)
            echo "Converting: "(basename "$file")
            bash ~/Library/foobar2000-v2/convert_with_external_advanced.sh "$file" "$format" suffix
            echo
        end
    end
    
    echo "Batch conversion completed"
end

# Aliases for quick access
alias fb2k-menu='foobar-menu'
alias fb2k-convert='foobar-convert'
alias fb2k-monitor='foobar-monitor'
alias fb2k-add='foobar-add'
alias fb2k-quality='foobar-quality'

echo "foobar2000 Fish functions loaded!"
echo "Available commands:"
echo "  foobar-menu      - Interactive menu"
echo "  foobar-convert   - Convert file"
echo "  foobar-monitor   - Import monitoring"
echo "  foobar-add       - Add to foobar2000"
echo "  foobar-quality   - Quality analysis"
echo "  foobar-batch-convert - Batch conversion"
echo
echo "Aliases: fb2k-menu, fb2k-convert, fb2k-monitor, fb2k-add, fb2k-quality"