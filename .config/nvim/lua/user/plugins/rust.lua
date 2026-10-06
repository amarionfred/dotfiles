local function cargo_root(bufnr)
	local file = vim.api.nvim_buf_get_name(bufnr or 0)
	local start = file ~= "" and vim.fs.dirname(file) or vim.fn.getcwd()
	local manifest = vim.fs.find("Cargo.toml", { path = start, upward = true })[1]
	return manifest and vim.fs.dirname(manifest) or vim.fn.getcwd()
end

local function cargo_task(args, bufnr)
	vim.cmd("botright 15new")
	vim.bo.bufhidden = "wipe"
	vim.bo.swapfile = false
	vim.api.nvim_buf_set_name(0, "cargo://" .. table.concat(args, "-"))

	local command = vim.list_extend({ "cargo" }, vim.deepcopy(args))
	local job = vim.fn.jobstart(command, {
		cwd = cargo_root(bufnr),
		term = true,
		on_exit = function(_, code)
			vim.schedule(function()
				vim.notify("cargo " .. args[1] .. " exited with code " .. code, code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
			end)
		end,
	})

	if job <= 0 then
		vim.notify("Could not start cargo " .. args[1], vim.log.levels.ERROR)
		return
	end
	vim.cmd("startinsert")
end

return {
	{
		"mrcjkb/rustaceanvim",
		ft = { "rust" },
		dependencies = {
			"mfussenegger/nvim-dap",
			"hrsh7th/cmp-nvim-lsp",
		},
		init = function()
			vim.g.rustaceanvim = {
				tools = {
					executor = "termopen",
					test_executor = "neotest",
					crate_test_executor = "neotest",
					enable_clippy = true,
					reload_workspace_from_cargo_toml = true,
					code_actions = { ui_select_fallback = true },
				},
				server = {
					capabilities = require("cmp_nvim_lsp").default_capabilities(),
					on_attach = function(_, bufnr)
						local function map(mode, lhs, rhs, desc)
							vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
						end

						map("n", "<leader>rr", function() vim.cmd.RustLsp("runnables") end, "Rust: choose runnable")
						map("n", "<leader>rR", function() vim.cmd.RustLsp({ "runnables", bang = true }) end, "Rust: repeat last runnable")
						map("n", "<leader>rt", function() vim.cmd.RustLsp("testables") end, "Rust: choose test")
						map("n", "<leader>rT", function() require("neotest").run.run() end, "Rust: test nearest")
						map("n", "<leader>rA", function() require("neotest").run.run(vim.fn.expand("%")) end, "Rust: test file")
						map("n", "<leader>rd", function() vim.cmd.RustLsp("debug") end, "Rust: debug target at cursor")
						map("n", "<leader>rD", function() vim.cmd.RustLsp("debuggables") end, "Rust: choose debuggable")
						map("n", "<leader>rc", function() vim.cmd.RustLsp({ "flyCheck", "run" }) end, "Rust: run Clippy check")
						map("n", "<leader>ra", function() vim.cmd.RustLsp("codeAction") end, "Rust: code action")
						map("n", "<leader>re", function() vim.cmd.RustLsp({ "explainError", "current" }) end, "Rust: explain error")
						map("n", "<leader>rE", function() vim.cmd.RustLsp({ "renderDiagnostic", "current" }) end, "Rust: render compiler diagnostic")
						map("n", "<leader>rm", function() vim.cmd.RustLsp("expandMacro") end, "Rust: expand macro")
						map("n", "<leader>ro", function() vim.cmd.RustLsp("openDocs") end, "Rust: open docs.rs")
						map("n", "<leader>rp", function() vim.cmd.RustLsp("parentModule") end, "Rust: parent module")
						map("n", "<leader>rC", function() vim.cmd.RustLsp("openCargo") end, "Rust: open Cargo.toml")
						map("n", "<leader>rS", function() require("neotest").summary.toggle() end, "Rust: test summary")
						map("n", "<leader>rO", function() require("neotest").output_panel.toggle() end, "Rust: test output")
						map("n", "]t", function() require("neotest").jump.next({ status = "failed" }) end, "Next failed test")
						map("n", "[t", function() require("neotest").jump.prev({ status = "failed" }) end, "Previous failed test")

						map("n", "<leader>cb", function() cargo_task({ "build", "--workspace", "--all-targets", "--all-features" }, bufnr) end, "Cargo build all")
						map("n", "<leader>cc", function() cargo_task({ "check", "--workspace", "--all-targets", "--all-features" }, bufnr) end, "Cargo check all")
						map("n", "<leader>cl", function() cargo_task({ "clippy", "--workspace", "--all-targets", "--all-features" }, bufnr) end, "Cargo Clippy all")
						map("n", "<leader>ct", function() cargo_task({ "test", "--workspace", "--all-targets", "--all-features" }, bufnr) end, "Cargo test all")
						map("n", "<leader>cf", function() cargo_task({ "fmt", "--all" }, bufnr) end, "Cargo format all")
						map("n", "<leader>cd", function() cargo_task({ "doc", "--workspace", "--all-features", "--no-deps" }, bufnr) end, "Cargo docs all")

						vim.api.nvim_create_autocmd("BufWritePre", {
							group = vim.api.nvim_create_augroup("RustFormatOnSave" .. bufnr, { clear = true }),
							buffer = bufnr,
							callback = function()
								vim.lsp.buf.format({ bufnr = bufnr, async = false, name = "rust-analyzer" })
							end,
						})
					end,
					default_settings = {
						["rust-analyzer"] = {
							checkOnSave = true,
							check = {
								command = "clippy",
								allTargets = true,
								features = "all",
								workspace = true,
							},
							cargo = {
								allTargets = true,
								features = "all",
								buildScripts = { enable = true },
							},
							procMacro = { enable = true },
							inlayHints = {
								bindingModeHints = { enable = true },
								closureReturnTypeHints = { enable = "always" },
								discriminantHints = { enable = "always" },
								lifetimeElisionHints = { enable = "always", useParameterNames = true },
							},
						},
					},
				},
				dap = { autoload_configurations = true },
			}
		end,
	},
}
