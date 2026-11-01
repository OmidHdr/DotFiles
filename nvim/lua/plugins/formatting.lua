return {
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" }, json = { "prettierd", "prettier", stop_after_first = true },
        jsonc = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        xml = { "xmlformat" }, sh = { "shfmt" }, bash = { "shfmt" }, sql = { "sql_formatter" },
      },
      format_on_save = function(bufnr)
        if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat or vim.bo[bufnr].filetype == "java" then return end
        return { timeout_ms = 1500, lsp_format = "fallback" }
      end,
    },
    init = function()
      vim.api.nvim_create_user_command("FormatDisable", function(args)
        if args.bang then vim.b.disable_autoformat = true else vim.g.disable_autoformat = true end
      end, { bang = true })
      vim.api.nvim_create_user_command("FormatEnable", function() vim.b.disable_autoformat = false; vim.g.disable_autoformat = false end, {})
      vim.keymap.set({ "n", "v" }, "<leader>lf", function()
        if vim.bo.filetype == "java" then vim.lsp.buf.format({ async = true })
        else require("conform").format({ async = true, lsp_format = "fallback" }) end
      end, { desc = "Format file or selection" })
    end,
  },
}
