# System Update Guide

This document explains how to update your installed foobar2000 automation system with the latest changes from the repository.

## Quick Update

```bash
# Simple update (recommended)
./update.sh

# Update with backup of existing files
./update.sh --backup

# See what would be updated without making changes
./update.sh --dry-run
```

## Update Script Options

```bash
./update.sh [options]
```

### Available Options

- `--dry-run` - Show what would be updated without making any changes
- `--backup` - Create backup of existing files before update
- `--force` - Force update even if system files are newer than repository files
- `--help` - Show help message

### Examples

```bash
# Safe update with backup
./update.sh --backup

# Check what needs updating
./update.sh --dry-run

# Force complete update
./update.sh --force --backup

# Get help
./update.sh --help
```

## What Gets Updated

The update script synchronizes the following files:

### Core Scripts
- `convert_with_external_advanced.sh` - Advanced conversion engine
- `foobar_integration_setup.sh` - System integration setup
- `foobar_monitor.sh` - File monitoring daemon

### User Interface
- `foobar_menu_fish.sh` - Interactive menu system
- `foobar2000_fish_functions.fish` - Fish shell function library

### Configurations
- `encoder_presets_macos.cfg` - Audio encoder configurations
- `MASSTAGGER_MACOS.txt` - Mass tagging scripts
- `macos_integration.cfg` - macOS integration templates

## Post-Update Steps

After running the update script:

1. **Reload Fish Functions** (if using Fish shell):
   ```bash
   source ~/Library/foobar2000-v2/foobar2000_fish_functions.fish
   ```

2. **Test the System**:
   ```bash
   # Interactive menu
   foobar-menu
   
   # Or direct script access
   bash ~/Library/foobar2000-v2/foobar_menu_fish.sh
   ```

3. **Verify New Features**:
   - Test new encoding formats: `flac_commercial`, `mp3_commercial`
   - Check metadata preservation in conversions
   - Verify all menu options work correctly

## File Locations

- **Repository**: `/Users/paul/work/music/foobar2000-automation-macos/`
- **System Installation**: `~/Library/foobar2000-v2/`
- **Update Logs**: `~/Library/foobar2000-v2/logs/update.log`
- **Backups**: `~/Library/foobar2000-v2/backups/YYYYMMDD_HHMMSS/`

## Safety Features

- **Backup Creation**: Use `--backup` to save current files before update
- **Dry Run Mode**: Use `--dry-run` to preview changes without applying them
- **Timestamp Checking**: Only updates files that are newer in repository
- **Verification**: Automatically checks installation after update
- **Logging**: All operations logged to `update.log`

## Troubleshooting

### Update Script Won't Run
```bash
# Make sure script is executable
chmod +x update.sh
```

### Permission Errors
```bash
# Fix permissions for system directory
chmod -R u+w ~/Library/foobar2000-v2/
```

### Fish Functions Not Loading
```bash
# Manually reload functions
source ~/Library/foobar2000-v2/foobar2000_fish_functions.fish

# Or add to Fish config
echo "source ~/Library/foobar2000-v2/foobar2000_fish_functions.fish" >> ~/.config/fish/config.fish
```

### Rollback to Previous Version
If you created a backup with `--backup`:

```bash
# Find your backup
ls ~/Library/foobar2000-v2/backups/

# Restore from backup
cp ~/Library/foobar2000-v2/backups/YYYYMMDD_HHMMSS/* ~/Library/foobar2000-v2/
```

## Development Workflow

For developers working on the automation system:

```bash
# Make changes to repository files
# Test changes locally
# Run dry-run to see what would update
./update.sh --dry-run

# Apply updates with backup
./update.sh --backup

# Test updated system
foobar-menu
```

## Version Information

This update system was introduced with the addition of:
- FLAC Commercial encoding (44.1kHz, 24-bit)
- MP3 Commercial encoding (44.1kHz, 24-bit, 192kbps)
- Enhanced metadata preservation across all formats
- Improved Fish shell integration

For support or issues, check the logs at `~/Library/foobar2000-v2/logs/update.log`.