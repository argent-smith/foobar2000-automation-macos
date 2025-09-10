#!/bin/bash
#
# System Update Script for foobar2000 macOS Automation
# Updates installed system scripts, functions and configurations from repository
#
# Usage: ./update_system.sh [--dry-run] [--backup] [--force]
#

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
SYSTEM_DIR="$HOME/Library/foobar2000-v2"
BACKUP_DIR="$SYSTEM_DIR/backups/$(date +%Y%m%d_%H%M%S)"
LOG_FILE="$SYSTEM_DIR/logs/update.log"

# Colors
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'

# Parse command line arguments
DRY_RUN=false
CREATE_BACKUP=false
FORCE_UPDATE=false

for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --backup)
            CREATE_BACKUP=true
            shift
            ;;
        --force)
            FORCE_UPDATE=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo "Options:"
            echo "  --dry-run    Show what would be updated without making changes"
            echo "  --backup     Create backup of existing files before update"
            echo "  --force      Force update even if files are newer in system"
            echo "  --help       Show this help message"
            exit 0
            ;;
        *)
            echo "Unknown option: $arg"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Create necessary directories
mkdir -p "$SYSTEM_DIR/logs" "$SYSTEM_DIR/backups"

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] [$level] $message" | tee -a "$LOG_FILE"
}

log_info() { log "INFO" "$@"; echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { log "SUCCESS" "$@"; echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warning() { log "WARNING" "$@"; echo -e "${YELLOW}[WARNING]${NC} $*"; }
log_error() { log "ERROR" "$@"; echo -e "${RED}[ERROR]${NC} $*"; }

# Header
show_header() {
    echo -e "${CYAN}=====================================${NC}"
    echo -e "${CYAN}  foobar2000 macOS System Updater   ${NC}"
    echo -e "${CYAN}=====================================${NC}"
    echo
    echo -e "${BLUE}Repository:${NC} $REPO_ROOT"
    echo -e "${BLUE}System Directory:${NC} $SYSTEM_DIR"
    if [[ "$DRY_RUN" == "true" ]]; then
        echo -e "${YELLOW}Mode: DRY RUN (no changes will be made)${NC}"
    fi
    if [[ "$CREATE_BACKUP" == "true" ]]; then
        echo -e "${BLUE}Backup Directory:${NC} $BACKUP_DIR"
    fi
    echo
}

# Check if repository exists and is valid
check_repository() {
    log_info "Checking repository structure..."
    
    if [[ ! -d "$REPO_ROOT" ]]; then
        log_error "Repository root not found: $REPO_ROOT"
        return 1
    fi
    
    if [[ ! -d "$REPO_ROOT/scripts" ]]; then
        log_error "Scripts directory not found: $REPO_ROOT/scripts"
        return 1
    fi
    
    if [[ ! -d "$REPO_ROOT/configs" ]]; then
        log_error "Configs directory not found: $REPO_ROOT/configs"
        return 1
    fi
    
    log_success "Repository structure validated"
    return 0
}

# Create backup of existing files
create_backup() {
    if [[ "$CREATE_BACKUP" != "true" ]]; then
        return 0
    fi
    
    log_info "Creating backup in: $BACKUP_DIR"
    
    if [[ "$DRY_RUN" == "true" ]]; then
        echo "  [DRY RUN] Would create backup directory"
        return 0
    fi
    
    mkdir -p "$BACKUP_DIR"
    
    # Backup existing files
    local backup_count=0
    for file in \
        "convert_with_external_advanced.sh" \
        "foobar_menu_fish.sh" \
        "foobar2000_fish_functions.fish" \
        "foobar_integration_setup.sh" \
        "foobar_monitor.sh" \
        "encoder_presets_macos.cfg"; do
        
        if [[ -f "$SYSTEM_DIR/$file" ]]; then
            cp "$SYSTEM_DIR/$file" "$BACKUP_DIR/"
            ((backup_count++))
            log_info "Backed up: $file"
        fi
    done
    
    log_success "Created backup of $backup_count files"
}

# Compare file modification times
is_newer() {
    local repo_file="$1"
    local system_file="$2"
    
    if [[ ! -f "$system_file" ]]; then
        return 0  # System file doesn't exist, repo is "newer"
    fi
    
    if [[ "$FORCE_UPDATE" == "true" ]]; then
        return 0  # Force update regardless
    fi
    
    # Compare modification times
    local repo_time=$(stat -f %m "$repo_file" 2>/dev/null || echo 0)
    local system_time=$(stat -f %m "$system_file" 2>/dev/null || echo 0)
    
    [[ "$repo_time" -gt "$system_time" ]]
}

# Update individual file
update_file() {
    local repo_file="$1"
    local system_file="$2"
    local description="$3"
    
    if [[ ! -f "$repo_file" ]]; then
        log_warning "Source file not found: $repo_file"
        return 1
    fi
    
    if is_newer "$repo_file" "$system_file"; then
        if [[ "$DRY_RUN" == "true" ]]; then
            echo -e "  ${GREEN}[UPDATE]${NC} $description"
            return 0
        fi
        
        cp "$repo_file" "$system_file"
        chmod +x "$system_file" 2>/dev/null || true
        log_success "Updated: $description"
        return 0
    else
        echo -e "  ${YELLOW}[SKIP]${NC} $description (system file is newer or same)"
        return 0
    fi
}

# Main update function
perform_update() {
    log_info "Starting system update..."
    
    local update_count=0
    
    # Core conversion scripts
    echo -e "${CYAN}Updating core scripts:${NC}"
    if update_file "$REPO_ROOT/scripts/convert_with_external_advanced.sh" \
                   "$SYSTEM_DIR/convert_with_external_advanced.sh" \
                   "Advanced conversion script"; then
        ((update_count++))
    fi
    
    if update_file "$REPO_ROOT/scripts/foobar_integration_setup.sh" \
                   "$SYSTEM_DIR/foobar_integration_setup.sh" \
                   "Integration setup script"; then
        ((update_count++))
    fi
    
    # Check for monitor script in scripts directory
    if [[ -f "$REPO_ROOT/scripts/foobar_monitor.sh" ]]; then
        if update_file "$REPO_ROOT/scripts/foobar_monitor.sh" \
                       "$SYSTEM_DIR/foobar_monitor.sh" \
                       "Monitoring script"; then
            ((update_count++))
        fi
    fi
    
    echo
    echo -e "${CYAN}Updating menu and functions:${NC}"
    if update_file "$REPO_ROOT/scripts/foobar_menu_fish.sh" \
                   "$SYSTEM_DIR/foobar_menu_fish.sh" \
                   "Fish shell menu"; then
        ((update_count++))
    fi
    
    if update_file "$REPO_ROOT/scripts/foobar2000_fish_functions.fish" \
                   "$SYSTEM_DIR/foobar2000_fish_functions.fish" \
                   "Fish shell functions"; then
        ((update_count++))
    fi
    
    echo
    echo -e "${CYAN}Updating configurations:${NC}"
    if update_file "$REPO_ROOT/configs/presets/encoder_presets_macos.cfg" \
                   "$SYSTEM_DIR/encoder_presets_macos.cfg" \
                   "Encoder presets configuration"; then
        ((update_count++))
    fi
    
    # Update other configuration files if they exist
    if [[ -f "$REPO_ROOT/configs/scripts/MASSTAGGER_MACOS.txt" ]]; then
        mkdir -p "$SYSTEM_DIR/scripts"
        if update_file "$REPO_ROOT/configs/scripts/MASSTAGGER_MACOS.txt" \
                       "$SYSTEM_DIR/scripts/MASSTAGGER_MACOS.txt" \
                       "Masstagger scripts"; then
            ((update_count++))
        fi
    fi
    
    if [[ -f "$REPO_ROOT/configs/templates/macos_integration.cfg" ]]; then
        mkdir -p "$SYSTEM_DIR/templates"
        if update_file "$REPO_ROOT/configs/templates/macos_integration.cfg" \
                       "$SYSTEM_DIR/templates/macos_integration.cfg" \
                       "macOS integration templates"; then
            ((update_count++))
        fi
    fi
    
    echo
    if [[ "$DRY_RUN" == "true" ]]; then
        log_info "Dry run completed. $update_count files would be updated."
    else
        log_success "Update completed. $update_count files updated."
    fi
}

# Verify installation
verify_installation() {
    if [[ "$DRY_RUN" == "true" ]]; then
        return 0
    fi
    
    log_info "Verifying installation..."
    
    local verification_failed=false
    
    # Check core files
    for file in \
        "convert_with_external_advanced.sh" \
        "foobar_menu_fish.sh" \
        "foobar2000_fish_functions.fish" \
        "encoder_presets_macos.cfg"; do
        
        if [[ -f "$SYSTEM_DIR/$file" ]]; then
            log_success "Verified: $file"
        else
            log_error "Missing: $file"
            verification_failed=true
        fi
    done
    
    # Check executability of scripts
    for script in \
        "convert_with_external_advanced.sh" \
        "foobar_menu_fish.sh"; do
        
        if [[ -x "$SYSTEM_DIR/$script" ]]; then
            log_success "Executable: $script"
        else
            log_warning "Not executable: $script"
            if [[ -f "$SYSTEM_DIR/$script" ]]; then
                chmod +x "$SYSTEM_DIR/$script"
                log_success "Fixed permissions: $script"
            fi
        fi
    done
    
    if [[ "$verification_failed" == "true" ]]; then
        log_error "Verification failed - some files are missing"
        return 1
    else
        log_success "Installation verification completed"
        return 0
    fi
}

# Show post-update instructions
show_post_update() {
    if [[ "$DRY_RUN" == "true" ]]; then
        return 0
    fi
    
    echo
    echo -e "${CYAN}=====================================${NC}"
    echo -e "${CYAN}         Post-Update Instructions    ${NC}"
    echo -e "${CYAN}=====================================${NC}"
    echo
    echo -e "${BLUE}To reload Fish functions:${NC}"
    echo "  source ~/Library/foobar2000-v2/foobar2000_fish_functions.fish"
    echo
    echo -e "${BLUE}To test the updated system:${NC}"
    echo "  foobar-menu                    # Interactive menu"
    echo "  bash ~/Library/foobar2000-v2/foobar_menu_fish.sh"
    echo
    echo -e "${BLUE}Available formats now include:${NC}"
    echo "  flac, flac_commercial, flac_commercial_16-bit, mp3_v0, mp3_320, mp3_commercial, mp3_commercial_16-bit, opus"
    echo
    if [[ "$CREATE_BACKUP" == "true" ]]; then
        echo -e "${YELLOW}Backup created in:${NC} $BACKUP_DIR"
        echo
    fi
    echo -e "${BLUE}Logs available at:${NC} $LOG_FILE"
    echo
}

# Main execution
main() {
    show_header
    
    if ! check_repository; then
        log_error "Repository validation failed"
        exit 1
    fi
    
    create_backup
    
    perform_update
    
    if ! verify_installation; then
        log_error "Installation verification failed"
        exit 1
    fi
    
    show_post_update
    
    log_success "System update completed successfully"
}

# Handle script interruption
cleanup_on_exit() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        log_error "Update process interrupted (exit code: $exit_code)"
    fi
    exit $exit_code
}

trap cleanup_on_exit EXIT INT TERM

# Execute main function
main "$@"