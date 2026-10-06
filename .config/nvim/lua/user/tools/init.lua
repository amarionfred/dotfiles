local M = {}

function M.setup()
	local group = vim.api.nvim_create_augroup("PersonalIncludeFormatter", { clear = true })

	-- C/C++ include formatter
	vim.api.nvim_create_autocmd("BufWritePre", {
		group = group,
		pattern = { "*.h", "*.hpp", "*.hh", "*.hxx", "*.c", "*.cc", "*.cpp", "*.cxx" },
		callback = function(args)
			require("user.tools.include_formatter").format(args.buf)
		end,
	})

	-- :Skel command
	vim.api.nvim_create_user_command("Skel", function()
		require("user.tools.skeleton").insert()
	end, {})

	require("user.tools.cpp_extract").setup()
	require("user.tools.cpp_trivial_constructor").setup()
	require("user.tools.live_server").setup()
end

return M
