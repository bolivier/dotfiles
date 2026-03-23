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

if command -q mise
    source ~/.config/fish/mise.fish  # no longer in conf.d/
end
