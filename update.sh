#!/bin/bash
#
# Simple wrapper for the system update script
# Usage: ./update.sh [options]
#

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Execute the main update script
exec "$SCRIPT_DIR/scripts/update_system.sh" "$@"