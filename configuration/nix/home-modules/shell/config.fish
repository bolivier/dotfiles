function fish_prompt
    set_color cyan
    echo -n " "(whoami) " "

    set_color yellow
    echo -n (prompt_pwd) " "

    # Check for jj repository first
    if jj status >/dev/null 2>&1
        set_color brmagenta
        set jj_rev (jj log -r @ --no-graph -T 'change_id.short() ++ " " ++ description.first_line()' 2>/dev/null)
        if test -n "$jj_rev"
            echo -n "jj:$jj_rev "
        end
    # Fall back to git if not in jj repo
    else if git rev-parse --git-dir >/dev/null 2>&1
        set_color brmagenta
        set __fish_git_prompt_showcolor yes
        set __fish_git_prompt_showupstream auto
        set __fish_git_prompt_showbranch yes
        set __fish_git_prompt_color_branch magenta
        echo -n (fish_git_prompt)
    end

    echo ""
    set_color green
    echo -n "λ "
    set_color normal
end
