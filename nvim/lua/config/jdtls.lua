local M = {}

local function first(pattern)
  return vim.fn.glob(pattern, false, true)[1]
end

local function java21()
  for _, path in ipairs({ vim.env.JAVA_HOME, "/usr/lib/jvm/java-21-openjdk", "/usr/lib/jvm/java-21-openjdk-amd64" }) do
    if path and vim.fn.executable(path .. "/bin/java") == 1 then
      local version = vim.fn.system({ path .. "/bin/java", "-version" })
      if version:match('version "21') or version:match("openjdk 21") then return path end
    end
  end
end

local function adapter_bundles()
  local share, result = vim.fn.stdpath("data") .. "/mason/packages/", {}
  local debug = first(share .. "java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar")
  if debug then result[#result + 1] = debug end
  vim.list_extend(result, vim.fn.glob(share .. "java-test/extension/server/*.jar", false, true))
  return result, debug ~= nil
end

function M.start()
  local jdtls = require("jdtls")
  local root = jdtls.setup.find_root({ "mvnw", "pom.xml", "gradlew", "build.gradle", ".git" })
  if not root then return end
  local home = java21()
  if not home then
    vim.notify("Java 21 not found. Set JAVA_HOME or install jdk21-openjdk.", vim.log.levels.ERROR)
    return
  end
  local data = vim.fn.stdpath("data")
  local launcher = first(data .. "/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar")
  local config_dir = data .. "/mason/packages/jdtls/config_linux"
  if not launcher or vim.fn.isdirectory(config_dir) == 0 then
    vim.notify("JDTLS is missing. Run :MasonToolsInstall.", vim.log.levels.ERROR)
    return
  end
  local project = vim.fn.fnamemodify(root, ":t")
  local workspace = vim.fn.stdpath("cache") .. "/jdtls-workspace/" .. project .. "-" .. vim.fn.sha256(root):sub(1, 8)
  local bundles, can_debug = adapter_bundles()
  jdtls.start_or_attach({
    cmd = {
      home .. "/bin/java", "-Declipse.application=org.eclipse.jdt.ls.core.id1",
      "-Dosgi.bundles.defaultStartLevel=4", "-Declipse.product=org.eclipse.jdt.ls.core.product",
      "-Dlog.protocol=true", "-Dlog.level=WARN", "-Xms1g", "--add-modules=ALL-SYSTEM",
      "--add-opens", "java.base/java.util=ALL-UNNAMED", "--add-opens", "java.base/java.lang=ALL-UNNAMED",
      "-jar", launcher, "-configuration", config_dir, "-data", workspace,
    },
    root_dir = root,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    init_options = { bundles = bundles },
    settings = { java = {
      home = home, eclipse = { downloadSources = true }, maven = { downloadSources = true, updateSnapshots = true },
      configuration = { updateBuildConfiguration = "interactive", runtimes = { { name = "JavaSE-21", path = home, default = true } } },
      contentProvider = { preferred = "fernflower" }, signatureHelp = { enabled = true },
      format = { enabled = true }, sources = { organizeImports = { starThreshold = 9999, staticStarThreshold = 9999 } },
    } },
    on_attach = function(_, bufnr)
      local function map(mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc }) end
      map("n", "gd", vim.lsp.buf.definition, "Go to definition"); map("n", "gr", "<cmd>Telescope lsp_references<cr>", "Find references")
      map("n", "K", vim.lsp.buf.hover, "Hover documentation"); map("n", "<C-k>", vim.lsp.buf.signature_help, "Signature help")
      map("n", "<leader>la", vim.lsp.buf.code_action, "Code action"); map("n", "<leader>lr", vim.lsp.buf.rename, "Rename symbol")
      map("n", "<leader>jo", jdtls.organize_imports, "Organize imports")
      map("n", "<leader>jv", jdtls.extract_variable, "Extract variable"); map("v", "<leader>jv", function() jdtls.extract_variable(true) end, "Extract variable")
      map("v", "<leader>jc", function() jdtls.extract_constant(true) end, "Extract constant")
      map("v", "<leader>jm", function() jdtls.extract_method(true) end, "Extract method")
      map("n", "<leader>ju", jdtls.update_project_config, "Update project config"); map("n", "<leader>jC", jdtls.compile, "Compile project")
      map("n", "<leader>jn", jdtls.test_nearest_method, "Run nearest test"); map("n", "<leader>jt", jdtls.test_class, "Run test class")
      map("n", "<leader>jd", function() jdtls.test_nearest_method({ config_overrides = { console = "integratedTerminal" } }) end, "Debug nearest test")
      map("n", "<leader>jD", function() jdtls.test_class({ config_overrides = { console = "integratedTerminal" } }) end, "Debug test class")
      map("n", "<leader>jr", "<cmd>JdtRunMain<cr>", "Select and run main"); map("n", "<leader>jb", "<cmd>SpringBootDebug<cr>", "Select and debug main")
      if can_debug then
        jdtls.setup_dap({ hotcodereplace = "auto", config_overrides = { console = "integratedTerminal" } })
        jdtls.dap.setup_dap_main_class_configs()
      else vim.notify("Java debug adapter missing; run :MasonToolsInstall", vim.log.levels.WARN) end
    end,
  })
end

return M
