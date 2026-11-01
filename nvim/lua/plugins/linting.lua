return {
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost", "InsertLeave" },
    config = function()
      require("lint").linters_by_ft = { sh = { "shellcheck" }, bash = { "shellcheck" } }
      vim.api.nvim_create_autocmd({ "BufWritePost", "InsertLeave" }, {
        group = vim.api.nvim_create_augroup("LintOnChange", { clear = true }),
        callback = function() require("lint").try_lint() end,
      })
      vim.keymap.set("n", "<leader>ll", function() require("lint").try_lint() end, { desc = "Lint buffer" })
    end,
  },
}
