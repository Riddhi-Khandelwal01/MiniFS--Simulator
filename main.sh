#!/bin/bash

# Load all project modules
source modules/disk.sh
source modules/directory.sh
source modules/file.sh
source modules/utilities.sh

echo "================================="
echo "   Welcome to Mini File System"
echo "================================="

while true
do
    echo -n "MiniFS> "
    read command

    case $command in
        exit)
            echo "Exiting Mini File System..."
            break
            ;;
        *)
            echo "Command not implemented yet."
            ;;
    esac
done