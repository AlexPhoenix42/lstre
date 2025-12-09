#!/usr/bin/env bash

lstre() {
  # defaults
  dir="."
  excludes=("node_modules" "target" ".git")
  depth_args=""
  hide_dotfiles=false
  icons=false
  help_mode=0

#  # parse args
#  while [[ $# -gt 0 ]]; do
#    case "$1" in
#      -h|--help)
#
#        cat <<EOF
#Usage: lstre [TARGET] [EXCLUDE1 EXCLUDE2 ...] [OPTIONS]
#
#Display a tree view of files and directories, excluding specified folders.
#Folders: yellow | Files: green
#
#Options:
#  --depth N         Limit recursion to N levels (default: unlimited)
#  --hide-dotfiles   Hide dotfiles and dot-directories at all levels
#  --icons           Show 📁 for folders and 📄 for files
#  -h, --help        Show this help
#
#Arguments:
#  TARGET     Directory to scan (default: .)
#  EXCLUDE... Folders to prune (default: node_modules target .git)
#EOF
#        return 0
#        ;;
#      --depth)
#        depth_args="-maxdepth $2"
#        shift 2
#        ;;
#      --hide-dotfiles)
#        hide_dotfiles=true
#        shift
#        ;;
#      --icons)
#        icons=true
#        shift
#        ;;
#      *)
#        if [[ "$dir" == "." ]]; then
#          dir="$1"
#        else
#          excludes+=("$1")
#        fi
#        shift
#        ;;
#    esac
#  done

 # parse args
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -h|--help)
        help_mode=1
        shift
        ;;
      --depth)
        depth_args="-maxdepth $2"
        shift 2
        ;;
      --hide-dotfiles)
        hide_dotfiles=true
        shift
        ;;
      --icons)
        icons=true
        shift
        ;;
      *)
        if [[ "$dir" == "." ]]; then
          dir="$1"
        else
          excludes+=("$1")
        fi
        shift
        ;;
    esac
  done

  # Help mode
  if [[ $help_mode -eq 1 ]]; then
    echo
    echo -e "\e]8;;https://github.com/AlexPhoenix42\e\\Powered by $BLUEgithub.com/AlexPhoenix42$RESET 🌈🚀\e]8;;\e\\"
    echo
    echo "Usage: lstre [TARGET] [EXCLUDE1 EXCLUDE2 ...] [OPTIONS]"
    echo ""
    echo "Display a tree view of files and directories, excluding specified folders."
    echo "Folders: yellow | Files: green"
    echo ""
    echo "Options:"
    echo "  --depth N         Limit recursion to N levels (default: unlimited)"
    echo "  --hide-dotfiles   Hide dotfiles and dot-directories at all levels"
    echo "  --icons           Show 📁 for folders and 📄 for files"
    echo "  -h, --help        Show this help message"
    echo ""
    echo "Arguments:"
    echo "  TARGET     Directory to scan (default: .)"
    echo "  EXCLUDE... Folders to prune (default: node_modules target .git)"
    echo ""
    echo "Examples:"
    echo "  lstre                               # Current dir, default excludes"
    echo "  lstre .. build dist                 # Parent dir, also exclude build and dist"
    echo "  lstre /path/to/project --depth 2    # Limit to 2 levels"
    echo "  lstre . --hide-dotfiles             # Skip dotfiles/dirs"
    echo "  lstre . --icons                     # Add icons to output"
    echo "  lstre -h                            # This help"
    exit 0
  fi


  # build filters
  top_filter_args=()
  for ex in "${excludes[@]}"; do
    top_filter_args+=(-not -path "$dir/$ex")
  done
  if $hide_dotfiles; then
    top_filter_args+=(-not -name '.*')
  fi

  # PASS 1: immediate files
  find "$dir" -maxdepth 1 -mindepth 1 -type f "${top_filter_args[@]}" -printf "%p %y\n" 2>/dev/null |
  while read -r path type; do
    [[ -z "$path" ]] && continue
    formatted=$(echo "$path" | sed -e 's;[^/]*/;|── ;g;s;── |;├─ ;g;s;── $;└─ ;g')
    if $icons; then
      name=$(basename -- "$path")
      prefix=${formatted:0:$((${#formatted} - ${#name}))}
      echo -e "\033[32m${prefix}📄 $name\033[0m"
    else
      echo -e "\033[32m$formatted\033[0m"
    fi
  done

  # prune args
  prune_args=()
  if $hide_dotfiles; then
    prune_args+=(-name '.*' -prune -o)
  fi
  for ex in "${excludes[@]}"; do
    prune_args+=(-path "$dir/$ex" -prune -o)
  done

  # PASS 2: directories + deeper files
  find "$dir" "${prune_args[@]}" -mindepth 1 $depth_args -printf "%p %y %d\n" 2>/dev/null |
  while read -r path type depth; do
    [[ -z "$path" ]] && continue
    [[ "$type" == "f" && $depth -eq 1 ]] && continue
    formatted=$(echo "$path" | sed -e 's;[^/]*/;|── ;g;s;── |;├─ ;g;s;── $;└─ ;g')
    if [[ "$type" == "d" ]]; then
      if $icons; then
        name=$(basename -- "$path")
        prefix=${formatted:0:$((${#formatted} - ${#name}))}
        echo -e "\033[33m${prefix}📁 $name\033[0m"
      else
        echo -e "\033[33m$formatted\033[0m"
      fi
    else
      if $icons; then
        name=$(basename -- "$path")
        prefix=${formatted:0:$((${#formatted} - ${#name}))}
        echo -e "\033[32m${prefix}📄 $name\033[0m"
      else
        echo -e "\033[32m$formatted\033[0m"
      fi
    fi
  done
}

# allow running directly
if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  lstre "$@"
fi

# ========================================================================
# alias lstre="~/bin/lstre.sh"
# ========================================================================
