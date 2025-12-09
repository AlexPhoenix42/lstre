function lstre
    # Flags: --depth N, --hide-dotfiles, --icons
    argparse 'h/help' 'd/depth=' 'D/hide-dotfiles' 'i/icons' -- $argv
    or return

    if set -q _flag_help
        echo
        echo -e "\e]8;;https://github.com/AlexPhoenix42\e\\Powered by $BLUEgithub.com/AlexPhoenix42$RESET 🌈🚀\e]8;;\e\\"
        echo
        echo "Usage: lstre [TARGET] [EXCLUDE1 EXCLUDE2 ...]"
        echo ""
        echo "Display a tree view of files and directories, excluding specified folders."
        echo "Folders: yellow | Files: green"
        echo ""
        echo "Natively ignores: node_modules, target, .git (hardcoded defaults)"
        echo "Extra args after TARGET are also excluded"
        echo "Options:"
        echo "  --depth N         Limit recursion to N levels (default: unlimited)"
        echo "  --hide-dotfiles   Hide dotfiles and dot-directories at all levels"
        echo "  --icons           Show 📁 for folders and 📄 for files"
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
        return 0
    end

    set dir .
    test (count $argv) -gt 0 && set dir $argv[1]

    # default excludes
    set excludes node_modules target .git
    if test (count $argv) -gt 1
        set excludes $excludes $argv[2..-1]
    end
    set excludes (for ex in $excludes; string replace -r '/$' '' -- $ex; end)

    # depth handling
    set depth_args
    if set -q _flag_depth
        if string match -r '^[0-9]+$' -- $_flag_depth
            set depth_args -maxdepth $_flag_depth
        end
    end

    # filters for top-level files
    set top_filter_args
    for ex in $excludes
        set top_filter_args $top_filter_args -not -path "$dir/$ex"
    end
    if set -q _flag_hide_dotfiles
        set top_filter_args $top_filter_args -not -name '.*'
    end

    # PASS 1: immediate files at level 0 (green)
    find $dir -maxdepth 1 -mindepth 1 -type f $top_filter_args -printf "%p %y\n" 2>/dev/null | \
    while read -l path type
        if test -z "$path"
            continue
        end

        set formatted (echo $path | sed -e 's;[^/]*/;|── ;g;s;── |;├─ ;g;s;── $;└─ ;g')

        if set -q _flag_icons
            set name (basename -- $path)
            set flen (string length -- $formatted)
            set nlen (string length -- $name)
            set prefix (string sub -l (math "$flen - $nlen") -- $formatted)
            echo -e "\x1b[32m$prefix📄 $name\x1b[0m"
        else
            echo -e "\x1b[32m$formatted\x1b[0m"
        end
    end

    # build prune args
    set prune_args
    if set -q _flag_hide_dotfiles
        set prune_args $prune_args -name '.*' -prune -o
    end
    for ex in $excludes
        set prune_args $prune_args -path "$dir/$ex" -prune -o
    end

    # PASS 2: directories (any depth per --depth) + files deeper than level 0
    find $dir $prune_args -mindepth 1 $depth_args -printf "%p %y %d\n" 2>/dev/null | \
    while read -l path type depth
        if test -z "$path"
            continue
        end
        if test "$type" = f -a $depth -eq 1
            continue
        end

        set formatted (echo $path | sed -e 's;[^/]*/;|── ;g;s;── |;├─ ;g;s;── $;└─ ;g')

        if test "$type" = d
            if set -q _flag_icons
                set name (basename -- $path)
                set flen (string length -- $formatted)
                set nlen (string length -- $name)
                set prefix (string sub -l (math "$flen - $nlen") -- $formatted)
                echo -e "\x1b[33m$prefix📁 $name\x1b[0m"
            else
                echo -e "\x1b[33m$formatted\x1b[0m"
            end
        else
            if set -q _flag_icons
                set name (basename -- $path)
                set flen (string length -- $formatted)
                set nlen (string length -- $name)
                set prefix (string sub -l (math "$flen - $nlen") -- $formatted)
                echo -e "\x1b[32m$prefix📄 $name\x1b[0m"
            else
                echo -e "\x1b[32m$formatted\x1b[0m"
            end
        end
    end
end
