-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

local function getTelescopeOpts(state, path)
  return {
    cwd = path,
    search_dirs = { path },
    -- attach_mappings = function(prompt_bufnr, map)
    --   local actions = require "telescope.actions"
    --   actions.select_default:replace(function()
    --     actions.close(prompt_bufnr)
    --     local action_state = require "telescope.actions.state"
    --     local selection = action_state.get_selected_entry()
    --     local filename = selection.filename
    --     if filename == nil then filename = selection[1] end
    --     -- any way to open the file without triggering auto-close event of neo-tree?
    --     require("neo-tree.sources.filesystem").navigate(state, state.path, filename)
    --   end)
    --   return true
    -- end,
  }
end

---@type LazySpec
return {

  -- == Examples of Adding Plugins ==
  --
  -- "andweeb/presence.nvim",
  -- {
  --   "ray-x/lsp_signature.nvim",
  --   event = "BufRead",
  --   config = function() require("lsp_signature").setup() end,
  -- },

  -- == Examples of Overriding Plugins ==

  -- customize alpha options
  -- {
  --   "goolord/alpha-nvim",
  --   opts = function(_, opts)
  --     -- customize the dashboard header
  --     opts.section.header.val = {
  --       " █████  ███████ ████████ ██████   ██████",
  --       "██   ██ ██         ██    ██   ██ ██    ██",
  --       "███████ ███████    ██    ██████  ██    ██",
  --       "██   ██      ██    ██    ██   ██ ██    ██",
  --       "██   ██ ███████    ██    ██   ██  ██████",
  --       " ",
  --       "    ███    ██ ██    ██ ██ ███    ███",
  --       "    ████   ██ ██    ██ ██ ████  ████",
  --       "    ██ ██  ██ ██    ██ ██ ██ ████ ██",
  --       "    ██  ██ ██  ██  ██  ██ ██  ██  ██",
  --       "    ██   ████   ████   ██ ██      ██",
  --     }
  --     return opts
  --   end,
  -- },

  -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
  {
    "max397574/better-escape.nvim",
    enabled = false,
  },
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom luasnip configuration such as filetype extend or custom snippets
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom autopairs configuration such as custom rules
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules(
        {
          Rule("$", "$", { "tex", "latex" })
            -- don't add a pair if the next character is %
            :with_pair(cond.not_after_regex "%%")
            -- don't add a pair if  the previous character is xxx
            :with_pair(
              cond.not_before_regex("xxx", 3)
            )
            -- don't move right when repeat character
            :with_move(cond.none())
            -- don't delete if the next character is xx
            :with_del(cond.not_after_regex "xx")
            -- disable adding a newline when you press <cr>
            :with_cr(cond.none()),
        },
        -- disable for .vim files, but it work for another filetypes
        Rule("a", "a", "-vim")
      )
    end,
  },
  {
    "mbbill/undotree",
    cmd = { "UndotreeToggle", "UndotreeShow", "UndotreeFocus" },
    keys = {
      { "<leader>U", "", desc = "UndoTree" },
      { "<leader>Ut", "<cmd>UndotreeToggle<CR>", desc = "UndoTree Toggle" },
      { "<leader>Uf", "<cmd>UndotreeFocus<CR>", desc = "UndoTree Focus" },
    },
    config = function()
      vim.g.undotree_ShortIndicators = 1
      vim.g.undotree_SplitWidth = 50
    end,
  },
  {
    "alexghergh/nvim-tmux-navigation",
    config = function()
      require("nvim-tmux-navigation").setup {
        disable_when_zoomed = true, -- defaults to false
        keybindings = {
          left = "<C-w>h",
          down = "<C-w>j",
          up = "<C-w>k",
          right = "<C-w>l",
          last_active = "<C-w>\\",
          next = "<C-w><Space>",
        },
      }
    end,
  },
  {
    "lewis6991/spaceless.nvim",
    config = function() require("spaceless").setup() end,
  },
  {
    "catppuccin",
    opts = {
      flavour = "macchiato",
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      signs = {
        add = { text = "▌" },
        change = { text = "▌" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "▌" },
        untracked = { text = "▌" },
      },
      signcolumn = true,
      numhl = true,
      linehl = false,
      yadm = { enable = true },
    },
  },
  {
    "rmagatti/goto-preview",
    config = function() require("goto-preview").setup {} end,
    keys = {
      { "gp", "", desc = "Peek" },
      { "gpd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", desc = "Peek Definition" },
      { "gpt", "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", desc = "Peek Type Definition" },
      { "gpi", "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>", desc = "Peek Implementation" },
      { "gpc", "<cmd>lua require('goto-preview').close_all_win()<CR>", desc = "Close all peek windows" },
      { "gpr", "<cmd>lua require('goto-preview').goto_preview_references()<CR>", desc = "Peek References" },
    },
  },
  {
    "ldelossa/nvim-dap-projects",
    config = function() require("nvim-dap-projects").search_project_config() end,
    dependencies = {
      { "mfussenegger/nvim-dap" },
    },
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "alfaix/neotest-gtest",
    },
    opts = { adapters = { "neotest-gtest" } },
  },
  {
    "s1n7ax/nvim-window-picker",
    version = "2.*",
    config = function()
      require("window-picker").setup {
        selection_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
        show_prompt = false,
        filter_rules = {
          include_current_win = false,
          autoselect_one = true,
          -- filter using buffer options
          bo = {
            -- if the file type is one of following, the window will be ignored
            filetype = { "neo-tree", "neo-tree-popup", "notify", "noice" },
            -- if the buffer type is one of following, the window will be ignored
            buftype = { "terminal", "quickfix" },
          },
        },
      }
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "s1n7ax/nvim-window-picker",
    },
    opts = {
      defaults = {
        get_selection_window = function() return require("window-picker").pick_window() end,
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      "s1n7ax/nvim-window-picker",
    },
    opts = {
      window = {
        mappings = {
          ["gF"] = "telescope_find",
          ["gG"] = "telescope_grep",
          ["<cr>"] = "open_with_window_picker",
        },
      },
      commands = {
        telescope_find = function(state)
          local path = state.tree:get_node():get_id()
          require("telescope.builtin").find_files { cwd = path, search_dirs = { path } }
        end,
        telescope_grep = function(state)
          local path = state.tree:get_node():get_id()
          require("telescope.builtin").live_grep { cwd = path, search_dirs = { path } }
        end,
      },
      event_handlers = {
        {
          event = "neo_tree_buffer_enter",
          handler = function(arg)
            vim.cmd [[
              setlocal relativenumber
            ]]
          end,
        },
      },
    },
  },
  -- {
  --   "zbirenbaum/copilot.lua",
  --   cmd = "Copilot",
  --   -- event = "InsertEnter",
  --   event = "User AstroFile",
  --   opts = function(_, _)
  --     return {
  --       suggestion = {
  --         enabled = true,
  --         auto_trigger = true,
  --         debounce = 150,
  --         keymap = {
  --           accept = "<M-l>",
  --           accept_word = false,
  --           accept_line = false,
  --           next = "<M-]>",
  --           prev = "<M-[>",
  --           dismiss = "<C-]>",
  --         },
  --       },
  --       -- panel = {
  --       --   enabled = true,
  --       --   auto_refresh = true,
  --       -- },
  --     }
  --   end,
  --   -- keys = {
  --   --   { "<leader>lc", "<cmd>Copilot panel<cr>", desc = "Panel" },
  --   -- },
  -- },
}
