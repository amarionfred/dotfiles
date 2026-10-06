local terminal = "kitty"
local file_manager = "dolphin"
local menu = "rofi -show drun"
local main_mod = "SUPER"
local wallpaper_cmd = "@HOME@/.config/hypr/set-wallpaper.sh --next"

hl.monitor({ output = "eDP-1", mode = "preferred", position = "0x0", scale = 1 })
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("GTK_THEME", "Adwaita:dark")
hl.env("SHELL", "/usr/bin/zsh")

hl.config({
	input = { kb_layout = "it", follow_mouse = 1, sensitivity = 0, touchpad = { natural_scroll = false } },
	general = { gaps_in = 5, gaps_out = 5, border_size = 2, col = { active_border = { colors = { "rgba(ffffffff)", "rgba(ffffffff)" }, angle = 45 }, inactive_border = "rgba(00000000)" }, resize_on_border = false, allow_tearing = false, layout = "dwindle" },
	decoration = { rounding = 5, rounding_power = 2, active_opacity = 0.90, inactive_opacity = 0.98, shadow = { enabled = false }, blur = { enabled = false } },
	dwindle = { preserve_split = true },
	master = { new_status = "master" },
	misc = { disable_hyprland_logo = true, force_default_wallpaper = 0 },
})

hl.curve("smoothInOut", { type = "bezier", points = { { 0.65, 0 }, { 0.35, 1 } } })
hl.curve("stylish", { type = "bezier", points = { { 0.2, 0.9 }, { 0.2, 1 } } })
hl.curve("subtle", { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1 } } })
hl.animation({ leaf = "global", enabled = true, speed = 1, bezier = "smoothInOut" })
hl.animation({ leaf = "windows", enabled = true, speed = 6, bezier = "stylish", style = "popin 96%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 5, bezier = "smoothInOut", style = "popin 96%" })
hl.animation({ leaf = "border", enabled = true, speed = 9, bezier = "subtle" })
hl.animation({ leaf = "fade", enabled = true, speed = 5, bezier = "smoothInOut" })
hl.animation({ leaf = "layersIn", enabled = true, speed = 5, bezier = "subtle", style = "slide bottom" })
hl.animation({ leaf = "layersOut", enabled = true, speed = 4, bezier = "smoothInOut", style = "slide bottom" })
hl.animation({ leaf = "fadeLayersIn", enabled = true, speed = 4, bezier = "subtle" })
hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 4, bezier = "smoothInOut" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 6, bezier = "stylish", style = "slide" })

hl.bind(main_mod .. " + S", hl.dsp.exec_cmd("@HOME@/.local/bin/save-screenshot region"))
hl.bind("Print", hl.dsp.exec_cmd("@HOME@/.local/bin/save-screenshot full"))
hl.bind(main_mod .. " + SHIFT + S", hl.dsp.exec_cmd("@HOME@/.local/bin/save-screenshot full"))
hl.bind(main_mod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(main_mod .. " + D", hl.dsp.exec_cmd(menu))
hl.bind(main_mod .. " + E", hl.dsp.exec_cmd(file_manager))
hl.bind(main_mod .. " + Q", hl.dsp.window.close())
hl.bind(main_mod .. " + SHIFT + Q", hl.dsp.exit())
hl.bind(main_mod .. " + Escape", hl.dsp.exec_cmd("sh -lc 'command -v hyprlock >/dev/null 2>&1 && exec hyprlock'"))
hl.bind(main_mod .. " + H", hl.dsp.focus({ direction = "left" }))
hl.bind(main_mod .. " + J", hl.dsp.focus({ direction = "down" }))
hl.bind(main_mod .. " + K", hl.dsp.focus({ direction = "up" }))
hl.bind(main_mod .. " + L", hl.dsp.focus({ direction = "right" }))
hl.bind(main_mod .. " + left", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(main_mod .. " + right", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(main_mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(main_mod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(main_mod .. " + SHIFT + H", hl.dsp.window.move({ direction = "left" }))
hl.bind(main_mod .. " + SHIFT + J", hl.dsp.window.move({ direction = "down" }))
hl.bind(main_mod .. " + SHIFT + K", hl.dsp.window.move({ direction = "up" }))
hl.bind(main_mod .. " + SHIFT + L", hl.dsp.window.move({ direction = "right" }))
hl.bind(main_mod .. " + T", hl.dsp.group.toggle())
hl.bind(main_mod .. " + Tab", hl.dsp.group.next())
hl.bind(main_mod .. " + SHIFT + Tab", hl.dsp.group.prev())
hl.bind(main_mod .. " + SHIFT + T", hl.dsp.window.deny_from_group())
hl.bind(main_mod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(main_mod .. " + SHIFT + F", hl.dsp.window.fullscreen())
hl.bind(main_mod .. " + R", hl.dsp.exec_cmd("hyprctl reload"))
hl.bind(main_mod .. " + W", hl.dsp.exec_cmd(wallpaper_cmd))
hl.bind(main_mod .. " + SHIFT + R", hl.dsp.exec_cmd("@HOME@/.config/hypr/set-wallpaper.sh"))
hl.bind(main_mod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(main_mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })
for i = 1, 10 do local key = i % 10; hl.bind(main_mod .. " + " .. key, hl.dsp.focus({ workspace = i })); hl.bind(main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i })) end
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.window_rule({ name = "origo-workspace", match = { class = "^(origo)$" }, workspace = 4 })
hl.window_rule({ name = "suppress-maximize-events", match = { class = ".*" }, suppress_event = "maximize" })
hl.window_rule({ name = "unmanaged-move", match = { title = "^(unmanaged)$" }, move = "5 50" })
hl.window_rule({ name = "unmanaged-size", match = { title = "^(unmanaged)$" }, size = "1900 1000" })
hl.window_rule({ name = "unmanaged-float", match = { title = "^(unmanaged)$" }, float = true })
hl.on("hyprland.start", function()
	hl.exec_cmd("setsid -f waybar -c @HOME@/.config/waybar/config.json -s @HOME@/.config/waybar/style.css")
	hl.exec_cmd("@HOME@/.config/hypr/set-wallpaper.sh")
	hl.exec_cmd("setsid -f mako")
	hl.exec_cmd("setsid -f /usr/lib/hyprpolkitagent/hyprpolkitagent")
end)
