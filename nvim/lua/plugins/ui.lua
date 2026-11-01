return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    lazy = false,
    priority = 1000,
    opts = {
      flavour = "mocha",
      transparent_background = vim.g.transparent_background,
      integrations = { cmp = true, gitsigns = true, treesitter = true, telescope = true, dap_ui = true, native_lsp = { enabled = true } },
    },
    config = function(_, opts) require("catppuccin").setup(opts); vim.cmd.colorscheme("catppuccin") end,
  },
  { "nvim-tree/nvim-web-devicons", lazy = true, enabled = vim.g.have_nerd_font },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = { options = { theme = "catppuccin", globalstatus = true, component_separators = "|", section_separators = "" } },
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    event = "VeryLazy",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = { options = { diagnostics = "nvim_lsp", separator_style = "thin", always_show_bufferline = false } },
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next buffer" },
      { "<leader>bd", "<cmd>bdelete<cr>", desc = "Delete buffer" },
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    opts = { presets = { bottom_search = true, command_palette = true, long_message_to_split = true, lsp_doc_border = true } },
  },
  { "rcarriga/nvim-notify", lazy = true, opts = { stages = "fade_in_slide_out", timeout = 2500 } },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = { indent = { char = "│" }, scope = { enabled = true, show_start = false } },
  },
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.header.val = { "  Spring • Java • Neovim  " }
      dashboard.section.buttons.val = {
        dashboard.button("f", "Find file", "<cmd>Telescope find_files<cr>"),
        dashboard.button("r", "Recent files", "<cmd>Telescope oldfiles<cr>"),
        dashboard.button("p", "Find project text", "<cmd>Telescope live_grep<cr>"),
        dashboard.button("s", "Restore session", "<cmd>lua require('persistence').load()<cr>"),
        dashboard.button("q", "Quit", "<cmd>qa<cr>"),
      }
      require("alpha").setup(dashboard.config)
    end,
  },
}
