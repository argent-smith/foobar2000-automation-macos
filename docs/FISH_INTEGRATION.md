# Fish Shell Integration Guide

Complete guide for Fish shell integration with foobar2000 automation system.

## Overview

Fish shell integration provides an enhanced command-line experience with intelligent completions, interactive functions, and streamlined workflows. While the system works with any POSIX-compliant shell, Fish offers the best user experience.

## Benefits of Fish Integration

### Enhanced User Experience
- **Tab Completion**: Intelligent completion for files, formats, and commands
- **Syntax Highlighting**: Real-time command validation and highlighting
- **Command History**: Persistent, searchable command history
- **Error Feedback**: Clear error messages with suggestions

### Streamlined Workflow
- **One-Command Operations**: Convert files with simple, memorable commands
- **Batch Processing**: Easy folder-based operations
- **Quality Analysis**: Quick audio file inspection
- **System Integration**: Direct foobar2000 control from command line

### Professional Features
- **Function Libraries**: Extensible command framework
- **Alias System**: Short commands for frequent operations
- **Error Handling**: Graceful failure with informative messages
- **Logging Integration**: Automatic operation logging

## Installation and Setup

### 1. Install Fish Shell

```bash
# Install Fish via Homebrew
brew install fish

# Make Fish your default shell (optional)
echo /opt/homebrew/bin/fish | sudo tee -a /etc/shells
chsh -s /opt/homebrew/bin/fish
```

### 2. Load foobar2000 Functions

#### Automatic Loading (Recommended)
```bash
# Add to Fish configuration for automatic loading
echo "source ~/Library/foobar2000-v2/foobar2000_fish_functions.fish" >> ~/.config/fish/config.fish

# Reload Fish configuration
source ~/.config/fish/config.fish
```

#### Manual Loading
```bash
# Load functions for current session only
source ~/Library/foobar2000-v2/foobar2000_fish_functions.fish
```

### 3. Verify Installation
```bash
# Check if functions are loaded
functions | grep foobar

# Test a simple command
foobar-menu --help
```

## Core Functions Reference

### foobar-menu
**Purpose**: Launch the interactive menu system  
**Usage**: `foobar-menu`

```bash
# Launch interactive GUI-style menu
foobar-menu
```

**Features**:
- Color-coded interface
- Step-by-step guidance
- Error recovery
- Progress tracking

### foobar-convert
**Purpose**: Convert single audio files  
**Usage**: `foobar-convert <input_file> <output_format>`

```bash
# Convert WAV to FLAC Commercial
foobar-convert ~/Music/input.wav flac_commercial

# Convert FLAC to MP3 Commercial  
foobar-convert ~/Music/input.flac mp3_commercial

# Convert with tab completion
foobar-convert ~/Music/[TAB]  # Shows available files
foobar-convert ~/Music/input.wav [TAB]  # Shows available formats
```

**Supported Formats**:
- `flac` - Standard FLAC lossless
- `flac_commercial` - Commercial FLAC (44.1kHz, 24-bit)
- `mp3_v0` - MP3 VBR (~245 kbps)
- `mp3_320` - MP3 320 kbps CBR
- `mp3_commercial` - Commercial MP3 (192 kbps, 24-bit)
- `opus` - Opus 192 kbps

### foobar-batch-convert
**Purpose**: Batch convert entire folders  
**Usage**: `foobar-batch-convert <folder_path> <output_format>`

```bash
# Convert entire album folder to FLAC Commercial
foobar-batch-convert ~/Music/AlbumFolder flac_commercial

# Batch convert with progress display
foobar-batch-convert ~/Music/Masters mp3_v0

# Convert multiple folders
for folder in ~/Music/Albums/*
    foobar-batch-convert $folder flac_commercial
end
```

**Features**:
- Recursive file discovery
- Progress indication
- Error handling per file
- Automatic output organization

### foobar-quality  
**Purpose**: Analyze audio file quality with MediaInfo  
**Usage**: `foobar-quality <audio_file>`

```bash
# Analyze single file
foobar-quality ~/Music/test.flac

# Batch quality analysis
for file in ~/Music/*.flac
    echo "Analyzing: "(basename $file)
    foobar-quality $file
end
```

**Output Information**:
- Format and codec details
- Bitrate and sample rate
- Channel configuration
- Quality assessment
- Metadata completeness

### foobar-add
**Purpose**: Add files or folders to foobar2000 library  
**Usage**: `foobar-add <path>`

```bash
# Add single file
foobar-add ~/Music/new_track.flac

# Add entire folder
foobar-add ~/Music/NewAlbum/

# Add multiple items
foobar-add ~/Music/Track1.flac ~/Music/Track2.flac
```

**Requirements**:
- foobar2000 must be running
- AppleScript integration enabled
- Files must be in supported formats

### foobar-monitor
**Purpose**: Start file monitoring for automatic import  
**Usage**: `foobar-monitor`

```bash
# Start monitoring ~/Music/Import folder
foobar-monitor

# Monitor runs in background
# Press Ctrl+C to stop
```

**Features**:
- Real-time file detection
- Automatic format validation
- Import queue management
- Background operation support

## Command Aliases

Short aliases for frequent operations:

```bash
# Short form commands
fb2k-menu          # Same as foobar-menu
fb2k-convert       # Same as foobar-convert  
fb2k-monitor       # Same as foobar-monitor
fb2k-add           # Same as foobar-add
fb2k-quality       # Same as foobar-quality
```

## Advanced Usage Patterns

### Workflow Automation

#### Master-to-Release Pipeline
```bash
#!/usr/bin/env fish

# Process master recordings to multiple release formats
function process-masters
    set master_dir $argv[1]
    set release_dir $argv[2]
    
    # Create release directories
    mkdir -p $release_dir/flac_commercial
    mkdir -p $release_dir/mp3_commercial
    
    # Process each master file
    for master in $master_dir/*.wav
        echo "Processing: "(basename $master)
        
        # Create FLAC Commercial
        foobar-convert $master flac_commercial
        mv (string replace .wav _flac_commercial.flac $master) $release_dir/flac_commercial/
        
        # Create MP3 Commercial  
        foobar-convert $master mp3_commercial
        mv (string replace .wav _mp3_commercial.mp3 $master) $release_dir/mp3_commercial/
    end
    
    echo "Processing complete!"
end

# Usage: process-masters ~/Music/Masters ~/Music/Releases
```

#### Quality Control Pipeline  
```bash
#!/usr/bin/env fish

# Quality control check for audio files
function quality-control
    set input_dir $argv[1]
    set report_file $argv[2]
    
    echo "Quality Control Report" > $report_file
    echo "Generated: "(date) >> $report_file
    echo "" >> $report_file
    
    for file in $input_dir/*.{flac,mp3,wav}
        echo "Analyzing: "(basename $file) >> $report_file
        foobar-quality $file >> $report_file
        echo "---" >> $report_file
    end
    
    echo "Report saved to: $report_file"
end

# Usage: quality-control ~/Music/ToCheck ~/Desktop/quality_report.txt
```

### Interactive Workflows

#### Smart Conversion Function
```bash
function smart-convert
    set input_file $argv[1]
    
    if not test -f $input_file
        echo "Error: File not found: $input_file"
        return 1
    end
    
    # Analyze source file
    echo "Analyzing source file..."
    foobar-quality $input_file
    
    # Interactive format selection
    echo ""
    echo "Select target format:"
    echo "1) FLAC Commercial (lossless, 44.1kHz, 24-bit)"
    echo "2) MP3 Commercial (192kbps, 44.1kHz, 24-bit)"
    echo "3) MP3 V0 (VBR ~245kbps)"
    echo "4) Opus (192kbps)"
    
    read -P "Choice (1-4): " choice
    
    switch $choice
        case 1
            set format flac_commercial
        case 2  
            set format mp3_commercial
        case 3
            set format mp3_v0
        case 4
            set format opus
        case '*'
            echo "Invalid choice"
            return 1
    end
    
    echo "Converting to $format..."
    foobar-convert $input_file $format
end
```

## Tab Completion Setup

### Custom Completions
Create enhanced tab completions for better workflow:

```bash
# Create completions directory
mkdir -p ~/.config/fish/completions

# Create foobar2000 completions file
cat > ~/.config/fish/completions/foobar-convert.fish << 'EOF'
# Tab completions for foobar-convert

# Complete input files (audio files only)
complete -c foobar-convert -n '__fish_use_subcommand' -a '(__fish_complete_suffix .wav .flac .mp3 .m4a .aac)'

# Complete output formats
complete -c foobar-convert -n '__fish_seen_subcommand_from *' -a 'flac flac_commercial mp3_v0 mp3_320 mp3_commercial opus'

# Add descriptions for formats
complete -c foobar-convert -n '__fish_seen_subcommand_from *' -a 'flac' -d 'FLAC lossless (-8 compression)'
complete -c foobar-convert -n '__fish_seen_subcommand_from *' -a 'flac_commercial' -d 'FLAC Commercial (44.1kHz, 24-bit)'
complete -c foobar-convert -n '__fish_seen_subcommand_from *' -a 'mp3_v0' -d 'MP3 VBR (~245 kbps)'
complete -c foobar-convert -n '__fish_seen_subcommand_from *' -a 'mp3_320' -d 'MP3 320 kbps CBR'
complete -c foobar-convert -n '__fish_seen_subcommand_from *' -a 'mp3_commercial' -d 'MP3 Commercial (192 kbps)'
complete -c foobar-convert -n '__fish_seen_subcommand_from *' -a 'opus' -d 'Opus 192 kbps'
EOF
```

### Directory-Based Completions
```bash
# Complete directories for batch operations
complete -c foobar-batch-convert -n '__fish_use_subcommand' -a '(__fish_complete_directories)'
```

## Fish-Specific Enhancements

### Function Introspection
```bash
# List all foobar functions
functions | grep foobar

# Show function definition
functions foobar-convert

# Get function help
foobar-convert --help
```

### History Integration
```bash
# Search command history
history | grep foobar-convert

# Re-run last foobar command
history | grep foobar | tail -1 | fish
```

### Variable Integration
```bash
# Set default output format
set -x FOOBAR_DEFAULT_FORMAT flac_commercial

# Set default batch directory
set -x FOOBAR_BATCH_DIR ~/Music/ToProcess

# Use variables in functions
foobar-batch-convert $FOOBAR_BATCH_DIR $FOOBAR_DEFAULT_FORMAT
```

## Error Handling and Debugging

### Fish-Specific Error Handling
```bash
# Function with comprehensive error handling
function safe-convert
    set input_file $argv[1]
    set output_format $argv[2]
    
    # Validate input
    if not test -f $input_file
        echo "Error: Input file not found: $input_file" >&2
        return 1
    end
    
    # Validate format
    if not contains $output_format flac flac_commercial mp3_v0 mp3_320 mp3_commercial opus
        echo "Error: Unsupported format: $output_format" >&2
        echo "Supported formats: flac, flac_commercial, mp3_v0, mp3_320, mp3_commercial, opus"
        return 1
    end
    
    # Perform conversion with error checking
    if foobar-convert $input_file $output_format
        echo "Successfully converted $input_file to $output_format"
        return 0
    else
        echo "Error: Conversion failed for $input_file" >&2
        return 1
    end
end
```

### Debug Mode
```bash
# Enable debug output
set -x DEBUG 1
foobar-convert input.wav flac

# Disable debug
set -e DEBUG
```

## Integration with Other Tools

### Integration with Finder
```bash
# Convert files dropped from Finder
function convert-dropped-files
    for file in $argv
        echo "Converting: "(basename $file)
        foobar-convert $file flac_commercial
    end
end
```

### Integration with Terminal Multiplexers
```bash
# tmux session for batch processing
function start-conversion-session
    tmux new-session -d -s conversion
    tmux send-keys -t conversion 'foobar-monitor' C-m
    tmux split-window -t conversion
    tmux send-keys -t conversion 'foobar-menu' C-m
    tmux attach-session -t conversion
end
```

## Performance Optimization

### Parallel Processing with Fish
```bash
# Parallel batch conversion
function parallel-convert
    set input_dir $argv[1]
    set output_format $argv[2]
    set max_jobs $argv[3]
    
    if test -z $max_jobs
        set max_jobs (nproc)
    end
    
    # Create job queue
    set files (find $input_dir -name "*.wav" -o -name "*.flac")
    
    # Process files in parallel
    for file in $files
        while test (jobs | wc -l) -ge $max_jobs
            sleep 0.1
        end
        
        # Start conversion in background
        fish -c "foobar-convert '$file' '$output_format'" &
    end
    
    # Wait for all jobs to complete
    wait
    echo "Parallel conversion complete!"
end
```

## Troubleshooting Fish Integration

### Common Issues and Solutions

#### Functions Not Loading
```bash
# Check if functions file exists
test -f ~/Library/foobar2000-v2/foobar2000_fish_functions.fish
echo $status  # Should be 0

# Manually load functions
source ~/Library/foobar2000-v2/foobar2000_fish_functions.fish

# Check Fish configuration
cat ~/.config/fish/config.fish | grep foobar
```

#### Tab Completion Not Working
```bash
# Reload completions
complete -e foobar-convert
source ~/.config/fish/completions/foobar-convert.fish

# Check completion status
complete -C foobar-convert
```

#### Path Issues
```bash
# Check Fish PATH
echo $PATH | tr : \n | grep -E "(homebrew|local)"

# Add Homebrew paths if missing
fish_add_path /opt/homebrew/bin    # Apple Silicon
fish_add_path /usr/local/bin       # Intel
```

### Performance Issues
```bash
# Profile function execution
time foobar-convert input.wav flac

# Check system resources
top -pid (pgrep fish)
```

## Custom Function Development

### Template for New Functions
```bash
function foobar-custom
    # Function description and usage
    if contains -- $argv[1] -h --help
        echo "Usage: foobar-custom [options] <arguments>"
        echo "Description: Custom foobar2000 function"
        return 0
    end
    
    # Argument validation
    if test (count $argv) -lt 1
        echo "Error: Insufficient arguments"
        return 1
    end
    
    # Main function logic
    set input_arg $argv[1]
    
    # Error handling
    if not some_validation_check $input_arg
        echo "Error: Validation failed" >&2
        return 1
    end
    
    # Success
    echo "Custom function completed successfully"
    return 0
end
```

### Function Library Extension
Add your custom functions to the main library:

```bash
# Edit the functions file
nano ~/Library/foobar2000-v2/foobar2000_fish_functions.fish

# Or create separate custom functions file
echo "source ~/Library/foobar2000-v2/custom_functions.fish" >> ~/.config/fish/config.fish
```

Fish shell integration transforms the foobar2000 automation system into a powerful, user-friendly audio processing environment suitable for both casual users and professional workflows.