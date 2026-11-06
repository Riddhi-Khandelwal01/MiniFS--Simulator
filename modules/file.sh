
#!/bin/bash

# ==========================================
# MiniFS - File Management Module
# Member 3
# ==========================================

# Store simulated files and their contents
declare -A FILES


# ------------------------------------------
# Helper: Resolve file path
# ------------------------------------------

fs_resolve_path() {
    dir_normalize "$1"
}


# ------------------------------------------
# Helper: Validate parent directory
# ------------------------------------------

fs_check_parent() {
    local path="$1"
    local parent="${path%/*}"

    [[ -z "$parent" ]] && parent="/"

    if [[ -z "${DIRS[$parent]+exists}" ]]; then
        echo "Error: Parent directory does not exist."
        return 1
    fi

    return 0
}


# ------------------------------------------
# 1. CREATE FILE (touch)
# ------------------------------------------

fs_touch() {
    if [[ $# -ne 1 || -z "$1" ]]; then
        echo "Error: Usage: touch <filename>"
        return 1
    fi

    local path
    path=$(fs_resolve_path "$1")

    if [[ -n "${FILES[$path]+exists}" ]]; then
        echo "Error: File already exists."
        return 1
    fi

    if [[ -n "${DIRS[$path]+exists}" ]]; then
        echo "Error: A directory with this name exists."
        return 1
    fi

    fs_check_parent "$path" || return 1

    FILES["$path"]=""

    echo "File created: $path"
}


# ------------------------------------------
# 2. DISPLAY FILE CONTENTS (cat)
# ------------------------------------------

fs_cat() {
    if [[ $# -ne 1 || -z "$1" ]]; then
        echo "Error: Usage: cat <filename>"
        return 1
    fi

    local path
    path=$(fs_resolve_path "$1")

    if [[ -z "${FILES[$path]+exists}" ]]; then
        echo "Error: File not found."
        return 1
    fi

    printf '%s\n' "${FILES[$path]}"
}


# ------------------------------------------
# 3. COPY FILE (cp)
# ------------------------------------------

fs_cp() {
    if [[ $# -ne 2 ]]; then
        echo "Error: Usage: cp <source> <destination>"
        return 1
    fi

    local src dest

    src=$(fs_resolve_path "$1")
    dest=$(fs_resolve_path "$2")

    if [[ -z "${FILES[$src]+exists}" ]]; then
        echo "Error: Source file not found."
        return 1
    fi

    if [[ -n "${FILES[$dest]+exists}" ||
          -n "${DIRS[$dest]+exists}" ]]; then
        echo "Error: Destination already exists."
        return 1
    fi

    fs_check_parent "$dest" || return 1

    FILES["$dest"]="${FILES[$src]}"

    echo "File copied: $src -> $dest"
}


# ------------------------------------------
# 4. MOVE / RENAME FILE (mv)
# ------------------------------------------

fs_mv() {
    if [[ $# -ne 2 ]]; then
        echo "Error: Usage: mv <source> <destination>"
        return 1
    fi

    local src dest

    src=$(fs_resolve_path "$1")
    dest=$(fs_resolve_path "$2")

    if [[ -z "${FILES[$src]+exists}" ]]; then
        echo "Error: Source file not found."
        return 1
    fi

    if [[ -n "${FILES[$dest]+exists}" ||
          -n "${DIRS[$dest]+exists}" ]]; then
        echo "Error: Destination already exists."
        return 1
    fi

    fs_check_parent "$dest" || return 1

    FILES["$dest"]="${FILES[$src]}"
    unset 'FILES[$src]'

    echo "File moved: $src -> $dest"
}


# ------------------------------------------
# 5. DELETE FILE (rm)
# ------------------------------------------

fs_rm() {
    if [[ $# -ne 1 || -z "$1" ]]; then
        echo "Error: Usage: rm <filename>"
        return 1
    fi

    local path
    path=$(fs_resolve_path "$1")

    if [[ -z "${FILES[$path]+exists}" ]]; then
        echo "Error: File not found."
        return 1
    fi

    unset 'FILES[$path]'

    echo "File deleted: $path"
}
