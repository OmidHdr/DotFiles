return {
  {
    "mfussenegger/nvim-dap",
    dependencies = { "rcarriga/nvim-dap-ui", "nvim-neotest/nvim-nio" },
    keys = {
      { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Toggle breakpoint" },
      { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Conditional breakpoint" },
      { "<leader>dc", function() require("dap").continue() end, desc = "Continue / start" },
      { "<leader>dl", function() require("dap").run_last() end, desc = "Run last" },
      { "<leader>dr", function() require("dap").restart() end, desc = "Restart" },
      { "<leader>dp", function() require("dap").pause() end, desc = "Pause" },
      { "<leader>dn", function() require("dap").step_over() end, desc = "Step over" },
      { "<leader>di", function() require("dap").step_into() end, desc = "Step into" },
      { "<leader>do", function() require("dap").step_out() end, desc = "Step out" },
      { "<leader>dt", function() require("dap").terminate() end, desc = "Terminate" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle debug UI" },
      { "<leader>de", function() require("dapui").eval() end, mode = { "n", "v" }, desc = "Inspect expression" },
      { "<leader>dR", function() require("dap").repl.open() end, desc = "Open debug console" },
    },
    config = function()
      local dap, dapui = require("dap"), require("dapui")
      dapui.setup({ layouts = {
        { elements = { { id = "scopes", size = 0.55 }, { id = "stacks", size = 0.25 }, { id = "breakpoints", size = 0.2 } }, size = 40, position = "left" },
        { elements = { { id = "repl", size = 0.5 }, { id = "console", size = 0.5 } }, size = 12, position = "bottom" },
      } })
      vim.fn.sign_define("DapBreakpoint", { text = "●", texthl = "DiagnosticError" })
      vim.fn.sign_define("DapStopped", { text = "▶", texthl = "DiagnosticInfo", linehl = "Visual" })
      dap.listeners.before.attach.dapui_config = function() dapui.open() end
      dap.listeners.before.launch.dapui_config = function() dapui.open() end
      dap.listeners.before.event_terminated.dapui_config = function() dapui.close() end
      dap.listeners.before.event_exited.dapui_config = function() dapui.close() end
      vim.api.nvim_create_user_command("SpringBootDebug", function()
        local ok, jdtls = pcall(require, "jdtls")
        if not ok or vim.bo.filetype ~= "java" then vim.notify("Open a Java file in the project first.", vim.log.levels.WARN); return end
        jdtls.dap.setup_dap_main_class_configs({ on_ready = function() dap.continue() end })
      end, {})
    end,
  },
}
