-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

local function getTelescopeOpts(state, path)
  return {
    cwd = path,
    search_dirs = { path },
    -- attach_mappings = function(prompt_bufnr, map)
    --   local actions = require "telescope.actions" actions.select_default:replace(function()
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

local function get_visual_selection()
  -- this will exit visual mode
  -- use 'gv' to reselect the text
  local _, csrow, cscol, cerow, cecol
  local mode = vim.fn.mode()
  if mode == "v" or mode == "V" or mode == "" then
    -- if we are in visual mode use the live position
    _, csrow, cscol, _ = unpack(vim.fn.getpos ".")
    _, cerow, cecol, _ = unpack(vim.fn.getpos "v")
    if mode == "V" then
      -- visual line doesn't provide columns
      cscol, cecol = 0, 999
    end
    -- exit visual mode
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
  else
    -- otherwise, use the last known visual position
    _, csrow, cscol, _ = unpack(vim.fn.getpos "'<")
    _, cerow, cecol, _ = unpack(vim.fn.getpos "'>")
  end
  -- swap vars if needed
  if cerow < csrow then
    csrow, cerow = cerow, csrow
  end
  if cecol < cscol then
    cscol, cecol = cecol, cscol
  end
  local lines = vim.fn.getline(csrow, cerow)

  -- local n = cerow-csrow+1
  local n = 0
  for _ in pairs(lines) do
    n = n + 1
  end

  if n <= 0 then return "" end
  lines[n] = string.sub(lines[n], 1, cecol)
  lines[1] = string.sub(lines[1], cscol)
  return table.concat(lines, "\n")
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
  -- {
  --   "LunarVim/bigfile.nvim",
  --   opts = {
  --     filesize = 2, -- size of the file in MiB, the plugin round file sizes to the closest MiB
  --     -- pattern = { "*" }, -- autocmd pattern or function see <### Overriding the detection of big files>
  --     features = { -- features to disable
  --       "indent_blankline",
  --       "illuminate",
  --       "lsp",
  --       "treesitter",
  --       "syntax",
  --       "matchparen",
  --       "vimopts",
  --       "filetype",
  --     },
  --   },
  -- },
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = true },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    enabled = true,
  },
  {
    "echasnovski/mini.diff",
    opts = {
      mappings = {
        textobject = "gh",
      },
    },
  },
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
    event = "User AstroFile",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "purarue/gitsigns-yadm.nvim",
    },
    opts = {
      _on_attach_pre = function(_, callback) require("gitsigns-yadm").yadm_signs(callback) end,
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
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- 'eol' | 'overlay' | 'right_align'
        delay = 50,
        ignore_whitespace = false,
        virt_text_priority = 100,
      },
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
  -- {
  --   "ldelossa/nvim-dap-projects",
  --   config = function() require("nvim-dap-projects").search_project_config() end,
  --   dependencies = {
  --     { "mfussenegger/nvim-dap" },
  --   },
  -- },
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
            filetype = { "neo-tree", "neo-tree-popup", "notify", "noice", "blame", "undotree" },
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
      {
        "AstroNvim/astrocore",
        opts = function(_, opts)
          local maps = opts.mappings
          maps.v["<Leader>f"] = vim.tbl_get(opts, "_map_sections", "f")
          maps.v["<Leader>ff"] = {
            function()
              require("telescope.builtin").find_files {
                default_text = get_visual_selection(),
              }
            end,
            desc = "Find files",
          }
          if vim.fn.executable "rg" == 1 then
            maps.v["<Leader>fw"] = {
              function()
                require("telescope.builtin").live_grep {
                  default_text = get_visual_selection(),
                }
              end,
              desc = "Find words",
            }
            maps.v["<Leader>fW"] = {
              function()
                require("telescope.builtin").live_grep {
                  default_text = get_visual_selection(),
                  additional_args = function(args) return vim.list_extend(args, { "--hidden", "--no-ignore" }) end,
                }
              end,
              desc = "Find words in all files",
            }
          end
        end,
      },
      opts = {
        defaults = {
          get_selection_window = function() return require("window-picker").pick_window() or 0 end,
        },
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
  {
    "mrjones2014/smart-splits.nvim",
    keys = {
      { "<M-Up>", function() require("smart-splits").resize_up() end, desc = "Resize split up" },
      { "<M-Down>", function() require("smart-splits").resize_down() end, desc = "Resize split down" },
      { "<M-Left>", function() require("smart-splits").resize_left() end, desc = "Resize split left" },
      { "<M-Right>", function() require("smart-splits").resize_right() end, desc = "Resize split right" },
    },
  },
  {
    "glepnir/template.nvim",
    cmd = { "Template" },
    config = function()
      utils_funcs = {}
      utils_funcs.cap_filename = function()
        local filename = vim.fn.expand "%:t"
        local snakeCase = string
          .gsub(filename, "[.%u]", function(c)
            if c == "." then
              return "_"
            else
              return "_" .. c
            end
          end)
          :gsub("^_", "")
        return string.upper(snakeCase)
      end
      require("template").setup {
        temp_dir = vim.fn.stdpath "config" .. "/templates",
      }
      require("telescope").load_extension "find_template"
    end,
    keys = {
      { "<leader>fp", ":Telescope find_template type=insert<CR>", mode = "n", desc = "Find templates" },
    },
  },
}
