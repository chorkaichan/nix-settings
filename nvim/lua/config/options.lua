-- Options are automatically loaded before lazy.nvim startup
-- Default options: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

vim.opt.relativenumber = false
vim.opt.shell = "/bin/bash"
vim.g.autoformat = false

vim.diagnostic.config({
  virtual_text = false,
})

-- Show line diagnostics automatically in hover window
vim.o.updatetime = 250
