return {
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local nvimtree = require("nvim-tree")

    local hide_root_files = false

    nvimtree.setup({
      sync_root_with_cwd = true,
      respect_buf_cwd = false,
      update_focused_file = {
        enable = true,
        update_root = false,
      },
      view = {
        side = "left",
        width = 35,
        preserve_window_proportions = true,
      },
      actions = {
        open_file = {
          quit_on_open = false,
          resize_window = true,
        },
      },
      renderer = {
        highlight_opened_files = "all",
        indent_markers = {
          enable = true,
          -- Keep folder arrows in their own column so an expanded folder
          -- cannot replace the guide for its parent level.
          inline_arrows = false,
          icons = {
            -- Straight editor-style indent guides: no tree elbows/branches.
            corner = "▏",
            edge = "▏",
            item = "▏",
            bottom = " ",
            -- NvimTree normally blanks an ancestor column after its final
            -- direct child. Keep it drawn through all deeper descendants,
            -- like code indentation guides rather than branch connectors.
            none = "▏",
          },
        },
      },
      git = { enable = false },
      tab = {
        sync = {
          open = false,
          close = false,
          ignore = {},
        },
      },
    })

    local function set_tree_guide_highlight()
      vim.api.nvim_set_hl(0, "NvimTreeIndentMarker", { fg = "#454545", nocombine = true })
    end

    set_tree_guide_highlight()
    vim.api.nvim_create_autocmd("ColorScheme", {
      group = vim.api.nvim_create_augroup("NvimTreeVisibleIndentMarkers", { clear = true }),
      callback = set_tree_guide_highlight,
    })

    require("user.tools.include_rename").setup(require("nvim-tree.api"))

    local keymap = vim.keymap
    keymap.set("n", "<C-n>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
    keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
    keymap.set("n", "<leader>E", "<cmd>NvimTreeFocus<CR>", { desc = "Focus file explorer" })
  end,
}
