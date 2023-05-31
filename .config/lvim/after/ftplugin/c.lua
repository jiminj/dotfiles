vim.opt_local.shiftwidth = 4
vim.opt_local.tabstop = 4
vim.opt_local.cindent = true

local wk = require("which-key")
wk.register({
  ["<leader>lp"] = { ":ClangdSwitchSourceHeader<CR>", "Switch source-header" },
})
