# Script Reference Documentation

Complete reference for all automation scripts and their usage.

## Core Scripts Overview

The system consists of several specialized scripts that work together to provide comprehensive foobar2000 automation:

| Script | Purpose | User Level | Priority |
|--------|---------|------------|----------|
| `install.sh` | Main installation orchestrator | All | Critical |
| `update_system.sh` | System updates and synchronization | All | High |
| `convert_with_external_advanced.sh` | Advanced audio conversion | All | Critical |
| `foobar_menu_fish.sh` | Interactive menu system | Beginner | High |
| `foobar2000_fish_functions.fish` | Shell function library | Intermediate | Medium |
| `components-downloader.sh` | Package manager for encoders | Advanced | Medium |
| `config-generator.sh` | Configuration file generator | Advanced | Medium |
| `validator.sh` | System validation and testing | All | High |

## Installation Scripts

### install.sh

**Purpose**: Main installation orchestrator with profile-based setup  
**Location**: `scripts/install.sh`  
**User Level**: All users

#### Usage
```bash
./scripts/install.sh [OPTIONS]
```

#### Options
| Option | Description | Default |
|--------|-------------|---------|
| `--mode <mode>` | Installation mode: `interactive` or `automatic` | `interactive` |
| `--profile <profile>` | Configuration profile: `minimal`, `standard`, `professional`, `custom` | Prompt |
| `--backup` | Create backup before installation | false |
| `--force` | Force reinstallation over existing setup | false |
| `--dry-run` | Show what would be installed without doing it | false |
| `--help` | Show help message | - |

#### Examples
```bash
# Interactive installation (recommended for first-time users)
./scripts/install.sh --mode interactive

# Automatic professional installation with backup
./scripts/install.sh --profile professional --mode automatic --backup

# Dry run to see what would be installed
./scripts/install.sh --profile standard --dry-run

# Force complete reinstallation
./scripts/install.sh --profile professional --force --backup
```

#### Exit Codes
- `0`: Success
- `1`: General error
- `2`: Missing dependencies
- `3`: User cancellation
- `4`: Validation failure

### update_system.sh

**Purpose**: Updates installed system files from repository  
**Location**: `scripts/update_system.sh`  
**User Level**: All users

#### Usage
```bash
./scripts/update_system.sh [OPTIONS]
```

#### Options
| Option | Description |
|--------|-------------|
| `--dry-run` | Show what would be updated |
| `--backup` | Create backup before update |
| `--force` | Force update even if system files are newer |
| `--help` | Show help message |

#### Examples
```bash
# Safe update with backup
./scripts/update_system.sh --backup

# Preview updates without applying
./scripts/update_system.sh --dry-run

# Force complete update
./scripts/update_system.sh --force --backup
```

## Audio Conversion Scripts

### convert_with_external_advanced.sh

**Purpose**: Advanced audio conversion with multiple modes and comprehensive error handling  
**Location**: `scripts/convert_with_external_advanced.sh`  
**User Level**: All users

#### Usage
```bash
./scripts/convert_with_external_advanced.sh <input_file> <output_format> [mode] [suffix] [--batch]
```

#### Parameters
| Parameter | Description | Required |
|-----------|-------------|----------|
| `input_file` | Path to source audio file | Yes |
| `output_format` | Target format profile | Yes |
| `mode` | Conversion mode | No (default: `suffix`) |
| `suffix` | Custom suffix for output file | No |
| `--batch` | Enable batch mode (non-interactive) | No |

#### Supported Output Formats
- `flac` - Standard FLAC lossless
- `flac_commercial` - Commercial FLAC (44.1kHz, 24-bit)
- `mp3_v0` - MP3 Variable Bitrate (~245 kbps)
- `mp3_320` - MP3 320 kbps CBR
- `mp3_commercial` - Commercial MP3 (44.1kHz, 24-bit, 192 kbps)
- `opus` - Opus 192 kbps

#### Conversion Modes
- `suffix` - Create new file with format suffix
- `replace` - Replace original file (with backup)
- `interactive` - Prompt for each decision

#### Examples
```bash
# Convert WAV to FLAC Commercial with suffix
./scripts/convert_with_external_advanced.sh input.wav flac_commercial suffix

# Replace original with MP3 Commercial version
./scripts/convert_with_external_advanced.sh input.flac mp3_commercial replace

# Batch mode conversion (non-interactive)
./scripts/convert_with_external_advanced.sh input.wav opus suffix --batch

# Interactive mode with user prompts
./scripts/convert_with_external_advanced.sh input.wav mp3_320 interactive
```

#### Advanced Usage
```bash
# Custom suffix
./scripts/convert_with_external_advanced.sh input.wav flac suffix _master

# Multiple files with shell expansion
for file in *.wav; do
    ./scripts/convert_with_external_advanced.sh "$file" flac_commercial suffix
done

# With error handling
./scripts/convert_with_external_advanced.sh input.wav mp3_v0 suffix || echo "Conversion failed"
```

#### Logging
All conversions are logged to:
- `~/Library/foobar2000-v2/logs/conversion.log`

Log levels:
- `INFO`: General information
- `SUCCESS`: Successful operations
- `WARNING`: Non-critical issues
- `ERROR`: Failure conditions

## Interactive Menu System

### foobar_menu_fish.sh

**Purpose**: GUI-style interactive menu for all operations  
**Location**: `scripts/foobar_menu_fish.sh`  
**User Level**: Beginner to Intermediate

#### Usage
```bash
bash ~/Library/foobar2000-v2/foobar_menu_fish.sh
```

#### Menu Options
1. **Convert audio file** - Single file conversion with format selection
2. **Start import monitoring** - Automatic file monitoring for ~/Music/Import
3. **Analyze file quality** - MediaInfo-based quality analysis
4. **Add file to foobar2000** - Direct import via AppleScript
5. **Batch convert folder** - Mass conversion with progress tracking
6. **Show statistics** - System status and encoder availability
7. **Settings and help** - Configuration information and help

#### Features
- **Color-coded output** for better readability
- **Progress tracking** for batch operations
- **Error recovery** with detailed feedback
- **Format validation** before processing
- **Backup confirmation** for destructive operations

#### Examples
```bash
# Launch interactive menu
bash ~/Library/foobar2000-v2/foobar_menu_fish.sh

# Direct menu access via Fish function (if loaded)
foobar-menu
```

## Configuration and Management Scripts

### components-downloader.sh

**Purpose**: Homebrew package manager for audio encoders  
**Location**: `scripts/components-downloader.sh`  
**User Level**: Advanced

#### Usage
```bash
./scripts/components-downloader.sh [OPTIONS]
```

#### Options
| Option | Description |
|--------|-------------|
| `-c <components>` | Comma-separated list of components to install |
| `--list` | Show all available components |
| `--update` | Update existing components |
| `--remove <components>` | Remove specified components |
| `--verify` | Verify installation of components |

#### Available Components
- `flac` - FLAC encoder/decoder
- `lame` - MP3 encoder
- `opus-tools` - Opus encoder/decoder
- `ffmpeg` - Universal media converter
- `mediainfo` - Media file analyzer
- `tag` - Audio tag editor
- `fswatch` - File system monitoring

#### Examples
```bash
# Install basic encoding suite
./scripts/components-downloader.sh -c flac,lame,opus-tools

# Install all components
./scripts/components-downloader.sh -c all

# List available components
./scripts/components-downloader.sh --list

# Update all installed components
./scripts/components-downloader.sh --update

# Verify installations
./scripts/components-downloader.sh --verify
```

### config-generator.sh

**Purpose**: Dynamic configuration file generation based on system architecture  
**Location**: `scripts/config-generator.sh`  
**User Level**: Advanced

#### Usage
```bash
./scripts/config-generator.sh [OPTIONS]
```

#### Options
| Option | Description |
|--------|-------------|
| `--profile <profile>` | Configuration profile to generate |
| `--library-paths <paths>` | Comma-separated library paths |
| `--backup` | Create backup of existing configuration |
| `--output <file>` | Specify output file location |
| `--template <template>` | Use specific configuration template |

#### Examples
```bash
# Generate standard configuration
./scripts/config-generator.sh --profile standard

# Professional config with custom library paths
./scripts/config-generator.sh --profile professional --library-paths ~/Music,~/FLAC,~/Masters

# Create backup before generating new config
./scripts/config-generator.sh --profile standard --backup

# Generate to specific location
./scripts/config-generator.sh --profile minimal --output ~/Desktop/test_config.cfg
```

### validator.sh

**Purpose**: Comprehensive system validation and health checks  
**Location**: `scripts/validator.sh`  
**User Level**: All users

#### Usage
```bash
./scripts/validator.sh [OPTIONS]
```

#### Options
| Option | Description |
|--------|-------------|
| `--detailed` | Perform comprehensive validation |
| `--report <file>` | Generate JSON report file |
| `--profile <profile>` | Validate specific profile configuration |
| `--fix` | Attempt to fix detected issues |
| `--quiet` | Minimize output (errors only) |

#### Validation Categories
- **System Requirements**: macOS version, architecture, disk space
- **Dependencies**: Homebrew, encoders, utilities
- **Configuration**: File integrity, paths, permissions
- **Integration**: Fish functions, system services
- **Performance**: Encoder functionality, conversion tests

#### Examples
```bash
# Basic validation
./scripts/validator.sh

# Detailed validation with report
./scripts/validator.sh --detailed --report validation_report.json

# Validate professional profile
./scripts/validator.sh --profile professional --detailed

# Quiet validation (errors only)
./scripts/validator.sh --quiet

# Validate and attempt fixes
./scripts/validator.sh --detailed --fix
```

#### Report Format
The JSON report includes:
```json
{
  "timestamp": "2025-08-21T22:00:00Z",
  "system": {
    "os": "macOS 14.0",
    "architecture": "arm64"
  },
  "validation_results": {
    "dependencies": "PASS",
    "configuration": "PASS",
    "integration": "WARNING"
  },
  "recommendations": [
    "Install fswatch for better monitoring performance"
  ]
}
```

## Shell Integration Scripts

### foobar2000_fish_functions.fish

**Purpose**: Fish shell function library for command-line access  
**Location**: `scripts/foobar2000_fish_functions.fish`  
**User Level**: Intermediate

#### Functions Overview
| Function | Purpose | Usage |
|----------|---------|-------|
| `foobar-menu` | Launch interactive menu | `foobar-menu` |
| `foobar-convert` | Convert single file | `foobar-convert <file> <format>` |
| `foobar-batch-convert` | Batch convert folder | `foobar-batch-convert <folder> <format>` |
| `foobar-quality` | Analyze audio quality | `foobar-quality <file>` |
| `foobar-add` | Add file to foobar2000 | `foobar-add <path>` |
| `foobar-monitor` | Start import monitoring | `foobar-monitor` |

#### Aliases
- `fb2k-menu` → `foobar-menu`
- `fb2k-convert` → `foobar-convert`
- `fb2k-monitor` → `foobar-monitor`
- `fb2k-add` → `foobar-add`
- `fb2k-quality` → `foobar-quality`

#### Examples
```bash
# Convert audio file
foobar-convert ~/Music/input.wav flac_commercial

# Batch convert entire folder
foobar-batch-convert ~/Music/Albums mp3_v0

# Analyze file quality
foobar-quality ~/Music/test.flac

# Add files to foobar2000
foobar-add ~/Music/NewAlbum/
```

#### Function Loading
```bash
# Manual loading
source ~/Library/foobar2000-v2/foobar2000_fish_functions.fish

# Automatic loading (add to Fish config)
echo "source ~/Library/foobar2000-v2/foobar2000_fish_functions.fish" >> ~/.config/fish/config.fish
```

## Utility and Helper Scripts

### System Integration Scripts

#### foobar_integration_setup.sh
**Purpose**: macOS system integration setup  
**Usage**: Called automatically during installation  
**Features**:
- File association setup
- Launch Agent configuration
- Spotlight metadata integration
- QuickLook plugin installation

#### foobar_monitor.sh
**Purpose**: File system monitoring daemon  
**Usage**: `bash ~/Library/foobar2000-v2/foobar_monitor.sh`  
**Features**:
- Automatic import detection
- Real-time file processing
- Background operation support
- Multiple folder monitoring

## Error Handling and Logging

### Standard Exit Codes
| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Missing dependencies |
| 3 | User cancellation |
| 4 | Validation failure |
| 5 | Configuration error |
| 6 | Permission error |
| 7 | Network error |
| 8 | File system error |

### Log Locations
- **Installation**: `./foobar2000-automation.log`
- **Conversion**: `~/Library/foobar2000-v2/logs/conversion.log`
- **System Updates**: `~/Library/foobar2000-v2/logs/update.log`
- **Monitoring**: `~/Library/foobar2000-v2/logs/monitor.log`

### Debug Mode
Enable debug output for troubleshooting:
```bash
export DEBUG=1
./scripts/convert_with_external_advanced.sh input.wav flac suffix
```

## Advanced Usage Patterns

### Scripted Automation
```bash
#!/bin/bash
# Batch processing script example

input_dir="~/Music/Masters"
output_dir="~/Music/Releases"
formats=("flac_commercial" "mp3_commercial")

for format in "${formats[@]}"; do
    mkdir -p "$output_dir/$format"
    for file in "$input_dir"/*.wav; do
        ./scripts/convert_with_external_advanced.sh \
            "$file" "$format" suffix --batch
        mv "${file%.*}_${format}."* "$output_dir/$format/"
    done
done
```

### Pipeline Integration
```bash
# Integration with other audio tools
find ~/Music/Raw -name "*.wav" | \
    while read file; do
        # Normalize first
        ffmpeg-normalize "$file" -o "${file%.*}_normalized.wav"
        
        # Convert to release formats
        ./scripts/convert_with_external_advanced.sh \
            "${file%.*}_normalized.wav" flac_commercial suffix --batch
    done
```

### Performance Monitoring
```bash
# Monitor conversion performance
time ./scripts/convert_with_external_advanced.sh large_file.wav flac suffix

# Batch performance testing
for file in test_files/*.wav; do
    /usr/bin/time -l ./scripts/convert_with_external_advanced.sh \
        "$file" flac suffix --batch 2>&1 | grep "real\|peak"
done
```

## Customization and Extension

### Adding New Formats
1. Edit `encoder_presets_macos.cfg`
2. Add new format case in `convert_with_external_advanced.sh`
3. Update menu options in `foobar_menu_fish.sh`
4. Add to Fish functions format list

### Custom Script Integration
Scripts can be extended by:
- Adding hooks in configuration files
- Creating wrapper scripts
- Extending the menu system
- Adding new validation checks

For detailed customization examples, see `docs/EXAMPLES.md`.