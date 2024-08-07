--
-- Visuals Config File
--

-- Color scheme and details
--lvim.colorscheme = "oxocarbon"
vim.g.tokyonight_style = "night"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = false

-- Config for Neovide GUI
vim.o.guifont = "Fira Code:h9"
--{ "catppuccin/nvim", name = "catppuccin", priority = 1000 }
vim.colorscheme = "catppuccin/nvim"


-- My own fast theme change function
--lvim.keys.normal_mode["|"] = ":lua ToggleTheme() <cr> "
--function ToggleTheme()
--  if (vim.o.background == "dark") then
--    vim.o.background = "light"
--  else
--    vim.o.background = "dark"
--  end
--end
