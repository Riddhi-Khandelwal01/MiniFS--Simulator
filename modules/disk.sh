#!/bin/bash

# ==========================================================
# Mini File System Simulator - Disk Management Module
# ==========================================================

# ---------------- CONFIGURATION ----------------

# Base directory of the simulated file system
DISK_PATH="mini_fs_storage"

# Root directory where the simulated files and directories exist
ROOT_PATH="$DISK_PATH/root"

# Metadata directory (internal MiniFS information)
META_PATH="$DISK_PATH/.metadata"

# Disk information file
DISK_INFO="$META_PATH/disk_info.txt"

# Total simulated disk capacity in KB
TOTAL_DISK_SIZE=10240


# ==========================================================
# FUNCTION: is_disk_formatted
# Checks whether the MiniFS disk has been initialized
# ==========================================================

is_disk_formatted() {
    if [ -d "$DISK_PATH" ] && [ -d "$ROOT_PATH" ] && [ -f "$DISK_INFO" ]; then
        return 0
    else
        return 1
    fi
}


# ==========================================================
# FUNCTION: get_used_space
# Calculates the current storage used by the simulated disk
# ==========================================================

get_used_space() {

    if ! is_disk_formatted; then
        echo "0"
        return
    fi

    # Calculate size in KB
    du -sk "$DISK_PATH" 2>/dev/null | awk '{print $1}'
}


# ==========================================================
# FUNCTION: get_free_space
# Calculates the remaining simulated disk space
# ==========================================================

get_free_space() {

    local used_space
    used_space=$(get_used_space)

    local free_space=$((TOTAL_DISK_SIZE - used_space))

    # Do not show negative disk space
    if [ "$free_space" -lt 0 ]; then
        free_space=0
    fi

    echo "$free_space"
}


# ==========================================================
# FUNCTION: format_disk
# Creates or resets the simulated MiniFS disk
# ==========================================================

format_disk() {

    # Warn before deleting an existing simulated disk
    if [ -d "$DISK_PATH" ]; then
        echo "Warning: Formatting will erase all MiniFS data."

        read -r -p "Continue? (y/n): " choice

        case "$choice" in
            y|Y|yes|YES)
                echo "Formatting MiniFS disk..."
                ;;
            *)
                echo "Format cancelled."
                return
                ;;
        esac

        # Remove only the simulated disk, never real system files
        rm -rf "$DISK_PATH"
    fi

    # Create the MiniFS structure
    mkdir -p "$ROOT_PATH"
    mkdir -p "$META_PATH"

    # Save disk metadata
    cat > "$DISK_INFO" << EOF
========================================
        MiniFS Disk Information
========================================
Status: FORMATTED
Total Capacity: ${TOTAL_DISK_SIZE} KB
Root Directory: $ROOT_PATH
EOF

    echo "----------------------------------------"
    echo "MiniFS disk formatted successfully!"
    echo "Total capacity: ${TOTAL_DISK_SIZE} KB"
    echo "Root directory: $ROOT_PATH"
    echo "----------------------------------------"
}


# ==========================================================
# FUNCTION: show_disk_usage
# Displays simulated disk usage information
# ==========================================================

show_disk_usage() {

    if ! is_disk_formatted; then
        echo "Error: MiniFS disk is not formatted."
        echo "Please run 'format' first."
        return
    fi

    local used_space
    local free_space

    used_space=$(get_used_space)
    free_space=$(get_free_space)

    local usage_percent=0

    if [ "$TOTAL_DISK_SIZE" -gt 0 ]; then
        usage_percent=$((used_space * 100 / TOTAL_DISK_SIZE))
    fi

    echo "========================================"
    echo "           MiniFS Disk Usage"
    echo "========================================"
    echo "Total Space : ${TOTAL_DISK_SIZE} KB"
    echo "Used Space  : ${used_space} KB"
    echo "Free Space  : ${free_space} KB"
    echo "Usage       : ${usage_percent}%"
    echo "========================================"
}


# ==========================================================
# FUNCTION: show_disk_info
# Displays information about the simulated disk
# ==========================================================

show_disk_info() {

    if ! is_disk_formatted; then
        echo "Error: MiniFS disk is not formatted."
        echo "Please run 'format' first."
        return
    fi

    cat "$DISK_INFO"
}


# ==========================================================
# FUNCTION: check_disk_space
# Used by other modules before creating large files
#
# Usage:
#     check_disk_space <required_space_in_KB>
# ==========================================================

check_disk_space() {

    local required_space="$1"
    local free_space

    # Validate input
    if ! [[ "$required_space" =~ ^[0-9]+$ ]]; then
        return 1
    fi

    free_space=$(get_free_space)

    if [ "$required_space" -le "$free_space" ]; then
        return 0
    else
        return 1
    fi
}