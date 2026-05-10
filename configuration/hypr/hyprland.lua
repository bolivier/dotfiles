-- Hyprland configuration (ported from hyprland.conf)

--------------------
--- MONITORS ---
--------------------

monitor("DP-3", "preferred", "auto", 1.2)
monitor("eDP-1", "preferred", "auto", 1, { mirror = "DP-3" })

xwayland {
    force_zero_scaling = true
}

-- toolkit-specific scale
env("GDK_SCALE", "1")
env("XCURSOR_SIZE", "24")

---------------------
--- MY PROGRAMS ---
---------------------

local terminal = "ghostty"
local browser = "brave --ozone-platform=wayland --new-window"
local webapp = browser .. " --app"

-------------------
--- AUTOSTART ---
-------------------

exec_once("noctalia-shell")

bind("SUPER", "space", "exec", "noctalia-shell ipc call launcher toggle")

-------------------------------
--- ENVIRONMENT VARIABLES ---
-------------------------------

env("XCURSOR_SIZE", "24")
env("HYPRCURSOR_SIZE", "24")

-----------------------
--- LOOK AND FEEL ---
-----------------------

general {
    gaps_in = 5
    gaps_out = 5

    border_size = 2

    ["col.active_border"] = rgba("33ccffee") .. " " .. rgba("00ff99ee") .. " 45deg"
    ["col.inactive_border"] = rgba("595959aa")

    resize_on_border = true

    allow_tearing = false

    layout = "scrolling"
}

decoration {
    rounding = 10

    active_opacity = 1
    inactive_opacity = 0.98

    blur {
        enabled = true
        size = 3
        passes = 2

        vibrancy = 0.1696
    }
}

animations {
    enabled = true

    bezier("myBezier", 0.05, 0.9, 0.1, 1.05)

    animation("windows", true, 7, "myBezier")
    animation("windowsOut", true, 7, "default", "popin 80%")
    animation("border", true, 10, "default")
    animation("borderangle", true, 8, "default")
    animation("fade", true, 7, "default")
    animation("workspaces", true, 6, "default")
}

scrolling {}

dwindle {
    pseudotile = true
    preserve_split = true
    bind("SUPER", "h", "movefocus", "l")
    bind("SUPER", "l", "movefocus", "r")
    bind("SUPER", "k", "movefocus", "u")
    bind("SUPER", "j", "movefocus", "d")
    bind("SUPER_SHIFT", "h", "swapwindow", "l")
    bind("SUPER_SHIFT", "l", "swapwindow", "r")
    bind("SUPER_SHIFT", "j", "swapwindow", "d")
    bind("SUPER_SHIFT", "k", "swapwindow", "u")
}

master {
    mfact = 0.65
    new_status = "master"
    new_on_top = true
    bind("SUPER", "j", "layoutmsg", "rollnext")
    bind("SUPER", "k", "layoutmsg", "rollprev")
    bind("SUPER_SHIFT", "j", "layoutmsg", "rollnext")
    bind("SUPER_SHIFT", "k", "layoutmsg", "rollprev")
}

misc {
    disable_hyprland_logo = true
    focus_on_activate = true
}

---------------
--- INPUT ---
---------------

input {
    kb_layout = "us"
    kb_variant = ""
    kb_model = ""
    kb_options = ""
    kb_rules = ""

    follow_mouse = 1

    sensitivity = 0

    touchpad {
        natural_scroll = false
    }
}

device {
    name = "epic-mouse-v1"
    sensitivity = -0.5
}

----------------------
--- KEYBINDINGS ---
----------------------

bind("SUPER", "q", "killactive", "")
bind("SUPER", "return", "exec", terminal)
bind("SUPER", "e", "exec", "emacs")
bind("SUPER", "m", "exec", "spotify")
bind("SUPER", "V", "togglefloating", "")
bind("SUPER", "escape", "exec", "hyprlock")

-- apps
bind("SUPER", "b", "exec", terminal .. " -e bluetui")
bind("SUPER", "s", "exec", "slack")
bind("SUPER", "w", "exec", browser)
bind("SUPER", "z", "exec", "zathura")
bind("SUPER", "y", "exec", webapp .. "=https://youtube.com")

bind("SUPER", "f", "fullscreen", "")
bind("SUPER SHIFT", "f", "togglefloating", "")
bind("SUPER", "PRINT", "exec", "hyprshot -m region")
bind("SUPER", "p", "exec", "hyprshot -m region")

-- Switch workspaces with mainMod + [0-9]
for i = 1, 9 do
    bind("SUPER", tostring(i), "workspace", tostring(i))
end
bind("SUPER", "0", "workspace", "10")

-- Move active window to a workspace with mainMod + SHIFT + [0-9]
for i = 1, 9 do
    bind("SUPER SHIFT", tostring(i), "movetoworkspace", tostring(i))
end
bind("SUPER SHIFT", "0", "movetoworkspace", "10")

-- Scroll through existing workspaces with mainMod + scroll
bind("SUPER", "mouse_down", "workspace", "e+1")
bind("SUPER", "mouse_up", "workspace", "e-1")

-- Move/resize windows with mainMod + LMB/RMB and dragging
bindm("SUPER", "mouse:272", "movewindow")
bindm("SUPER", "mouse:273", "resizewindow")

-- Volume controls
bindel("", "XF86AudioRaiseVolume", "exec", "pactl set-sink-volume @DEFAULT_SINK@ +5%")
bindel("", "XF86AudioLowerVolume", "exec", "pactl set-sink-volume @DEFAULT_SINK@ -5%")
bindl("", "XF86AudioMute", "exec", "pactl set-sink-mute @DEFAULT_SINK@ toggle")
bindl("", "XF86AudioMicMute", "exec", "pactl set-source-mute @DEFAULT_SOURCE@ toggle")

-- Media controls
bindl("", "XF86AudioPlay", "exec", "playerctl play-pause")
bindl("", "XF86AudioNext", "exec", "playerctl next")
bindl("", "XF86AudioPrev", "exec", "playerctl previous")
bindl("", "XF86AudioStop", "exec", "playerctl stop")

--------------------------------
--- WINDOWS AND WORKSPACES ---
--------------------------------

-- Window rules can be added here as needed
-- windowrule("float", "^(kitty)$")
