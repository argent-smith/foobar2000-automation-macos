# foobar2000 File Monitoring

## Primary Solution - bash Script

**File:** `scripts/foobar_monitor.sh`

### Advantages:
- No additional dependencies required
- Works out-of-the-box on any macOS
- Two operation modes: fswatch and polling
- Built-in logging
- Command-line management

### Usage:
```bash
# Start monitoring
bash ~/Library/foobar2000-v2/foobar_monitor.sh

# Check status
bash ~/Library/foobar2000-v2/foobar_monitor.sh --status

# Stop monitoring
bash ~/Library/foobar2000-v2/foobar_monitor.sh --stop
```

### Operation Modes:

1. **With fswatch (recommended):**
   ```bash
   brew install fswatch
   ```
   - Instant reaction to changes
   - Minimal resource consumption
   - Uses macOS system events

2. **Polling mode:**
   - No additional installations required
   - Check every 5 seconds
   - Higher system load

## Other Alternatives

### 1. launchd + Folder Actions

Automatic launch via macOS system services:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.foobar2000.monitor</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>/Users/username/Library/foobar2000-v2/foobar_monitor.sh</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/Users/username/Library/foobar2000-v2/logs/launchd.log</string>
</dict>
</plist>
```

### 2. AppleScript + Folder Actions

Create Folder Action for automatic processing:

```applescript
on adding folder items to this_folder after receiving added_items
    repeat with this_item in added_items
        set item_path to POSIX path of this_item
        
        -- Check audio format
        if item_path ends with ".flac" or item_path ends with ".mp3" or ¬
           item_path ends with ".wav" or item_path ends with ".m4a" then
            
            tell application "foobar2000"
                open this_item
            end tell
            
        end if
    end repeat
end adding folder items to
```

### 3. Hazel (Commercial Solution)

If Hazel is installed:
- Create rule for `~/Music/Import` folder
- Condition: file matches audio formats
- Action: open in foobar2000

### 4. Automator Workflow

Create Automator workflow:
1. New "Folder Action"
2. Select `~/Music/Import` folder
3. Add "Filter Finder Items" action (audio files)
4. Add "Open Finder Items" action (in foobar2000)

## Solution Comparison

| Solution | Installation | Resources | Speed | Reliability |
|----------|-------------|-----------|-------|-------------|
| Bash + fswatch | ★★★★☆ | ★★★★★ | ★★★★★ | ★★★★★ |
| Bash polling | ★★★★★ | ★★★☆☆ | ★★★☆☆ | ★★★★☆ |
| launchd | ★★☆☆☆ | ★★★★★ | ★★★★★ | ★★★★★ |
| Folder Actions | ★★★☆☆ | ★★★★☆ | ★★★★☆ | ★★★☆☆ |
| Hazel | ★★★★★ | ★★★★☆ | ★★★★★ | ★★★★★ |
| Automator | ★★★★☆ | ★★★★☆ | ★★★★☆ | ★★★☆☆ |

## Recommendation

For most users, the **bash script** with fswatch installation is recommended:

```bash
# Install fswatch
brew install fswatch

# Start monitoring
bash ~/Library/foobar2000-v2/foobar_monitor.sh
```

This provides the optimal balance between installation simplicity, performance, and reliability.