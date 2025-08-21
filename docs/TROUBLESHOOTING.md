# Troubleshooting Guide

Comprehensive troubleshooting guide for foobar2000 automation system issues on macOS.

## Common Issues and Solutions

### Installation Problems

#### 1. Homebrew Not Found

**Symptoms:**
```
bash: brew: command not found
Error: Homebrew is not installed or not in PATH
```

**Solution:**
```bash
# For Apple Silicon Macs
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc

# For Intel Macs  
echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zshrc
source ~/.zshrc

# Install Homebrew if not present
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Prevention:**
- Always install Homebrew before running the automation system
- Verify Homebrew is in PATH: `which brew`

#### 2. Permission Errors During Installation

**Symptoms:**
```
Permission denied: /usr/local/lib/pkgconfig
Error: Cannot write to system directories
```

**Solution:**
```bash
# Fix Homebrew permissions (Intel)
sudo chown -R $(whoami) /usr/local/lib/pkgconfig
sudo chmod -R 755 /usr/local/lib/pkgconfig

# Fix Homebrew permissions (Apple Silicon)  
sudo chown -R $(whoami) /opt/homebrew/lib/pkgconfig
sudo chmod -R 755 /opt/homebrew/lib/pkgconfig

# Fix user library permissions
sudo chown -R $(whoami) ~/Library/foobar2000-v2
chmod -R 755 ~/Library/foobar2000-v2
```

**Prevention:**
- Run installation scripts as regular user, not sudo
- Ensure proper Homebrew installation

#### 3. Component Installation Failures

**Symptoms:**
```
Error: Failed to install flac
Error: Formula not found
```

**Solution:**
```bash
# Update Homebrew first
brew update

# Check for issues
brew doctor

# Install components individually
brew install flac
brew install lame
brew install opus-tools
brew install ffmpeg

# Verify installations
which flac lame opusenc ffmpeg
```

**Alternative Solution:**
```bash
# Clean Homebrew cache
brew cleanup

# Reinstall problematic components
brew uninstall flac && brew install flac
```

### Conversion Issues

#### 4. Encoder Not Found Errors

**Symptoms:**
```
Error: Encoder not found: /opt/homebrew/bin/flac
FLAC encoder failed
```

**Diagnosis:**
```bash
# Check if encoder is installed
which flac
ls -la /opt/homebrew/bin/flac  # Apple Silicon
ls -la /usr/local/bin/flac     # Intel

# Check architecture mismatch
file /opt/homebrew/bin/flac
```

**Solution:**
```bash
# Reinstall encoder for correct architecture
brew uninstall flac
brew install flac

# Verify installation
flac --version

# Update configuration paths if needed
./scripts/config-generator.sh --profile standard
```

#### 5. Conversion Script Failures

**Symptoms:**
```
Error: Conversion failed with exit code 1
No output file created
```

**Diagnosis Steps:**
```bash
# Enable debug mode
export DEBUG=1
./scripts/convert_with_external_advanced.sh input.wav flac suffix

# Check logs
tail -f ~/Library/foobar2000-v2/logs/conversion.log

# Test encoder directly
/opt/homebrew/bin/flac --version
/opt/homebrew/bin/flac -8 -V input.wav -o test.flac
```

**Solutions:**
```bash
# Fix file permissions
chmod 644 input.wav
chmod +x ~/Library/foobar2000-v2/convert_with_external_advanced.sh

# Check disk space
df -h ~/Library/foobar2000-v2/temp/

# Clear temporary files
rm -rf ~/Library/foobar2000-v2/temp/*
```

#### 6. Batch Conversion Hangs

**Symptoms:**
```
Conversion process appears stuck
No progress output during batch operations
```

**Solution:**
```bash
# Kill hanging processes
pkill -f convert_with_external
pkill flac lame opusenc

# Clear locks and temp files
rm -rf ~/Library/foobar2000-v2/temp/*

# Use batch mode flag
./scripts/convert_with_external_advanced.sh input.wav flac suffix --batch
```

**Prevention:**
```bash
# Monitor system resources during batch operations
top -pid $(pgrep -f convert_with_external)

# Use smaller batch sizes
# Process 10 files at a time instead of entire folders
```

### Fish Shell Integration Issues

#### 7. Functions Not Loading

**Symptoms:**
```
fish: Unknown command: foobar-menu
Functions not available after installation
```

**Diagnosis:**
```bash
# Check if functions file exists
test -f ~/Library/foobar2000-v2/foobar2000_fish_functions.fish
echo $status  # Should return 0

# Check Fish configuration
cat ~/.config/fish/config.fish | grep foobar
```

**Solution:**
```bash
# Manually load functions
source ~/Library/foobar2000-v2/foobar2000_fish_functions.fish

# Add to Fish configuration permanently
mkdir -p ~/.config/fish
echo "source ~/Library/foobar2000-v2/foobar2000_fish_functions.fish" >> ~/.config/fish/config.fish

# Reload Fish configuration
source ~/.config/fish/config.fish
```

#### 8. Tab Completion Not Working

**Symptoms:**
```
Tab completion doesn't show audio files or formats
No intelligent completion available
```

**Solution:**
```bash
# Create completions directory
mkdir -p ~/.config/fish/completions

# Reload Fish
exec fish

# Test completion manually
complete -C "foobar-convert "
```

### System Integration Issues

#### 9. foobar2000 AppleScript Errors

**Symptoms:**
```
Error: foobar2000 not found
AppleScript execution failed
```

**Solution:**
```bash
# Verify foobar2000 is installed
ls -la /Applications/foobar2000.app

# Install if missing
brew install --cask foobar2000

# Test AppleScript directly
osascript -e 'tell application "foobar2000" to activate'
```

#### 10. File Monitoring Not Working

**Symptoms:**
```
Files added to Import folder are not processed
Monitoring script exits immediately
```

**Diagnosis:**
```bash
# Check if fswatch is installed
which fswatch

# Test monitoring manually
fswatch -o ~/Music/Import
```

**Solution:**
```bash
# Install fswatch for better performance
brew install fswatch

# Use polling fallback if fswatch unavailable
export USE_POLLING=1
bash ~/Library/foobar2000-v2/foobar_monitor.sh
```

### Performance Issues

#### 11. Slow Conversion Performance

**Symptoms:**
```
Conversions taking much longer than expected
High CPU usage during encoding
```

**Optimization:**
```bash
# Check system resources
top -o cpu
iostat -d 1

# Optimize for your system
# Reduce FLAC compression level for speed
sed -i '' 's/-8/-5/g' ~/Library/foobar2000-v2/encoder_presets_macos.cfg

# Use parallel processing (with caution)
export MAKEFLAGS="-j$(sysctl -n hw.ncpu)"
```

#### 12. High Memory Usage

**Symptoms:**
```
System becomes unresponsive during batch operations
Memory pressure warnings
```

**Solution:**
```bash
# Process files in smaller batches
# Instead of entire folders, process 10-20 files at a time

# Monitor memory usage
memory_pressure

# Clear system cache if needed
sudo purge
```

### macOS-Specific Issues

#### 13. Gatekeeper and Security Issues

**Symptoms:**
```
"App cannot be opened because it is from an unidentified developer"
Security warnings for downloaded scripts
```

**Solution:**
```bash
# Allow execution of scripts
xattr -dr com.apple.quarantine ~/path/to/script

# For entire project directory
xattr -dr com.apple.quarantine ~/path/to/foobar2000-automation-macos

# System Preferences → Security & Privacy → Allow apps from identified developers
```

#### 14. Path Issues on Apple Silicon

**Symptoms:**
```
Encoders not found despite installation
Architecture mismatch errors
```

**Diagnosis:**
```bash
# Check system architecture
uname -m  # Should return 'arm64' for Apple Silicon

# Check Homebrew installation path
brew --prefix  # Should return '/opt/homebrew' for Apple Silicon

# Verify encoder architecture
file $(brew --prefix)/bin/flac  # Should show arm64
```

**Solution:**
```bash
# Ensure native ARM64 installation
brew uninstall flac lame opus-tools ffmpeg
arch -arm64 brew install flac lame opus-tools ffmpeg

# Update configuration
./scripts/config-generator.sh --profile standard
```

### Metadata and Quality Issues

#### 15. Missing or Corrupted Metadata

**Symptoms:**
```
Converted files missing tags
Metadata not preserved during conversion
```

**Diagnosis:**
```bash
# Check source file metadata
mediainfo --full input.wav
exiftool input.wav

# Check converted file metadata
mediainfo --full output.flac
```

**Solution:**
```bash
# Ensure MediaInfo is installed
brew install mediainfo exiftool

# Verify metadata preservation settings
grep -r "preserve-modtime\|keep-foreign-metadata" configs/

# Re-convert with explicit metadata preservation
./scripts/convert_with_external_advanced.sh input.wav flac suffix
```

#### 16. Quality Analysis Failures

**Symptoms:**
```
foobar-quality command fails
MediaInfo not providing expected output
```

**Solution:**
```bash
# Install/reinstall MediaInfo
brew reinstall mediainfo

# Test MediaInfo directly
mediainfo --version
mediainfo input.flac

# Check file permissions
chmod 644 input.flac
```

## Advanced Troubleshooting

### Debug Mode Usage

Enable comprehensive debugging:
```bash
# Set debug environment
export DEBUG=1
export VERBOSE=1

# Run problematic command
./scripts/convert_with_external_advanced.sh input.wav flac suffix

# View detailed logs
tail -f ~/Library/foobar2000-v2/logs/conversion.log
```

### Log Analysis

#### Understanding Log Entries
```bash
# Conversion logs
[2025-08-21 22:00:00] [INFO] Starting conversion...
[2025-08-21 22:00:01] [SUCCESS] FLAC conversion completed
[2025-08-21 22:00:01] [ERROR] Failed to create output file

# System logs
tail -f /var/log/system.log | grep foobar
```

#### Log Locations
- **Installation**: `./foobar2000-automation.log`
- **Conversion**: `~/Library/foobar2000-v2/logs/conversion.log`
- **Updates**: `~/Library/foobar2000-v2/logs/update.log`
- **Monitoring**: `~/Library/foobar2000-v2/logs/monitor.log`

### System Information Collection

For bug reports, collect comprehensive system information:

```bash
#!/bin/bash
# System diagnosis script

echo "=== System Information ==="
sw_vers
uname -a
echo ""

echo "=== Architecture ==="
uname -m
echo ""

echo "=== Homebrew Status ==="
brew --version
brew --prefix
echo ""

echo "=== Encoder Status ==="
which flac lame opusenc ffmpeg
flac --version 2>/dev/null | head -1
lame --version 2>/dev/null | head -1
opusenc --version 2>/dev/null | head -1
ffmpeg -version 2>/dev/null | head -1
echo ""

echo "=== Installation Status ==="
ls -la ~/Library/foobar2000-v2/
echo ""

echo "=== Recent Logs ==="
if [[ -f ~/Library/foobar2000-v2/logs/conversion.log ]]; then
    tail -20 ~/Library/foobar2000-v2/logs/conversion.log
fi
echo ""

echo "=== Validation Report ==="
./scripts/validator.sh --quiet 2>&1
```

### Recovery Procedures

#### Complete System Reset
```bash
# Stop all processes
pkill -f foobar
pkill -f convert_with_external

# Remove system files
rm -rf ~/Library/foobar2000-v2/

# Uninstall components
brew uninstall flac lame opus-tools ffmpeg mediainfo

# Clean Homebrew
brew cleanup
brew doctor

# Fresh installation
./scripts/install.sh --profile standard --mode automatic
```

#### Partial Recovery
```bash
# Reset configuration only
cp ~/Library/foobar2000-v2/encoder_presets_macos.cfg ~/Desktop/backup.cfg
./scripts/config-generator.sh --profile standard --backup

# Reset functions only
source ~/Library/foobar2000-v2/foobar2000_fish_functions.fish

# Update system files only
./scripts/update_system.sh --backup
```

## Getting Help

### Information to Include in Bug Reports

1. **System Information**:
   ```bash
   sw_vers
   uname -m
   brew --version
   ```

2. **Error Messages**: Complete error output with context

3. **Steps to Reproduce**: Exact commands and files used

4. **Log Files**: Relevant log entries from the time of error

5. **Configuration**: Profile used and any customizations

### Diagnostic Commands

Quick diagnostic command sequence:
```bash
# Complete system check
./scripts/validator.sh --detailed --report diagnostic_report.json

# Test basic functionality
echo "Test file" > test.txt
./scripts/convert_with_external_advanced.sh --help

# Check Fish integration
if command -v fish >/dev/null; then
    fish -c "functions | grep foobar"
fi
```

### Community Resources

- **GitHub Issues**: Report bugs with diagnostic information
- **Discussions**: Ask questions and share solutions  
- **Wiki**: Community-maintained troubleshooting tips

### Professional Support

For complex issues:
- Provide complete diagnostic report
- Include system logs and error messages
- Describe the specific use case and requirements
- Mention any custom configurations or modifications

## Prevention Best Practices

### Regular Maintenance
```bash
# Weekly maintenance script
#!/bin/bash

# Update Homebrew and components
brew update && brew upgrade

# Clean up old logs
find ~/Library/foobar2000-v2/logs/ -name "*.log" -mtime +30 -delete

# Clear temporary files
rm -rf ~/Library/foobar2000-v2/temp/*

# Validate system
./scripts/validator.sh --quiet
```

### Backup Strategy
```bash
# Backup configuration
tar -czf ~/Desktop/foobar2000-backup-$(date +%Y%m%d).tar.gz ~/Library/foobar2000-v2/

# Backup custom configurations
cp ~/Library/foobar2000-v2/encoder_presets_macos.cfg ~/Desktop/
```

### Monitoring Setup
```bash
# Set up system monitoring
# Add to crontab for regular health checks
0 6 * * * ~/path/to/foobar2000-automation-macos/scripts/validator.sh --quiet >> /var/log/foobar2000-health.log
```

Most issues can be resolved by following this troubleshooting guide. For persistent problems, gather the diagnostic information outlined above and seek community support through the project's GitHub repository.