-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.b.autoformat = false

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "lua" },
  callback = function()
    vim.b.autoformat = true
  end,
})

vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "c", "cpp", "cmake" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.cindent = true
    require("nvim-treesitter.configs").setup({
      indent = { enable = false },
    })
  end,
})
