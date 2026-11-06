# Member 4: Utilities and Integration Notes

## Commands

`modules/utilities.sh` supplies the advanced commands expected by the command prompt:

- `chmod <mode> <path>` stores a three- or four-digit octal mode for an existing simulated file or directory. Modes are descriptive metadata; the simulator does not enforce access permissions.
- `ln <target> <link>` adds another file path with the same simulated inode and content.
- `ln -s <target> <link>` records a symbolic link to an existing simulated file. The current file module stores data by path, so the link also has a content entry for `cat`.
- `stat <path>` reports object type, permission mode, simulated inode, byte size and link count.
- `df` reports total, used and available simulated capacity using the file contents held in memory.
- `du [path]` totals file data below a path, counting a hard-linked inode once.

File sizes are measured in bytes using Bash string lengths under the C locale. Usage is shown in 1 KB blocks. Directories and links do not use file-data blocks.

## Shared project data

The existing modules define `DIRS` and `FILES` as Bash associative arrays. Paths use the same virtual form as the directory and file modules, such as `/notes.txt` or `/docs/notes.txt`. The utility module keeps three small metadata arrays:

- `UTIL_MODES`: simulated permission mode by path.
- `UTIL_INODES`: simulated inode number by path. Hard-linked paths share the same number.
- `UTIL_SYMLINKS`: symbolic-link target by path.

The utility code normalizes paths itself and uses the shared arrays, so it does not require host filesystem paths or root privileges.

## Integration in `main.sh`

The command prompt loads `utilities.sh` after the other modules. Its command cases call the existing directory and file function names, plus the Member 4 functions `change_permissions`, `create_link`, `show_statistics`, `show_disk_usage` and `show_directory_usage`. The help text includes both forms of `ln`.

After a successful `mv` or `rm`, the prompt updates or clears the matching utility metadata so modes, inode numbers and link information do not remain at the old path.

## Current limits and issues to coordinate

- The command prompt splits arguments on whitespace; filenames with spaces are unsupported.
- Symbolic links currently support existing files only. Their file contents are copied in the in-memory table because the file module reads by path; the simulator has no command for editing existing contents.
- Permission values are reported but are not enforced by file operations.
- The disk module's original `get_used_space` measures the host `mini_fs_storage` directory. The Member 4 `df` command instead totals the in-memory `FILES` entries, which are the simulated user data.
- The existing directory module's `dir_normalize` conditional is malformed (`if [["$input"==/*]]`); directory and file command testing should wait for its owner to correct that helper. The directory listing also currently lists directories but not files.

## Verification checklist

After the directory path helper is corrected, run `format` and check:

```text
touch note
chmod 640 note
stat note
ln note note-hard
stat note-hard
ln -s note note-soft
stat note-soft
du /
df
rm note-hard
rm note-soft
rm note
```

Also check invalid modes, missing paths, duplicate link names, empty files, nested paths, and moving or removing links. The current repository needs this integrated Ubuntu run before the work can be called fully verified.
