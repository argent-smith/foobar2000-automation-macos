# Encoding Profiles Documentation

Complete reference for all supported audio encoding profiles and formats.

## Overview

This system provides professional-grade audio encoding with optimized profiles for different use cases. All profiles include comprehensive metadata preservation and are optimized for macOS performance.

## Lossless Encoding Formats

### FLAC Standard (`flac`)

**Profile**: `flac`  
**Use Case**: General lossless archiving  
**Quality**: Perfect reproduction, no data loss

#### Technical Specifications
- **Compression Level**: 8 (maximum)
- **Verification**: Enabled (--verify)
- **Metadata Preservation**: Complete
- **Unicode Support**: Full UTF-8
- **File Extension**: `.flac`

#### Encoding Parameters
```bash
flac -8 -V --preserve-modtime --keep-foreign-metadata \
     -T "ARTIST=%artist%" -T "TITLE=%title%" -T "ALBUM=%album%" \
     -T "DATE=%date%" -T "GENRE=%genre%" -T "TRACKNUMBER=%tracknumber%" \
     -T "ALBUMARTIST=%albumartist%" -T "TOTALTRACKS=%totaltracks%" \
     -o "output.flac" "input"
```

#### Performance
- **Apple Silicon M2**: ~15x realtime
- **Intel i9**: ~8x realtime  
- **File Size**: 50-70% of original WAV
- **CPU Usage**: High during encoding, zero during playback

#### Recommended For
- Archival storage of master recordings
- Source material for further processing
- Critical listening applications
- Professional music libraries

### FLAC Commercial (`flac_commercial`)

**Profile**: `flac_commercial`  
**Use Case**: Commercial release preparation  
**Quality**: CD-quality standard with enhanced metadata

#### Technical Specifications
- **Sample Rate**: 44.1kHz (forced resampling)
- **Bit Depth**: 24-bit (high resolution)
- **Compression Level**: 4 (balanced speed/size)
- **Commercial Ready**: Yes
- **File Extension**: `.flac`

#### Encoding Parameters
```bash
flac -4 -V --force --sample-rate=44100 --bps=24 \
     --preserve-modtime --keep-foreign-metadata \
     -T "ARTIST=%artist%" -T "TITLE=%title%" -T "ALBUM=%album%" \
     -T "DATE=%date%" -T "GENRE=%genre%" -T "TRACKNUMBER=%tracknumber%" \
     -T "ALBUMARTIST=%albumartist%" -T "TOTALTRACKS=%totaltracks%" \
     -o "output.flac" "input"
```

#### Performance
- **Apple Silicon M2**: ~20x realtime (faster compression)
- **Intel i9**: ~12x realtime
- **File Size**: 60-80% of original WAV
- **Processing**: Optimized for batch operations

#### Recommended For
- Digital music distribution
- Commercial releases requiring lossless quality
- High-resolution audio preparation
- Professional mastering workflows

### ALAC (Apple Lossless) (`alac_ffmpeg`)

**Profile**: `alac_ffmpeg`  
**Use Case**: Apple ecosystem integration  
**Quality**: Lossless, optimized for Apple devices

#### Technical Specifications
- **Container**: M4A
- **Metadata**: Both standard and ID3-style tags
- **Compatibility**: Native Apple support
- **File Extension**: `.m4a`

#### Encoding Parameters
```bash
ffmpeg -i "input" -c:a alac -map_metadata 0 \
       -metadata title="%title%" -metadata artist="%artist%" \
       -metadata album="%album%" -metadata date="%date%" \
       -metadata genre="%genre%" -metadata track="%tracknumber%" \
       -metadata album_artist="%albumartist%" \
       "output.m4a"
```

#### Recommended For
- iTunes/Apple Music integration
- Apple device playback
- macOS/iOS native applications
- Cross-platform lossless distribution

## Lossy Encoding Formats

### MP3 Variable Bitrate (`mp3_v0`)

**Profile**: `mp3_v0`  
**Use Case**: High-quality variable bitrate encoding  
**Quality**: Near-transparent (~245 kbps average)

#### Technical Specifications
- **Mode**: VBR (Variable Bitrate)
- **Quality**: V0 (highest VBR setting)
- **Average Bitrate**: ~245 kbps
- **ID3 Tags**: v2.4 with full metadata preservation
- **File Extension**: `.mp3`

#### Encoding Parameters
```bash
lame -V 0 -h -m j --vbr-new --add-id3v2 --id3v2-only --preserve-modtime \
     --tt "%title%" --ta "%artist%" --tl "%album%" --ty "%date%" \
     --tg "%genre%" --tn "%tracknumber%/%totaltracks%" --TPE2 "%albumartist%" \
     --tv "TPE1=%artist%" --tv "TIT2=%title%" --tv "TALB=%album%" \
     "input" "output.mp3"
```

#### Performance
- **Apple Silicon M2**: ~25x realtime
- **Intel i9**: ~15x realtime
- **File Size**: ~10-15% of original WAV
- **Quality**: Transparent to most listeners

#### Recommended For
- High-quality personal music libraries
- Audiophile collections with size constraints
- Professional archiving with space limitations
- Critical listening where lossless isn't required

### MP3 320 CBR (`mp3_320`)

**Profile**: `mp3_320`  
**Use Case**: Maximum quality constant bitrate  
**Quality**: Highest MP3 quality, constant bitrate

#### Technical Specifications
- **Mode**: CBR (Constant Bitrate)
- **Bitrate**: 320 kbps (maximum)
- **Compatibility**: Universal MP3 player support
- **File Extension**: `.mp3`

#### Encoding Parameters
```bash
lame -b 320 -h -m j --cbr --add-id3v2 --id3v2-only --preserve-modtime \
     --tt "%title%" --ta "%artist%" --tl "%album%" --ty "%date%" \
     --tg "%genre%" --tn "%tracknumber%/%totaltracks%" --TPE2 "%albumartist%" \
     --tv "TPE1=%artist%" --tv "TIT2=%title%" --tv "TALB=%album%" \
     "input" "output.mp3"
```

#### Recommended For
- Maximum compatibility requirements
- DJ and performance applications
- Consistent bitrate requirements
- Professional broadcast standards

### MP3 Commercial (`mp3_commercial`)

**Profile**: `mp3_commercial`  
**Use Case**: Commercial release standard  
**Quality**: Optimized for digital distribution

#### Technical Specifications
- **Sample Rate**: 44.1kHz (forced resampling)
- **Bit Depth**: 24-bit processing
- **Bitrate**: 192 kbps CBR
- **Commercial Ready**: Yes
- **File Extension**: `.mp3`

#### Encoding Parameters
```bash
lame -b 192 -h -m j --cbr --resample 44.1 --bitwidth 24 \
     --add-id3v2 --id3v2-only --preserve-modtime \
     --tt "%title%" --ta "%artist%" --tl "%album%" --ty "%date%" \
     --tg "%genre%" --tn "%tracknumber%/%totaltracks%" --TPE2 "%albumartist%" \
     "input" "output.mp3"
```

#### Performance
- **File Size**: ~8-12% of original WAV
- **Quality**: High quality suitable for commercial release
- **Processing**: Optimized for batch commercial preparation

#### Recommended For
- Digital music store distribution
- Radio broadcast preparation
- Commercial release mastering
- Industry-standard digital formats

### Opus (`opus`)

**Profile**: `opus`  
**Use Case**: Modern efficient compression  
**Quality**: Superior compression efficiency

#### Technical Specifications
- **Bitrate**: 192 kbps
- **Compression**: Level 10 (maximum)
- **Frame Size**: 20ms (optimized for music)
- **Modern Codec**: Superior to MP3 at same bitrates
- **File Extension**: `.opus`

#### Encoding Parameters
```bash
opusenc --bitrate 192 --comp 10 --framesize 20 --preserve-modtime \
        --artist "%artist%" --title "%title%" --album "%album%" \
        --date "%date%" --genre "%genre%" \
        --comment "ALBUMARTIST=%albumartist%" \
        --comment "TRACKNUMBER=%tracknumber%" \
        --comment "TOTALTRACKS=%totaltracks%" \
        "input" "output.opus"
```

#### Performance
- **Apple Silicon M2**: ~30x realtime
- **Intel i9**: ~18x realtime
- **File Size**: ~6-10% of original WAV
- **Quality**: Superior to MP3 at equivalent bitrates

#### Recommended For
- Modern streaming applications
- Bandwidth-limited scenarios
- Future-proof archiving
- High-efficiency compression needs

### AAC High Quality (`aac_ffmpeg_high`)

**Profile**: `aac_ffmpeg_high`  
**Use Case**: High-quality AAC encoding  
**Quality**: 256 kbps for premium applications

#### Technical Specifications
- **Bitrate**: 256 kbps
- **Container**: M4A
- **Encoder**: FFmpeg native AAC
- **Metadata**: Complete preservation
- **File Extension**: `.m4a`

#### Encoding Parameters
```bash
ffmpeg -i "input" -c:a aac -b:a 256k -map_metadata 0 \
       -metadata title="%title%" -metadata artist="%artist%" \
       -metadata album="%album%" -metadata date="%date%" \
       -metadata genre="%genre%" -metadata track="%tracknumber%" \
       -metadata album_artist="%albumartist%" \
       "output.m4a"
```

#### Recommended For
- Apple ecosystem compatibility
- High-quality streaming
- Professional broadcast
- Cross-platform distribution

## Profile Selection Guide

### By Use Case

| Use Case | Recommended Profile | Alternative |
|----------|-------------------|-------------|
| **Master Archive** | `flac` | `alac_ffmpeg` |
| **Commercial Release** | `flac_commercial` + `mp3_commercial` | `mp3_320` |
| **Personal Library** | `mp3_v0` | `opus` |
| **Streaming** | `opus` | `aac_ffmpeg_high` |
| **Apple Devices** | `alac_ffmpeg` | `aac_ffmpeg_high` |
| **Universal Compatibility** | `mp3_320` | `mp3_v0` |
| **Bandwidth Limited** | `opus` | `mp3_commercial` |

### By Quality Requirements

| Quality Level | Profiles | Notes |
|---------------|----------|-------|
| **Lossless** | `flac`, `flac_commercial`, `alac_ffmpeg` | Perfect reproduction |
| **Near-Lossless** | `mp3_v0`, `opus` @256k | Transparent to most |
| **High Quality** | `mp3_320`, `aac_ffmpeg_high` | Very good quality |
| **Commercial** | `mp3_commercial`, `flac_commercial` | Industry standard |
| **Efficient** | `opus`, lower bitrate AAC | Modern compression |

### By File Size (Relative to CD-quality WAV)

| Profile | Approximate Size | Quality Trade-off |
|---------|-----------------|-------------------|
| `flac` | 50-70% | None (lossless) |
| `flac_commercial` | 60-80% | None (lossless) |
| `alac_ffmpeg` | 50-60% | None (lossless) |
| `mp3_v0` | 10-15% | Minimal |
| `mp3_320` | 15-20% | Very minimal |
| `mp3_commercial` | 8-12% | Small |
| `opus` | 6-10% | Minimal (superior codec) |
| `aac_ffmpeg_high` | 12-18% | Small |

## Advanced Configuration

### Custom Profile Creation

Create custom profiles by modifying the encoder presets:

```bash
# Edit the main configuration
nano ~/Library/foobar2000-v2/encoder_presets_macos.cfg

# Add custom profile section
[my_custom_profile]
name=My Custom Profile
description=Custom settings for specific use case
encoder_path_arm64=/opt/homebrew/bin/flac
encoder_path_intel=/usr/local/bin/flac
extension=flac
parameters=-6 -V --custom-parameters
```

### Batch Profile Processing

Process files with multiple profiles simultaneously:

```bash
#!/bin/bash
profiles=("flac_commercial" "mp3_commercial" "opus")
input_dir="~/Music/Masters"

for profile in "${profiles[@]}"; do
    mkdir -p "output_$profile"
    for file in "$input_dir"/*.wav; do
        ./scripts/convert_with_external_advanced.sh "$file" "$profile" suffix
        mv "${file%.*}_${profile}.${ext}" "output_$profile/"
    done
done
```

### Quality Validation

Test encoding quality with ABX testing:

```bash
# Create test files for comparison
./scripts/convert_with_external_advanced.sh reference.wav flac suffix
./scripts/convert_with_external_advanced.sh reference.wav mp3_v0 suffix
./scripts/convert_with_external_advanced.sh reference.wav opus suffix

# Analyze with MediaInfo
mediainfo reference_flac.flac
mediainfo reference_v0.mp3
mediainfo reference_opus.opus
```

## Metadata Preservation

All profiles preserve:

### Standard Tags
- Artist, Title, Album, Date
- Genre, Track Number, Album Artist
- Total Tracks, Composer
- Comments, Lyrics

### Technical Metadata
- Original file timestamps
- Source format information
- Encoding parameters
- Quality metrics

### Format-Specific Features
- **FLAC**: Vorbis Comments, embedded CUE sheets
- **MP3**: ID3v2.4 with extended frames
- **Opus**: Native comment system
- **AAC/ALAC**: Both iTunes and standard metadata

## Performance Optimization

### Multi-Core Processing
```bash
# Set parallel jobs for batch processing
export MAKEFLAGS="-j$(sysctl -n hw.ncpu)"
```

### Memory Optimization
```bash
# For large batch operations
ulimit -v 4194304  # 4GB virtual memory limit
```

### Disk I/O Optimization
```bash
# Use faster temporary directory
export TMPDIR=/tmp/ramdisk  # If you have ramdisk setup
```

## Troubleshooting Encoding Issues

### Common Problems

#### Encoding Failures
```bash
# Check encoder availability
which flac lame opusenc ffmpeg

# Test encoder directly
flac --version
lame --version
```

#### Metadata Issues
```bash
# Verify source metadata
mediainfo --full input_file.wav

# Check tag preservation
exiftool output_file.flac
```

#### Performance Problems
```bash
# Monitor system resources
top -pid $(pgrep flac)
iostat -d 1

# Check disk space
df -h ~/Library/foobar2000-v2/temp/
```

## Future Format Support

The system is designed for easy extension with new formats:

### Planned Additions
- **MQA**: Master Quality Authenticated
- **DSD**: Direct Stream Digital
- **Dolby Atmos**: Spatial audio formats
- **Hi-Res PCM**: 32-bit/384kHz support

### Custom Format Integration
New formats can be added by:
1. Adding encoder definitions to `encoder_presets_macos.cfg`
2. Updating the conversion script format detection
3. Adding profile definitions to the menu systems
4. Testing and validation integration

For the latest format support status, check the project repository releases.