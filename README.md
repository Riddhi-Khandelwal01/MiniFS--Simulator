# Mini File System Simulator (MiniFS)

A UNIX-based Mini File System Simulator developed using **Bash scripting**. The project provides a command-line interface that simulates basic file system operations such as directory management, file handling, disk management, and other utility commands.

## Features

- Interactive command-line interface
- Disk formatting and storage management
- Directory management
- File management
- Basic file system utility commands
- Command help and validation
- Modular project structure

## Project Structure

```text
Mini-File-System-Simulator-UNIX/
│
├── main.sh                 # Main command controller
├── modules/
│   ├── disk.sh             # Disk formatting and storage management
│   ├── directory.sh        # Directory management functions
│   ├── file.sh             # File management functions
│   └── utilities.sh        # Additional utility functions
│
├── .gitignore
└── README.md
```

> Some modules may be added or expanded as the project develops.

## Requirements

- Linux or WSL
- Bash shell

## How to Run

### 1. Clone the repository

Clone the project repository and navigate to the project folder.

### 2. Run the program

```bash
bash main.sh
```

The MiniFS command interface will start.

## Available Commands

| Command | Description |
|---------|-------------|
| `help` | Display available commands |
| `format` | Format and initialize the MiniFS storage |
| `df` | Display disk usage information |
| `mkdir` | Create a directory |
| `ls` | List directory contents |
| `cd` | Change the current directory |
| `pwd` | Display the current directory |
| `rmdir` | Remove a directory |
| `touch` | Create a file |
| `cat` | Display file contents |
| `cp` | Copy a file |
| `mv` | Move or rename a file |
| `rm` | Remove a file |
| `chmod` | Modify file permissions |
| `stat` | Display file information |
| `du` | Display directory storage usage |
| `exit` | Exit the MiniFS simulator |

## Example Usage

```text
MiniFS> format
MiniFS> df
MiniFS> mkdir documents
MiniFS> ls
MiniFS> exit
```

## Project Architecture

The project follows a modular structure:

```text
User Command
     │
     ▼
   main.sh
     │
     ├── disk.sh
     ├── directory.sh
     ├── file.sh
     └── utilities.sh
```

The `main.sh` file acts as the central command controller. It receives commands from the user and routes them to the appropriate functions in the corresponding modules.

## Team Contributions

The project is developed collaboratively, with different members responsible for different modules and functionalities.

## Notes

The `mini_fs_storage/` directory is generated during program execution and is excluded from version control using `.gitignore`.

## Future Improvements

- Enhanced error handling
- Improved file permission simulation
- Additional UNIX command support
- Improved storage and metadata management

---

**Developed as a UNIX/Operating Systems project using Bash scripting.**
