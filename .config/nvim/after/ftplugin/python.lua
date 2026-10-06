vim.bo.expandtab = true
vim.bo.tabstop = 4
vim.bo.softtabstop = 4
vim.bo.shiftwidth = 4
vim.bo.smartindent = false
require("user.python").setup_buffer(vim.api.nvim_get_current_buf())
