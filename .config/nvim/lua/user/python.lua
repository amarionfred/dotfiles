local M = {}
local selected = {}
local markers = { "pyproject.toml", "pyrightconfig.json", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", "pytest.ini", ".venv", "venv", ".git" }

local function directory(path)
	if type(path) == "number" or path == nil then
		path = vim.api.nvim_buf_get_name(path or 0)
	end
	if path == "" then
		return vim.fn.getcwd()
	end
	path = vim.fs.normalize(vim.fn.fnamemodify(path, ":p"))
	return vim.fn.isdirectory(path) == 1 and path or vim.fs.dirname(path)
end

function M.root(path)
	local start = directory(path)
	local marker = vim.fs.find(markers, { path = start, upward = true })[1]
	return marker and vim.fs.dirname(marker) or start
end

function M.python(path)
	local root = M.root(path)
	if selected[root] and vim.fn.executable(selected[root]) == 1 then
		return selected[root]
	end
	for _, name in ipairs({ ".venv", "venv", "env", ".env" }) do
		local python = root .. "/" .. name .. "/bin/python"
		if vim.fn.executable(python) == 1 then
			return python
		end
	end
	for _, name in ipairs({ "VIRTUAL_ENV", "CONDA_PREFIX" }) do
		local env = vim.env[name]
		if env and vim.fn.executable(env .. "/bin/python") == 1 then
			return env .. "/bin/python"
		end
	end
	return vim.fn.exepath("python3") ~= "" and vim.fn.exepath("python3") or "python"
end

local function update_python(root)
	local python = M.python(root)
	for _, client in ipairs(vim.lsp.get_clients({ name = "pyright" })) do
		if client.config.root_dir == root then
			client.settings.python = vim.tbl_extend("force", client.settings.python or {}, { pythonPath = python })
			client:notify("workspace/didChangeConfiguration", { settings = client.settings })
		end
	end
	vim.cmd.redrawstatus()
	vim.notify("Python: " .. python)
end

function M.select(path, bufnr)
	local root = M.root(bufnr)
	local function choose(value)
		if not value or value == "" then
			return
		end
		local python = vim.fs.normalize(vim.fn.expand(value))
		if python:sub(1, 1) ~= "/" then
			python = root .. "/" .. python
		end
		if vim.fn.isdirectory(python) == 1 then
			python = python .. "/bin/python"
		end
		if vim.fn.executable(python) ~= 1 then
			vim.notify("Python interpreter is not executable: " .. python, vim.log.levels.ERROR)
			return
		end
		selected[root] = python
		update_python(root)
	end
	if path and path ~= "" then
		choose(path)
	else
		vim.ui.input({ prompt = "Python interpreter or venv: ", default = M.python(root), completion = "file" }, choose)
	end
end

function M.reset(bufnr)
	local root = M.root(bufnr)
	selected[root] = nil
	update_python(root)
end

function M.info(bufnr)
	vim.notify("Project: " .. M.root(bufnr) .. "\nPython: " .. M.python(bufnr))
end

local function save(bufnr)
	if vim.api.nvim_buf_get_name(bufnr) == "" then
		vim.notify("Save the Python file first.", vim.log.levels.WARN)
		return false
	end
	local ok, err = pcall(vim.api.nvim_buf_call, bufnr, function() vim.cmd.update() end)
	if not ok then
		vim.notify(tostring(err), vim.log.levels.ERROR)
	end
	return ok
end

function M.terminal(args, bufnr, opts)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	opts = opts or {}
	local source_win = vim.api.nvim_get_current_win()
	local root, python = M.root(bufnr), M.python(bufnr)
	local command = vim.list_extend({ python }, args)
	vim.cmd("botright 14new")
	vim.bo.bufhidden = "hide"
	vim.bo.swapfile = false
	local terminal_buf = vim.api.nvim_get_current_buf()
	local job = vim.fn.jobstart(command, {
		cwd = root,
		term = true,
		env = { PATH = vim.fs.dirname(python) .. ":" .. (vim.env.PATH or "") },
		on_exit = function(_, code)
			vim.schedule(function()
				vim.notify("Python exited with code " .. code, code == 0 and vim.log.levels.INFO or vim.log.levels.ERROR)
			end)
		end,
	})
	if job <= 0 then
		vim.notify("Could not start " .. python, vim.log.levels.ERROR)
		return
	end
	vim.keymap.set("t", "<Esc><Esc>", [[<C-\><C-n>]], { buffer = true, desc = "Leave terminal mode" })
	if opts.focus == false then
		vim.api.nvim_set_current_win(source_win)
	else
		vim.cmd.startinsert()
	end
	return job, terminal_buf
end

function M.run(args, bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	if save(bufnr) then
		return M.terminal(vim.list_extend({ vim.api.nvim_buf_get_name(bufnr) }, args or {}), bufnr)
	end
end

function M.module(args, bufnr)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	if save(bufnr) then
		return M.terminal(vim.list_extend({ "-m" }, args), bufnr)
	end
end

function M.test(scope, debug)
	local bufnr = vim.api.nvim_get_current_buf()
	if not save(bufnr) then
		return
	end
	local target = scope == "file" and vim.api.nvim_buf_get_name(bufnr) or scope == "project" and M.root(bufnr) or nil
	require("neotest").run.run({ target, cwd = M.root(bufnr), strategy = debug and "dap" or "integrated" })
end

function M.debug()
	local bufnr = vim.api.nvim_get_current_buf()
	if not save(bufnr) then
		return
	end
	require("dap").run({
		type = "python",
		request = "launch",
		name = "Python: current file",
		program = vim.api.nvim_buf_get_name(bufnr),
		pythonPath = M.python(bufnr),
		cwd = M.root(bufnr),
		console = "integratedTerminal",
		justMyCode = true,
	})
end

function M.setup_dap(dap)
	dap.adapters.python = {
		type = "executable",
		command = vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python",
		args = { "-m", "debugpy.adapter" },
	}
	dap.configurations.python = {
		{
			type = "python",
			request = "launch",
			name = "Python: current file",
			program = "${file}",
			pythonPath = function() return M.python() end,
			cwd = function() return M.root() end,
			console = "integratedTerminal",
			justMyCode = true,
		},
	}
end

function M.setup_buffer(bufnr)
	local function command(name, callback, opts)
		vim.api.nvim_buf_create_user_command(bufnr, name, callback, opts or {})
	end
	command("PythonRun", function(opts) M.run(opts.fargs, bufnr) end, { nargs = "*", desc = "Run current Python file with arguments" })
	command("PythonModule", function(opts) M.module(opts.fargs, bufnr) end, { nargs = "+", desc = "Run a Python module with arguments" })
	command("PythonREPL", function() M.terminal({ "-q" }, bufnr) end, { desc = "Open the project Python REPL" })
	command("PythonEnv", function(opts) M.select(opts.args, bufnr) end, { nargs = "?", complete = "file", desc = "Select project interpreter or virtual environment" })
	command("PythonEnvReset", function() M.reset(bufnr) end, { desc = "Restore automatic environment detection" })
	command("PythonInfo", function() M.info(bufnr) end, { desc = "Show Python project and interpreter" })

	local function map(lhs, rhs, desc)
		vim.keymap.set("n", "<leader>p" .. lhs, rhs, { buffer = bufnr, silent = true, desc = "Python: " .. desc })
	end
	map("r", "<cmd>PythonRun<CR>", "run file")
	map("i", "<cmd>PythonREPL<CR>", "open REPL")
	map("v", "<cmd>PythonEnv<CR>", "select environment")
	map("e", "<cmd>PythonInfo<CR>", "show environment")
	map("f", function() require("conform").format({ bufnr = bufnr, timeout_ms = 2000, lsp_format = "never" }) end, "format and sort imports")
	map("F", function() require("conform").format({ bufnr = bufnr, formatters = { "ruff_fix", "ruff_organize_imports", "ruff_format" }, timeout_ms = 2000, lsp_format = "never" }) end, "apply Ruff fixes")
	map("t", function() M.test("nearest") end, "test nearest")
	map("T", function() M.test("file") end, "test file")
	map("a", function() M.test("project") end, "test project")
	map("s", function() require("neotest").summary.toggle() end, "toggle test summary")
	map("o", function() require("neotest").output.open({ enter = true }) end, "show test output")
	map("O", function() require("neotest").output_panel.toggle() end, "toggle test output panel")
	map("x", function() require("neotest").run.stop() end, "stop test")
	map("d", M.debug, "debug file")
	map("D", function() M.test("nearest", true) end, "debug nearest test")
end

return M
