return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			python = { "ruff_organize_imports", "ruff_format" },
			html = { "prettier" },
			css = { "prettier" },
			scss = { "prettier" },
			less = { "prettier" },
			javascript = { "prettier" },
			javascriptreact = { "prettier" },
			typescript = { "prettier" },
			typescriptreact = { "prettier" },
			json = { "prettier" },
			jsonc = { "prettier" },
		},
		format_on_save = function(bufnr)
			local ft = vim.bo[bufnr].filetype
			if ft == "python" then
				if not vim.b[bufnr].disable_autoformat then
					return { timeout_ms = 2000, lsp_format = "never" }
				end
				return
			end
			if vim.tbl_contains({
				"html",
				"css",
				"scss",
				"less",
				"javascript",
				"javascriptreact",
				"typescript",
				"typescriptreact",
				"json",
				"jsonc",
			}, ft) then
				return { timeout_ms = 2000, lsp_format = "fallback" }
			end
		end,
	},
}
