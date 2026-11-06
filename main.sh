#!/bin/bash

# ==========================================
# Mini File System Simulator - Main Controller
# ==========================================

# Check whether all required modules exist
required_modules=(
    "modules/disk.sh"
    "modules/directory.sh"
    "modules/file.sh"
    "modules/utilities.sh"
)

for module in "${required_modules[@]}"
do
    if [ ! -f "$module" ]; then
        echo "Error: Required module '$module' is missing."
        exit 1
    fi
done

# Load all project modules
source modules/disk.sh
source modules/directory.sh
source modules/file.sh
source modules/utilities.sh

# Display welcome message
clear
echo "========================================="
echo "       MINI FILE SYSTEM SIMULATOR"
echo "========================================="
echo "Type 'help' to see available commands."
echo

# Function to display all commands
show_help() {
    echo "Available commands:"
    echo
    echo "  DISK:"
    echo "    format              Initialize the Mini File System"
    echo "    df                  Show disk usage"
    echo
    echo "  DIRECTORY:"
    echo "    mkdir <name>        Create a directory"
    echo "    ls                  List directory contents"
    echo "    cd <directory>      Change directory"
    echo "    pwd                 Show current directory"
    echo "    rmdir <name>        Remove a directory"
    echo
    echo "  FILE:"
    echo "    touch <name>        Create a file"
    echo "    cat <file>          Display file contents"
    echo "    cp <source> <dest>  Copy a file"
    echo "    mv <source> <dest>  Move or rename a file"
    echo "    rm <name>           Remove a file"
    echo
    echo "  UTILITIES:"
    echo "    chmod <perm> <file> Change permissions"
    echo "    ln <target> <link> Create a hard link"
    echo "    ln -s <target> <link> Create a symbolic link"
    echo "    stat <name>         Show file information"
    echo "    du [path]           Show directory usage"
    echo
    echo "  SYSTEM:"
    echo "    help                Show this help message"
    echo "    clear               Clear the screen"
    echo "    about               Show project information"
    echo "    exit                Exit MiniFS"
}

# Main command loop
while true
do
    echo
    read -r -p "MiniFS> " command arguments
    read -r -a command_args <<< "$arguments"

    case $command in

        # Disk commands
        format)
            format_disk
            ;;

        # Directory commands
        mkdir)
            dir_mkdir "${command_args[@]}"
            ;;

        ls)
            dir_ls "${command_args[@]}"
            ;;

        cd)
            dir_cd "${command_args[@]}"
            ;;

        pwd)
            dir_pwd
            ;;

        rmdir)
            if dir_rmdir "${command_args[@]}"; then
                utilities_forget_path "${command_args[0]}"
            fi
            ;;

        # File commands
        touch)
            fs_touch "${command_args[@]}"
            ;;

        cat)
            fs_cat "${command_args[@]}"
            ;;

        cp)
            fs_cp "${command_args[@]}"
            ;;

        mv)
            if fs_mv "${command_args[@]}"; then
                utilities_move_metadata "${command_args[0]}" "${command_args[1]}"
            fi
            ;;

        rm)
            if fs_rm "${command_args[@]}"; then
                utilities_forget_path "${command_args[0]}"
            fi
            ;;

        # Utility commands
        chmod)
            change_permissions "${command_args[@]}"
            ;;

        ln)
            create_link "${command_args[@]}"
            ;;

        stat)
            show_statistics "${command_args[@]}"
            ;;

        df)
            show_disk_usage
            ;;

        du)
            show_directory_usage "${command_args[@]}"
            ;;

        # System commands controlled by main.sh
        help)
            show_help
            ;;

        clear)
            clear
            ;;

        about)
            echo "Mini File System Simulator"
            echo "A simplified simulation of Unix file system operations."
            echo "Developed as a Unix project."
            ;;

        exit)
            read -r -p "Are you sure you want to exit? (y/n): " choice

            case $choice in
                y|Y|yes|YES)
                    echo "Exiting Mini File System..."
                    break
                    ;;
                *)
                    echo "Returning to MiniFS..."
                    ;;
            esac
            ;;

        # Empty command
        "")
            ;;

        # Unknown command
        *)
            echo "Error: Command '$command' not found."
            echo "Type 'help' to see available commands."
            ;;
    esac

done
