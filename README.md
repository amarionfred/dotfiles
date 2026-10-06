# Arch / Hyprland dotfiles

A shareable desktop, Zsh and Neovim configuration.

## Included

- Hyprland, wallpaper switching, Waybar, Mako and application launchers.
- Kitty, Zsh, Starship and tmux.
- Neovim with C/C++, Rust and ordinary Python editing, formatting, tests and debugging.
- Cava, Fastfetch, GTK/font preferences, btop, desktop autostart and the Waybar user service override.
- A screenshot helper that saves images and copies them to the clipboard.

`install-files.txt` is the complete list of installed files. The repository uses a restricted path list and does not capture other home-directory contents.

## Install

```sh
git clone https://github.com/amarionfred/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh --dry-run
./install.sh
```

The installer requires Python 3, backs up replaced files under `~/.local/state/dotfiles-backups/`, and leaves unrelated files alone. It expands `@HOME@` placeholders to your home directory. Use `--target-dir /path/to/home` to preview or install elsewhere.

Install your chosen applications separately. The main components are Hyprland, Waybar, Kitty, Zsh, Starship, tmux, Neovim, Rofi/Wofi, Mako, Hyprpaper, Cava and Fastfetch. Screenshots need `grim`, `slurp`, `wl-clipboard`, `xdg-user-dirs` and `notify-send`. The standalone screenshot helper uses Bash; no Bash startup configuration is installed.

Adjust the `eDP-1` monitor and Italian keyboard layout to your hardware. Reopen affected applications after installation. Kitty and the desktop session use `/usr/bin/zsh`; changing your account's login shell is a separate choice.

## Neovim

Run `:Lazy restore` to install the locked plugin versions and inspect `:Mason` for language tools. See [the Neovim guide](.config/nvim/README.md).

Python uses an explicitly selected interpreter, a project virtual environment, an activated environment, or system Python. Optional Obsidian support discovers the current vault or uses `OBSIDIAN_VAULT`; no vault or personal workspace is bundled.

## Common shortcuts

| Shortcut | Action |
| --- | --- |
| `Super Return` | Kitty |
| `Super D` | App launcher |
| `Super Q` | Close window |
| `Super H/J/K/L` | Move focus |
| `Super Shift H/J/K/L` | Move window |
| `Super W` | Next wallpaper |
| `Super S` | Select, save and copy screenshot |
| `Print` / `Super Shift S` | Save and copy full screenshot |
| `Space pr` / `Space pd` in Neovim | Run / debug Python |

Use `nv` for Neovim in tmux. Review and copy changes to the relevant public configuration files manually; the repository has no automatic home-directory capture command.
