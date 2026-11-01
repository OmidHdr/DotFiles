return {
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    dependencies = { "mfussenegger/nvim-dap", "williamboman/mason.nvim", "hrsh7th/cmp-nvim-lsp" },
    config = function()
      vim.api.nvim_create_autocmd("FileType", { pattern = "java", callback = require("config.jdtls").start })
      if vim.bo.filetype == "java" then require("config.jdtls").start() end
    end,
  },
}
