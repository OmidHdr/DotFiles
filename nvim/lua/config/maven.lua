local M = {}
local terminals = {}

local function run(name, args)
  local project = require("config.project")
  local executable, root = project.maven()
  local Terminal = require("toggleterm.terminal").Terminal
  if terminals[name] then terminals[name]:shutdown() end
  terminals[name] = Terminal:new({
    cmd = executable .. " " .. args,
    dir = root,
    direction = "horizontal",
    close_on_exit = false,
    hidden = true,
    env = project.env(root),
    on_open = function(term)
      vim.cmd("startinsert!")
      vim.keymap.set("t", "<C-c>", "<C-c>", { buffer = term.bufnr, desc = "Stop process" })
    end,
  })
  terminals[name]:toggle(18)
end

function M.setup()
  local commands = {
    SpringBootRun = { "spring", "spring-boot:run" },
    MavenTest = { "test", "test" },
    MavenCleanTest = { "clean-test", "clean test" },
    MavenPackage = { "package", "clean package" },
    MavenVerify = { "verify", "verify" },
    MavenSpotless = { "spotless", "spotless:apply" },
    MavenFlyway = { "flyway", "flyway:migrate" },
  }
  for command, spec in pairs(commands) do
    vim.api.nvim_create_user_command(command, function() run(spec[1], spec[2]) end, {})
  end
end

return M
