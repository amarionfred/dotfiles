#!/bin/sh

WALL_DIR="${HYPR_WALLPAPER_DIR:-$HOME/.config/hypr/wallpapers}"
STATE="${XDG_STATE_HOME:-$HOME/.local/state}/hypr-wallpaper"
LOG="${XDG_STATE_HOME:-$HOME/.local/state}/hypr-wallpaper.log"
CONF="$HOME/.config/hypr/hyprpaper.conf"

mkdir -p "$(dirname "$STATE")"

pick_next() {
	current="$(cat "$STATE" 2>/dev/null || true)"
	find "$WALL_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | sort | awk -v current="$current" '
		NR == 1 { first = $0 }
		found { print; printed = 1; exit }
		$0 == current { found = 1 }
		END { if (!printed && first) print first }
	'
}

pick_current() {
	img="$(cat "$STATE" 2>/dev/null || true)"
	if [ -f "$img" ]; then
		printf '%s\n' "$img"
		return
	fi
	find "$WALL_DIR" -maxdepth 1 -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) | sort | head -n 1
}

if [ -n "${HYPR_WALLPAPER:-}" ]; then
	IMG="$HYPR_WALLPAPER"
elif [ "${1:-}" = "--next" ]; then
	IMG="$(pick_next)"
else
	IMG="$(pick_current)"
fi

if [ ! -f "$IMG" ]; then
	printf '%s no-wallpaper-found in %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$WALL_DIR" >> "$LOG"
	exit 1
fi

printf '%s\n' "$IMG" > "$STATE"
printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$IMG" >> "$LOG"

if ! command -v hyprpaper >/dev/null 2>&1; then
	exit 1
fi

if ! pgrep -x hyprpaper >/dev/null 2>&1; then
	setsid -f hyprpaper --config "$CONF" >/dev/null 2>&1
	sleep 0.3
fi

if command -v hyprctl >/dev/null 2>&1 && [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
	hyprctl monitors | awk '/^Monitor / { print $2 }' | while IFS= read -r mon; do
		[ -n "$mon" ] && hyprctl hyprpaper wallpaper "$mon,$IMG" >/dev/null 2>&1 || true
	done
fi
