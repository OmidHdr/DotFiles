local group = vim.api.nvim_create_augroup("BackendIDE", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  callback = function() vim.highlight.on_yank({ timeout = 150 }) end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "gitcommit", "markdown" },
  callback = function() vim.opt_local.wrap = true; vim.opt_local.spell = true end,
})
vim.api.nvim_create_autocmd("FileType", {
  group = group,
  pattern = { "java", "lua", "xml", "yaml", "json", "sql", "sh", "fish" },
  callback = function() vim.opt_local.colorcolumn = "100" end,
})
