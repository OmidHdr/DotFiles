#if status is-interactive
#  set PATH /home/h0p3/.local/bin $PATH
#   # Commands to run in interactive sessions can go here
#end

# ------ default editor and browser ------
set -x VISUAL lvim
set -x EDITOR lvim
set -x BROWSER /usr/bin/brave

# Export paths
set -x PATH $PATH /home/h0p3/.local/bin /opt/clion-2022.3.1/bin /opt/oracle/product/18c/dbhomeXE/bin
#set -x JAVA_HOME /usr/lib/jvm/default
set -U fish_user_paths ~/.local/share/jdtls/bin $fish_user_paths
set -x JAVA_HOME /usr/lib/jvm/java-17-openjdk
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
set -x LESSHISTFILE "-"
set -x WGETRC "$XDG_CONFIG_HOME/wget/wgetrc"
set -x MBSYNCRC "$XDG_CONFIG_HOME/mbsync/config"
set -x PASSWORD_STORE_DIR "$XDG_DATA_HOME/password-store"
set -x GOPATH "$XDG_DATA_HOME/go"
set -x CARGO_HOME "$XDG_DATA_HOME/cargo"
set -x NPM_CONFIG_USERCONFIG "$XDG_CONFIG_HOME/npm/npmrc"
set -x N_PREFIX "$HOME/.local/bin/n"
set -x ZDOTDIR "$HOME/.config/zsh"
set -x MANPAGER "less -R --use-color -Dd+r -Du+b"
set -x WINIT_X11_SCALE_FACTOR 1.75  # Corrected syntax
set -x LF_ICONS "tw=:st=:ow=:dt=:di=:fi=:ln=:or=:ex=:*.c=:*.cc=:*.clj=:*.coffee=:*.cpp=:*.css=:*.d=:*.dart=:*.erl=:*.exs=:*.fs=:*.go=:*.h=:*.hh=:*.hpp=:*.hs=:*.html=:*.java=:*.jl=:*.js=:*.json=:*.lua=:*.md=:*.php=:*.pl=:*.pro=:*.py=:*.rb=:*.rs=:*.scala=:*.ts=:*.vim=:*.cmd=:*.ps1=:*.sh=:*.bash=:*.zsh=:*.fish=:*.tar=:*.tgz=:*.arc=:*.arj=:*.taz=:*.lha=:*.lz4=:*.lzh=:*.lzma=:*.tlz=:*.txz=:*.tzo=:*.t7z=:*.zip=:*.z=:*.dz=:*.gz=:*.lrz=:*.lz=:*.lzo=:*.xz=:*.zst=:*.tzst=:*.bz2=:*.bz=:*.tbz=:*.tbz2=:*.tz=:*.deb=:*.rpm=:*.jar=:*.war=:*.ear=:*.sar=:*.rar=:*.alz=:*.ace=:*.zoo=:*.cpio=:*.7z=:*.rz=:*.cab=:*.wim=:*.swm=:*.dwm=:*.esd=:*.jpg=:*.jpeg=:*.mjpg=:*.mjpeg=:*.gif=:*.bmp=:*.pbm=:*.pgm=:*.ppm=:*.tga=:*.xbm=:*.xpm=:*.tif=:*.tiff=:*.png=:*.svg=:*.svgz=:*.mng=:*.pcx=:*.mov=:*.mpg=:*.mpeg=:*.m2v=:*.mkv=:*.webm=:*.ogm=:*.mp4=:*.m4v=:*.mp4v=:*.vob=:*.qt=:*.nuv=:*.wmv=:*.asf=:*.rm=:*.rmvb=:*.flc=:*.avi=:*.fli=:*.flv=:*.gl=:*.dl=:*.xcf=:*.xwd=:*.yuv=:*.cgm=:*.emf=:*.ogv=:*.ogx=:*.aac=:*.au=:*.flac=:*.m4a=:*.mid=:*.midi=:*.mka=:*.mp3=:*.mpc=:*.ogg=:*.ra=:*.wav=:*.oga=:*.opus=:*.spx=:*.xspf=:*.pdf=:*.nix=:"

set -x LC_ALL en_US.UTF-8

set -x ___MY_VMOPTIONS_SHELL_FILE "$HOME/.jetbrains.vmoptions.sh"
if test -f "$___MY_VMOPTIONS_SHELL_FILE"
    source "$___MY_VMOPTIONS_SHELL_FILE"
end

# Aliases
alias notes 'xfce4-notes'
alias lf 'lfub'
alias ls 'lsd'
alias l 'ls -l'
alias la 'ls -a'
alias lla 'ls -la'
alias lt 'ls --tree'
alias vim 'lvim'


# --------------------- Fuzzy Stuff ---------------------
alias fcd='cd $(fd -t d | fzf --exact)'

function open
    set -l file (find -type f -not -path '*/.*' | fzf --exact)
    if test -n "$file"
        nohup xdg-open "$file" > /dev/null 2>&1 &
    end
end


function getpath
    fd -t f | fzf --exact | sed -E 's/ /\\\\ /g; s/([()])/\\\\\1/g; s/([\[\]])/\\\\\1/g' | tr -d '\n' | xclip -selection c
end


alias prorm 'rm $(find -type f | fzf -m --exact)'


function procp
    # انتخاب فایل‌ها با fzf
    set -l files (find -type f -not -path '*/.*' | sed -E 's/ /\\\\ /g; s/([()])/\\\\\1/g; s/([\[\]])/\\\\\1/g' | fzf --multi --exact --preview 'cat {}' --preview-window=up:30%:wrap)
    
    # اگر هیچ فایلی انتخاب نشده باشد، خروج
    if test -z "$files"
        echo "No files selected."
        return 1
    end

    # ایجاد دستور rsync
    set -l command "rsync -avh --progress $files ~/"
    
    # ذخیره دستور به کلیپ‌بورد
    printf '%s' "$command" | xclip -selection c

end

function promv
    # انتخاب فایل‌ها با fzf
    set -l files (find -type f -not -path '*/.*' | sed -E 's/ /\\\\ /g; s/([()])/\\\\\1/g; s/([\[\]])/\\\\\1/g' | fzf --multi --exact --preview 'cat {}' --preview-window=up:30%:wrap)
    
    # اگر هیچ فایلی انتخاب نشده باشد، خروج
    if test -z "$files"
        echo "No files selected."
        return 1
    end

    # ایجاد دستور rsync
    set -l command "rsync -avh --progress --remove-source-files $files ~/"
    
    # ذخیره دستور به کلیپ‌بورد
    printf '%s' "$command" | xclip -selection c

end

function fkill
    set pid (ps -e | fzf | awk '{print $1}')
    if test -n "$pid"
        kill -9 $pid
    end
end

function fssh
    set cmd (history | grep ssh | fzf)
    if test -n "$cmd"
        eval $cmd
    end
end

bind \ck fkill
bind \cs fssh

# Set up colors for fzf
set fg "#CBE0F0"
set bg "#011628"
set bg_highlight "#143652"
set purple "#B388FF"
set blue "#06BCE4"
set cyan "#2CF9ED"

set -x FZF_DEFAULT_OPTS --color=fg:$fg,bg:$bg,hl:$purple,fg+:$fg,bg+:$bg_highlight,hl+:$purple,info:$blue,prompt:$cyan,pointer:$cyan,marker:$cyan,spinner:$cyan,header:$cyan

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
#set -x BAT_THEME "tokyonight_night"

# ---- TheFuck ----
# Function for using 'thefuck' with Fish shell

function fuck -d "Correct your previous console command"
    set -l fucked_up_command (history | head -n1)
    set -l unfucked_command (env TF_SHELL=fish TF_ALIAS=fuck PYTHONIOENCODING=utf-8 thefuck $fucked_up_command $argv)
    
    if test -n "$unfucked_command"
        eval $unfucked_command
        history delete --exact --case-sensitive -- $fucked_up_command
        history merge
    end
end

function fk -d "Correct your previous console command"
    set -l fucked_up_command (history | head -n1)
    set -l unfucked_command (env TF_SHELL=fish TF_ALIAS=fk PYTHONIOENCODING=utf-8 thefuck $fucked_up_command $argv)
    
    if test -n "$unfucked_command"
        eval $unfucked_command
        history delete --exact --case-sensitive -- $fucked_up_command
        history merge
    end
end

# ---- Zoxide (better cd) ----
zoxide init fish | source
alias cd="z"

# -------------------- End of Fuzzy Stuff -----------------------------





