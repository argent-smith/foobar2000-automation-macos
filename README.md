# foobar2000 Automation for macOS

Professional audio library management and digital release creation system for foobar2000 on macOS.

## Overview

This project provides a comprehensive automation system for foobar2000 on macOS, featuring professional-grade audio conversion, batch processing, and seamless macOS integration. Designed for audiophiles, music producers, and digital release creators who demand quality and efficiency.

## Key Features

### 🎵 Professional Audio Conversion
- **Lossless Formats**: FLAC with multiple compression levels
- **Commercial Ready**: FLAC Commercial (44.1kHz, 24-bit) and MP3 Commercial (44.1kHz, 24-bit, 192kbps)
- **High-Quality Lossy**: MP3 V0/320/Commercial, Opus, AAC, ALAC
- **Metadata Preservation**: Complete tag and timestamp preservation across all formats

### 🖥️ macOS Integration
- **Apple Silicon Optimized**: Native ARM64 support with Intel compatibility
- **Homebrew Integration**: Automated installation of audio encoders
- **Fish Shell Support**: Interactive functions and command completion
- **System Integration**: Spotlight metadata, QuickLook, media keys

### ⚙️ Automation Features
- **Batch Processing**: Mass conversion with progress tracking
- **File Monitoring**: Automatic import and processing
- **Interactive Menus**: User-friendly GUI-style interfaces
- **Error Handling**: Comprehensive logging and recovery

### 🔧 Professional Tools
- **Quality Analysis**: Detailed audio file inspection with MediaInfo
- **Multiple Modes**: Suffix, replace, and interactive conversion modes
- **Backup System**: Automatic backup creation before operations
- **Update System**: Easy synchronization with repository updates

## Quick Start

### Prerequisites
- macOS 11.0 Big Sur or later (macOS 13.0+ recommended)
- Homebrew package manager
- foobar2000 v2.1+
- 2GB free disk space

### Installation

1. **Clone the repository**:
   ```bash
   git clone https://github.com/argent-smith/foobar2000-automation-macos.git
   cd foobar2000-automation-macos
   ```

2. **Run the installation script**:
   ```bash
   # Interactive installation (recommended)
   ./scripts/install.sh --mode interactive
   
   # Quick install with standard profile
   ./scripts/install.sh --profile standard --mode automatic
   ```

3. **Load Fish functions** (if using Fish shell):
   ```bash
   source ~/Library/foobar2000-v2/foobar2000_fish_functions.fish
   ```

### Basic Usage

```bash
# Interactive menu system
foobar-menu

# Convert single file
foobar-convert input.wav flac_commercial

# Batch convert folder
foobar-batch-convert ~/Music/ToConvert mp3_commercial

# Analyze audio quality
foobar-quality audio_file.flac
```

## Supported Formats

### Lossless Formats
| Format | Profile | Description | Quality |
|--------|---------|-------------|---------|
| FLAC | `flac` | Standard lossless | -8 compression, full metadata |
| FLAC Commercial | `flac_commercial` | Commercial release ready | 44.1kHz, 24-bit, -4 compression |
| ALAC | `alac_ffmpeg` | Apple Lossless | Full compatibility with Apple ecosystem |

### Lossy Formats
| Format | Profile | Description | Quality |
|--------|---------|-------------|---------|
| MP3 V0 | `mp3_v0` | Variable bitrate high quality | ~245 kbps VBR |
| MP3 320 | `mp3_320` | Constant bitrate maximum | 320 kbps CBR |
| MP3 Commercial | `mp3_commercial` | Commercial release ready | 44.1kHz, 24-bit, 192 kbps CBR |
| Opus | `opus` | Modern efficient codec | 192 kbps, superior compression |
| AAC | `aac_ffmpeg_high` | High-quality AAC | 256 kbps |

## Project Structure

```
foobar2000-automation-macos/
├── README.md                    # This file
├── UPDATE.md                    # Update system documentation
├── CLAUDE.md                    # Development guidelines
├── update.sh                    # Quick update script
├── scripts/                     # Core automation scripts
│   ├── install.sh              # Main installation script
│   ├── update_system.sh        # System update script
│   ├── convert_with_external_advanced.sh  # Advanced converter
│   ├── foobar_menu_fish.sh     # Interactive menu system
│   ├── foobar2000_fish_functions.fish     # Fish shell functions
│   ├── foobar_integration_setup.sh        # System integration
│   ├── components-downloader.sh           # Homebrew package installer
│   ├── config-generator.sh               # Configuration generator
│   └── validator.sh                      # Installation validator
├── configs/                     # Configuration files
│   ├── presets/
│   │   └── encoder_presets_macos.cfg     # Audio encoder configurations
│   ├── scripts/
│   │   └── MASSTAGGER_MACOS.txt          # Mass tagging scripts
│   └── templates/
│       └── macos_integration.cfg         # Integration templates
├── docs/                        # Documentation
│   ├── INSTALLATION.md         # Detailed installation guide
│   ├── ENCODING_PROFILES.md    # Complete format documentation
│   ├── SCRIPT_REFERENCE.md     # Script usage reference
│   ├── FISH_INTEGRATION.md     # Fish shell guide
│   ├── TROUBLESHOOTING.md      # Problem resolution guide
│   ├── ARCHITECTURE.md         # System architecture
│   └── EXAMPLES.md             # Usage examples
└── resources/                   # Additional resources
    ├── macos_components.json   # Homebrew component definitions
    └── compatibility_macos.json # macOS version compatibility
```

## Configuration Profiles

The system supports multiple configuration profiles for different use cases:

### Minimal Profile
- Basic encoders (FLAC, MP3)
- Essential functionality
- Minimal disk usage

### Standard Profile (Recommended)
- Full encoder set including commercial formats
- Complete metadata preservation
- Interactive tools and analysis

### Professional Profile
- All encoders including FFmpeg-based formats
- Advanced batch processing
- Complete automation and monitoring

### Custom Profile
- User-defined encoder selection
- Configurable quality settings
- Tailored for specific workflows

## System Requirements

### macOS Compatibility
- ✅ macOS 14.0 Sonoma (recommended)
- ✅ macOS 13.0 Ventura (recommended)
- ✅ macOS 12.0 Monterey (supported)
- ✅ macOS 11.0 Big Sur (minimum)

### Architecture Support
- ✅ Apple Silicon (M1/M2/M3) - Native ARM64 optimization
- ✅ Intel x86_64 - Full compatibility with Rosetta 2

### Dependencies
- **Homebrew**: Package management for audio encoders
- **foobar2000**: Target application (v2.1+ recommended)
- **Command Line Tools**: Xcode command line tools

### Optional Enhancements
- **Fish Shell**: Enhanced interactive experience
- **MediaInfo**: Detailed audio analysis
- **fswatch**: Efficient file monitoring

## Integration Features

### macOS System Integration
- **File Associations**: Automatic registration of audio formats
- **Spotlight Integration**: Searchable metadata indexing
- **QuickLook Support**: Audio file preview in Finder
- **Notification Center**: Conversion progress and completion alerts
- **Media Key Support**: Hardware playback control
- **Dock Integration**: Progress indication and context menus

### Shell Integration
- **Fish Shell Functions**: Native command completion and help
- **Bash Compatibility**: Works in all POSIX-compliant shells
- **Interactive Menus**: GUI-style terminal interfaces
- **Command Aliases**: Short commands for common operations

## Performance Benchmarks

### Apple Silicon M2 Max
- FLAC Level 8: ~15x realtime speed
- MP3 V0: ~25x realtime speed
- Opus 192k: ~30x realtime speed
- Batch processing: 1000 files in ~10 minutes

### Intel Core i9
- FLAC Level 8: ~8x realtime speed
- MP3 V0: ~15x realtime speed
- Opus 192k: ~18x realtime speed
- Batch processing: 1000 files in ~18 minutes

## Usage Examples

### Single File Conversion
```bash
# Convert WAV to FLAC Commercial format
./scripts/convert_with_external_advanced.sh input.wav flac_commercial suffix

# Replace file with MP3 Commercial version
./scripts/convert_with_external_advanced.sh input.flac mp3_commercial replace
```

### Batch Operations
```bash
# Interactive menu for batch conversion
bash ~/Library/foobar2000-v2/foobar_menu_fish.sh

# Command-line batch conversion
foobar-batch-convert ~/Music/Albums flac_commercial
```

### Quality Analysis
```bash
# Analyze single file
foobar-quality ~/Music/test.flac

# Batch quality analysis
for file in ~/Music/*.flac; do
    echo "Analyzing: $(basename "$file")"
    foobar-quality "$file"
done
```

## Update System

Keep your installation current with the latest improvements:

```bash
# Check for updates (dry run)
./update.sh --dry-run

# Update with backup
./update.sh --backup

# Force complete update
./update.sh --force --backup
```

## Contributing

This project welcomes contributions from the audio and macOS development community.

### Development Setup
1. Fork the repository
2. Create a feature branch
3. Follow the coding standards in `CLAUDE.md`
4. Test on both Apple Silicon and Intel if possible
5. Submit a pull request

### Areas for Contribution
- Additional audio format support
- Performance optimizations
- GUI applications
- Integration with other audio tools
- Documentation improvements

## Support and Community

### Getting Help
- 📖 **Documentation**: Check the `docs/` directory for detailed guides
- 🐛 **Issues**: Report bugs and request features on GitHub
- 💬 **Discussions**: Community support and feature discussions

### Common Issues
- **Installation Problems**: See `docs/TROUBLESHOOTING.md`
- **Performance Issues**: Check system requirements and available resources
- **Format Support**: Verify Homebrew package installation

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- **foobar2000 Development Team**: For creating an exceptional audio player
- **Homebrew Community**: For simplifying macOS package management
- **Audio Codec Developers**: FLAC, LAME, Opus, and FFmpeg teams
- **macOS Audio Community**: For testing and feedback

## Version History

- **v1.1.0**: Added commercial encoding profiles and enhanced metadata preservation
- **v1.0.1**: Critical bug fixes for batch conversion and system integration
- **v1.0.0**: Initial stable release with complete automation system

---

**Status**: Active Development  
**Minimum macOS**: 11.0 Big Sur  
**Recommended macOS**: 13.0 Ventura or later  
**Architecture**: Universal (Apple Silicon + Intel)  
**License**: MIT