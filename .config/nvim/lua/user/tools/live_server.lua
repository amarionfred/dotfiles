local M = {}

local process

local port = 5555

local function executable()
	return vim.fn.stdpath("data") .. "/web-tools/node_modules/.bin/five-server"
end

local function project_root(file)
	local root = vim.fs.root(file, { "package.json" })
	if root then
		return root
	end

	local file_dir = vim.fs.dirname(file)
	local parent = vim.fs.dirname(file_dir)
	for _, asset_dir in ipairs({ "css", "js", "assets", "images" }) do
		if vim.fn.isdirectory(vim.fs.joinpath(parent, asset_dir)) == 1 then
			return parent
		end
	end

	return file_dir
end

local function stop(notify)
	if not process or process:is_closing() then
		process = nil
		if notify then
			vim.notify("Live Server is not running", vim.log.levels.INFO)
		end
		return
	end

	process:kill(15)
	process = nil
	if notify then
		vim.notify("Live Server stopped", vim.log.levels.INFO)
	end
end

local function start()
	if process and not process:is_closing() then
		vim.notify("Live Server is already running", vim.log.levels.INFO)
		return
	end

	local file = vim.api.nvim_buf_get_name(0)
	if file == "" then
		vim.notify("Save the HTML file before starting Live Server", vim.log.levels.WARN)
		return
	end

	local cmd = executable()
	if vim.fn.executable(cmd) ~= 1 then
		vim.notify("Five Server is not installed", vim.log.levels.ERROR)
		return
	end

	local root = project_root(file)
	local open_path = file:sub(#root + 2)
	local job
	job = vim.system({ cmd, "--port=" .. port, "--open=" .. open_path, "." }, {
		cwd = root,
		stdout = false,
		text = true,
	}, function(result)
		vim.schedule(function()
			local was_current = process == job
			if was_current then
				process = nil
			end
			if was_current and result.code ~= 0 then
				local message = result.stderr and vim.trim(result.stderr) or "unknown error"
				vim.notify("Five Server failed: " .. message, vim.log.levels.ERROR)
			end
		end)
	end)
	process = job

	vim.notify("Five Server: http://127.0.0.1:" .. port .. "/" .. open_path, vim.log.levels.INFO)
end

function M.setup()
	vim.api.nvim_create_user_command("LiveServerStart", start, { desc = "Start Live Server for the current file" })
	vim.api.nvim_create_user_command("LiveServerStop", function()
		stop(true)
	end, { desc = "Stop Live Server" })
	vim.api.nvim_create_user_command("LiveServerToggle", function()
		if process and not process:is_closing() then
			stop(true)
		else
			start()
		end
	end, { desc = "Toggle Live Server" })

	vim.keymap.set("n", "<leader>ls", "<cmd>LiveServerToggle<CR>", { desc = "Toggle Live Server" })

	vim.api.nvim_create_autocmd("VimLeavePre", {
		callback = function()
			stop(false)
		end,
	})
end

return M
