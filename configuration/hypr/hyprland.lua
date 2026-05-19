local terminal = "ghostty"
local browser = "brave --ozone-platform=wayland --new-window"

hl.monitor({
	output = "DP-3",
	mode = "preferred",
	position = "auto",
	scale = "1.2",
})

hl.monitor({
	output = "eDP-1",
	mode = "preferred",
	position = "auto",
  mirror = "DP-3",
	scale = "auto",
})

hl.monitor({
	output = "",
	mode = "preferred",
	position = "auto",
	scale = "auto",
})

hl.env("GDK_SCALE", "24")
hl.env("XCURSOR_SIZE", "20")
hl.env("HYPRCURSOR_SIZE", "24")

hl.config({
    general = {
      gaps_in = 5,
      gaps_out = 5,
      border_size = 2,
      col = {
        active_border   = { colors = {"rgba(33ccffee)", "rgba(00ff99ee)"}, angle = 45 },
        inactive_border = "rgba(595959aa)",
      },


      resize_on_border = true,

      allow_tearing = false,
      layout = "scrolling",
    },

    decoration = {
      rounding = 10,
      rounding_power = 2,

      shadow = {
        enabled = true,
        range = 4,
        render_power = 3,
        color = 0xee1a1a1a,

      }
    },

    xwayland = {
      -- Fixes the Emacs font
      force_zero_scaling = true,
    },

    misc = {
      disable_hyprland_logo = true,
      disable_splash_rendering = true,
    }
})

function super(key) 
    return "SUPER + " .. key
end

function super_shift(key) 
    return "SUPER + SHIFT + " .. key
end

local global_super_bindings = {
  q = hl.dsp.window.close(),
  ["return"] = hl.dsp.exec_cmd(terminal),
  q =  hl.dsp.window.close(),
  e =  hl.dsp.exec_cmd("emacs"),
  w =  hl.dsp.exec_cmd(browser),
  m =  hl.dsp.exec_cmd("spotify"),
  s =  hl.dsp.exec_cmd("slack"),
  escape =  hl.dsp.exec_cmd("hyprlock"),
  print =  hl.dsp.exec_cmd("hyprshot -m region"),
  space = hl.dsp.exec_cmd("noctalia-shell ipc call launcher toggle"),
}

for k, f in pairs(global_super_bindings) do
  hl.bind(super(k), f)
end

hl.bind(super_shift("p"), hl.dsp.exec_cmd("hyprshot -m region"))

-- Laptop multimedia keys for volume and LCD brightness
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ +5%"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("pactl set-sink-volume @DEFAULT_SINK@ -5%"),      { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("pactl set-sink-mute @DEFAULT_SINK@ toggle"),     { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",     hl.dsp.exec_cmd("pactl set-source-mute @DEFAULT_SOURCE@ toggle"),   { locked = true, repeating = true })

-- Requires playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

hl.bind(super("h"), hl.dsp.focus({  direction = "left" }))
hl.bind(super("l"), hl.dsp.focus({  direction = "right" }))
hl.bind(super_shift("h"), hl.dsp.layout('swapcol l'))
hl.bind(super_shift("l"), hl.dsp.layout('swapcol r'))


function toggle_fullscreen_ish()
-- Figure out how to toggle 'fit active' and colsize 0.5 here.
-- mostly need to know how to procure data about window

end


hl.bind(super("f"), hl.dsp.layout('fit active'))

for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(super(key), hl.dsp.focus({ workspace = i}))
    hl.bind(super_shift(key), hl.dsp.window.move({ workspace = i }))
end


