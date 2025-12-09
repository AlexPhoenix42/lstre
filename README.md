# 🌳 lstre

A colorful tree command for **Fish** and **Bash** shells.  
It displays a tree‑style view of files and directories with options for depth limiting, dotfile hiding, excludes, and optional 📁/📄 icons.

---

## Features

- 🌳 Tree view of directories and files
- 🎨 Color output: **yellow** for folders, **green** for files
- 📁/📄 Optional icons before names
- 🔍 Flags:
  - `--depth N` → limit recursion depth
  - `--hide-dotfiles` → skip dotfiles and dot‑directories
  - `--icons` → show icons before names
  - `-h, --help` → usage information
- 🚫 Default excludes: `node_modules`, `target`, `.git`
- ➕ Extra excludes can be passed after the target directory

---

## Fish Version

Add the function to your Fish config (`~/.config/fish/functions/lstre.fish`):

```fish
function lstre
    # Flags: --depth N, --hide-dotfiles, --icons
    argparse 'h/help' 'd/depth=' 'D/hide-dotfiles' 'i/icons' -- $argv
    or return
    ...
end
```

> The Fish version uses `argparse` for clean flag handling and Fish’s built‑in string utilities.

---

## Bash Version

Save as `lstre.sh` and make it executable:

```bash
#!/usr/bin/env bash

lstre() {
  # defaults
  dir="."
  excludes=("node_modules" "target" ".git")
  depth_args=""
  hide_dotfiles=false
  icons=false

  # parse args
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help) ... ;;
      --depth) ... ;;
      --hide-dotfiles) ... ;;
      --icons) ... ;;
      *) ... ;;
    esac
  done

  # Pass 1 + Pass 2 logic
  ...
}

# allow running directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  lstre "$@"
fi
```

> The Bash version uses manual argument parsing and standard string operations, but preserves the same features and output style.

---

## Usage Examples

```bash
# Current directory, default excludes
lstre

# Parent dir, also exclude build and dist
lstre .. build dist

# Limit to 2 levels deep
lstre . --depth 2

# Skip dotfiles/dirs
lstre . --hide-dotfiles

# Add icons to output
lstre . --icons
```

---

## Demo Output

With `--icons`:

```
├── 📁 src/
│   └── 📄 main.c
└── 📄 README.md
```

Without `--icons`:

```
├── src/
│   └── main.c
└── README.md
```

---

## 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## Powered by github.com/AlexPhoenix42 🌈🚀
https://github.com/AlexPhoenix42
