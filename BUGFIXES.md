# foobar2000 macOS Automation Bug Fixes

## Version: 2025-08-21

### Critical Batch Conversion Issues Fixed

#### Issue 1: Script Crash During Batch Conversion
**Files**: `foobar_menu_fish.sh`, `convert_with_external_advanced.sh`

**Symptoms**:
- Interactive menu crashed after selecting files for conversion
- Script terminated without processing files
- No progress output from conversion utilities

**Causes**:
1. `set -euo pipefail` caused immediate exit on any error
2. Process substitution `< <(find ...)` with `while read` was unstable
3. Interactive prompts in batch mode blocked execution
4. Unsafe array handling with loops

**Fixes**:
1. **Added `--batch` flag** in `convert_with_external_advanced.sh`
   - Automatic backup deletion
   - Disabled foobar2000 addition prompts
   
2. **Replaced file search logic** in `foobar_menu_fish.sh`
   - Removed problematic `while IFS= read -r -d '' file; done < <(...)` construct
   - Used safe command substitution with heredoc
   
3. **Added error handling**
   - Temporary disabling of `set -e` for critical sections
   - Explicit exit code control
   - Graceful recovery on errors

4. **Fixed parameter passing**
   - `foobar_menu_fish.sh` now passes `--batch` flag
   - Correct non-interactive mode handling

#### Issue 2: Missing Conversion Progress Output
**File**: `foobar_menu_fish.sh:274`

**Symptoms**:
- User couldn't see LAME/FLAC/Opus progress
- Missing bitrate and timing information

**Fixes**:
- Removed `>/dev/null 2>&1` redirection
- All conversion utility output now visible to user

#### Issue 3: Unstable Batch Mode Operation
**Files**: `convert_with_external_advanced.sh:283-296, 332-346`

**Symptoms**:
- Interactive prompts blocked batch conversion
- Undefined behavior in automatic mode

**Fixes**:
- Added `BATCH_MODE` variable with `--batch` flag parsing
- Logic `[[ "$BATCH_MODE" == "true" || ! -t 0 ]]` for mode detection
- Automatic responses in batch mode

### Results
- **Batch conversion works stably**
- **Full progress output** for LAME/FLAC/Opus
- **Batch mode** without interactive prompts
- **Error handling** with graceful recovery
- **All format support**: FLAC, MP3 V0/320/Commercial, Opus

### Testing
Tested on:
- **macOS**: Darwin 24.6.0 (Apple Silicon)
- **Shell**: Fish + Bash
- **Files**: 4 MP3 files (48kHz → 44.1kHz, 192 kbps CBR)
- **Modes**: suffix, replace
- **Formats**: mp3_commercial

All tests passed successfully with full progress output and correct file handling.

## Installation Instructions

### For New Installations
```bash
./scripts/install.sh --profile professional --mode automatic
```

### For Existing Installation Updates
```bash
# Copy fixed files
cp scripts/foobar_menu_fish.sh ~/Library/foobar2000-v2/
cp scripts/convert_with_external_advanced.sh ~/Library/foobar2000-v2/
cp scripts/foobar2000_fish_functions.fish ~/Library/foobar2000-v2/

# Reload Fish functions
fish -c "source ~/Library/foobar2000-v2/foobar2000_fish_functions.fish"
```

### Usage
```bash
# Launch interactive menu
foobar-menu

# Select option 5 - Batch Convert Folder
# All fixes are applied automatically
```

## Change History
- **2025-08-21**: Fixed critical batch conversion bugs
- **2025-08-20**: Initial version with known issues