-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

local opt = vim.opt

local function is_remote() return vim.env.SSH_CLIENT ~= nil or vim.env.SSH_TTY ~= nil end

if is_remote() then
  opt.clipboard = "unnamedplus"
  vim.g.clipboard = {
    name = "OSC 52",
    copy = {
      ["+"] = require("vim.ui.clipboard.osc52").copy "+",
      ["*"] = require("vim.ui.clipboard.osc52").copy "*",
    },
    paste = {
      ["+"] = require("vim.ui.clipboard.osc52").paste "+",
      ["*"] = require("vim.ui.clipboard.osc52").paste "*",
    },
  }
end

opt.exrc = true

-- vim.api.nvim_create_autocmd({ "FileType" }, {
--   pattern = { "c", "cpp", "cmake" },
--   callback = function()
--     vim.opt_local.shiftwidth = 4
--     vim.opt_local.tabstop = 4
--     -- vim.opt_local.cindent = true
--     -- require("nvim-treesitter.configs").setup {
--     --   indent = { enable = false },
--     -- }
--   end,
-- })
