# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Language Guidelines

- All documentation, code comments, script interface and commit messages should be in English
- Never use emojis in code or commit messages
- Use clear, professional English without colloquialisms

## Project Overview

This is a macOS automation system for foobar2000 professional audio library management and digital release creation. The project provides:

- Automated installation and configuration of foobar2000 on macOS
- Integration with Homebrew-installed audio encoders (FLAC, MP3, Opus, AAC)
- Professional-grade conversion and batch processing tools
- macOS-specific optimizations for Apple Silicon and Intel architectures
- Fish Shell integration with interactive commands and monitoring

## Core Architecture

### Script Hierarchy
The system follows a modular architecture with specialized bash scripts:

- **install.sh** - Main installation orchestrator with profile-based setup
- **components-downloader.sh** - Homebrew package manager for audio encoders
- **config-generator.sh** - Dynamic configuration file generation based on system architecture
- **validator.sh** - Comprehensive system validation and health checks
- **foobar_integration_setup.sh** - macOS-specific integration setup

### Conversion System
Two-tier conversion architecture:
- **convert_with_external.sh** - Simple compatibility wrapper for fish functions
- **convert_with_external_advanced.sh** - Full-featured converter with logging, batch processing, and multiple modes (suffix, replace, interactive)

### Monitoring System
- **foobar_monitor.sh** - File system monitoring with dual backend support (fswatch/polling)
- **foobar_menu_fish.sh** - Interactive menu system for all operations
- **foobar2000_fish_functions.fish** - Fish shell function library

## Configuration Profiles

The system uses four configuration profiles defined in install.sh:
- **minimal** - Basic encoders (FLAC, MP3)
- **standard** - Full set with Opus and analysis tools  
- **professional** - Maximum configuration with FFmpeg and automation
- **custom** - User-defined settings

Configuration generation is architecture-aware and automatically detects:
- Apple Silicon: `/opt/homebrew/bin/` paths
- Intel Mac: `/usr/local/bin/` paths

## Key Development Commands

### Installation and Setup
```bash
# Interactive installation (recommended for development)
./scripts/install.sh --mode interactive

# Install with specific profile for testing
./scripts/install.sh --profile professional --mode automatic

# Component installation with specific encoders
./scripts/components-downloader.sh -c flac,lame,opus

# Generate configuration for testing
./scripts/config-generator.sh --profile standard --backup
```

### Validation and Testing
```bash
# Comprehensive system validation
./scripts/validator.sh --detailed --report validation-report.json

# Test conversion system
./scripts/convert_with_external_advanced.sh test.wav mp3_320 suffix

# Test monitoring system
./scripts/foobar_monitor.sh --status
```

### Fish Shell Integration Testing
```bash
# Source functions for testing
source scripts/foobar2000_fish_functions.fish

# Test interactive menu
bash scripts/foobar_menu_fish.sh

# Test individual functions
foobar-convert test.wav mp3_320
foobar-quality test.flac
```

## Architecture-Specific Behavior

### Apple Silicon (M1/M2/M3)
- Uses `/opt/homebrew/bin/` for encoder paths
- Native ARM64 performance optimizations
- Energy efficiency considerations in batch processing

### Intel Mac
- Uses `/usr/local/bin/` for encoder paths
- Rosetta 2 compatibility handling
- Legacy path support

### Dual Architecture Support
The config generator automatically detects architecture and sets appropriate paths:
```bash
HOMEBREW_PREFIX=$(brew --prefix 2>/dev/null || echo "/opt/homebrew")
```

## File System Layout

```
~/Library/foobar2000-v2/                 # Main config directory
├── logs/                               # All logging output
├── temp/                              # Temporary conversion files
├── convert_with_external.sh           # Generated conversion script
└── foobar_monitor.sh                  # Monitoring daemon

configs/
├── presets/encoder_presets_macos.cfg   # Encoder configurations
├── scripts/MASSTAGGER_MACOS.txt        # Tagging scripts
└── templates/macos_integration.cfg     # Integration templates
```

## Logging and Error Handling

All scripts implement comprehensive logging:
- **Installation**: `./foobar2000-automation.log`
- **Conversion**: `~/Library/foobar2000-v2/logs/conversion.log`
- **Monitoring**: `~/Library/foobar2000-v2/logs/monitor.log`

Error handling follows bash best practices with `set -euo pipefail` and proper cleanup functions.

## Development Workflow

1. **System Validation**: Always run `validator.sh` after changes
2. **Profile Testing**: Test all configuration profiles (minimal, standard, professional)
3. **Architecture Testing**: Verify on both Apple Silicon and Intel if possible
4. **Fish Integration**: Test both individual functions and interactive menu
5. **Batch Processing**: Test conversion with various file types and edge cases

## Critical Dependencies

- **Homebrew**: Package manager for all audio encoders
- **macOS 11.0+**: Minimum supported version
- **foobar2000 v2.1**: Target application version
- **fswatch** (optional): For efficient file monitoring
- **Fish Shell**: For enhanced user interaction

## Special Considerations

### Unicode and File Paths
All scripts handle Unicode file paths correctly for international music libraries.

### Batch Processing
The advanced converter includes protection against:
- Incomplete file writes during monitoring
- Concurrent access to the same files
- Resource exhaustion during large batch operations
- Graceful handling of encoding failures

### macOS Integration
Scripts integrate with macOS-specific features:
- AppleScript automation for foobar2000 control
- Notification Center integration
- Spotlight metadata handling
- File association management