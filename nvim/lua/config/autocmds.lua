-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = { "*.ts", "*.tsx", "*.svelte" },
  callback = function()
    vim.lsp.buf.format()
  end,
})

vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
  pattern = { "*.ts", "*.tsx", "*.svelte" },
  callback = function()
    local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line(".") - 1 })
    if vim.tbl_isempty(diagnostics) then
      vim.lsp.buf.hover({ focusable = false })
    else
      vim.diagnostic.open_float(nil, { focusable = false })
    end
  end,
})

-- Blade: open as php so intelephense attaches, then switch back to blade
local augroup = vim.api.nvim_create_augroup("lsp_blade_workaround", { clear = true })

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  group = augroup,
  pattern = "*.blade.php",
  callback = function()
    vim.bo.filetype = "php"
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  group = augroup,
  pattern = "*.blade.php",
  callback = function(args)
    vim.schedule(function()
      if #vim.lsp.get_clients({ bufnr = args.buf, name = "intelephense" }) > 0 then
        vim.bo[args.buf].filetype = "blade"
        vim.bo[args.buf].syntax = "blade"
      end
    end)
  end,
})

-- make $ part of the keyword for php
vim.api.nvim_create_autocmd("FileType", {
  pattern = "php",
  callback = function()
    vim.opt_local.iskeyword:append("$")
  end,
})
