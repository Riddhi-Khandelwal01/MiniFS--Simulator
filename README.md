# Mini File System Simulator

MiniFS is a Bash project that keeps simulated directories in the `DIRS` array and file contents in the `FILES` array. It is intended to run in Ubuntu or another Linux system with Bash 4 or newer.

## Run

```bash
bash main.sh
```

At the prompt, run `format` first. Formatting clears the on-disk disk-information folder; file and directory data are currently held in memory by the other modules.

## Commands

| Command | Description |
| --- | --- |
| `format` | Initialize the simulated disk |
| `mkdir`, `ls`, `cd`, `pwd`, `rmdir` | Manage directories |
| `touch`, `cat`, `cp`, `mv`, `rm` | Manage simulated files |
| `chmod <mode> <path>` | Set a simulated octal permission mode, such as `640` |
| `ln <target> <link>` | Make a hard link to a simulated file |
| `ln -s <target> <link>` | Make a symbolic link to a simulated file |
| `stat <path>` | Show type, mode, inode, size and link count |
| `df` | Show simulated capacity and used space |
| `du [path]` | Show file data used below a path |
| `help`, `clear`, `about`, `exit` | Prompt controls |

The prompt accepts whitespace-separated arguments, so names with spaces are not supported. Permissions are simulated metadata and do not restrict commands. Links are represented in the in-memory file table; symbolic links to directories and dangling symbolic links are not supported.

## Member 4 utilities

The utility functions are in `modules/utilities.sh`. They use the existing `DIRS` and `FILES` arrays and keep permission modes, inode numbers, and symbolic-link targets in small Bash associative arrays. File sizes are measured in bytes; disk and directory usage are reported in 1 KB blocks. Hard links share an inode and are counted once by `df` and `du`.

`docs/project_documentation.md` describes the utility behavior and integration notes.
