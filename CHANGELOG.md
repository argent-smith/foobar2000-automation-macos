# Changelog - foobar2000 Automation for macOS

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

### Planned
- Automatic update support via Homebrew
- GUI application for profile management
- MusicBrainz integration for automatic tagging
- Support for DSD and other high-res formats

## [1.0.1] - 2025-08-21

### Fixed - Critical Batch Conversion Bugs
- **Fixed script crash** during batch file conversion
- **Restored progress output** for LAME/FLAC/Opus during conversion
- **Eliminated interactive prompts** in batch conversion mode
- **Improved error handling** with graceful recovery

#### Technical Fixes
- **Replaced file search logic** - removed unstable process substitution
- **Added --batch flag** for non-interactive mode
- **Fixed array handling** with disabled set -e for critical sections
- **Removed >/dev/null redirection** that hid conversion output

#### Affected Files
- `scripts/foobar_menu_fish.sh` - fixed main batch conversion loop
- `scripts/convert_with_external_advanced.sh` - added batch mode
- `scripts/foobar2000_fish_functions.fish` - updated functions
- `scripts/foobar_integration_setup.sh` - improved integration

#### Results
- Batch conversion now works stably
- Full progress output with bitrate and timing
- Support for all formats: FLAC, MP3 (V0/320/Commercial), Opus
- Automatic backup management during file replacement

### Added
- `BUGFIXES.md` document with detailed fix descriptions
- Improved diagnostics and debugging in scripts
- Safe Unicode character handling in filenames

## [1.0.0] - 2024-01-15

### Added
- First stable release for macOS
- Full adaptation of Windows version for macOS
- Apple Silicon (M1/M2/M3) and Intel processor support
- Automatic installation via Homebrew
- Three installation profiles: minimal, standard, professional

#### Main Scripts
- `install.sh` - main installation script with interactive and automatic modes
- `components-downloader.sh` - automatic encoder installation via Homebrew
- `config-generator.sh` - configuration generation for various profiles
- `validator.sh` - installation and configuration validation

#### Supported Encoders
- **FLAC** (1.4.3) - lossless encoding with compression levels 0-8
- **LAME** (3.100) - MP3 encoding with CBR/VBR/ABR support
- **Opus** (0.2) - modern lossy encoder
- **FFmpeg** (6.1) - universal multimedia framework
- **MediaInfo** (23.11) - metadata analysis
- **tag** (1.1.1) - audio tag editing

#### macOS Integration
- File associations for audio formats
- Spotlight support for metadata search
- QuickLook audio file preview
- Notification Center notifications
- Media key support
- Dock integration with progress

#### Configuration Files
- Encoder presets adapted for macOS
- Masstagger scripts with Unicode support
- Templates for macOS system service integration
- JSON compatibility files for various macOS versions

#### Documentation
- Detailed installation guide
- Troubleshooting guide
- Customization guide
- Performance optimization guide
- macOS version compatibility matrix

### Changed from Windows Version
- Use Homebrew instead of direct downloads
- Adapted paths for macOS filesystem
- Optimization for Apple Silicon architecture
- Replaced Windows-specific components with macOS equivalents
- Integration with macOS system services

### Fixed
- Unicode path issues on macOS
- Correct handling of spaces in filenames
- Processor architecture detection (Intel/Apple Silicon)
- Proper Homebrew paths for different architectures

### Security
- Validation of all downloaded components
- Homebrew package signature verification
- macOS Gatekeeper compatibility
- System Integrity Protection (SIP) support

## [0.9.0] - 2024-01-01

### Added
- Initial macOS adaptation
- Basic Homebrew installation support
- Apple Silicon testing

### Changed
- Reworked scripts for bash compatibility
- Adapted paths for macOS

## Development Roadmap

### Version 1.1.0
- Additional format support (DSD, MQA)
- Automatic configuration updates
- Extended Finder integration
- iCloud settings synchronization support

### Version 1.2.0
- GUI management application
- Plugin architecture for extensions
- Automatic tagging via MusicBrainz
- Batch processing with progress indication

### Version 2.0.0
- Complete architecture redesign
- Streaming service support
- Apple Music/iTunes integration
- Machine Learning for automatic processing

## Compatibility

### Supported macOS Versions
- macOS 14.0 Sonoma (recommended)
- macOS 13.0 Ventura (recommended)
- macOS 12.0 Monterey
- macOS 11.0 Big Sur (minimum)
- macOS 10.15 Catalina (not supported)

### Supported Architectures
- Apple Silicon (M1/M2/M3) (optimized)
- Intel x86_64 (full support)

### foobar2000 Versions
- foobar2000 v2.1 (tested)
- foobar2000 v2.0 (compatible)

## Contributing

### How to Report a Bug
1. Check [existing issues](https://github.com/your-repo/foobar2000-automation-macos/issues)
2. Create a new issue with detailed description
3. Include diagnostic information:
   ```bash
   # System information
   sw_vers
   uname -m
   
   # Component versions
   brew --version
   brew list --versions flac lame opus-tools
   
   # Execution logs
   ./scripts/validator.sh --detailed
   ```

### How to Suggest Improvements
1. Describe the proposed functionality
2. Explain how it improves user experience
3. Provide usage examples

### Contributing to Development
1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## License

This project is distributed under the MIT License. See [LICENSE](LICENSE) file for details.

## Acknowledgments

- foobar2000 development team for the excellent audio player
- Homebrew community for the convenient macOS package system
- All contributors and testers of the project

---

**Project Status:** Active development  
**Support:** macOS 11.0+, Apple Silicon + Intel  
**License:** MIT