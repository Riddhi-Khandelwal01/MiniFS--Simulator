#!/bin/bash


# MiniFS - Directory Management Module

#Directory storage
declare -A DIRS

#Root directory
DIRS["/"]=1

#Current working directory
CURRENT_DIR="/"



#Normalize a path
#Handles absolute, relative, . and ..


dir_normalize() {
    local input="$1"
    local full_path
    local result=""
    local part

    if [[ "$input" == /* ]]; then
        full_path="$input"
    else
        full_path="$CURRENT_DIR/$input"
    fi

    IFS='/' read -ra parts <<< "$full_path"

    for part in "${parts[@]}"; do
        case "$part" in
            ""|".")
                continue
                ;;
            "..")
                if [[ -n "$result" ]]; then
                    result="${result%/*}"
                fi
                ;;
            *)
                result="$result/$part"
                ;;
        esac
    done

    echo "${result:-/}"
}


# Create a directory


dir_mkdir() {
    if [[ $# -ne 1 || -z "$1" ]]; then
        echo "Error: Usage: mkdir <directory>"
        return 1
    fi

    local path
    path=$(dir_normalize "$1")

    if [[ "$path" == "/" || -n "${DIRS[$path]+exists}" ]]; then
        echo "Error: Directory already exists."
        return 1
    fi

    local parent="${path%/*}"
    [[ -z "$parent" ]] && parent="/"

    if [[ -z "${DIRS[$parent]+exists}" ]]; then
        echo "Error: Parent directory does not exist."
        return 1
    fi

    DIRS["$path"]=1

    echo "Directory created: $path"
}


# ------------------------------------------
# List directory contents
# ------------------------------------------

dir_ls() {
    local path="${1:-$CURRENT_DIR}"
    path=$(dir_normalize "$path")

    if [[ -z "${DIRS[$path]+exists}" ]]; then
        echo "Error: Directory not found."
        return 1
    fi

    local prefix="$path"
    [[ "$path" != "/" ]] && prefix="$path/"

    local -a children=()
    local item
    local remaining

    # List directories
    for item in "${!DIRS[@]}"; do
        if [[ "$item" == "$prefix"* && "$item" != "$path" ]]; then
            remaining="${item#"$prefix"}"

            if [[ "$remaining" != */* && -n "$remaining" ]]; then
                children+=("$remaining/")
            fi
        fi
    done

    # List files
    for item in "${!FILES[@]}"; do
        if [[ "$item" == "$prefix"* ]]; then
            remaining="${item#"$prefix"}"

            if [[ "$remaining" != */* && -n "$remaining" ]]; then
                children+=("$remaining")
            fi
        fi
    done

    if [[ ${#children[@]} -eq 0 ]]; then
        echo "(empty)"
    else
        printf '%s\n' "${children[@]}" | sort
    fi
}


# ------------------------------------------
# Change current directory
# ------------------------------------------

dir_cd() {
    if [[ $# -gt 1 ]]; then
        echo "Error: Usage: cd <directory>"
        return 1
    fi

    local path="${1:-/}"
    path=$(dir_normalize "$path")

    if [[ -z "${DIRS[$path]+exists}" ]]; then
        echo "Error: Directory not found."
        return 1
    fi

    CURRENT_DIR="$path"

    echo "Current directory: $CURRENT_DIR"
}


# ------------------------------------------
# Display current directory
# ------------------------------------------

dir_pwd() {
    echo "$CURRENT_DIR"
}


# ------------------------------------------
# Remove an empty directory
# ------------------------------------------

dir_rmdir() {
    if [[ $# -ne 1 || -z "$1" ]]; then
        echo "Error: Usage: rmdir <directory>"
        return 1
    fi

    local path
    path=$(dir_normalize "$1")

    if [[ "$path" == "/" ]]; then
        echo "Error: Cannot remove root directory."
        return 1
    fi

    if [[ -z "${DIRS[$path]+exists}" ]]; then
        echo "Error: Directory not found."
        return 1
    fi

    if [[ "$CURRENT_DIR" == "$path" || "$CURRENT_DIR" == "$path/"* ]]; then
        echo "Error: Cannot remove current directory or its parent."
        return 1
    fi

    local item

    # Check for subdirectories
for item in "${!DIRS[@]}"; do
    if [[ "$item" == "$path/"* ]]; then
        echo "Error: Directory is not empty."
        return 1
    fi
done

# Check for files
for item in "${!FILES[@]}"; do
    if [[ "$item" == "$path/"* ]]; then
        echo "Error: Directory is not empty."
        return 1
    fi
done

unset 'DIRS[$path]'

echo "Directory removed: $path"
}


# ------------------------------------------
# Display available commands
# ------------------------------------------

dir_help() {
    echo "MiniFS Directory Management Commands"
    echo "------------------------------------"
    echo "mkdir <name>  : Create a directory"
    echo "ls [path]     : List directory contents"
    echo "cd <path>     : Change current directory"
    echo "pwd           : Display current directory"
    echo "rmdir <name>  : Remove an empty directory"
    echo "help          : Display available commands"
}