return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    cmd = { "ToggleTerm", "TermExec" },
    opts = { size = 18, open_mapping = [[<C-\>]], direction = "horizontal", shade_terminals = true, persist_mode = true },
    config = function(_, opts) require("toggleterm").setup(opts); require("config.maven").setup() end,
    keys = {
      { "<leader>tt", "<cmd>ToggleTerm<cr>", desc = "Toggle terminal" },
      { "<leader>mr", "<cmd>SpringBootRun<cr>", desc = "Spring Boot run" },
      { "<leader>md", "<cmd>SpringBootDebug<cr>", desc = "Spring Boot debug" },
      { "<leader>mt", "<cmd>MavenTest<cr>", desc = "Maven test" },
      { "<leader>mc", "<cmd>MavenCleanTest<cr>", desc = "Maven clean test" },
      { "<leader>mp", "<cmd>MavenPackage<cr>", desc = "Maven clean package" },
      { "<leader>mv", "<cmd>MavenVerify<cr>", desc = "Maven verify" },
      { "<leader>ms", "<cmd>MavenSpotless<cr>", desc = "Spotless apply" },
      { "<leader>mf", "<cmd>MavenFlyway<cr>", desc = "Flyway migrate" },
    },
  },
}
