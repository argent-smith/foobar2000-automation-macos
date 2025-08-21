# Usage Examples and Workflows

Practical examples and real-world workflows for the foobar2000 automation system.

## Basic Usage Examples

### Single File Conversion

#### Convert WAV to FLAC Commercial
```bash
# Basic conversion with suffix
./scripts/convert_with_external_advanced.sh ~/Music/master.wav flac_commercial suffix

# Result: ~/Music/master_flac_commercial.flac
```

#### Replace Original File
```bash
# Convert and replace original (creates backup)
./scripts/convert_with_external_advanced.sh ~/Music/source.wav mp3_commercial replace

# Original file is backed up as source.wav.backup_TIMESTAMP
# New file replaces original: source.mp3
```

#### Interactive Mode
```bash
# Let user choose options interactively
./scripts/convert_with_external_advanced.sh ~/Music/audio.wav flac interactive

# Script will prompt for:
# - Output filename
# - Overwrite confirmation
# - Quality settings
```

### Fish Shell Functions

#### Quick Conversion
```bash
# Using Fish functions (after loading functions)
foobar-convert ~/Music/track.wav flac_commercial

# Short alias version
fb2k-convert ~/Music/track.wav mp3_v0
```

#### Quality Analysis
```bash
# Analyze audio file quality
foobar-quality ~/Music/test.flac

# Output includes:
# - Format details
# - Bitrate and sample rate  
# - Quality assessment
# - Metadata information
```

## Professional Workflows

### Digital Release Preparation

#### Master-to-Release Pipeline
```bash
#!/bin/bash
# Complete digital release workflow

MASTER_DIR="~/Music/Masters/AlbumName"
RELEASE_DIR="~/Music/Releases/AlbumName"

# Create release directory structure
mkdir -p "$RELEASE_DIR"/{flac_commercial,mp3_commercial,mp3_320}

echo "Processing masters for digital release..."

# Process each master file
for master_file in "$MASTER_DIR"/*.wav; do
    filename=$(basename "$master_file" .wav)
    echo "Processing: $filename"
    
    # Create FLAC Commercial (lossless digital release)
    ./scripts/convert_with_external_advanced.sh "$master_file" flac_commercial suffix --batch
    mv "${master_file%.*}_flac_commercial.flac" "$RELEASE_DIR/flac_commercial/"
    
    # Create MP3 Commercial (standard digital release)  
    ./scripts/convert_with_external_advanced.sh "$master_file" mp3_commercial suffix --batch
    mv "${master_file%.*}_mp3_commercial.mp3" "$RELEASE_DIR/mp3_commercial/"
    
    # Create MP3 320 (high-quality distribution)
    ./scripts/convert_with_external_advanced.sh "$master_file" mp3_320 suffix --batch
    mv "${master_file%.*}_mp3_320.mp3" "$RELEASE_DIR/mp3_320/"
    
    echo "✓ Completed: $filename"
done

echo "Digital release preparation complete!"
echo "Files created in: $RELEASE_DIR"
```

#### Quality Control Workflow
```bash
#!/bin/bash
# Quality control and validation workflow

RELEASE_DIR="~/Music/Releases/AlbumName"
QC_REPORT="~/Desktop/QC_Report_$(date +%Y%m%d).txt"

echo "QUALITY CONTROL REPORT" > "$QC_REPORT"
echo "Generated: $(date)" >> "$QC_REPORT"
echo "Album: AlbumName" >> "$QC_REPORT"
echo "================================" >> "$QC_REPORT"
echo "" >> "$QC_REPORT"

# Check each format
for format_dir in "$RELEASE_DIR"/*; do
    format_name=$(basename "$format_dir")
    echo "=== $format_name ===" >> "$QC_REPORT"
    
    for file in "$format_dir"/*; do
        echo "File: $(basename "$file")" >> "$QC_REPORT"
        
        # Quality analysis
        foobar-quality "$file" >> "$QC_REPORT"
        
        # File size check
        size=$(du -h "$file" | cut -f1)
        echo "Size: $size" >> "$QC_REPORT"
        echo "---" >> "$QC_REPORT"
    done
    echo "" >> "$QC_REPORT"
done

echo "Quality control report saved to: $QC_REPORT"
open "$QC_REPORT"
```

### Batch Processing Workflows

#### Folder-Based Batch Conversion
```bash
# Convert entire music library to multiple formats
#!/bin/bash

LIBRARY_ROOT="~/Music/Library"
OUTPUT_ROOT="~/Music/Converted"

# Create output directories
mkdir -p "$OUTPUT_ROOT"/{flac,mp3_v0,opus}

echo "Starting library conversion..."

# Find all FLAC files and convert to lossy formats
find "$LIBRARY_ROOT" -name "*.flac" -type f | while read -r flac_file; do
    # Preserve directory structure
    relative_path=$(realpath --relative-to="$LIBRARY_ROOT" "$flac_file")
    output_dir=$(dirname "$relative_path")
    filename=$(basename "$flac_file" .flac)
    
    # Create output directories
    mkdir -p "$OUTPUT_ROOT/mp3_v0/$output_dir"
    mkdir -p "$OUTPUT_ROOT/opus/$output_dir"
    
    echo "Converting: $relative_path"
    
    # Convert to MP3 V0
    ./scripts/convert_with_external_advanced.sh "$flac_file" mp3_v0 suffix --batch
    mv "${flac_file%.*}_mp3_v0.mp3" "$OUTPUT_ROOT/mp3_v0/$output_dir/$filename.mp3"
    
    # Convert to Opus
    ./scripts/convert_with_external_advanced.sh "$flac_file" opus suffix --batch
    mv "${flac_file%.*}_opus.opus" "$OUTPUT_ROOT/opus/$output_dir/$filename.opus"
done

echo "Library conversion complete!"
```

#### Parallel Batch Processing
```bash
#!/bin/bash
# Parallel processing for faster batch operations

MAX_JOBS=4  # Adjust based on CPU cores
PIDS=()

process_file() {
    local input_file="$1"
    local output_format="$2"
    
    echo "Processing: $(basename "$input_file")"
    ./scripts/convert_with_external_advanced.sh "$input_file" "$output_format" suffix --batch
    echo "✓ Completed: $(basename "$input_file")"
}

# Export function for parallel execution
export -f process_file

# Find files and process in parallel
find ~/Music/ToConvert -name "*.wav" -type f | \
    xargs -n 1 -P "$MAX_JOBS" -I {} bash -c 'process_file "{}" flac_commercial'

echo "Parallel processing complete!"
```

## Advanced Integration Examples

### Automated Import Workflow

#### Watch Folder with Processing
```bash
#!/bin/bash
# Automated import and processing system

WATCH_DIR="~/Music/Import"
ARCHIVE_DIR="~/Music/Archive" 
CONVERTED_DIR="~/Music/Converted"

# Create directories
mkdir -p "$WATCH_DIR" "$ARCHIVE_DIR" "$CONVERTED_DIR"

# File processing function
process_new_file() {
    local file_path="$1"
    local filename=$(basename "$file_path")
    local extension="${filename##*.}"
    
    echo "New file detected: $filename"
    
    # Validate audio file
    if [[ "$extension" =~ ^(wav|flac|aiff)$ ]]; then
        echo "Processing audio file: $filename"
        
        # Convert to multiple formats
        ./scripts/convert_with_external_advanced.sh "$file_path" flac_commercial suffix --batch
        ./scripts/convert_with_external_advanced.sh "$file_path" mp3_v0 suffix --batch
        
        # Move converted files
        mv "${file_path%.*}_flac_commercial.flac" "$CONVERTED_DIR/"
        mv "${file_path%.*}_mp3_v0.mp3" "$CONVERTED_DIR/"
        
        # Archive original
        mv "$file_path" "$ARCHIVE_DIR/"
        
        echo "✓ Processing complete: $filename"
    else
        echo "⚠ Skipping non-audio file: $filename"
    fi
}

# Monitor directory using fswatch
if command -v fswatch >/dev/null; then
    echo "Starting file monitoring with fswatch..."
    fswatch -o "$WATCH_DIR" | while read path; do
        for file in "$WATCH_DIR"/*; do
            if [[ -f "$file" ]]; then
                process_new_file "$file"
            fi
        done
    done
else
    echo "Starting file monitoring with polling..."
    while true; do
        for file in "$WATCH_DIR"/*; do
            if [[ -f "$file" ]]; then
                process_new_file "$file"
            fi
        done
        sleep 5
    done
fi
```

### Integration with External Tools

#### Integration with Metadata Editors
```bash
#!/bin/bash
# Workflow with external metadata editing

PROCESSING_DIR="~/Music/Processing"

# Function to process with metadata enhancement
process_with_metadata() {
    local input_file="$1"
    local temp_file="${input_file%.*}_temp.${input_file##*.}"
    
    echo "Processing: $(basename "$input_file")"
    
    # Enhance metadata using external tools
    if command -v mid3v2 >/dev/null; then
        # Add ReplayGain tags
        mp3gain -r -k "$input_file"
        
        # Add custom metadata
        mid3v2 --TPE2 "Various Artists" \
               --TPOS "1/1" \
               --id3v2-only \
               "$input_file"
    fi
    
    # Convert with preserved enhanced metadata
    ./scripts/convert_with_external_advanced.sh "$input_file" flac_commercial suffix --batch
    
    echo "✓ Enhanced and converted: $(basename "$input_file")"
}

# Process all files in directory
for file in "$PROCESSING_DIR"/*.mp3; do
    if [[ -f "$file" ]]; then
        process_with_metadata "$file"
    fi
done
```

#### Integration with Audio Analysis Tools
```bash
#!/bin/bash
# Advanced audio analysis workflow

analyze_and_convert() {
    local input_file="$1"
    local analysis_report="${input_file%.*}_analysis.txt"
    
    echo "Analyzing: $(basename "$input_file")"
    
    # Comprehensive analysis
    {
        echo "=== AUDIO ANALYSIS REPORT ==="
        echo "File: $input_file"
        echo "Date: $(date)"
        echo ""
        
        # Basic MediaInfo analysis
        echo "=== MediaInfo Analysis ==="
        mediainfo "$input_file"
        echo ""
        
        # Spectral analysis with SoX (if available)
        if command -v sox >/dev/null; then
            echo "=== Spectral Analysis ==="
            sox "$input_file" -n spectrogram -o "${input_file%.*}_spectrum.png"
            echo "Spectrogram saved: ${input_file%.*}_spectrum.png"
            echo ""
        fi
        
        # Dynamic range analysis
        if command -v ffmpeg >/dev/null; then
            echo "=== Dynamic Range Analysis ==="
            ffmpeg -i "$input_file" -af "dynaudnorm=print_stats=1" -f null - 2>&1 | \
                grep -E "(max|mean|std)"
            echo ""
        fi
        
    } > "$analysis_report"
    
    # Decision-based conversion
    local sample_rate=$(mediainfo --Inform="Audio;%SamplingRate%" "$input_file")
    local bit_depth=$(mediainfo --Inform="Audio;%BitDepth%" "$input_file")
    
    if [[ "$sample_rate" -gt 48000 ]] || [[ "$bit_depth" -gt 16 ]]; then
        echo "High-res source detected - converting to FLAC Commercial"
        ./scripts/convert_with_external_advanced.sh "$input_file" flac_commercial suffix --batch
    else
        echo "Standard resolution - converting to MP3 V0"
        ./scripts/convert_with_external_advanced.sh "$input_file" mp3_v0 suffix --batch
    fi
    
    echo "✓ Analysis and conversion complete"
    echo "Report saved: $analysis_report"
}

# Process files with analysis
for file in ~/Music/ToAnalyze/*.{wav,flac}; do
    if [[ -f "$file" ]]; then
        analyze_and_convert "$file"
    fi
done
```

## Specialized Use Cases

### Podcast Production Workflow
```bash
#!/bin/bash
# Podcast production and distribution workflow

RECORDING_DIR="~/Podcasts/Recordings"
PRODUCTION_DIR="~/Podcasts/Production"
DISTRIBUTION_DIR="~/Podcasts/Distribution"

process_podcast_episode() {
    local raw_file="$1"
    local episode_name=$(basename "$raw_file" .wav)
    
    echo "Processing podcast episode: $episode_name"
    
    # Create episode directory
    mkdir -p "$PRODUCTION_DIR/$episode_name"
    mkdir -p "$DISTRIBUTION_DIR/$episode_name"
    
    # High-quality archive (FLAC)
    ./scripts/convert_with_external_advanced.sh "$raw_file" flac suffix --batch
    mv "${raw_file%.*}_flac.flac" "$PRODUCTION_DIR/$episode_name/${episode_name}_archive.flac"
    
    # Distribution formats
    ./scripts/convert_with_external_advanced.sh "$raw_file" mp3_320 suffix --batch
    mv "${raw_file%.*}_mp3_320.mp3" "$DISTRIBUTION_DIR/$episode_name/${episode_name}_high.mp3"
    
    ./scripts/convert_with_external_advanced.sh "$raw_file" mp3_commercial suffix --batch  
    mv "${raw_file%.*}_mp3_commercial.mp3" "$DISTRIBUTION_DIR/$episode_name/${episode_name}_standard.mp3"
    
    ./scripts/convert_with_external_advanced.sh "$raw_file" opus suffix --batch
    mv "${raw_file%.*}_opus.opus" "$DISTRIBUTION_DIR/$episode_name/${episode_name}_web.opus"
    
    echo "✓ Podcast episode ready: $episode_name"
}

# Process all recorded episodes
for recording in "$RECORDING_DIR"/*.wav; do
    if [[ -f "$recording" ]]; then
        process_podcast_episode "$recording"
    fi
done
```

### Live Recording Archive System
```bash
#!/bin/bash
# Live recording archival and distribution system

LIVE_RECORDING_DIR="~/Music/Live"
ARCHIVE_DIR="~/Music/Archive/Live"
DISTRIBUTION_DIR="~/Music/Distribution/Live"

process_live_recording() {
    local recording_file="$1"
    local recording_name=$(basename "$recording_file" .wav)
    local date_stamp=$(date +%Y%m%d)
    
    echo "Processing live recording: $recording_name"
    
    # Create organized directory structure
    mkdir -p "$ARCHIVE_DIR/$date_stamp"
    mkdir -p "$DISTRIBUTION_DIR/$date_stamp"
    
    # Archive master (FLAC lossless)
    echo "Creating archive master..."
    ./scripts/convert_with_external_advanced.sh "$recording_file" flac suffix --batch
    mv "${recording_file%.*}_flac.flac" "$ARCHIVE_DIR/$date_stamp/${recording_name}_master.flac"
    
    # Commercial distribution formats
    echo "Creating distribution formats..."
    
    # FLAC Commercial (44.1kHz, 24-bit)
    ./scripts/convert_with_external_advanced.sh "$recording_file" flac_commercial suffix --batch
    mv "${recording_file%.*}_flac_commercial.flac" "$DISTRIBUTION_DIR/$date_stamp/${recording_name}_commercial.flac"
    
    # MP3 V0 (high quality lossy)
    ./scripts/convert_with_external_advanced.sh "$recording_file" mp3_v0 suffix --batch
    mv "${recording_file%.*}_mp3_v0.mp3" "$DISTRIBUTION_DIR/$date_stamp/${recording_name}_hq.mp3"
    
    # Create listening notes
    {
        echo "Live Recording: $recording_name"
        echo "Date: $date_stamp"  
        echo "Processed: $(date)"
        echo ""
        echo "Files created:"
        echo "- Archive Master: ${recording_name}_master.flac"
        echo "- Commercial FLAC: ${recording_name}_commercial.flac"
        echo "- High Quality MP3: ${recording_name}_hq.mp3"
        echo ""
        echo "Quality Analysis:"
        foobar-quality "$ARCHIVE_DIR/$date_stamp/${recording_name}_master.flac"
    } > "$DISTRIBUTION_DIR/$date_stamp/${recording_name}_notes.txt"
    
    echo "✓ Live recording archived: $recording_name"
}

# Process all live recordings
for recording in "$LIVE_RECORDING_DIR"/*.wav; do
    if [[ -f "$recording" ]]; then
        process_live_recording "$recording"
    fi
done
```

## Fish Shell Advanced Workflows

### Interactive Batch Selection
```fish
#!/usr/bin/env fish

# Interactive batch conversion with format selection
function interactive-batch-convert
    set source_dir $argv[1]
    
    if not test -d $source_dir
        echo "Error: Directory not found: $source_dir"
        return 1
    end
    
    # Find audio files
    set audio_files (find $source_dir -name "*.wav" -o -name "*.flac" -o -name "*.aiff")
    
    if test (count $audio_files) -eq 0
        echo "No audio files found in $source_dir"
        return 1
    end
    
    echo "Found "(count $audio_files)" audio files"
    
    # Format selection
    echo ""
    echo "Select output format:"
    echo "1) FLAC Commercial (44.1kHz, 24-bit)"
    echo "2) MP3 V0 (VBR ~245kbps)"  
    echo "3) MP3 Commercial (192kbps, 24-bit)"
    echo "4) Opus (192kbps)"
    
    read -P "Choice (1-4): " format_choice
    
    switch $format_choice
        case 1
            set format flac_commercial
        case 2
            set format mp3_v0
        case 3
            set format mp3_commercial
        case 4
            set format opus
        case '*'
            echo "Invalid choice"
            return 1
    end
    
    # Process files with progress
    set count 1
    for file in $audio_files
        echo "[$count/"(count $audio_files)"] Converting: "(basename $file)
        foobar-convert $file $format
        set count (math $count + 1)
    end
    
    echo "✓ Batch conversion complete!"
end

# Usage: interactive-batch-convert ~/Music/ToConvert
```

### Smart Format Selection
```fish  
#!/usr/bin/env fish

# Intelligent format selection based on source analysis
function smart-convert
    set input_file $argv[1]
    
    if not test -f $input_file
        echo "Error: File not found: $input_file"
        return 1
    end
    
    # Analyze source file
    set sample_rate (mediainfo --Inform="Audio;%SamplingRate%" $input_file)
    set bit_depth (mediainfo --Inform="Audio;%BitDepth%" $input_file)
    set format (mediainfo --Inform="Audio;%Format%" $input_file)
    
    echo "Source analysis:"
    echo "  Format: $format"
    echo "  Sample Rate: $sample_rate Hz"
    echo "  Bit Depth: $bit_depth bit"
    echo ""
    
    # Smart format selection
    if test $sample_rate -gt 48000; or test $bit_depth -gt 16
        echo "High-resolution source detected"
        echo "Recommended: FLAC Commercial (preserves quality)"
        set recommended_format flac_commercial
    else if string match -q "*FLAC*" $format
        echo "Lossless source detected"
        echo "Recommended: MP3 V0 (efficient conversion)"
        set recommended_format mp3_v0
    else
        echo "Lossy source detected"  
        echo "Recommended: FLAC (archival quality)"
        set recommended_format flac
    end
    
    # User confirmation
    read -P "Use recommended format ($recommended_format)? [Y/n]: " confirm
    
    if test "$confirm" = "n"; or test "$confirm" = "N"
        echo "Available formats:"
        echo "  flac, flac_commercial, mp3_v0, mp3_320, mp3_commercial, opus"
        read -P "Enter format: " recommended_format
    end
    
    echo "Converting to $recommended_format..."
    foobar-convert $input_file $recommended_format
end

# Usage: smart-convert ~/Music/input.wav
```

These examples demonstrate the flexibility and power of the foobar2000 automation system for various professional and personal audio workflows. The system can be easily adapted for specific requirements and integrated with external tools for enhanced functionality.