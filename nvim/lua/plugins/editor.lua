return {
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
    dependencies = { "nvim-lua/plenary.nvim", { "nvim-telescope/telescope-fzf-native.nvim", build = "make" } },
    opts = { defaults = { border = true, layout_strategy = "horizontal" }, extensions = { fzf = {} } },
    config = function(_, opts) require("telescope").setup(opts); pcall(require("telescope").load_extension, "fzf") end,
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Find text" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Find buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Find help" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim", "nvim-tree/nvim-web-devicons" },
    opts = { filesystem = { follow_current_file = { enabled = true }, filtered_items = { hide_dotfiles = false } }, window = { width = 34 } },
    keys = { { "<leader>e", "<cmd>Neotree toggle reveal<cr>", desc = "Explorer" } },
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = { preset = "modern" },
    config = function(_, opts)
      local wk = require("which-key"); wk.setup(opts)
      wk.add({
        { "<leader>b", group = "buffers" }, { "<leader>d", group = "debug" },
        { "<leader>f", group = "find" }, { "<leader>g", group = "git" },
        { "<leader>j", group = "java" }, { "<leader>l", group = "language" },
        { "<leader>m", group = "maven" }, { "<leader>s", group = "sessions" },
        { "<leader>t", group = "tests/terminal" }, { "<leader>u", group = "UI" },
      })
    end,
  },
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  { "kylechui/nvim-surround", version = "*", event = "VeryLazy", opts = {} },
  { "numToStr/Comment.nvim", event = "VeryLazy", opts = {} },
  {
    "folke/trouble.nvim", cmd = "Trouble", opts = {},
    keys = { { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics list" } },
  },
  {
    "folke/persistence.nvim", event = "BufReadPre", opts = {},
    keys = {
      { "<leader>sr", function() require("persistence").load() end, desc = "Restore session" },
      { "<leader>ss", function() require("persistence").select() end, desc = "Select session" },
      { "<leader>sd", function() require("persistence").stop() end, desc = "Do not save session" },
    },
  },
}
