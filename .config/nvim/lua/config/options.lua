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

local function is_remote()
  return vim.env.SSH_CLIENT ~= nil or vim.env.SSH_TTY ~= nil
end

if is_remote() then
  opt.clipboard = "unnamedplus"
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
      ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste("+"),
      ["*"] = require("vim.ui.clipboard.osc52").paste("*"),
    },
  }
end
