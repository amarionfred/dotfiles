return {
	"nvim-neotest/neotest",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-neotest/nvim-nio",
		"nvim-treesitter/nvim-treesitter",
		"mrcjkb/rustaceanvim",
		"nvim-neotest/neotest-python",
	},
	config = function()
		local python = require("user.python")
		local adapter = require("neotest-python")({
			python = function(root) return python.python(root) end,
			dap = { justMyCode = true },
		})
		-- The adapter defaults test/debug cwd to Neovim's cwd. Use the test's
		-- project so opening a file from another directory still works.
		local build_spec = adapter.build_spec
		adapter.build_spec = function(args)
			local spec = build_spec(args)
			spec.cwd = python.root(args.tree:data().path)
			if type(spec.strategy) == "table" then
				spec.strategy.cwd = spec.cwd
			end
			return spec
		end
		require("neotest").setup({
			adapters = {
				require("rustaceanvim.neotest"),
				adapter,
			},
			output = { open_on_run = "short" },
			quickfix = { open = false },
			status = { virtual_text = true, signs = true },
		})
	end,
}
