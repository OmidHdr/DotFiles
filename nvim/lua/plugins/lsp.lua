return {
  { "williamboman/mason.nvim", cmd = "Mason", build = ":MasonUpdate", opts = { ui = { border = "rounded" } } },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    opts = { ensure_installed = { "lua_ls", "jsonls", "yamlls", "lemminx", "bashls", "dockerls", "docker_compose_language_service" }, automatic_enable = false },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = "williamboman/mason.nvim",
    opts = { ensure_installed = { "jdtls", "java-debug-adapter", "java-test", "stylua", "prettierd", "shfmt", "shellcheck", "checkstyle", "sql-formatter" }, run_on_start = true },
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "hrsh7th/cmp-nvim-lsp", "williamboman/mason-lspconfig.nvim" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()
      local on_attach = function(_, bufnr)
        local function m(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc }) end
        m("gd", vim.lsp.buf.definition, "Go to definition"); m("gD", vim.lsp.buf.declaration, "Go to declaration")
        m("gr", "<cmd>Telescope lsp_references<cr>", "Find references"); m("gi", "<cmd>Telescope lsp_implementations<cr>", "Go to implementation")
        m("K", vim.lsp.buf.hover, "Hover documentation"); m("<C-k>", vim.lsp.buf.signature_help, "Signature help")
        m("<leader>la", vim.lsp.buf.code_action, "Code action"); m("<leader>lr", vim.lsp.buf.rename, "Rename symbol")
        m("<leader>ls", "<cmd>Telescope lsp_document_symbols<cr>", "Document symbols")
      end
      vim.diagnostic.config({ severity_sort = true, update_in_insert = false, underline = true, virtual_text = { spacing = 3, source = "if_many", prefix = "●" }, float = { border = "rounded", source = true } })
      for kind, icon in pairs({ Error = " ", Warn = " ", Hint = "󰌵 ", Info = " " }) do vim.fn.sign_define("DiagnosticSign" .. kind, { text = icon, texthl = "DiagnosticSign" .. kind }) end
      local servers = {
        lua_ls = { settings = { Lua = { diagnostics = { globals = { "vim" } }, workspace = { checkThirdParty = false }, telemetry = { enable = false } } } },
        jsonls = {}, yamlls = { settings = { yaml = { keyOrdering = false } } }, lemminx = {},
        bashls = {}, dockerls = {}, docker_compose_language_service = {},
      }
      for name, config in pairs(servers) do
        config.capabilities, config.on_attach = capabilities, on_attach
        vim.lsp.config(name, config)
        vim.lsp.enable(name)
      end
    end,
  },
}
