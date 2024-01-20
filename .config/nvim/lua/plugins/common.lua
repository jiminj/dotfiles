local cmp = require("cmp")
return {
  {
    "stevearc/aerial.nvim",
    opts = {
      layout = {
        max_width = { 120, 0.4 },
        resize_to_content = true,
      },
    },
  },
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        always_show_bufferline = true,
      },
    },
  },
  {
    "monaqa/dial.nvim",
    event = "BufRead",
    keys = {
      {
        "<C-a>",
        function()
          require("dial.map").manipulate("increment", "normal")
        end,
        mode = "n",
        desc = "Increase",
      },
      {
        "<C-x>",
        function()
          require("dial.map").manipulate("decrement", "normal")
        end,
        mode = "n",
        desc = "Decrease",
      },
      {
        "g<C-a>",
        function()
          require("dial.map").manipulate("increment", "gnormal")
        end,
        mode = "n",
        desc = "Group Increase",
      },
      {
        "g<C-x>",
        function()
          require("dial.map").manipulate("decrement", "gnormal")
        end,
        mode = "n",
        desc = "Group Decrease",
      },
      {
        "<C-a>",
        function()
          require("dial.map").manipulate("increment", "visual")
        end,
        mode = "x",
        desc = "Increase",
      },
      {
        "<C-x>",
        function()
          require("dial.map").manipulate("decrement", "visual")
        end,
        mode = "x",
        desc = "Decrease",
      },
      {
        "g<C-a>",
        function()
          require("dial.map").manipulate("increment", "gvisual")
        end,
        mode = "x",
        desc = "Group Increase",
      },
      {
        "g<C-x>",
        function()
          require("dial.map").manipulate("decrement", "gvisual")
        end,
        mode = "x",
        desc = "Group Decrease",
      },
    },
    config = function()
      local augend = require("dial.augend")
      require("dial.config").augends:register_group({
        default = {
          augend.integer.alias.decimal,
          augend.integer.alias.hex,
          augend.date.alias["%Y/%m/%d"],
          augend.integer.alias.octal,
          augend.integer.alias.binary,
          augend.date.alias["%Y/%m/%d"],
          augend.date.alias["%Y-%m-%d"],
          augend.date.alias["%m/%d/%y"],
          augend.date.alias["%m/%d"],
          augend.date.alias["%-m/%-d"],
          augend.date.alias["%H:%M"],
          augend.date.alias["%H:%M:%S"],
          augend.constant.alias.bool,
          augend.constant.alias.alpha,
          augend.constant.alias.Alpha,
          augend.constant.alias.semver,
        },
        -- visual = {
        --   augend.integer.alias.decimal,
        --   augend.integer.alias.hex,
        --   augend.date.alias["%Y/%m/%d"],
        --   augend.constant.alias.alpha,
        --   augend.constant.alias.Alpha,
        -- },
      })
    end,
  },
  { "sindrets/diffview.nvim", dependencies = "nvim-lua/plenary.nvim" },
  {
    "stevearc/overseer.nvim",
    config = function()
      require("overseer").setup()
    end,
  },
  { "folke/flash.nvim", enabled = false },
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
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 100,
      },
      signcolumn = true,
      numhl = true,
      linehl = false,
      current_line_blame_formatter = "-- [<abbrev_sha>] <author>, <author_time:%Y-%m-%d> - <summary>",
      yadm = { enable = true },
    },
  },
  {
    "ggandor/flit.nvim",
    enabled = false,
  },
  {
    "rmagatti/goto-preview",
    config = function()
      require("goto-preview").setup({})
    end,
    keys = {
      { "gpd", "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", desc = "Peek Definition" },
      { "gpt", "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", desc = "Peek Type Definition" },
      { "gpi", "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>", desc = "Peek Implementation" },
      { "gpc", "<cmd>lua require('goto-preview').close_all_win()<CR>", desc = "Close all peek windows" },
      { "gpr", "<cmd>lua require('goto-preview').goto_preview_references()<CR>", desc = "Peek References" },
    },
  },

  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    -- event = "BufRead",
    config = function()
      local harpoon = require("harpoon")
      harpoon:setup({})
      -- require("telescope").load_extension("harpoon")
    end,
    keys = {
      {
        "<leader>ha",
        function()
          require("harpoon"):list():append()
        end,
        desc = "Append",
      },
      {
        "<leader>hq",
        function()
          require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
        end,
        desc = "Toggle Quick Menu",
      },
      {
        "<leader>h1",
        function()
          require("harpoon"):list():select(1)
        end,
        desc = "Select 1",
      },
      {
        "<leader>h2",
        function()
          require("harpoon"):list():select(2)
        end,
        desc = "Select 2",
      },
      {
        "<leader>h3",
        function()
          require("harpoon"):list():select(3)
        end,
        desc = "Select 3",
      },
      {
        "<leader>h4",
        function()
          require("harpoon"):list():select(4)
        end,
        desc = "Select 4",
      },
      {
        "<leader>hp",
        function()
          require("harpoon"):list():prev()
        end,
        desc = "Prev",
      },
      {
        "<leader>hn",
        function()
          require("harpoon"):list():next()
        end,
        mode = "n",
        desc = "Next",
      },
      { "<leader>hs", "<cmd>Telescope harpoon marks<cr>", desc = "Search" },
    },
  },
  {
    "echasnovski/mini.comment",
    opts = {
      mappings = {
        comment_line = "<leader>/",
        comment_visual = "<leader>/",
        textobject = "<leader>/",
      },
    },
  },
  {
    "karb94/neoscroll.nvim",
    event = "WinScrolled",
    config = function()
      require("neoscroll").setup({

        -- All these keys will be mapped to their corresponding default scrolling animation
        mappings = { "<C-u>", "<C-d>", "<C-b>", "<C-f>", "<C-y>", "<C-e>", "zt", "zz", "zb" },
        hide_cursor = true, -- Hide cursor while scrolling
        stop_eof = true, -- Stop at <EOF> when scrolling downwards
        use_local_scrolloff = false, -- Use the local scope of scrolloff instead of the global scope
        respect_scrolloff = false, -- Stop scrolling when the cursor reaches the scrolloff margin of the file
        cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
        easing_function = nil, -- Default easing function
        pre_hook = nil, -- Function to run before the scrolling animation starts
        post_hook = nil, -- Function to run after the scrolling animation ends
      })
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "alfaix/neotest-gtest",
    },
    opts = { adapters = { "neotest-gtest" } },
  },
  {
    "ldelossa/nvim-dap-projects",
    config = function()
      require("nvim-dap-projects").search_project_config()
    end,
    dependencies = {
      { "mfussenegger/nvim-dap" },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    dependencies = {
      {
        "s1n7ax/nvim-window-picker",
        version = "2.*",
        config = function()
          require("window-picker").setup({
            selection_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
            show_prompt = false,
            filter_rules = {
              include_current_win = false,
              autoselect_one = true,
              -- filter using buffer options
              bo = {
                -- if the file type is one of following, the window will be ignored
                filetype = { "neo-tree", "neo-tree-popup", "notify" },
                -- if the buffer type is one of following, the window will be ignored
                buftype = { "terminal", "quickfix" },
              },
            },
            highlights = {
              statusline = {
                unfocused = {
                  fg = "#ededed",
                  bg = "#4493c8",
                  bold = true,
                },
              },
            },
          })
        end,
      },
    },
    opts = {
      window = {
        mappings = {
          ["<cr>"] = "open_with_window_picker",
        },
      },
    },
  },
  {
    "hrsh7th/nvim-cmp",
    sources = {},
    opts = {
      window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
      },
      -- experimental = {
      --   ghost_text = {
      --     hl_group = "Comment",
      --   },
      -- },
      formatting = {
        format = function(_, item)
          local m = item.menu and item.menu or ""
          if #m > 20 then
            item.menu = string.sub(m, 1, 17) .. "..."
          end
          local icons = require("lazyvim.config").icons.kinds
          if icons[item.kind] then
            item.kind = icons[item.kind] .. item.kind
          end
          item.dup = 0
          return item
        end,
      },

      matching = {
        disallow_prefix_unmatching = true,
      },
    },
  },
  {
    "saadparwaiz1/cmp_luasnip",
    enabled = false,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "SmiteshP/nvim-navbuddy",
        dependencies = {
          "SmiteshP/nvim-navic",
          "MunifTanjim/nui.nvim",
        },
        opts = {
          window = {
            border = "double",
            size = "80%",
          },
          lsp = { auto_attach = true },
        },
        keys = {
          { "<leader>cn", "<cmd>Navbuddy<cr>", desc = "Navbuddy" },
        },
      },
    },
  },

  {
    "rcarriga/nvim-notify",
    keys = {
      {
        "<leader>snt",
        "<cmd>lua require('telescope').extensions.notify.notify()<cr>",
        desc = "Open in Telescope",
      },
    },
  },
  {
    "petertriho/nvim-scrollbar",
    config = function()
      require("scrollbar").setup({})
    end,
  },
  {
    "alexghergh/nvim-tmux-navigation",
    config = function()
      require("nvim-tmux-navigation").setup({
        disable_when_zoomed = true, -- defaults to false
        keybindings = {
          left = "<C-w>h",
          down = "<C-w>j",
          up = "<C-w>k",
          right = "<C-w>l",
          last_active = "<C-w>\\",
          next = "<C-w><Space>",
        },
      })
    end,
  },
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("refactoring").setup({
        prompt_func_return_type = {
          go = true,
          java = true,
          cpp = true,
          c = true,
          h = true,
          hpp = true,
          cxx = true,
        },
        prompt_func_param_type = {
          go = true,
          java = true,
          cpp = true,
          c = true,
          h = true,
          hpp = true,
          cxx = true,
        },
        show_success_message = true,
      })
    end,

    keys = {
      {
        "<leader>rr",
        function()
          require("refactoring").select_refactor()
        end,
        mode = { "n", "x" },
        desc = "Open Refactoring Options",
      },
      {
        "<leader>rv",
        ":lua require('refactoring').debug.printf({below = false})<CR>",
        mode = "n",
        desc = "Add printf statement",
      },
      {
        "<leader>rp",
        ":lua require('refactoring').debug.print_var({ normal = true })<CR>",
        mode = { "n", "x" },
        desc = "Add debug(print) statement from the word",
      },
      {
        "<leader>rP",
        ":lua require('refactoring').debug.cleanup({})<CR>",
        mode = "n",
        desc = "Cleanup debug statements",
      },
      {
        "<leader>rb",
        ":lua require('refactoring').refactor('Extract Block')<CR>",
        mode = "n",
        desc = "Extract Block",
      },
      {
        "<leader>rf",
        ":lua require('refactoring').refactor('Extract Block To File')<CR>",
        mode = "n",
        desc = "Extract Block To File",
      },
      {
        "<leader>ri",
        ":lua require('refactoring').refactor('Inline Function')<CR>",
        mode = "n",
        desc = "Inline Function",
      },
      {
        "<leader>ri",
        ":lua require('refactoring').refactor('Inline Variable')<CR>",
        mode = { "n", "x" },
        desc = "Inline Variable",
      },
      {
        "<leader>re",
        ":lua require('refactoring').refactor('Extract Function')<CR>",
        mode = "x",
        desc = "Extract Function",
      },
      {
        "<leader>rf",
        ":lua require('refactoring').refactor('Extract Function To File')<CR>",
        mode = "x",
        desc = "Extract Function To File",
      },
      {
        "<leader>rv",
        ":lua require('refactoring').refactor('Extract Variable')<CR>",
        mode = "x",
        desc = "Extract Variable",
      },
    },
  },
  {
    "lewis6991/spaceless.nvim",
    config = function()
      require("spaceless").setup()
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    -- opts = function()
    -- Util.on_load("telescope.nvim", function()
    -- require("telescope").load_extension("ui-select")
    -- end)
    -- end,
    keys = {
      -- disable the keymap to grep files
      { "<leader>/", false },
      { "<leader><space>", false },
    },
  },
  {
    "glepnir/template.nvim",
    cmd = { "Template", "TemProject" },
    config = function()
      utils_funcs = {}
      utils_funcs.cap_filename = function()
        local filename = vim.fn.expand("%:t")
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

      require("template").setup({
        temp_dir = "~/.config/nvim/template",
        author = "Jimin Jeon",
        -- email = "jimin.jeon@42dot.ai",
      })
      require("telescope").load_extension("find_template")
    end,
    keys = {
      { "<leader>t", ":Telescope find_template type=insert<CR>", mode = "n", desc = "Find templates" },
    },
  },
  {
    "mbbill/undotree",
    cmd = { "UndotreeToggle", "UndotreeShow", "UndotreeFocus" },
    keys = {
      { "<leader>U", "<cmd>UndotreeToggle<CR>", desc = "UndoTree" },
    },
    config = function()
      vim.g.undotree_ShortIndicators = 1
      vim.g.undotree_SplitWidth = 30
    end,
  },
  {
    "folke/which-key.nvim",
    opts = {
      defaults = {
        ["<leader>p"] = { name = "+plugins" },
        ["<leader>r"] = { name = "+refactoring" },
        ["<leader>h"] = { name = "+Harpoon" },
        ["gp"] = { name = "+peek" },
      },
    },
  },
}
