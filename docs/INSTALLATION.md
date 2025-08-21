# Installation Guide

Complete installation and setup guide for foobar2000 Automation on macOS.

## System Requirements

### Operating System
- **macOS 11.0 Big Sur** (minimum)
- **macOS 13.0 Ventura** or later (recommended)
- **macOS 14.0 Sonoma** (optimal)

### Hardware Requirements
- **Apple Silicon** (M1/M2/M3) - Native ARM64 optimization
- **Intel x86_64** - Full compatibility with Rosetta 2 support
- **2GB** free disk space for installation
- **4GB RAM** minimum (8GB recommended for batch processing)

### Prerequisites

#### Required Software
1. **Homebrew Package Manager**
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```

2. **Xcode Command Line Tools**
   ```bash
   xcode-select --install
   ```

3. **foobar2000 v2.1+**
   ```bash
   brew install --cask foobar2000
   ```

#### Optional but Recommended
- **Fish Shell** (for enhanced user experience)
  ```bash
  brew install fish
  ```
- **MediaInfo** (for audio analysis)
  ```bash
  brew install mediainfo
  ```

## Installation Methods

### Method 1: Interactive Installation (Recommended)

This method provides a guided setup experience with profile selection and validation.

```bash
# Clone the repository
git clone https://github.com/argent-smith/foobar2000-automation-macos.git
cd foobar2000-automation-macos

# Run interactive installation
./scripts/install.sh --mode interactive
```

#### Interactive Installation Steps:
1. **System Check**: Validates prerequisites and architecture
2. **Profile Selection**: Choose from minimal, standard, professional, or custom
3. **Component Installation**: Installs required audio encoders via Homebrew
4. **Configuration Generation**: Creates optimized settings for your system
5. **System Integration**: Sets up Fish functions and system services
6. **Validation**: Verifies installation completeness

### Method 2: Automatic Installation

For automated deployments or when you know your desired configuration:

```bash
# Standard profile (recommended for most users)
./scripts/install.sh --profile standard --mode automatic

# Professional profile (all features)
./scripts/install.sh --profile professional --mode automatic

# Minimal profile (basic functionality only)
./scripts/install.sh --profile minimal --mode automatic
```

### Method 3: Manual Installation

For advanced users who want complete control:

```bash
# Install components manually
./scripts/components-downloader.sh -c flac,lame,opus-tools,ffmpeg

# Generate configuration
./scripts/config-generator.sh --profile standard

# Set up integration
./scripts/foobar_integration_setup.sh

# Validate installation
./scripts/validator.sh --detailed
```

## Configuration Profiles

### Minimal Profile
**Target Users**: Basic audio conversion needs
**Disk Usage**: ~100MB
**Components**:
- FLAC encoder
- LAME MP3 encoder
- Basic conversion scripts

### Standard Profile (Recommended)
**Target Users**: General audiophiles and music enthusiasts  
**Disk Usage**: ~300MB
**Components**:
- All minimal profile components
- Opus encoder
- Commercial encoding formats (FLAC Commercial, MP3 Commercial)
- MediaInfo for quality analysis
- Fish shell integration
- Interactive menu system

### Professional Profile  
**Target Users**: Music producers, digital release creators
**Disk Usage**: ~500MB
**Components**:
- All standard profile components
- FFmpeg for AAC/ALAC encoding
- File monitoring system
- Batch processing automation
- Complete masstagger scripts
- Advanced logging and backup systems

### Custom Profile
**Target Users**: Users with specific requirements
**Configuration**: Interactive selection of components and features

## Post-Installation Setup

### 1. Fish Shell Integration (Optional)

If you have Fish shell installed, load the functions:

```bash
# Add to Fish configuration
echo "source ~/Library/foobar2000-v2/foobar2000_fish_functions.fish" >> ~/.config/fish/config.fish

# Or load manually each session
source ~/Library/foobar2000-v2/foobar2000_fish_functions.fish
```

### 2. Test Installation

Verify everything works correctly:

```bash
# Test interactive menu
foobar-menu

# Test conversion
echo "Test conversion with a small audio file"
foobar-convert test.wav flac

# Check encoder availability
./scripts/validator.sh
```

### 3. Configure foobar2000

1. **Launch foobar2000**
2. **Import Encoder Presets**:
   - Go to File → Preferences → Tools → Converter
   - Import: `~/Library/foobar2000-v2/encoder_presets_macos.cfg`
3. **Set up Library Paths**:
   - Go to File → Preferences → Media Library
   - Add your music directories

## Troubleshooting Installation Issues

### Common Problems and Solutions

#### 1. Homebrew Not Found
```bash
# For Apple Silicon
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc

# For Intel Mac
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc

# Reload shell
source ~/.zshrc
```

#### 2. Permission Errors
```bash
# Fix permissions for system directories
sudo chown -R $(whoami) /usr/local/lib/pkgconfig
sudo chmod -R 755 /usr/local/lib/pkgconfig

# Or for Apple Silicon
sudo chown -R $(whoami) /opt/homebrew/lib/pkgconfig
sudo chmod -R 755 /opt/homebrew/lib/pkgconfig
```

#### 3. Component Installation Failures
```bash
# Update Homebrew first
brew update

# Try installing components individually
brew install flac
brew install lame  
brew install opus-tools
brew install ffmpeg

# Check for conflicts
brew doctor
```

#### 4. foobar2000 Not Found
```bash
# Install foobar2000 manually
brew install --cask foobar2000

# Or download from official site
open https://www.foobar2000.org/mac
```

### Architecture-Specific Issues

#### Apple Silicon (M1/M2/M3)
- **Issue**: Some Homebrew packages installing x86 versions
- **Solution**:
  ```bash
  # Ensure ARM64 Homebrew
  /opt/homebrew/bin/brew install flac lame opus-tools
  
  # Check architecture
  file /opt/homebrew/bin/flac
  # Should show: Mach-O 64-bit executable arm64
  ```

#### Intel Mac  
- **Issue**: Path conflicts with Apple Silicon installations
- **Solution**:
  ```bash
  # Use Intel-specific paths
  /usr/local/bin/brew install flac lame opus-tools
  
  # Verify paths in configuration
  grep -r "/opt/homebrew" configs/
  # Should show Intel paths: /usr/local/bin/
  ```

## Verification and Testing

### Installation Verification

Run the comprehensive validator:

```bash
./scripts/validator.sh --detailed --report validation-report.json
```

### Component Testing

Test each encoder individually:

```bash
# Test FLAC
/opt/homebrew/bin/flac --version  # or /usr/local/bin/flac

# Test LAME MP3
lame --version

# Test Opus
opusenc --version

# Test FFmpeg (if professional profile)
ffmpeg -version
```

### Conversion Testing

Test the conversion system:

```bash
# Create test audio file (1 second sine wave)
ffmpeg -f lavfi -i "sine=frequency=440:duration=1" -acodec pcm_s16le test.wav

# Test conversion to different formats
./scripts/convert_with_external_advanced.sh test.wav flac suffix
./scripts/convert_with_external_advanced.sh test.wav mp3_commercial suffix
./scripts/convert_with_external_advanced.sh test.wav opus suffix

# Verify output files
ls -la test_*
mediainfo test_flac.flac
```

## Advanced Configuration

### Custom Encoder Settings

Edit the encoder presets for your specific needs:

```bash
# Edit main configuration
nano ~/Library/foobar2000-v2/encoder_presets_macos.cfg

# Backup before editing
cp ~/Library/foobar2000-v2/encoder_presets_macos.cfg ~/Desktop/encoder_presets_backup.cfg
```

### System Integration

Enable additional macOS integration features:

```bash
# Set up Launch Agent for monitoring
cp resources/com.user.foobar2000.monitor.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.user.foobar2000.monitor.plist

# Create Automator workflows
open -a Automator
# Create Service → Shell Script → Add conversion commands
```

### Performance Optimization

For batch processing optimization:

```bash
# Increase file descriptor limit
ulimit -n 2048

# Set CPU priority for encoding processes
sudo nice -n -10 ./scripts/convert_with_external_advanced.sh

# Enable parallel processing
export MAKEFLAGS="-j$(sysctl -n hw.ncpu)"
```

## Uninstallation

If you need to remove the system:

```bash
# Remove Homebrew components
brew uninstall flac lame opus-tools ffmpeg mediainfo

# Remove system files
rm -rf ~/Library/foobar2000-v2/

# Remove Fish functions (if added)
sed -i '' '/foobar2000_fish_functions/d' ~/.config/fish/config.fish

# Remove Launch Agents (if installed)
launchctl unload ~/Library/LaunchAgents/com.user.foobar2000.monitor.plist
rm ~/Library/LaunchAgents/com.user.foobar2000.monitor.plist
```

## Next Steps

After successful installation:

1. **Read the Format Guide**: See `docs/ENCODING_PROFILES.md` for detailed format information
2. **Learn the Scripts**: Check `docs/SCRIPT_REFERENCE.md` for command documentation  
3. **Set up Fish Shell**: See `docs/FISH_INTEGRATION.md` for enhanced shell experience
4. **Explore Examples**: Review `docs/EXAMPLES.md` for usage examples

## Support

If you encounter installation issues:

1. **Check the logs**: `~/Library/foobar2000-v2/logs/installation.log`
2. **Run validator**: `./scripts/validator.sh --detailed`
3. **Report issues**: Include system info and error messages
4. **Consult troubleshooting**: See `docs/TROUBLESHOOTING.md`

For system information needed in bug reports:

```bash
# Generate system report
./scripts/validator.sh --detailed --report system_info.json
sw_vers
uname -m
brew --version
```