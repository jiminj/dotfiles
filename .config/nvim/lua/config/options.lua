-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--

local opt = vim.opt

opt.shiftwidth = 2
opt.tabstop = 2
opt.relativenumber = true
opt.timeout = true
opt.timeoutlen = 300
opt.wrap = true
opt.colorcolumn = "81"
opt.swapfile = false
opt.smartindent = true

vim.g.autoformat = false
