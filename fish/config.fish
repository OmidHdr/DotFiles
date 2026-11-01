# ------ default editor and browser ------
set -x VISUAL nvim
set -x EDITOR nvim
set -x BROWSER /usr/bin/brave

# Export paths
set -x PATH $PATH /home/h0p3/.local/bin /opt/clion-2022.3.1/bin /opt/oracle/product/18c/dbhomeXE/bin
#set -x JAVA_HOME /usr/lib/jvm/default
fish_add_path -U ~/.local/share/jdtls/bin
set -x JAVA_HOME /usr/lib/jvm/java-25-openjdk
set -x PATH $JAVA_HOME/bin $PATH

#----- shell theme config --------
set -g theme_powerline_fonts yes
set -g theme_color_scheme nord

# XDG Base Directory Specification
set -x XDG_CONFIG_HOME "$HOME/.config"
set -x XDG_DATA_HOME "$HOME/.local/share"
set -x XDG_STATE_HOME "$HOME/.local/state"
set -x XDG_CACHE_HOME "$HOME/.cache"

# Various environment variables
set -x ELECTRUMDIR "$XDG_DATA_HOME/electrum"
set -x GNUPGHOME "$XDG_DATA_HOME/gnupg"
set -x GTK2_RC_FILES "$XDG_CONFIG_HOME/gtk-2.0/gtkrc"
set -x _JAVA_OPTIONS -Djava.util.prefs.userRoot="$XDG_CONFIG_HOME/java"
set -x JULIA_DEPOT_PATH "$XDG_DATA_HOME/julia:$JULIA_DEPOT_PATH"
set -x NODE_REPL_HISTORY "$XDG_DATA_HOME/node_repl_history"
set -x PARALLEL_HOME "$XDG_CONFIG_HOME/parallel"
set -x TERMINFO "$XDG_DATA_HOME/terminfo"
set -x TERMINFO_DIRS "$XDG_DATA_HOME/terminfo:/usr/share/terminfo"
set -x WINEPREFIX "$XDG_DATA_HOME/wine"
set -x NOTMUCH_CONFIG "$XDG_CONFIG_HOME/notmuch-config"
set -x LESSHISTFILE -
set -x WGETRC "$XDG_CONFIG_HOME/wget/wgetrc"
set -x MBSYNCRC "$XDG_CONFIG_HOME/mbsync/config"
set -x PASSWORD_STORE_DIR "$XDG_DATA_HOME/password-store"
set -x GOPATH "$XDG_DATA_HOME/go"
set -x CARGO_HOME "$XDG_DATA_HOME/cargo"
set -x NPM_CONFIG_USERCONFIG "$XDG_CONFIG_HOME/npm/npmrc"
set -x N_PREFIX "$HOME/.local/bin/n"
set -x ZDOTDIR "$HOME/.config/zsh"
set -x MANPAGER "less -R --use-color -Dd+r -Du+b"
set -x WINIT_X11_SCALE_FACTOR 1.75 # Corrected syntax
set -x LF_ICONS "tw=:st=:ow=:dt=:di=:fi=:ln=:or=:ex=:*.c=:*.cc=:*.clj=:*.coffee=:*.cpp=:*.css=:*.d=:*.dart=:*.erl=:*.exs=:*.fs=:*.go=:*.h=:*.hh=:*.hpp=:*.hs=:*.html=:*.java=:*.jl=:*.js=:*.json=:*.lua=:*.md=:*.php=:*.pl=:*.pro=:*.py=:*.rb=:*.rs=:*.scala=:*.ts=:*.vim=:*.cmd=:*.ps1=:*.sh=:*.bash=:*.zsh=:*.fish=:*.tar=:*.tgz=:*.arc=:*.arj=:*.taz=:*.lha=:*.lz4=:*.lzh=:*.lzma=:*.tlz=:*.txz=:*.tzo=:*.t7z=:*.zip=:*.z=:*.dz=:*.gz=:*.lrz=:*.lz=:*.lzo=:*.xz=:*.zst=:*.tzst=:*.bz2=:*.bz=:*.tbz=:*.tbz2=:*.tz=:*.deb=:*.rpm=:*.jar=:*.war=:*.ear=:*.sar=:*.rar=:*.alz=:*.ace=:*.zoo=:*.cpio=:*.7z=:*.rz=:*.cab=:*.wim=:*.swm=:*.dwm=:*.esd=:*.jpg=:*.jpeg=:*.mjpg=:*.mjpeg=:*.gif=:*.bmp=:*.pbm=:*.pgm=:*.ppm=:*.tga=:*.xbm=:*.xpm=:*.tif=:*.tiff=:*.png=:*.svg=:*.svgz=:*.mng=:*.pcx=:*.mov=:*.mpg=:*.mpeg=:*.m2v=:*.mkv=:*.webm=:*.ogm=:*.mp4=:*.m4v=:*.mp4v=:*.vob=:*.qt=:*.nuv=:*.wmv=:*.asf=:*.rm=:*.rmvb=:*.flc=:*.avi=:*.fli=:*.flv=:*.gl=:*.dl=:*.xcf=:*.xwd=:*.yuv=:*.cgm=:*.emf=:*.ogv=:*.ogx=:*.aac=:*.au=:*.flac=:*.m4a=:*.mid=:*.midi=:*.mka=:*.mp3=:*.mpc=:*.ogg=:*.ra=:*.wav=:*.oga=:*.opus=:*.spx=:*.xspf=:*.pdf=:*.nix=:"

set -x LC_ALL en_US.UTF-8

set -x ___MY_VMOPTIONS_SHELL_FILE "$HOME/.jetbrains.vmoptions.sh"
if test -f "$___MY_VMOPTIONS_SHELL_FILE"
    source "$___MY_VMOPTIONS_SHELL_FILE"
end

# Aliases
alias notes xfce4-notes
alias lf lfub
alias ls lsd
alias l 'ls -l'
alias la 'ls -a'
alias lla 'ls -la'
alias lt 'ls --tree'
alias c 'clear'
#alias vim lvim
alias nano nvim
#alias htop btop
alias speedtest speedtest-cli

bind \ck fkill
bind \cs fssh

# Set up colors for fzf
set fg "#CBE0F0"
set bg "#011628"
set bg_highlight "#143652"
set purple "#B388FF"
set blue "#06BCE4"
set cyan "#2CF9ED"

set -x FZF_DEFAULT_OPTS "--exact --color=fg:$fg,bg:$bg,hl:$purple,fg+:$fg,bg+:$bg_highlight,hl+:$purple,info:$blue,prompt:$cyan,pointer:$cyan,marker:$cyan,spinner:$cyan,header:$cyan"

# Use fd instead of fzf
set -x FZF_DEFAULT_COMMAND "fd --hidden --strip-cwd-prefix --exclude .git"
set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -x FZF_ALT_C_COMMAND "fd --type=d --hidden --strip-cwd-prefix --exclude .git"

function _fzf_compgen_path
    fd --hidden --exclude .git . $argv
end

function _fzf_compgen_dir
    fd --type=d --hidden --exclude .git . $argv
end

# Preview setup for files and directories
set show_file_or_dir_preview "if test -d {}; eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; end"
set -x FZF_CTRL_T_OPTS "--preview '$show_file_or_dir_preview'"
set -x FZF_ALT_C_OPTS "--preview 'eza --tree --color=always {} | head -200'"

# ---- Bat (better cat) ----
set -x BAT_THEME "tokyonight_night"

# ---- Eza (better ls) ----
alias ls="eza --icons=always"

# ---- TheFuck ----
function fuck -d "Correct your previous console command"
    set -l fucked_up_command (history | head -n1)
    set -l unfucked_command (env TF_SHELL=fish TF_ALIAS=fuck PYTHONIOENCODING=utf-8 thefuck $fucked_up_command $argv)

    if test -n "$unfucked_command"
        eval $unfucked_command
        history delete --exact --case-sensitive -- $fucked_up_command
        history merge
    end
end

# ---- Zoxide (better cd) ----
zoxide init fish | source
alias cd="z"

fzf --fish --exact | source

function random_wall --description "Set random wallpaper from Anime, Good, Arch, space"
    set -l img (find ~/.wallpaper/Anime ~/.wallpaper/Good ~/.wallpaper/Arch ~/.wallpaper/space -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" -o -iname "*.webp" \) | shuf -n 1)

    if test -n "$img"
        swaymsg output '*' bg "$img" fill
        echo "✅ والپیپر تغییر کرد: "(basename $img)
    else
        echo "❌ هیچ عکسی در این چهار پوشه پیدا نشد!"
    end
end

# -------------------- End of Fuzzy Stuff -----------------------------
fish_vi_key_bindings
set -gx LANG en_US.UTF-8
set -gx LC_ALL en_US.UTF-8
starship init fish | source
set -gx GPG_TTY (tty)


# ===================== FUZZY FILE MANAGER =====================

# ---------------------------------------------------------
# Shared helpers
# ---------------------------------------------------------

function _fuzzy_scope
    printf '%s\n' \
        'CURRENT DIRECTORY' \
        'HOME' \
        'ROOT' |
        fzf --exact --prompt='Search from > '
end


function _fuzzy_resolve_scope
    switch "$argv[1]"
        case 'CURRENT DIRECTORY'
            pwd
        case 'HOME'
            echo $HOME
        case 'ROOT'
            echo /
    end
end


function _fuzzy_recursive_option
    printf '%s\n' \
        'YES (Include subdirectories)' \
        'NO (Current directory only)' |
        fzf --exact --prompt='Search inside subdirectories? > '
end


function _fuzzy_destination
    set -l scope (_fuzzy_scope)

    if test -z "$scope"
        return 1
    end

    set -l base (_fuzzy_resolve_scope "$scope")
    set -l rec_opt (_fuzzy_recursive_option)

    if test -z "$rec_opt"
        return 1
    end

    if string match -q 'YES*' "$rec_opt"
        fd -H -t d . "$base" 2>/dev/null |
            fzf --exact \
                --prompt='Destination > ' \
                --preview 'ls -la -- {}' \
                --preview-window=up:40%:wrap
    else
        fd -H -t d --max-depth 1 . "$base" 2>/dev/null |
            fzf --exact \
                --prompt='Destination > ' \
                --preview 'ls -la -- {}' \
                --preview-window=up:40%:wrap
    end
end


function _fuzzy_select_items
    set -l type "$argv[1]"
    set -l scope (_fuzzy_scope)

    if test -z "$scope"
        return 1
    end

    set -l base (_fuzzy_resolve_scope "$scope")
    set -l rec_opt (_fuzzy_recursive_option)

    if test -z "$rec_opt"
        return 1
    end

    set -l depth_arg
    if not string match -q 'YES*' "$rec_opt"
        set depth_arg --max-depth 1
    end

    if test "$type" = "FILE"
        fd -H -t f $depth_arg . "$base" 2>/dev/null |
            fzf --multi --exact \
                --prompt='Select file(s) > ' \
                --preview 'file --brief -- {}' \
                --preview-window=up:25%:wrap
    else
        fd -H -t d $depth_arg . "$base" 2>/dev/null |
            fzf --multi --exact \
                --prompt='Select directory(ies) > ' \
                --preview 'ls -la -- {}' \
                --preview-window=up:40%:wrap
    end
end


function _fuzzy_escape_items
    set -l escaped

    for item in $argv
        set item (string trim --right --chars=/ "$item")
        set -a escaped (string escape -- "$item")
    end

    string join ' ' -- $escaped
end


function _fuzzy_open_applications
    set -l applications

    for app in mpv vlc firefox brave chromium google-chrome code
        if command -q "$app"
            set -a applications "$app"
        end
    end

    # Text editor
    if command -q nvim
        set -a applications "nvim"
    end

    if command -q xdg-open
        set -a applications "xdg-open"
    end

    printf '%s\n' $applications | sort -u
end


# =========================================================
# fcp - Fuzzy Copy
# =========================================================

function fcp

    set -l type (
        printf '%s\n' \
            'FILE' \
            'DIRECTORY' |
        fzf --exact --prompt='Type > '
    )

    if test -z "$type"
        echo "Cancelled."
        return 1
    end

    set -l items (_fuzzy_select_items "$type")

    if test -z "$items"
        echo "Nothing selected."
        return 1
    end

    set -l destination (_fuzzy_destination)

    if test -z "$destination"
        echo "No destination selected."
        return 1
    end

    set -l source_string (_fuzzy_escape_items $items)
    set -l escaped_destination (string escape -- "$destination")

    set -l command \
        "rsync -ah --info=progress2 $source_string $escaped_destination/"

    printf '%s' "$command" | xclip -selection clipboard

    echo
    echo "Command copied to clipboard:"
    echo
    echo "$command"
    echo
end


# =========================================================
# fmv - Fuzzy Move
# =========================================================

function fmv

    set -l type (
        printf '%s\n' \
            'FILE' \
            'DIRECTORY' |
        fzf --exact --prompt='Type > '
    )

    if test -z "$type"
        echo "Cancelled."
        return 1
    end

    set -l items (_fuzzy_select_items "$type")

    if test -z "$items"
        echo "Nothing selected."
        return 1
    end

    set -l destination (_fuzzy_destination)

    if test -z "$destination"
        echo "No destination selected."
        return 1
    end

    set -l source_string (_fuzzy_escape_items $items)
    set -l escaped_destination (string escape -- "$destination")

    set -l command \
        "rsync -ah --info=progress2 --remove-source-files $source_string $escaped_destination/ && find $source_string -type d -empty -delete 2>/dev/null"

    printf '%s' "$command" | xclip -selection clipboard

    echo
    echo "Command copied to clipboard:"
    echo
    echo "$command"
    echo
end

# =========================================================
# fcd - Fuzzy Change Directory
# =========================================================

function fcd

    set -l scope (_fuzzy_scope)

    if test -z "$scope"
        return 1
    end

    set -l base (_fuzzy_resolve_scope "$scope")
    set -l rec_opt (_fuzzy_recursive_option)

    if test -z "$rec_opt"
        return 1
    end

    set -l depth_arg
    if not string match -q 'YES*' "$rec_opt"
        set depth_arg --max-depth 1
    end

    set -l destination (
        fd -H -t d $depth_arg . "$base" 2>/dev/null |
        fzf --exact \
            --prompt='Directory > ' \
            --preview 'ls -la -- {}' \
            --preview-window=up:40%:wrap
    )

    if test -z "$destination"
        return 1
    end

    builtin cd -- "$destination"
end


# =========================================================
# fopen - Fuzzy Open / Open With
# =========================================================

function fopen

    set -l scope (_fuzzy_scope)

    if test -z "$scope"
        return 1
    end

    set -l base (_fuzzy_resolve_scope "$scope")
    set -l rec_opt (_fuzzy_recursive_option)

    if test -z "$rec_opt"
        return 1
    end

    set -l depth_arg
    if not string match -q 'YES*' "$rec_opt"
        set depth_arg --max-depth 1
    end

    set -l file (
        fd -H -t f $depth_arg . "$base" 2>/dev/null |
        fzf --exact \
            --prompt='Open file > ' \
            --preview 'file --brief -- {}' \
            --preview-window=up:25%:wrap
    )

    if test -z "$file"
        return 1
    end

    set -l choice (
        printf '%s\n' \
            'OPEN WITH DEFAULT' \
            'CHOOSE APPLICATION' |
        fzf --exact --prompt='Open with > '
    )

    if test -z "$choice"
        return 1
    end

    if test "$choice" = "OPEN WITH DEFAULT"
        nohup xdg-open "$file" >/dev/null 2>&1 &
        disown
        return 0
    end

    set -l application (
        _fuzzy_open_applications |
        fzf --exact --prompt='Application > '
    )

    if test -z "$application"
        return 1
    end

    switch "$application"
        case nvim
            nvim "$file"

        case mpv vlc firefox brave chromium google-chrome code xdg-open
            nohup "$application" "$file" >/dev/null 2>&1 &
            disown

        case '*'
            echo "Unknown application: $application"
            return 1
    end
end


# =========================================================
# fpath - Fuzzy File Path -> Clipboard
# =========================================================

function fpath

    set -l scope (_fuzzy_scope)

    if test -z "$scope"
        return 1
    end

    set -l base (_fuzzy_resolve_scope "$scope")
    set -l rec_opt (_fuzzy_recursive_option)

    if test -z "$rec_opt"
        return 1
    end

    set -l depth_arg
    if not string match -q 'YES*' "$rec_opt"
        set depth_arg --max-depth 1
    end

    set -l file (
        fd -H -t f $depth_arg . "$base" 2>/dev/null |
        fzf --exact \
            --prompt='Select file > ' \
            --preview 'file --brief -- {}' \
            --preview-window=up:25%:wrap
    )

    if test -z "$file"
        return 1
    end

    set -l path (realpath -- "$file")

    printf '%s' "$path" | xclip -selection clipboard

    echo
    echo "Copied:"
    echo "$path"
    echo
end


# =========================================================
# fkill - Fuzzy Process Killer
# =========================================================

function fkill

    set -l process (
        ps -eo pid,user,%cpu,%mem,stat,comm --sort=-%cpu |
        sed 1d |
        fzf --exact \
            --header='Select process' \
            --prompt='Process > ' \
            --preview 'ps -fp {1}' \
            --preview-window=up:30%
    )

    if test -z "$process"
        return 1
    end

    set -l fields (string split -n ' ' (string trim "$process"))
    set -l pid "$fields[1]"

    if not string match -rq '^[0-9]+$' "$pid"
        echo "Invalid PID."
        return 1
    end

    echo
    ps -fp "$pid"
    echo

    set -l action (
        printf '%s\n' \
            'TERMINATE (SIGTERM)' \
            'FORCE KILL (SIGKILL)' \
            'CANCEL' |
        fzf --exact --prompt='Action > '
    )

    switch "$action"
        case 'TERMINATE (SIGTERM)'
            kill "$pid"
            echo "SIGTERM sent to PID $pid."

        case 'FORCE KILL (SIGKILL)'
            kill -9 "$pid"
            echo "SIGKILL sent to PID $pid."

        case '*'
            echo "Cancelled."
    end
end


# =========================================================
# fssh - Fuzzy SSH History
# =========================================================

function fssh

    set -l cmd (
        history |
        grep -E '(^|[;&|[:space:]])ssh([[:space:]]|$)' |
        fzf --tac --exact --prompt='SSH > '
    )

    if test -z "$cmd"
        return 1
    end

    echo
    echo "Selected command:"
    echo "$cmd"
    echo

    set -l action (
        printf '%s\n' \
            'RUN' \
            'EDIT' \
            'CANCEL' |
        fzf --exact --prompt='Action > '
    )

    switch "$action"
        case RUN
            eval "$cmd"

        case EDIT
            read -P "Command: " -c "$cmd" cmd

            if test -n "$cmd"
                eval "$cmd"
            end

        case '*'
            echo "Cancelled."
    end
end


# =========================================================
# fmount - Fuzzy Mount
# =========================================================

function fmount

    set -l device (
        lsblk -nrpo NAME,SIZE,FSTYPE,LABEL,MOUNTPOINT |
        awk 'NF >= 1 && $5 == "" {print}' |
        fzf --exact \
            --prompt='Mount device > ' \
            --preview 'lsblk -f {1}' \
            --preview-window=up:30%
    )

    if test -z "$device"
        return 1
    end

    set -l device_path (string split -m1 ' ' (string trim "$device"))[1]

    if not test -b "$device_path"
        echo "Invalid block device: $device_path"
        return 1
    end

    echo
    lsblk -f "$device_path"
    echo

    set -l action (
        printf '%s\n' \
            'MOUNT' \
            'CANCEL' |
        fzf --exact --prompt='Action > '
    )

    if test "$action" != "MOUNT"
        return 1
    end

    udisksctl mount -b "$device_path"
end


# =========================================================
# fumount - Fuzzy Unmount
# =========================================================

function fumount

    set -l mountpoint (
        lsblk -nrpo NAME,MOUNTPOINT |
        awk 'NF >= 2 && $2 != "" {print $2}' |
        sort -u |
        fzf --exact \
            --prompt='Unmount > ' \
            --preview 'ls -la -- {}' \
            --preview-window=up:40%:wrap
    )

    if test -z "$mountpoint"
        return 1
    end

    echo
    echo "Unmount:"
    echo "$mountpoint"
    echo

    set -l action (
        printf '%s\n' \
            'UNMOUNT' \
            'CANCEL' |
        fzf --exact --prompt='Action > '
    )

    if test "$action" != "UNMOUNT"
        return 1
    end

    set -l device_path (findmnt -no SOURCE --target "$mountpoint" 2>/dev/null)

    if test -z "$device_path"
        echo "Could not determine the block device for: $mountpoint"
        return 1
    end

    udisksctl unmount -b "$device_path"
end


# =========================================================
# fsize - Fuzzy File/Directory Size
# =========================================================

function fsize

    set -l scope (_fuzzy_scope)

    if test -z "$scope"
        return 1
    end

    set -l base (_fuzzy_resolve_scope "$scope")
    set -l rec_opt (_fuzzy_recursive_option)

    if test -z "$rec_opt"
        return 1
    end

    set -l depth_arg
    if not string match -q 'YES*' "$rec_opt"
        set depth_arg --max-depth 1
    end

    set -l item (
        fd -H $depth_arg . "$base" 2>/dev/null |
        fzf --exact \
            --prompt='Size > ' \
            --preview 'du -sh -- {} 2>/dev/null'
    )

    if test -z "$item"
        return 1
    end

    echo
    du -sh -- "$item"
end


# =========================================================
# finfo - Fuzzy File Information
# =========================================================

function finfo

    set -l scope (_fuzzy_scope)

    if test -z "$scope"
        return 1
    end

    set -l base (_fuzzy_resolve_scope "$scope")
    set -l rec_opt (_fuzzy_recursive_option)

    if test -z "$rec_opt"
        return 1
    end

    set -l depth_arg
    if not string match -q 'YES*' "$rec_opt"
        set depth_arg --max-depth 1
    end

    set -l item (
        fd -H $depth_arg . "$base" 2>/dev/null |
        fzf --exact \
            --prompt='Info > ' \
            --preview 'file -- {}'
    )

    if test -z "$item"
        return 1
    end

    echo
    stat -- "$item"
    echo
    file -- "$item"
end


# =========================================================
# frename - Fuzzy Rename
# =========================================================

function frename

    set -l scope (_fuzzy_scope)

    if test -z "$scope"
        return 1
    end

    set -l base (_fuzzy_resolve_scope "$scope")
    set -l rec_opt (_fuzzy_recursive_option)

    if test -z "$rec_opt"
        return 1
    end

    set -l depth_arg
    if not string match -q 'YES*' "$rec_opt"
        set depth_arg --max-depth 1
    end

    set -l item (
        fd -H $depth_arg . "$base" 2>/dev/null |
        fzf --exact \
            --prompt='Rename > ' \
            --preview 'ls -ld -- {}'
    )

    if test -z "$item"
        return 1
    end

    set -l directory (dirname -- "$item")
    set -l old_name (basename -- "$item")

    echo
    echo "Current name: $old_name"
    echo

    read -P "New name: " new_name

    if test -z "$new_name"
        echo "Cancelled."
        return 1
    end

    if test -e "$directory/$new_name"
        echo "A file or directory with that name already exists."
        return 1
    end

    mv -- "$item" "$directory/$new_name"

    echo
    echo "Renamed:"
    echo "$old_name -> $new_name"
end


# =========================================================
# fdelete - Fuzzy Delete
# =========================================================

function fdel

    set -l type (
        printf '%s\n' \
            'FILE' \
            'DIRECTORY' |
        fzf --exact --prompt='Delete type > '
    )

    if test -z "$type"
        echo "Cancelled."
        return 1
    end

    set -l items (_fuzzy_select_items "$type")

    if test -z "$items"
        echo "Nothing selected."
        return 1
    end

    echo
    echo "Selected:"
    printf '%s\n' $items
    echo

    set -l action (
        printf '%s\n' \
            'DELETE' \
            'CANCEL' |
        fzf --exact --prompt='Confirm > '
    )

    if test "$action" != "DELETE"
        echo "Cancelled."
        return 1
    end

    set -l total_bytes 0
    for item in $items
        if test -d "$item"
            set -l size (find "$item" -type f -printf '%s\n' 2>/dev/null | awk '{sum += $1} END {print sum + 0}')
        else
            set -l size (stat -c '%s' -- "$item" 2>/dev/null)
        end
        if test -n "$size"
            set total_bytes (math $total_bytes + $size)
        end
    end

    if test $total_bytes -le 0
        rm -rf -- $items
        echo
        echo "Deleted successfully."
        return $status
    end

    set -l done_bytes 0
    for item in $items
        if test -d "$item"
            for file in (find "$item" -type f -print0 | string split0)
                set -l size (stat -c '%s' -- "$file" 2>/dev/null)
                rm -f -- "$file"
                if test -n "$size"
                    set done_bytes (math $done_bytes + $size)
                end
                set -l percent (math "min(100, floor(100 * $done_bytes / $total_bytes))")
                printf '\rDeleting: %3d%%' $percent
            end
            rm -rf -- "$item"
        else
            set -l size (stat -c '%s' -- "$item" 2>/dev/null)
            rm -f -- "$item"
            if test -n "$size"
                set done_bytes (math $done_bytes + $size)
            end
            set -l percent (math "min(100, floor(100 * $done_bytes / $total_bytes))")
            printf '\rDeleting: %3d%%' $percent
        end
    end

    printf '\rDeleting: 100%%\n'
    echo "Deleted successfully."
end

# =========================================================
# fmkdir - Fuzzy Create Directory
# =========================================================

function fmkdir

    set -l destination (_fuzzy_destination)

    if test -z "$destination"
        return 1
    end

    read -P "Directory name: " name

    if test -z "$name"
        echo "Cancelled."
        return 1
    end

    mkdir -p -- "$destination/$name"

    echo "Created:"
    echo "$destination/$name"
end


# =========================================================
# farchive - Fuzzy Archive
# =========================================================

function farchive

    set -l type (
        printf '%s\n' \
            'FILE' \
            'DIRECTORY' |
        fzf --exact --prompt='Archive type > '
    )

    if test -z "$type"
        echo "Cancelled."
        return 1
    end

    set -l items (_fuzzy_select_items "$type")

    if test -z "$items"
        echo "Nothing selected."
        return 1
    end

    set -l format (
        printf '%s\n' \
            'ZIP' \
            'TAR.GZ' \
            'TAR.XZ' \
            '7Z' |
        fzf --exact --prompt='Format > '
    )

    if test -z "$format"
        return 1
    end

    set -l first (string trim --right --chars=/ "$items[1]")
    set -l name (basename -- "$first")
    set -l destination (_fuzzy_destination)

    if test -z "$destination"
        return 1
    end

    set -l common (dirname -- "$first")

    for item in $items[2..-1]
        set -l parent (dirname -- (string trim --right --chars=/ "$item"))

        while not string match -q -- "$common" "$parent"
            if test "$common" = "/"
                break
            end
            set common (dirname -- "$common")
        end
    end

    set -l relative_items
    for item in $items
        set -a relative_items (realpath --relative-to="$common" -- "$item")
    end

    set -l total_bytes 0
    for item in $items
        if test -d "$item"
            set -l size (find "$item" -type f -printf '%s\n' 2>/dev/null | awk '{sum += $1} END {print sum + 0}')
        else
            set -l size (stat -c '%s' -- "$item" 2>/dev/null)
        end
        if test -n "$size"
            set total_bytes (math $total_bytes + $size)
        end
    end

    set -l status_code 1

    switch "$format"
        case ZIP
            if not command -q 7z
                echo "7z is required for ZIP progress. Install it with: sudo pacman -S 7zip"
                return 1
            end
            pushd "$common" >/dev/null
            7z a -tzip -bsp1 "$destination/$name.zip" $relative_items
            set status_code $status
            popd >/dev/null

        case TAR.GZ
            if not command -q pv
                echo "pv is required for archive progress. Install it with: sudo pacman -S pv"
                return 1
            end
            if test $total_bytes -gt 0
                pushd "$common" >/dev/null
                tar -cf - $relative_items | pv -s $total_bytes -p -t -e -r | gzip > "$destination/$name.tar.gz"
                set -l pipe_status $pipestatus
                if test $pipe_status[1] -ne 0
                    set status_code $pipe_status[1]
                else if test $pipe_status[2] -ne 0
                    set status_code $pipe_status[2]
                else
                    set status_code $pipe_status[3]
                end
                popd >/dev/null
            else
                pushd "$common" >/dev/null
                tar -czf "$destination/$name.tar.gz" $relative_items
                set status_code $status
                popd >/dev/null
            end

        case TAR.XZ
            if not command -q pv
                echo "pv is required for archive progress. Install it with: sudo pacman -S pv"
                return 1
            end
            if test $total_bytes -gt 0
                pushd "$common" >/dev/null
                tar -cf - $relative_items | pv -s $total_bytes -p -t -e -r | xz > "$destination/$name.tar.xz"
                set -l pipe_status $pipestatus
                if test $pipe_status[1] -ne 0
                    set status_code $pipe_status[1]
                else if test $pipe_status[2] -ne 0
                    set status_code $pipe_status[2]
                else
                    set status_code $pipe_status[3]
                end
                popd >/dev/null
            else
                pushd "$common" >/dev/null
                tar -cJf "$destination/$name.tar.xz" $relative_items
                set status_code $status
                popd >/dev/null
            end

        case 7Z
            if not command -q 7z
                echo "7z is required. Install it with: sudo pacman -S 7zip"
                return 1
            end
            pushd "$common" >/dev/null
            7z a -bsp1 "$destination/$name.7z" $relative_items
            set status_code $status
            popd >/dev/null
    end

    if test $status_code -ne 0
        return $status_code
    end

    echo
    echo "Archive created:"
    switch "$format"
        case ZIP
            echo "$destination/$name.zip"
        case TAR.GZ
            echo "$destination/$name.tar.gz"
        case TAR.XZ
            echo "$destination/$name.tar.xz"
        case 7Z
            echo "$destination/$name.7z"
    end
    echo
end


# =========================================================
# fextract - Fuzzy Extract Archive
# =========================================================

function fextract

    set -l scope (_fuzzy_scope)

    if test -z "$scope"
        return 1
    end

    set -l base (_fuzzy_resolve_scope "$scope")
    set -l rec_opt (_fuzzy_recursive_option)

    if test -z "$rec_opt"
        return 1
    end

    set -l depth_arg
    if not string match -q 'YES*' "$rec_opt"
        set depth_arg --max-depth 1
    end

    set -l archive (
        fd -H -t f $depth_arg . "$base" 2>/dev/null |
        grep -Ei '\.(zip|tar|tgz|tar\.gz|tar\.xz|txz|7z|rar)$' |
        fzf --exact \
            --prompt='Extract > ' \
            --preview 'file -- {}'
    )

    if test -z "$archive"
        return 1
    end

    set -l destination (_fuzzy_destination)

    if test -z "$destination"
        return 1
    end

    if not command -q 7z
        echo "7z is required for extraction progress. Install it with: sudo pacman -S 7zip"
        return 1
    end

    7z x -bsp1 -aoa "$archive" "-o$destination"
end
