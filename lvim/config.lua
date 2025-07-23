-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny
vim.opt.cmdheight = 4             -- more space in the neovim command line for displaying messages
vim.opt.guifont = "monospace:h17" -- the font used in graphical neovim applications
vim.opt.shiftwidth = 4            -- the number of spaces inserted for each indentation
vim.opt.tabstop = 4               -- insert 2 spaces for a tab
vim.opt.relativenumber = true     -- relative line numbers
vim.opt.wrap = true               -- wrap lines
vim.opt.clipboard = 'unnamedplus'
_G.uv = vim.loop


-- تنظیمات پایه
vim.opt.relativenumber = true
vim.opt.number = true

-- اضافه کردن خط جدید پایین بدون ورود به insert mode
vim.keymap.set('n', 'go', function()
  local current_line = vim.fn.line('.')
  vim.fn.append(current_line, vim.fn['repeat']({''}, vim.v.count1))
  vim.fn.cursor(current_line + 1, 1)
end, {
  noremap = true,
  silent = true,
  desc = "اضافه کردن خط جدید پایین (بدون insert)"
})

-- اضافه کردن خط جدید بالا بدون ورود به insert mode
vim.keymap.set('n', 'gO', function()
  local current_line = vim.fn.line('.')
  vim.fn.append(current_line - 1, vim.fn['repeat']({''}, vim.v.count1))
  vim.fn.cursor(current_line, 1)
end, {
  noremap = true,
  silent = true,
  desc = "اضافه کردن خط جدید بالا (بدون insert)"
})

-- تنظیمات LSP برای جاوا
local lspconfig = require("lspconfig")
local jdtls = require("lspconfig.server_configurations.jdtls")

lspconfig.jdtls.setup {
  -- تنظیمات اضافی برای JDTLS اینجا قرار می‌گیرد
}

-- تنظیمات فرمت‌کننده‌ها
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
  {
    command = "google-java-format",
    filetypes = { "java" },
  }
}


-- general
vim.opt.relativenumber = true
lvim.log.level = "warn"
lvim.format_on_save = false
lvim.leader = "space"
lvim.keys.insert_mode["ii"] = "<Esc>"
lvim.keys.normal_mode["<S-l>"] = "<cmd> BufferLineCycleNext<CR>"
lvim.keys.normal_mode["<S-h>"] = "<cmd> BufferLineCyclePrev<CR>"

lvim.keys.normal_mode['er'] = "<cmd>lua require('rest-nvim').run()<CR>"

require('user.dashboard')
require('user.visuals')
require('user.terminal')
require('user.lualine')
require('user.intellisense')

local _, actions = pcall(require, "telescope.actions")
lvim.builtin.telescope.defaults.mappings = {
    -- for input mode
    i = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-n>"] = actions.cycle_history_next,
        ["<C-p>"] = actions.cycle_history_prev,
    },
    -- for normal mode
    n = {
        ["<C-j>"] = actions.move_selection_next,
        ["<C-k>"] = actions.move_selection_previous,
    },
}

lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }
local jdtls = require('jdtls')


-- setup dap configurations for Java
require('dap').configurations.java = {
  {
    type = 'java',
    request = 'launch',
    name = "Launch Java Program",
    mainClass = '', -- این را دستی یا خودکار مشخص کن
    projectName = '', -- اختیاری، فقط اگر لازم باشد
    args = '',        -- آرگومان‌های خط فرمان (اختیاری)
    cwd = vim.fn.getcwd(), -- یا هر مسیر دلخواه
  },
}

lvim.plugins = {
    {
        "AckslD/swenv.nvim",
        "stevearc/dressing.nvim",
        "mfussenegger/nvim-dap-python",
        "nvim-neotest/neotest",
        "nvim-neotest/neotest-python",
        "nvim-neotest/nvim-nio",
        "mfussenegger/nvim-jdtls",
    },
    { -- Plugins for databases
        "kristijanhusak/vim-dadbod-ui",
        --requires = {
        --"tpope/vim-dadbod",
        --"kristijanhusak/vim-dadbod-completion"
        --},
        config = function()
            require("user.database").setup()
        end
    },
    { "nyoom-engineering/oxocarbon.nvim" },
    { -- Scala Support
        "scalameta/nvim-metals",
        config = function()
            require("user.metals").config()
        end,
    },
    --{
    --  "rest-nvim/rest.nvim",
    --  requires = { "nvim-lua/plenary.nvim" },
    --  config = function()
    --    require("user.rest").setup()
    --  end,
    --},
    { -- Orgmode Support
        "nvim-orgmode/orgmode",
        config = function()
            require("user.orgmode").setup()
        end,
        ft = { "org" },
    }
}

lvim.builtin.treesitter.ensure_installed = {
    "python",
    "java",
}
------------------------- java --------------------------
local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
    {
        command = "clang-format",
        filetypes = { "java" },
    }
}

vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "jdtls" })

local status, jdtls = pcall(require, "jdtls")
if not status then
    return
end

local home = os.getenv "HOME"
local workspace_path = home .. "/.local/share/lunarvim/jdtls-workspace/"
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = workspace_path .. project_name

local os_config = "linux"
if vim.fn.has "mac" == 1 then
    os_config = "mac"
end

local capabilities = require("lvim.lsp").common_capabilities()
local extendedClientCapabilities = jdtls.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

lvim.builtin.dap.active = true
local bundles = {}
local mason_path = vim.fn.glob(vim.fn.stdpath "data" .. "/mason/")
vim.list_extend(bundles, vim.split(vim.fn.glob(mason_path .. "packages/java-test/extension/server/*.jar"), "\n"))
vim.list_extend(
    bundles,
    vim.split(
        vim.fn.glob(mason_path .. "packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"),
        "\n"
    )
)

lvim.builtin.dap.active = true
local config = {
    cmd = {
        "java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-Xms1g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens",
        "java.base/java.util=ALL-UNNAMED",
        "--add-opens",
        "java.base/java.lang=ALL-UNNAMED",
        "-javaagent:" .. home .. "/.local/share/nvim/mason/packages/jdtls/lombok.jar",
        "-jar",
        vim.fn.glob(home .. "/.local/share/nvim/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),
        "-configuration",
        home .. "/.local/share/nvim/mason/packages/jdtls/config_" .. os_config,
        "-data",
        workspace_dir,
    },
    root_dir = require("jdtls.setup").find_root { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" },
    capabilities = capabilities,

    settings = {
        java = {
            eclipse = {
                downloadSources = true,
            },
            configuration = {
                updateBuildConfiguration = "interactive",
                runtimes = {
                    {
                        name = "JavaSE-11",
                        path = "~/.sdkman/candidates/java/11.0.17-tem",
                    },
                    {
                        name = "JavaSE-17",
                        path = "/usr/lib/jvm/java-17-openjdk", -- مسیر واقعی نصب Java 17
                        default = true,
                    },
                    {
                        name = "JavaSE-18",
                        path = "~/.sdkman/candidates/java/18.0.2-sem",
                    },
                },
            },
            maven = {
                downloadSources = true,
            },
            referencesCodeLens = {
                enabled = true,
            },
            references = {
                includeDecompiledSources = true,
            },
            inlayHints = {
                parameterNames = {
                    enabled = "all", -- literals, all, none
                },
            },
            format = {
                enabled = false,
            },
        },
        signatureHelp = { enabled = true },
        extendedClientCapabilities = extendedClientCapabilities,
    },
    init_options = {
        bundles = bundles,
    },
}

config["on_attach"] = function(client, bufnr)
    local _, _ = pcall(vim.lsp.codelens.refresh)
    require("jdtls").setup_dap({ hotcodereplace = "auto" })
    require("lvim.lsp").on_attach(client, bufnr)
    local status_ok, jdtls_dap = pcall(require, "jdtls.dap")
    if status_ok then
        jdtls_dap.setup_dap_main_class_configs()
    end
end

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
    pattern = { "*.java" },
    callback = function()
        local _, _ = pcall(vim.lsp.codelens.refresh)
    end,
})

local formatters = require "lvim.lsp.null-ls.formatters"
formatters.setup {
    { command = "google_java_format", filetypes = { "java" } },
}

require("jdtls").start_or_attach(config)

local status_ok, which_key = pcall(require, "which-key")
if not status_ok then
    return
end

local opts = {
    mode = "n",
    prefix = "<leader>",
    buffer = nil,
    silent = true,
    noremap = true,
    nowait = true,
}

local vopts = {
    mode = "v",
    prefix = "<leader>",
    buffer = nil,
    silent = true,
    noremap = true,
    nowait = true,
}

local mappings = {
    C = {
        name = "Java",
        o = { "<Cmd>lua require'jdtls'.organize_imports()<CR>", "Organize Imports" },
        v = { "<Cmd>lua require('jdtls').extract_variable()<CR>", "Extract Variable" },
        c = { "<Cmd>lua require('jdtls').extract_constant()<CR>", "Extract Constant" },
        t = { "<Cmd>lua require'jdtls'.test_nearest_method()<CR>", "Test Method" },
        T = { "<Cmd>lua require'jdtls'.test_class()<CR>", "Test Class" },
        u = { "<Cmd>JdtUpdateConfig<CR>", "Update Config" },
    },
}

local vmappings = {
    C = {
        name = "Java",
        v = { "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", "Extract Variable" },
        c = { "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", "Extract Constant" },
        m = { "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", "Extract Method" },
    },
}

which_key.register(mappings, opts)
which_key.register(vmappings, vopts)
which_key.register(vmappings, vopts)

---------------------- python ------------------
local black = require "lvim.lsp.null-ls.formatters"
black.setup { { name = "black" }, }

local linters = require "lvim.lsp.null-ls.linters"
linters.setup { { command = "flake8", args = { "--ignore=E203" }, filetypes = { "python" } } }


require('swenv').setup({
    post_set_venv = function()
        vim.cmd("LspRestart")
    end,
})

lvim.builtin.which_key.mappings["C"] = {
    name = "Python",
    c = { "<cmd>lua require('swenv.api').pick_venv()<cr>", "Choose Env" },
}

lvim.builtin.dap.active = true
local mason_path = vim.fn.glob(vim.fn.stdpath "data" .. "/mason/")
pcall(function()
    require("dap-python").setup(mason_path .. "packages/debugpy/venv/bin/python")
end)

require("neotest").setup({
    adapters = {
        require("neotest-python")({
            dap = {
                justMyCode = false,
                console = "integratedTerminal",
            },
            args = { "--log-level", "DEBUG", "--quiet" },
            runner = "pytest",
        })
    }
})

lvim.builtin.which_key.mappings["dm"] = { "<cmd>lua require('neotest').run.run()<cr>",
    "Test Method" }
lvim.builtin.which_key.mappings["dM"] = { "<cmd>lua require('neotest').run.run({strategy = 'dap'})<cr>",
    "Test Method DAP" }
lvim.builtin.which_key.mappings["df"] = {
    "<cmd>lua require('neotest').run.run({vim.fn.expand('%')})<cr>", "Test Class" }
lvim.builtin.which_key.mappings["dF"] = {
    "<cmd>lua require('neotest').run.run({vim.fn.expand('%'), strategy = 'dap'})<cr>", "Test Class DAP" }
lvim.builtin.which_key.mappings["dS"] = { "<cmd>lua require('neotest').summary.toggle()<cr>", "Test Summary" }

