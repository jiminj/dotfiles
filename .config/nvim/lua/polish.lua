-- if true then return end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

local opt = vim.opt
opt.exrc = true
opt.clipboard = "unnamedplus"

if vim.env.TMUX ~= nil then
  local copy = { "tmux", "load-buffer", "-w", "-" }
  local paste = { "bash", "-c", "tmux refresh-client -l && sleep 0.05 && tmux save-buffer -" }
  vim.g.clipboard = {
    name = "tmux",
    copy = {
      ["+"] = copy,
      ["*"] = copy,
    },
    paste = {
      ["+"] = paste,
      ["*"] = paste,
    },
    cache_enabled = 0,
  }
else
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
