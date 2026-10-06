return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
		{ "folke/neodev.nvim", opts = {} },
	},
	config = function()
		local lspconfig = require("lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")
		local keymap = vim.keymap
		local qt_clangd_flag_pattern = "^Unknown argument:%s*['\"]?%-mno%-direct%-extern%-access['\"]?"

		local default_publish_diagnostics = vim.lsp.handlers["textDocument/publishDiagnostics"]
		vim.lsp.handlers["textDocument/publishDiagnostics"] = function(err, result, ctx, config)
			local client = ctx and vim.lsp.get_client_by_id(ctx.client_id)
			if client and client.name == "clangd" and result and result.diagnostics then
				result = vim.deepcopy(result)
				result.diagnostics = vim.tbl_filter(function(diagnostic)
					local message = diagnostic.message or ""
					return not message:match(qt_clangd_flag_pattern)
				end, result.diagnostics)
			end

			return default_publish_diagnostics(err, result, ctx, config)
		end

		-- setup keymaps when LSP attaches
		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("UserLspConfig", {}),
			callback = function(ev)
				local opts = { buffer = ev.buf, silent = true }

				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				if client and client.server_capabilities.semanticTokensProvider then
					client.server_capabilities.semanticTokensProvider = nil
				end

				opts.desc = "Show LSP references"
				keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)

				opts.desc = "Go to declaration"
				keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

				opts.desc = "Go to definition"
				keymap.set("n", "gd", vim.lsp.buf.definition, opts)

				opts.desc = "Show LSP implementations"
				keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

				opts.desc = "Show LSP type definitions"
				keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

				opts.desc = "See available code actions"
				keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)

				opts.desc = "Smart rename"
				keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

				opts.desc = "Show buffer diagnostics"
				keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

				opts.desc = "Show line diagnostics"
				keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)

				opts.desc = "Go to previous diagnostic"
				keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

				opts.desc = "Go to next diagnostic"
				keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

				opts.desc = "Show documentation under cursor"
				keymap.set("n", "K", vim.lsp.buf.hover, opts)

				opts.desc = "Restart LSP"
				keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)

				-- Enable inlay hints if supported
				local client = vim.lsp.get_client_by_id(ev.data.client_id)
				local ft = vim.bo[ev.buf].filetype
				local path = vim.api.nvim_buf_get_name(ev.buf)
				local disable_inlay_hints = vim.tbl_contains({ "c", "cpp", "objc", "objcpp" }, ft)
					or path:match("%.h$")
					or path:match("%.hh$")
					or path:match("%.hpp$")
					or path:match("%.hxx$")
					or path:match("%.inl$")

				if client and client.server_capabilities.inlayHintProvider and not disable_inlay_hints then
					vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
				end
			end,
		})

		-- LSP completion capabilities
		local capabilities = cmp_nvim_lsp.default_capabilities()

		-- diagnostic signs
		local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		-- Keep diagnostics useful without painting full lines across the editor.
		vim.diagnostic.config({
			virtual_text = false,
			signs = true,
			underline = {
				severity = vim.diagnostic.severity.ERROR,
			},
			update_in_insert = false,
			severity_sort = true,
		})

		-- ============================
		-- Language servers
		-- ============================
		local python = require("user.python")
		local function python_root(bufnr, on_dir)
			on_dir(python.root(bufnr))
		end
		vim.lsp.config("pyright", {
			capabilities = capabilities,
			root_dir = python_root,
			before_init = function(_, config)
				config.settings.python.pythonPath = python.python(config.root_dir)
			end,
			settings = {
				pyright = { disableOrganizeImports = true },
				python = {
					analysis = {
						autoSearchPaths = true,
						useLibraryCodeForTypes = true,
						diagnosticMode = "openFilesOnly",
						typeCheckingMode = "basic",
					},
				},
			},
		})
		vim.lsp.config("ruff", {
			capabilities = capabilities,
			root_dir = python_root,
			on_attach = function(client)
				client.server_capabilities.hoverProvider = false
			end,
		})
		vim.lsp.enable({ "pyright", "ruff" })

		-- TypeScript / TSX
		local capabilities = require("cmp_nvim_lsp").default_capabilities()

		-- ============================
		-- TypeScript / TSX (NEW API)
		-- ============================
		vim.lsp.config("ts_ls", {
			capabilities = capabilities,
			filetypes = {
				"typescript",
				"typescriptreact",
				"javascript",
				"javascriptreact",
			},
		})

		vim.lsp.enable("ts_ls")

		-- HTML / CSS / Emmet / Tailwind
		local web_servers = {
			html = {
				filetypes = { "html", "templ" },
			},
			cssls = {
				filetypes = { "css", "scss", "less" },
			},
			emmet_ls = {
				filetypes = {
					"html",
					"css",
					"scss",
					"less",
					"javascriptreact",
					"typescriptreact",
					"svelte",
				},
			},
			tailwindcss = {},
		}

		for server, server_config in pairs(web_servers) do
			server_config.capabilities = capabilities
			vim.lsp.config(server, server_config)
			vim.lsp.enable(server)
		end

		-- ============================
		-- Clang
		-- ============================
		vim.lsp.config("clangd", {
			capabilities = capabilities,
			cmd = {
				"clangd",
				"--background-index",
				"--clang-tidy",
				"--query-driver=/usr/bin/c++,/usr/bin/g++",
			},
		})
		vim.lsp.enable("clangd")

		-- auto-format on save
		vim.api.nvim_create_autocmd("BufWritePre", {
			callback = function(ev)
				local ft = vim.bo[ev.buf].filetype
				local cpp_like = vim.tbl_contains({ "c", "cpp", "objc", "objcpp" }, ft)

				if not cpp_like then
					return
				end

				vim.lsp.buf.format({
					bufnr = ev.buf,
					async = false,
					filter = function(client)
						return client.name == "clangd"
					end,
				})
			end,
		})
	end,
}
