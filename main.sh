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
    echo "    stat <name>         Show file information"
    echo "    du <name>           Show directory usage"
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

    case $command in

        # Disk commands
        format)
            format_disk
            ;;

        # Directory commands
        mkdir)
            create_directory "$arguments"
            ;;

        ls)
            list_directory "$arguments"
            ;;

        cd)
            change_directory "$arguments"
            ;;

        pwd)
            show_current_directory
            ;;

        rmdir)
            remove_directory "$arguments"
            ;;

        # File commands
        touch)
            create_file "$arguments"
            ;;

        cat)
            display_file "$arguments"
            ;;

        cp)
            copy_file $arguments
            ;;

        mv)
            move_file $arguments
            ;;

        rm)
            remove_file "$arguments"
            ;;

        # Utility commands
        chmod)
            change_permissions $arguments
            ;;

        stat)
            show_statistics "$arguments"
            ;;

        df)
            show_disk_usage
            ;;

        du)
            show_directory_usage "$arguments"
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