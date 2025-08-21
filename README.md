# foobar2000 Automation for macOS

Automation system for configuring foobar2000 on macOS with professional requirements for music library management and digital release creation.

## Features

- **Automatic installation** via Homebrew of all necessary encoders
- **Professional setup** of foobar2000 with macOS optimization
- **macOS integration** - Spotlight, QuickLook, media keys, notifications
- **Apple Silicon support** - native optimization for M1/M2/M3 chips
- **Profile flexibility** - from minimal to professional configuration
- **Batch conversion** - stable processing of large file collections
- **Fish Shell integration** - interactive commands and menus

## Latest Fixes (2025-08-21)

**Critical batch conversion bugs fixed:**
- Stable operation of interactive batch conversion menu
- Full progress output for LAME/FLAC/Opus during conversion
- Batch mode without interactive prompts
- Error handling with graceful recovery

Details in [`BUGFIXES.md`](./BUGFIXES.md)

## System Requirements

- **macOS 11.0 Big Sur** or higher (macOS 13.0+ recommended)
- **Homebrew** for encoder installation
- **2 GB** free disk space
- **Apple Silicon** (M1/M2/M3) or **Intel** processor
- Internet connection for component downloads

## Quick Start

### Installation

1. **Install Homebrew** (if not already installed):
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

2. **Clone the project**:
```bash
git clone https://github.com/your-repo/foobar2000-automation-macos.git
cd foobar2000-automation-macos
```

3. **Run automatic installation**:
```bash
# Interactive installation (recommended)
./scripts/install.sh --mode interactive

# Quick installation with standard profile
./scripts/install.sh --profile standard --mode automatic
```

### Configuration Profiles

- **minimal** - Basic encoders (FLAC, MP3)
- **standard** - Full set with Opus and analysis utilities
- **professional** - Maximum configuration with FFmpeg and automation
- **custom** - User-defined settings

## Architecture and Compatibility

### Apple Silicon (M1/M2/M3)
- Native ARM64 support
- Superior encoding performance
- Energy efficiency
- Homebrew paths: `/opt/homebrew/bin/`

### Intel Mac
- Full compatibility
- Rosetta 2 when needed
- Homebrew paths: `/usr/local/bin/`

## Project Structure

```
foobar2000-automation-macos/
├── scripts/                    # Bash scripts
│   ├── install.sh             # Main installation script
│   ├── components-downloader.sh # Encoder installation via Homebrew
│   ├── config-generator.sh    # Configuration generation
│   └── validator.sh           # Installation validation
├── configs/                   # Configuration files
│   ├── presets/              # Encoder presets for macOS
│   ├── scripts/              # Masstagger scripts (adapted for macOS)
│   └── templates/            # macOS integration templates
├── resources/                # Resource files
│   ├── macos_components.json # Homebrew component information
│   └── compatibility_macos.json # macOS compatibility matrix
└── docs/                     # Documentation
    ├── troubleshooting_macos.md
    └── customization_macos.md
```

## Supported Formats and Encoders

### Lossless Formats
- **FLAC** - via `flac` (Homebrew)
  - Compression: levels 0-8
  - Metadata: Vorbis Comments, CUE support
  - Unicode: full support

### Lossy Formats
- **MP3** - via `lame` (Homebrew)
  - Modes: CBR, VBR (V0-V9), ABR
  - Tags: ID3v1, ID3v2.3, ID3v2.4
  - Quality: up to 320 kbps

- **Opus** - via `opus-tools` (Homebrew)
  - Bitrate: 6-510 kbps
  - Modes: VBR, CVBR, CBR
  - Optimization: speech, music, low latency

- **AAC/ALAC** - via `ffmpeg` (Homebrew)
  - AAC: up to 256 kbps
  - ALAC: lossless
  - Container: M4A

## Script Usage

### Component Installation

```bash
# Install all basic encoders
./scripts/components-downloader.sh -c flac,lame,opus

# Install all components for professional use
./scripts/components-downloader.sh -c all

# Show available components
./scripts/components-downloader.sh
```

### Configuration Generation

```bash
# Create standard configuration
./scripts/config-generator.sh --profile standard

# Professional configuration with library paths
./scripts/config-generator.sh --profile professional --library-paths ~/Music,~/FLAC

# Create backup before changes
./scripts/config-generator.sh --profile standard --backup
```

### Installation Validation

```bash
# Basic validation
./scripts/validator.sh

# Detailed validation with report
./scripts/validator.sh --detailed --report validation-report.json

# Validate specific profile
./scripts/validator.sh --profile professional
```

## macOS Integration

### System Features
- **File associations** - automatic audio format registration
- **Spotlight** - metadata indexing for search
- **QuickLook** - audio file preview in Finder
- **Notification Center** - track change notifications
- **Media keys** - keyboard control
- **Dock integration** - progress indicators and menus

### Configuration Paths
```
~/Library/Application Support/foobar2000/     # Main configuration
~/Library/Application Support/foobar2000/encoder_presets/   # Encoder presets
~/Library/Application Support/foobar2000/masstagger_scripts/ # Tagging scripts
~/Library/Logs/foobar2000/                    # Application logs
```

## Masstagger Scripts for macOS

Specially adapted for macOS specifics:

- **Unicode compatibility** - proper handling of special characters
- **File system** - HFS+/APFS compatibility
- **Finder integration** - optimized folder structures

### Main Scripts:
- `AUTOTRACKNUMBER_MACOS` - track numbering
- `GENRE_STANDARDIZE_MACOS` - genre standardization
- `FILENAME_STRUCTURE_MACOS` - file and folder structure
- `REPLAYGAIN_AUTO_MACOS` - automatic ReplayGain

## Encoder Presets

### Recommended Quality Settings:

**Audiophile (maximum quality):**
- FLAC: `-8 -V` (maximum compression)
- MP3: `-V 0` (VBR ~245 kbps)
- Opus: `--bitrate 256`

**Standard (balanced):**
- FLAC: `-5 -V` (fast compression)
- MP3: `-V 2` (VBR ~190 kbps)
- Opus: `--bitrate 128`

**Portable (mobile devices):**
- FLAC: `-3` (fast)
- MP3: `-V 4` (VBR ~165 kbps)
- Opus: `--bitrate 96`

## Performance

### Encoding Benchmarks (approximate):

**Apple Silicon M2 Max:**
- FLAC level 8: ~15x realtime
- MP3 V0: ~25x realtime
- Opus 192k: ~30x realtime

**Intel Core i9:**
- FLAC level 8: ~8x realtime
- MP3 V0: ~15x realtime
- Opus 192k: ~18x realtime

## Troubleshooting

### Common Issues:

**Homebrew not found:**
```bash
# For Apple Silicon
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc

# For Intel
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc
```

**Folder access denied:**
- Grant access permissions in System Preferences → Security & Privacy → Privacy → Files and Folders

**Encoders not found:**
```bash
# Check installation
brew list flac lame opus-tools ffmpeg

# Reinstall if necessary
brew reinstall flac lame opus-tools
```

## Automation

### Creating Hot Folders:
```bash
# Automatic import
mkdir -p ~/Music/Import
# Files in this folder will be automatically added to library

# Automatic conversion
mkdir -p ~/Music/Convert
# Files will be converted according to preset settings
```

### Task Scheduler (cron):
```bash
# Automatic component updates every Sunday at 2:00 AM
0 2 * * 0 /opt/homebrew/bin/brew update && /opt/homebrew/bin/brew upgrade
```

## System Updates

```bash
# Update all Homebrew components
brew update && brew upgrade

# Update foobar2000
brew upgrade --cask foobar2000

# Check outdated packages
brew outdated

# Clear cache
brew cleanup
```

## Backup

```bash
# Configuration backup
cp -R ~/Library/Application\ Support/foobar2000 ~/Desktop/foobar2000-backup

# Encoder presets backup
tar -czf ~/Desktop/encoder-presets-backup.tar.gz -C ~/Library/Application\ Support/foobar2000 encoder_presets

# Restore
cp -R ~/Desktop/foobar2000-backup ~/Library/Application\ Support/foobar2000
```

## Customization

### Creating Custom Presets:
```bash
# Edit encoder presets
nano ~/Library/Application\ Support/foobar2000/encoder_presets/my_custom.preset

# Create custom tagging scripts
nano ~/Library/Application\ Support/foobar2000/masstagger_scripts/MY_CUSTOM_SCRIPT.txt
```

### Integration with Other Applications:
- **Automator** - create workflows for file processing
- **AppleScript** - automation via system scripts
- **Shortcuts** - integration with Shortcuts app

## Support and Development

- **GitHub Issues** - bug reports
- **Discussions** - usage questions
- **Wiki** - additional documentation

When creating issues, include:
- macOS version
- Processor architecture (Apple Silicon/Intel)
- foobar2000 version
- Script execution logs

## License

MIT License - free use and modification.

---

**Compatibility**: macOS 11.0+, Apple Silicon + Intel  
**Support**: Current macOS and foobar2000 versions  
**Updates**: Regular compatibility updates