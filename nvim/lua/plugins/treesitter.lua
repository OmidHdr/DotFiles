return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = { "java", "lua", "vim", "vimdoc", "query", "xml", "yaml", "json", "properties", "sql", "dockerfile", "markdown", "markdown_inline", "bash" },
      highlight = { enable = true },
      indent = { enable = true, disable = { "java" } },
    },
    config = function(_, opts) require("nvim-treesitter.configs").setup(opts) end,
  },
}
