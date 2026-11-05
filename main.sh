#!/bin/bash

# ==========================================
# Mini File System Simulator - Main Controller
# ==========================================

# Load all project modules
source modules/disk.sh
source modules/directory.sh
source modules/file.sh
source modules/utilities.sh

echo "========================================="
echo "      Welcome to Mini File System"
echo "========================================="
echo "Type 'help' to see available commands."

# Main command loop
while true
do
    echo -n "MiniFS> "
    read -r command arguments

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

        # Help command
        help)
            echo "Available commands:"
            echo "  format              - Initialize the Mini File System"
            echo "  mkdir <name>        - Create a directory"
            echo "  ls                  - List directory contents"
            echo "  cd <directory>      - Change directory"
            echo "  pwd                 - Show current directory"
            echo "  rmdir <name>        - Remove a directory"
            echo "  touch <name>        - Create a file"
            echo "  cat <file>          - Display file contents"
            echo "  cp <source> <dest>  - Copy a file"
            echo "  mv <source> <dest>  - Move or rename a file"
            echo "  rm <name>           - Remove a file"
            echo "  chmod <perm> <file> - Change permissions"
            echo "  stat <name>         - Show file information"
            echo "  df                  - Show disk usage"
            echo "  du <name>           - Show directory usage"
            echo "  help                - Show this help message"
            echo "  exit                - Exit the Mini File System"
            ;;

        # Exit command
        exit)
            echo "Exiting Mini File System..."
            break
            ;;

        # Empty input
        "")
            ;;

        # Unknown command
        *)
            echo "Error: Command '$command' not found."
            echo "Type 'help' to see available commands."
            ;;
    esac

done