#!/usr/bin/env bash

# Small metadata tables shared by the advanced utilities.
declare -Ag UTIL_MODES=()
declare -Ag UTIL_INODES=()
declare -Ag UTIL_SYMLINKS=()
UTIL_NEXT_INODE=1

utilities_error() {
    printf 'Error: %s\n' "$*" >&2
}

# Normalize a virtual path without depending on another module's private helper.
utilities_normalize() {
    local input=${1:-.} full part result=""
    local -a parts=()
    if [[ "$input" == /* ]]; then
        full=$input
    else
        full="${CURRENT_DIR:-/}/$input"
    fi
    IFS='/' read -r -a parts <<< "$full"
    for part in "${parts[@]}"; do
        case "$part" in
            ''|.) ;;
            ..) [[ -n "$result" ]] && result=${result%/*} ;;
            *) result="$result/$part" ;;
        esac
    done
    printf '%s\n' "${result:-/}"
}

utilities_path_type() {
    local path=$1
    if [[ -n "${UTIL_SYMLINKS[$path]+yes}" ]]; then
        printf 'symlink\n'
    elif [[ -n "${FILES[$path]+yes}" ]]; then
        printf 'file\n'
    elif [[ -n "${DIRS[$path]+yes}" ]]; then
        printf 'directory\n'
    else
        return 1
    fi
}

utilities_register_path() {
    local path=$1 type=$2
    if [[ -z "${UTIL_INODES[$path]+yes}" ]]; then
        UTIL_INODES[$path]=$UTIL_NEXT_INODE
        UTIL_NEXT_INODE=$((UTIL_NEXT_INODE + 1))
    fi
    if [[ -z "${UTIL_MODES[$path]+yes}" ]]; then
        case "$type" in
            file) UTIL_MODES[$path]=644 ;;
            directory) UTIL_MODES[$path]=755 ;;
            symlink) UTIL_MODES[$path]=777 ;;
        esac
    fi
}

utilities_parent_path() {
    local path=$1 parent=${1%/*}
    [[ -n "$parent" ]] || parent=/
    printf '%s\n' "$parent"
}

utilities_file_size() {
    local LC_ALL=C
    printf '%s' "${#FILES[$1]}"
}

change_permissions() {
    (( $# == 2 )) || { utilities_error 'Usage: chmod <mode> <path>'; return 2; }
    [[ "$1" =~ ^[0-7]{3,4}$ ]] || {
        utilities_error 'Use a three- or four-digit octal mode, such as 640 or 0755.'
        return 2
    }
    local path type
    path=$(utilities_normalize "$2") || return 1
    type=$(utilities_path_type "$path") || { utilities_error "Path not found: $path"; return 1; }
    [[ "$type" == file || "$type" == directory ]] || {
        utilities_error 'chmod supports files and directories only.'
        return 1
    }
    utilities_register_path "$path" "$type"
    local mode_value mode_path
    mode_value=$((8#$1))
    if [[ "$type" == file ]]; then
        for mode_path in "${!FILES[@]}"; do
            [[ -n "${UTIL_SYMLINKS[$mode_path]+yes}" ]] && continue
            if [[ "${UTIL_INODES[$mode_path]:-}" == "${UTIL_INODES[$path]}" ]]; then
                UTIL_MODES[$mode_path]=$(printf '%o' "$mode_value")
            fi
        done
    else
        UTIL_MODES[$path]=$(printf '%o' "$mode_value")
    fi
    printf 'Permissions for %s set to %s\n' "$path" "$1"
}

create_link() {
    local symbolic=0
    if [[ "${1:-}" == -s ]]; then symbolic=1; shift; fi
    (( $# == 2 )) || { utilities_error 'Usage: ln [-s] <target> <link-name>'; return 2; }

    local target link parent type
    target=$(utilities_normalize "$1") || return 1
    link=$(utilities_normalize "$2") || return 1
    parent=$(utilities_parent_path "$link")
    [[ -n "${DIRS[$parent]+yes}" ]] || { utilities_error "Link directory not found: $parent"; return 1; }
    [[ -z "$(utilities_path_type "$link" 2>/dev/null)" ]] || { utilities_error "Link destination already exists: $link"; return 1; }

    if (( symbolic )); then
        type=$(utilities_path_type "$target" 2>/dev/null) || {
            utilities_error "Symbolic link target must currently exist: $target"
            return 1
        }
        [[ "$type" == file ]] || { utilities_error 'This simulator supports symbolic links to files only.'; return 1; }
        utilities_register_path "$target" file
        UTIL_SYMLINKS[$link]=$target
        UTIL_INODES[$link]=$UTIL_NEXT_INODE
        UTIL_NEXT_INODE=$((UTIL_NEXT_INODE + 1))
        UTIL_MODES[$link]=777
        # The file module stores contents by path. Keep the link readable by
        # its existing cat command while stat and du still identify it as a link.
        FILES[$link]=${FILES[$target]}
        printf 'Symbolic link created: %s -> %s\n' "$link" "$target"
    else
        type=$(utilities_path_type "$target" 2>/dev/null) || {
            utilities_error "Hard link target not found: $target"
            return 1
        }
        [[ "$type" == file ]] || { utilities_error 'Hard links are supported for regular files only.'; return 1; }
        utilities_register_path "$target" file
        FILES[$link]=${FILES[$target]}
        UTIL_INODES[$link]=${UTIL_INODES[$target]}
        UTIL_MODES[$link]=${UTIL_MODES[$target]:-644}
        printf 'Hard link created: %s -> %s\n' "$link" "$target"
    fi
}

show_statistics() {
    (( $# == 1 )) || { utilities_error 'Usage: stat <path>'; return 2; }
    local path type size links=1 inode mode
    path=$(utilities_normalize "$1") || return 1
    type=$(utilities_path_type "$path") || { utilities_error "Path not found: $path"; return 1; }
    utilities_register_path "$path" "$type"
    inode=${UTIL_INODES[$path]}
    mode=${UTIL_MODES[$path]}
    size=0

    case "$type" in
        file) size=$(utilities_file_size "$path") ;;
        symlink)
            local LC_ALL=C
            size=${#UTIL_SYMLINKS[$path]}
            ;;
    esac
    if [[ "$type" == file ]]; then
        local other
        links=0
        for other in "${!FILES[@]}"; do
            [[ -n "${UTIL_SYMLINKS[$other]+yes}" ]] && continue
            [[ "${UTIL_INODES[$other]:-}" == "$inode" ]] && links=$((links + 1))
        done
        (( links > 0 )) || links=1
    fi
    printf 'Path: %s\nType: %s\nInode: %s\nPermissions: %04o\nSize: %s bytes\nLinks: %s\n' \
        "$path" "$type" "$inode" "$((8#$mode))" "$size" "$links"
    if [[ "$type" == symlink ]]; then
        printf 'Target: %s\n' "${UTIL_SYMLINKS[$path]}"
    fi
}

utilities_usage() {
    local root=$1 bytes=0 blocks=0 path inode size prefix
    local -A seen=()
    local LC_ALL=C
    if [[ "$root" == / ]]; then prefix=/; else prefix="$root/"; fi
    for path in "${!FILES[@]}"; do
        [[ -n "${UTIL_SYMLINKS[$path]+yes}" ]] && continue
        if [[ "$root" != / && "$path" != "$root" && "$path" != "$prefix"* ]]; then continue; fi
        inode=${UTIL_INODES[$path]:-}
        [[ -n "$inode" ]] || { utilities_register_path "$path" file; inode=${UTIL_INODES[$path]}; }
        [[ -n "${seen[$inode]+yes}" ]] && continue
        seen[$inode]=1
        size=${#FILES[$path]}
        bytes=$((bytes + size))
        blocks=$((blocks + (size + 1023) / 1024))
    done
    printf '%s %s\n' "$bytes" "$blocks"
}

show_disk_usage() {
    if ! is_disk_formatted; then
        utilities_error "MiniFS disk is not formatted. Run 'format' first."
        return 1
    fi
    local total=${TOTAL_DISK_SIZE:-0} bytes used free percent
    [[ "$total" =~ ^[0-9]+$ ]] || { utilities_error 'Disk capacity is invalid.'; return 1; }
    read -r bytes used <<< "$(utilities_usage /)"
    free=$((total - used))
    (( free < 0 )) && free=0
    percent=0
    if (( total > 0 )); then percent=$((used * 100 / total)); fi
    printf 'Total Space : %s KB\nUsed Space  : %s KB\nFree Space  : %s KB\nUsage       : %s%%\n' \
        "$total" "$used" "$free" "$percent"
}

show_directory_usage() {
    (( $# <= 1 )) || { utilities_error 'Usage: du [path]'; return 2; }
    local path type bytes blocks
    path=$(utilities_normalize "${1:-${CURRENT_DIR:-/}}") || return 1
    type=$(utilities_path_type "$path") || { utilities_error "Path not found: $path"; return 1; }
    read -r bytes blocks <<< "$(utilities_usage "$path")"
    printf '%s: %s KB (%s bytes)\n' "$path" "$blocks" "$bytes"
}

# Keep modes and inode IDs when the existing file module moves a file.
utilities_move_metadata() {
    local old_path new_path
    old_path=$(utilities_normalize "$1") || return 1
    new_path=$(utilities_normalize "$2") || return 1
    if [[ -n "${UTIL_INODES[$old_path]+yes}" ]]; then
        UTIL_INODES[$new_path]=${UTIL_INODES[$old_path]}
        UTIL_MODES[$new_path]=${UTIL_MODES[$old_path]:-644}
        unset 'UTIL_INODES[$old_path]' 'UTIL_MODES[$old_path]'
    fi
    if [[ -n "${UTIL_SYMLINKS[$old_path]+yes}" ]]; then
        UTIL_SYMLINKS[$new_path]=${UTIL_SYMLINKS[$old_path]}
        unset 'UTIL_SYMLINKS[$old_path]'
    fi
}

utilities_forget_path() {
    local path
    path=$(utilities_normalize "$1") || return 1
    unset 'UTIL_INODES[$path]' 'UTIL_MODES[$path]' 'UTIL_SYMLINKS[$path]'
}
