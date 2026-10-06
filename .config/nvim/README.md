# Personal Neovim Config

A focused Neovim setup for day-to-day Python, Rust, C/C++, and general coding, with fast navigation, LSP-backed editing, debugging, file browsing, transparent terminal visuals, and a theme workflow that is easy to switch without touching config files.

## Highlights

- Plugin management through [lazy.nvim](https://github.com/folke/lazy.nvim), bootstrapped automatically on first launch.
- Fuzzy finding, live grep, references, implementations, and diagnostics through Telescope.
- LSP setup for C/C++, TypeScript, web files, GraphQL, Svelte, and Python.
- Completion with `nvim-cmp`, LuaSnip snippets, path suggestions, buffer words, and LSP sources.
- Treesitter highlighting for common web, systems, scripting, and markdown filetypes.
- C/C++ debugging through `nvim-dap`, with LLDB or CodeLLDB auto-detection.
- Python editing with Pyright, Ruff formatting and linting, virtual environments, an integrated REPL, Neotest, and debugpy.
- Cargo-aware Rust editing through `rustaceanvim`: rust-analyzer, Clippy-on-save, runnable/test/debug target discovery, Neotest, LLDB, rustfmt, macros, compiler explanations, and docs.
- A custom theme picker with persisted selection and quick next/previous theme commands.
- Practical UI touches: file tree, bufferline, lualine, diagnostics, folds, markdown rendering, indent guides, cursor smear, and transparent editor backgrounds.

## Install

Back up your existing config first, then clone this repo into Neovim's config directory:

```sh
git clone <repo-url> ~/.config/nvim
nvim
```

On first launch, `lazy.nvim` installs itself and then installs the configured plugins.

### External tools

Some features work best when these tools are available on your `PATH`:

- `git`, `make`, and a C compiler for native plugin builds.
- Language servers such as `clangd`, `ts_ls`, `pyright`, `html`, `cssls`, `tailwindcss`, `svelte`, `graphql`, and `emmet_ls`.
- `lldb-dap` or `codelldb` for debugging C and C++.
- A Rust toolchain with `cargo`, `rust-analyzer`, `rustfmt`, and `clippy`.
- `tmux` is optional. When installed, the shell `nv` helper opens Neovim inside a `main` session with a bottom status strip.

## Workflow

Open Neovim from the project root so Telescope, clangd, diagnostics, debug paths, and build tooling see the same workspace:

```sh
cd ~/path/to/project
nvim .
```

For the terminal status-bar workflow, use:

```sh
nv
```

The daily C/C++ loop is intentionally plain:

```sh
cmake -S . -B build
cmake --build build
ctest --test-dir build
```

Use Telescope for movement across the project, LSP for code navigation, and DAP when you need an interactive debugger. C and C++ buffers format through `clangd` on save.

## Keybindings

Leader is `<Space>`. `<C-n>` means hold `Ctrl` and press `n`.

### Buffers, Tabs, and Splits

Bufferline shows open buffers across the top of the editor. These are the file-like tabs you switch through during normal work.

| Key | Action |
| --- | --- |
| `<Tab>` | Next buffer |
| `<S-Tab>` | Previous buffer |
| `<leader>x` | Delete / close the current buffer |
| `<leader>X` | Force-delete the current buffer |
| `<leader>h` | Move current buffer left |
| `<leader>l` | Move current buffer right |
| `<leader>n` | Open a real Vim tab page |
| `<leader>sv` | Vertical split |
| `<leader>sh` | Horizontal split |
| `<leader>sx` | Close current split |
| `<leader>se` | Equalize split sizes |
| `<C-h>` / `<C-j>` / `<C-k>` / `<C-l>` | Move left / down / up / right between splits (and tmux panes) |

### Main Commands

| Key | Action |
| --- | --- |
| `<leader>ff` | Find files |
| `<leader>fw` | Live grep |
| `<leader>fs` | Document symbols |
| `<leader>fc` | Search word under cursor |
| `<C-n>` | Toggle file tree |
| `<leader>e` | Toggle file tree |
| `<leader>E` | Focus file tree |
| `<leader>ts` | Select theme |
| `<leader>tn` / `<leader>tp` | Next / previous theme |
| `gd`, `gD`, `gi`, `gt` | LSP navigation |
| `<leader>ca` | Code action |
| `<leader>rn` | Rename symbol |
| `<leader>d` / `<leader>D` | Line / buffer diagnostics |
| `<leader>dc` | Continue debugger |
| `<leader>db` | Toggle breakpoint |
| `<leader>ds`, `<leader>di`, `<leader>do` | Step over / into / out |
| `<leader>du` | Toggle debugger UI |

### Rust and Cargo

These mappings are buffer-local and appear in Rust files.

| Key | Action |
| --- | --- |
| `<leader>rr` / `<leader>rR` | Choose a Cargo runnable / repeat it |
| `<leader>rt` | Choose and run a Rust test |
| `<leader>rT` / `<leader>rA` | Test nearest / current file |
| `<leader>rd` / `<leader>rD` | Debug target at cursor / choose a debuggable target |
| `<leader>rc` | Run the Clippy fly-check |
| `<leader>ra` | Rust-aware code actions |
| `<leader>re` / `<leader>rE` | Explain error / render full compiler diagnostic |
| `<leader>rm` | Expand macro |
| `<leader>ro` | Open docs.rs for the symbol |
| `<leader>rC` | Open the workspace `Cargo.toml` |
| `<leader>rS` / `<leader>rO` | Toggle test summary / test output |
| `]t` / `[t` | Next / previous failed test |
| `<leader>cb` | `cargo build` for the whole workspace |
| `<leader>cc` | `cargo check` for the whole workspace |
| `<leader>cl` | `cargo clippy` for the whole workspace |
| `<leader>ct` | `cargo test` for the whole workspace |
| `<leader>cf` | `cargo fmt --all` |
| `<leader>cd` | Build workspace documentation |

### Python

Open a Python project with `nvim .`. Python files use four spaces, Treesitter highlighting, Pyright completion/type checking, and Ruff diagnostics. Saving sorts imports and formats with Ruff; existing `pyproject.toml`/`ruff.toml` settings are respected. `gd`, `K`, `<leader>rn`, and `<leader>ca` provide navigation, documentation, rename, and code actions. Completion uses the existing Tab/Enter menu and Python snippets.

For a new project, create an environment and install its dependencies there:

```sh
cd ~/path/to/project
python3 -m venv .venv
.venv/bin/python -m pip install pytest
nvim .
```

Install your project's other dependencies into that same environment. Existing uv-created `.venv` directories work too. For projects without a `pyproject.toml` or `setup.cfg`, a `pytest.ini` containing `[pytest]` identifies the test root.

The interpreter is shared by Pyright, running files, the REPL, tests, and debugging. Detection prefers a selection made with `:PythonEnv`, then a project `.venv`, `venv`, `env`, or `.env`, then the activated `VIRTUAL_ENV`/`CONDA_PREFIX`, then system Python. Use `:PythonEnv /path/to/venv` or `:PythonEnv /path/to/python` for Poetry/Conda/custom environments. Relative paths resolve from the Python project root. Selections apply to that project for the current Neovim session; `:PythonEnvReset` restores automatic detection. Run it after creating an environment while Neovim is open so Pyright refreshes its interpreter.

| Key | Action |
| --- | --- |
| `<leader>pr` | Save and run the current file in a terminal split |
| `<leader>pi` | Open the project Python REPL |
| `<leader>pv` / `<leader>pe` | Select environment / show project and interpreter |
| `<leader>pf` | Format and sort imports |
| `<leader>pF` | Apply Ruff's safe fixes, sort imports, and format |
| `<leader>pt` / `<leader>pT` | Run nearest test / current test file |
| `<leader>pa` | Run project tests |
| `<leader>ps` | Toggle test summary |
| `<leader>po` / `<leader>pO` | Show test output / toggle output panel |
| `<leader>px` | Stop a test run |
| `<leader>pd` / `<leader>pD` | Debug current file / nearest test |
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Start or continue debugging |
| `<leader>ds`, `<leader>di`, `<leader>do` | Step over / into / out |
| `<leader>dt` / `<leader>du` | Stop debugger / toggle debugger UI |

Use `:PythonRun arg1 arg2` for script arguments or `:PythonModule package.module arg1` to run a module from the project root. Escape spaces in command arguments with a backslash. In a terminal or REPL, press Escape twice to return to normal mode; `:close` hides the split and Ctrl-D exits the REPL.

Neotest uses pytest when installed in the selected environment and otherwise detects unittest/Django. The debugger lives in Mason's isolated environment, so ordinary project debugging does not require installing debugpy in every project. Advanced launch configurations can go in `.vscode/launch.json`.

For a fresh installation, run `:MasonInstall pyright ruff debugpy` and `:TSInstall python toml`. Inspect `:LspInfo`, `:ConformInfo`, `:Mason`, or `:PythonInfo` when troubleshooting. Disable Python format-on-save for the current buffer with `:let b:disable_autoformat = v:true`.

References: [Ruff's Neovim setup](https://docs.astral.sh/ruff/editors/setup/#neovim), [Neotest Python](https://github.com/nvim-neotest/neotest-python), and [debugpy](https://github.com/microsoft/debugpy).

## Structure

```text
init.lua                 Entry point
lua/user/core/          Options, keymaps, theme state, filetype setup
lua/user/plugins/       Plugin specs
lua/user/plugins/lsp/   LSP and Mason setup
lua/user/tools/         Small local helper tools
lua/user/python.lua     Python environment, run, test, and debugger helpers
tools/ai_health.py      Framework/device/gradient checks
after/ftplugin/python.lua  Python indentation, commands, and keymaps
```
