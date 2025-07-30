# -*- mode: sh -*-
function g
    git status
end

alias vim='nvim'
fish_add_path ~/.config/emacs/bin

function doom-emacs
    doom run &
    disown
end

zoxide init fish | source

set -gx EDITOR nvim

function ols
    command ls $argv
end

function ls
    eza --long --group-directories-first --binary --no-permissions --octal-permissions --icons $argv
end

function ocd
    command cd $argv
end

function cd
    z $argv
end

# if "usage" is not installed show an error
if ! command -v usage &>/dev/null
    echo >&2
    echo "Error: usage CLI not found. This is required for completions to work in mise." >&2
    echo "See https://usage.jdx.dev for more information." >&2
    return 1
end

if ! set -q _usage_spec_mise_2025_7_2
    set -g _usage_spec_mise_2025_7_2 (mise usage | string collect)
end
set -l tokens
if commandline -x >/dev/null 2>&1
    complete -xc mise -a '(usage complete-word --shell fish -s "$_usage_spec_mise_2025_7_2" -- (commandline -xpc) (commandline -t))'
else
    complete -xc mise -a '(usage complete-word --shell fish -s "$_usage_spec_mise_2025_7_2" -- (commandline -opc) (commandline -t))'
end
