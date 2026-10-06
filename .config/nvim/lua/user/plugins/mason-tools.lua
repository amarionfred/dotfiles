return {
	"WhoIsSethDaniel/mason-tool-installer.nvim",
	dependencies = {
		"williamboman/mason.nvim",
	},
	opts = {
		ensure_installed = {
			"codelldb",
			"prettier",
			"taplo",
			"debugpy",
		},
		run_on_start = false,
	},
}
