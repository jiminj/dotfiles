-- api
-- local client = require("copilot.client").get()
-- local sent, request_id = require("copilot.api").check_status(client, function(err, data, ctx)
--   print("check!")
-- print(vim.inspect({ err = err, data = data, ctx = ctx }))

return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = function(_, item)
      return {
        suggestion = {
          enabled = true,
          auto_trigger = true,
          keymap = {
            accept = "<M-l>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        },
      }
    end,
    -- config = function()
    --   require("copilot").setup({
    --     -- panel = {
    --     --   enabled = true,
    --     --   auto_refresh = true
    --     -- },
    --     suggestion = {
    --       enabled = true,
    --       auto_trigger = true,
    --       keymap = {
    --         accept = "<M-l>",
    --         accept_word = false,
    --         accept_line = false,
    --         next = "<M-]>",
    --         prev = "<M-[>",
    --         dismiss = "<C-]>",
    --       },
    --     },
    --   })
    -- end,
    -- keys = {
    --   { "<leader>lc", "<cmd>Copilot panel<cr>", desc = "Panel" }
    -- }
  },
  {
    "jackMort/ChatGPT.nvim",
    event = "VeryLazy",
    config = function()
      require("chatgpt").setup()
    end,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
    },
  },
}
