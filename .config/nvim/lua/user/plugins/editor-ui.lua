return {
	{
		"lukas-reineke/indent-blankline.nvim",
		main = "ibl",
		opts = {
			indent = {
				char = "▏",
				highlight = "IblIndent",
			},
			scope = {
				enabled = true,
				char = "▏",
				show_start = false,
				show_end = false,
				highlight = "IblScope",
			},
		},
		config = function(_, opts)
			local function set_indent_highlights()
				-- Koda clears plugin highlights while loading. Reapply the same
				-- understated values used by base16-default-dark so its guides do
				-- not look heavier after a theme switch.
				vim.api.nvim_set_hl(0, "IblIndent", { fg = "#383838", nocombine = true })
				vim.api.nvim_set_hl(0, "IblScope", { fg = "#50505d", nocombine = true })
			end

			set_indent_highlights()
			vim.api.nvim_create_autocmd("ColorScheme", {
				group = vim.api.nvim_create_augroup("ConsistentThinIndentGuides", { clear = true }),
				callback = set_indent_highlights,
			})
			require("ibl").setup(opts)
		end,
	},
	{
		"lewis6991/gitsigns.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = {
			current_line_blame = true,
			current_line_blame_opts = {
				delay = 600,
			},
		},
	},
	{
		"SmiteshP/nvim-navic",
		opts = {
			highlight = true,
			separator = " > ",
			depth_limit = 5,
		},
		config = function(_, opts)
			local navic = require("nvim-navic")

			navic.setup(opts)

			vim.o.winbar = "%{%v:lua.require'nvim-navic'.get_location()%}"

			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("PersonalNavicAttach", { clear = true }),
				callback = function(args)
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client and client.server_capabilities.documentSymbolProvider then
						navic.attach(client, args.buf)
					end
				end,
			})
		end,
	},
	{
		"mvllow/modes.nvim",
		event = "VeryLazy",
		opts = {
			colors = {
				copy = "#8f7d52",
				delete = "#8a5158",
				insert = "#5f789e",
				visual = "#756384",
			},
			line_opacity = 0.05,
			set_cursor = true,
			set_cursorline = false,
			set_number = true,
		},
	},
}
