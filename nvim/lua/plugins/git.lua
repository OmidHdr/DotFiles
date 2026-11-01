return {
  {
    "lewis6991/gitsigns.nvim", event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = { add = { text = "▎" }, change = { text = "▎" }, delete = { text = "" }, topdelete = { text = "" }, changedelete = { text = "▎" } },
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function m(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = bufnr, desc = desc }) end
        m("]h", gs.next_hunk, "Next Git hunk"); m("[h", gs.prev_hunk, "Previous Git hunk")
        m("<leader>gs", gs.stage_hunk, "Stage hunk"); m("<leader>gr", gs.reset_hunk, "Reset hunk")
        m("<leader>gp", gs.preview_hunk, "Preview hunk"); m("<leader>gb", gs.blame_line, "Blame line")
      end,
    },
  },
  {
    "kdheepak/lazygit.nvim", cmd = "LazyGit", dependencies = "nvim-lua/plenary.nvim",
    keys = { { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" } },
  },
}
