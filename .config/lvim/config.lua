--[[
 THESE ARE EXAMPLE CONFIGS FEEL FREE TO CHANGE TO WHATEVER YOU WANT
 `lvim` is the global options object
]]
-- vim options
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.relativenumber = true
vim.opt.timeout = true
vim.opt.timeoutlen = 300
vim.opt.wrap = true
vim.opt.colorcolumn = "81"
-- vim.opt.spelllang = { "en_us" }
-- vim.opt.spell = true

-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "*",
--   once = false,
--   callback = function()
--     vim.cmd("hi SpellBad guisp=NONE")
--     vim.cmd("hi SpellCap guisp=NONE")
--     vim.cmd("hi SpellLocal guisp=NONE")
--     vim.cmd("hi SpellRare guisp=NONE")
--   end,
-- })

-- general
lvim.log.level = "info"
lvim.format_on_save = {
  enabled = true,
  pattern = "*.lua",
  timeout = 1000,
}

-- to disable icons and use a minimalist setup, uncomment the following
-- keymappings <https://www.lunarvim.org/docs/configuration/keybindings>

lvim.leader = "space" -- add your own keymapping
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
lvim.keys.normal_mode["<C-s>"] = ":w<cr>"
lvim.keys.normal_mode["Y"] = "yy"

-- vim.keymap.set({ 'n', 'i', 'v' }, '<ScrollWheelUp>', '<C-y>')
-- vim.keymap.set({ 'n', 'i', 'v' }, '<ScrollWheelDown>', '<C-e>')
-- -- Use which-key to add extra bindings with the leader-key prefix
-- lvim.builtin.which_key.mappings["W"] = { "<cmd>noautocmd w<cr>", "Save without formatting" }
-- lvim.builtin.which_key.mappings["P"] = { "<cmd>Telescope projects<CR>", "Projects" }

-- -- Change theme settings
-- lvim.colorscheme = "lunar"
lvim.builtin.alpha.active = true
lvim.builtin.alpha.mode = "dashboard"
lvim.builtin.terminal.active = true
lvim.builtin.nvimtree.setup.view.side = "left"
lvim.builtin.nvimtree.setup.renderer.icons.show.git = true

-- Automatically install missing parsers when entering buffer
lvim.builtin.treesitter.auto_install = true
lvim.builtin.treesitter.indent.disable = { "c", "cpp" }
-- lvim.builtin.lualine.sections = {
--   lunaline_a =
-- }
--
lvim.lazy.opts.dev = { path = "~/Workplace/nvimplugins" }

local lualine_components = require("lvim.core.lualine.components")

local get_noice_lualine_mode = function()
  local status_ok, noice = pcall(require, "noice")
  if status_ok and noice then
    return {
      noice.api.status.mode.get,
      cond = noice.api.status.mode.has,
    }
  else
    return nil
  end
end
-- local get_cmake_tools_lualine_component = function(component)
--   local status_ok, cmake_tools = pcall(require, "cmake-tools")
--   if status_ok and cmake_tools and cmake_tools.lualine then
--     -- print(vim.inspect(cmake_tools.lualine[component]()))
--     return cmake_tools.lualine[component]
--   else
--     return nil
--   end
-- end

lvim.builtin.lualine.sections = {
  lualine_a = {
    lualine_components.mode,
    get_noice_lualine_mode()
  },
  lualine_b = {
    lualine_components.branch,
    'diagnostics',
  },
  lualine_c = {
    { 'filename', path = 1 },
    'diff',
    -- get_cmake_tools_lualine_component("build_target")
  },
  lualine_x = {
    'encoding',
    lualine_components.diagnostics,
    lualine_components.lsp,
    lualine_components.filetype,
  },
  lualine_y = {
    lualine_components.location,
  },
  lualine_z = {
    lualine_components.progress,
  }
}


lvim.builtin.gitsigns.opts.signs.delete.text = '_'
lvim.builtin.gitsigns.opts.signs.topdelete.text = '‾'
lvim.builtin.gitsigns.opts.current_line_blame = true
lvim.builtin.gitsigns.opts.current_line_blame_opts.delay = 100
lvim.builtin.gitsigns.opts.current_line_blame_formatter =
'-- [<abbrev_sha>] <author>, <author_time:%Y-%m-%d> - <summary>'
-- lvim.builtin.gitsigns.opts.current_line_blame = true
-- lvim.builtin.gitsigns.opts.current_line_blame_opts = {
--   delay = 0
-- }
lvim.builtin.gitsigns.opts.yadm.enable = true

lvim.builtin.telescope.theme = "center"
lvim.builtin.telescope.defaults.dynamic_preview_title = true
-- lvim.builtin.telescope.pickers = {
--   find_files = {
--     layout_strategy = "horizontal",
--     layout_config = { width = 0.80, height = 0.80, preview_width = 0.60 },
--   },
--   live_grep = {
--     layout_strategy = "horizontal",
--     layout_config = { width = 0.80, height = 0.80, preview_width = 0.60 },
--   },
--   buffers = {
--     layout_strategy = "horizontal",
--     layout_config = { width = 0.80, height = 0.80, preview_width = 0.60 },
--   },
-- }
lvim.builtin.telescope.defaults.layout_strategy = "horizontal"
lvim.builtin.telescope.defaults.layout_config = { width = 0.80, height = 0.80, preview_width = 0.60 }
lvim.builtin.telescope.defaults.file_ignore_patterns = { "node_modules", ".git", "build" }

-- lvim.builtin.treesitter.ignore_install = { "haskell" }

-- -- always installed on startup, useful for parsers without a strict filetype
-- lvim.builtin.treesitter.ensure_installed = { "comment", "markdown_inline", "regex" }

-- -- generic LSP settings <https://www.lunarvim.org/docs/languages#lsp-support>

-- --- disable automatic installation of servers
-- lvim.lsp.installer.setup.automatic_installation = false

-- ---configure a server manually. IMPORTANT: Requires `:LvimCacheReset` to take effect
-- ---see the full default list `:lua =lvim.lsp.automatic_configuration.skipped_servers`
-- vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "pyright" })
-- local opts = {} -- check the lspconfig documentation for a list of all possible options
-- require("lvim.lsp.manager").setup("pyright", opts)


vim.list_extend(lvim.lsp.automatic_configuration.skipped_servers, { "clangd" })
local lspclangd_opts = require("lvim.lsp").get_common_opts()
lspclangd_opts.capabilities = require("lvim.lsp").common_capabilities()
lspclangd_opts.cmd = { "/usr/local/opt/llvm/bin/clangd", "--enable-config" }

lspclangd_opts.capabilities.offsetEncoding = { "utf-16" }

local clangd_extensions_status_ok, _ = pcall(require, "clangd_extensions")
if clangd_extensions_status_ok == false then
  require("lvim.lsp.manager").setup("clangd", lspclangd_opts)
end
--

vim.filetype.add({
  extension = { gradle = "gradle" }
})
vim.treesitter.language.register("java", "gradle")


-- ---remove a server from the skipped list, e.g. eslint, or emmet_ls. IMPORTANT: Requires `:LvimCacheReset` to take effect
-- ---`:LvimInfo` lists which server(s) are skipped for the current filetype
-- lvim.lsp.automatic_configuration.skipped_servers = vim.tbl_filter(function(server)
--   return server ~= "emmet_ls"
-- end, lvim.lsp.automatic_configuration.skipped_servers)

-- -- you can set a custom on_attach function that will be used for all the language servers
-- -- See <https://github.com/neovim/nvim-lspconfig#keybindings-and-completion>



lvim.lsp.buffer_mappings.normal_mode["gd"] = { "<cmd>lua require('telescope.builtin').lsp_definitions()<cr>",
  "Goto definition" }
lvim.lsp.buffer_mappings.normal_mode["gr"] = { "<cmd>lua require('telescope.builtin').lsp_references()<cr>",
  "Goto references" }
lvim.lsp.buffer_mappings.normal_mode["gI"] = { "<cmd>lua require('telescope.builtin').lsp_implementations()<cr>",
  "Goto implementation" }
lvim.lsp.buffer_mappings.normal_mode["gt"] = { "<cmd>lua require('telescope.builtin').lsp_type_definitions()<cr>",
  "Goto Type Definition" }

lvim.lsp.on_attach_callback = function(client, bufnr)
  require("nvim-navbuddy").attach(client, bufnr)
  -- local wk = require("which-key")
  -- wk.register({
  --   -- ["gd"] = { "<cmd>lua vim.lsp.buf.definition()<cr>", "Goto definition" },
  --   -- ["gD"] = { "<cmd>lua vim.lsp.buf.declaration()<cr>", "Goto Declaration" },
  --   -- ["gr"] = { "<cmd>lua require('telescope.builtin').lsp_references()<cr>", "Goto references Telescope" },
  --   -- ["gI"] = { "<cmd>lua vim.lsp.buf.implementation()<cr>", "Goto Implementation" },
  --   -- ["gs"] = { "<cmd>lua vim.lsp.buf.signature_help()<cr>", "show signature help" },
  -- })




  -- normal_mode = {
  --   ["K"] = { "<cmd>lua vim.lsp.buf.hover()<cr>", "Show hover" },
  --   ["gd"] = { "<cmd>lua vim.lsp.buf.definition()<cr>", "Goto definition" },
  --   ["gD"] = { "<cmd>lua vim.lsp.buf.declaration()<cr>", "Goto Declaration" },
  --   ["gr"] = { "<cmd>lua vim.lsp.buf.references()<cr>", "Goto references" },
  --   ["gI"] = { "<cmd>lua vim.lsp.buf.implementation()<cr>", "Goto Implementation" },
  --   ["gs"] = { "<cmd>lua vim.lsp.buf.signature_help()<cr>", "show signature help" },
  --   ["gl"] = {
  --     function()
  --       local config = lvim.lsp.diagnostics.float
  --       config.scope = "line"
  --       vim.diagnostic.open_float(0, config)
  --     end,
  --     "Show line diagnostics",
  --   },
  --
  -- local function buf_set_option(...)
  --   vim.api.nvim_buf_set_option(bufnr, ...)
  -- end
  -- --Enable completion triggered by <c-x><c-o>
  -- buf_set_option("omnifunc", "v:lua.vim.lsp.omnifunc")
end


-- -- linters and formatters <https://www.lunarvim.org/docs/languages#lintingformatting>
-- local formatters = require "lvim.lsp.null-ls.formatters"
-- formatters.setup {
--   { command = "stylua" },
--   {
--     command = "prettier",
--     extra_args = { "--print-width", "100" },
--     filetypes = { "typescript", "typescriptreact" },
--   },
-- }
-- local linters = require "lvim.lsp.null-ls.linters"
-- linters.setup {
--   { command = "flake8", filetypes = { "python" } },
--   {
--     command = "shellcheck",
--     args = { "--severity", "warning" },
--   },
-- }
--
--
--

-- -- Additional Plugins <https://www.lunarvim.org/docs/plugins#user-plugins>

lvim.plugins = {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup({
        panel = { enabled = false },
        suggestion = {
          -- enabled = false,
          auto_trigger = true,
          keymap = {
            accept = "<M-l>",
            accept_word = false,
            accept_line = false,
            next = "<M-]>",
            prev = "<M-[>",
            dismiss = "<C-]>",
          },
        }
      })
    end,
  },
  -- {
  --   "zbirenbaum/copilot-cmp",
  --   dependencies = { "copilot.lua" },
  --   config = function()
  --     require("copilot_cmp").setup()
  --   end
  -- },
  {
    "ThePrimeagen/refactoring.nvim",
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-treesitter/nvim-treesitter" }
    },
    config = function()
      require('refactoring').setup({
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
        }
      })
      require("telescope").load_extension("refactoring")
      lvim.builtin.which_key.mappings["r"] = {
        name = "Refactoring",
        r = { "<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>",
          "Open Refactoring Options" },
        v = { ":lua require('refactoring').debug.printf({below = false})<CR>", "Add printf statement" },
        p = { ":lua require('refactoring').debug.print_var({ normal = true })<CR>",
          "Add debug(print) statement from the word" },
        P = { ":lua require('refactoring').debug.cleanup({})<CR>", "Cleanup debug statements" },
        b = { "<Cmd>lua require('refactoring').refactor('Extract Block')<CR>", "Extract Block" },
        f = { "<Cmd>lua require('refactoring').refactor('Extract Block To File')<CR>", "Extract Block To File" },
        i = { "<Cmd>lua require('refactoring').refactor('Inline Variable')<CR>", "Inline Variable" },
      }

      lvim.builtin.which_key.vmappings["r"] = {
        name = "Refactoring",
        p = { ":lua require('refactoring').debug.print_var({})<CR>", "Add debug(print) statement" },
        r = { "<Esc><cmd>lua require('telescope').extensions.refactoring.refactors()<CR>", "Open Refactoring Options" },
        e = { "<Esc><Cmd>lua require('refactoring').refactor('Extract Function')<CR>", "Extract Function" },
        f = { "<Esc><Cmd>lua require('refactoring').refactor('Extract Function To File')<CR>", "Extract Function To File" },
        v = { "<Esc><Cmd>lua require('refactoring').refactor('Extract Variable')<CR>", "Extract Variable" },
        i = { "<Esc><Cmd>lua require('refactoring').refactor('Inline Variable')<CR>", "Inline Variable" }
      }
    end,
    keys = {
      {
        "<leader>rr",
        ":lua require('telescope').extensions.refactoring.refactors()<CR>",
        mode = "n",
        desc = "Open Refactoring Options"
      },
      {
        "<leader>rv",
        ":lua require('refactoring').debug.printf({below = false})<CR>",
        mode = "n",
        desc = "Add printf statement"
      },
      {
        "<leader>rp",
        ":lua require('refactoring').debug.print_var({ normal = true })<CR>",
        mode = "n",
        desc = "Add debug(print) statement from the word"
      },
      {
        "<leader>rP",
        ":lua require('refactoring').debug.cleanup({})<CR>",
        mode = "n",
        desc = "Cleanup debug statements"
      },
      {
        "<leader>rb",
        ":lua require('refactoring').refactor('Extract Block')<CR>",
        mode = "n",
        desc = "Extract Block"
      },
      {
        "<leader>rf",
        ":lua require('refactoring').refactor('Extract Block To File')<CR>",
        mode = "n",
        desc = "Extract Block To File"
      },
      {
        "<leader>ri",
        ":lua require('refactoring').refactor('Inline Variable')<CR>",
        mode = "n",
        desc = "Inline Variable"
      },
      {
        "<leader>rp",
        ":lua require('refactoring').debug.print_var({})<CR>",
        mode = "v",
        desc = "Add debug(print) statement"
      },
      {
        "<leader>rr",
        ":lua require('telescope').extensions.refactoring.refactors()<CR>",
        mode = "v",
        desc = "Open Refactoring Options"
      },
      {
        "<leader>re",
        ":lua require('refactoring').refactor('Extract Function')<CR>",
        mode = "v",
        desc = "Extract Function"
      },
      {
        "<leader>rf",
        ":lua require('refactoring').refactor('Extract Function To File')<CR>",
        mode = "v",
        desc = "Extract Function To File"
      },
      {
        "<leader>rv",
        ":lua require('refactoring').refactor('Extract Variable')<CR>",
        mode = "v",
        desc = "Extract Variable"
      },
      {
        "<leader>ri",
        ":lua require('refactoring').refactor('Inline Variable')<CR>",
        mode = "v",
        desc = "Inline Variable"
      }

    }
  },
  {
    "Badhi/nvim-treesitter-cpp-tools",
    cmd = { "TsCppDefineClassFunc", "TSCppMakeConcreteClass", "TSCppRuleOf3", "TSCppRuleOf5" },
    keys = {
      { "<leader>rd", ":TsCppDefineClassFunc<cr>",   mode = "v", desc = "Define Class Functions" },
      { "<leader>rc", ":TSCppMakeConcreteClass<cr>", mode = "v", desc = "Make Concrete Class" },
      { "<leader>r3", ":TSCppRuleOf3<cr>",           mode = "v", desc = "Make To Obey Rule of Three" },
      { "<leader>r5", ":TSCppRuleOf5<cr>",           mode = "v", desc = "Make To Obey Rule of Five" },
    },
    ft = { "cpp", "c", "h", "hpp", "cxx" },
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" }
    },
    config = function()
      require 'nt-cpp-tools'.setup({
        preview = {
          quit = 'q',             -- optional keymapping for quit preview
          accept = '<tab>'        -- optional keymapping for accept preview
        },
        header_extension = 'h',   -- optional
        source_extension = 'cpp', -- optional
        custom_define_class_function_commands = {
          -- optional
          TSCppImplWrite = {
            output_handle = require 'nt-cpp-tools.output_handlers'.get_add_to_cpp()
          }
          --[[
        <your impl function custom command name> = {
            output_handle = function (str, context)
                -- string contains the class implementation
                -- do whatever you want to do with it
            end
        }
        ]]
        }
      })
    end
  },
  {
    "p00f/clangd_extensions.nvim",
    dependencies = {
      "neovim/nvim-lspconfig"
    },
    keys = {
      { "<leader>lm", ":ClangdMemoryUsage<cr>",   mode = "n", desc = "Show Clangd Memory Usage" },
      { "<leader>lh", ":ClangdTypeHierarchy<cr>", mode = "n", desc = "Type Hierachy" },
      { "<leader>lo", ":ClangdSymbolInfo<cr>",    mode = "n", desc = "Symbol Info" },
      { "<leader>lA", ":ClangAST<cr>",            mode = "n", desc = "AST" },
      { "<leader>lA", ":ClangAST<cr>",            mode = "v", desc = "AST" }

    },
    config = function()
      require("clangd_extensions").setup({
        server = lspclangd_opts,
        extensions = {
          memory_usage = { border = "rounded" },
          symbol_info = { border = "rounded" }
        },
      })
      -- local cmp = require("cmp")
      -- cmp.setup.sorting = {
      --   comparators = {
      --     require("copilot_cmp.comparators").prioritize,
      --     cmp.config.compare.offset,
      --     cmp.config.compare.exact,
      --     require("clangd_extensions.cmp_scores"),
      --     cmp.config.compare.recently_used,
      --     cmp.config.compare.kind,
      --     cmp.config.compare.sort_text,
      --     cmp.config.compare.length,
      --     cmp.config.compare.order,
      --   }
      -- }
    end,
    ft = { "cpp", "c", "h", "hpp", "cxx" },
  },
  {
    "ldelossa/nvim-dap-projects",
    config = function()
      require('nvim-dap-projects').search_project_config()
    end,
    dependencies = {
      { "mfussenegger/nvim-dap" }
    },
  },
  {
    'stevearc/overseer.nvim',
    config = function() require('overseer').setup() end
  },
  {
    "Civitasv/cmake-tools.nvim",
    config = function()
      require("cmake-tools").setup({
        cmake_command = "cmake",
        cmake_build_directory = "",
        cmake_build_directory_prefix = "cmake_build_",                                        -- when cmake_build_directory is "", this option will be activated
        cmake_generate_options = { "-D", "CMAKE_EXPORT_COMPILE_COMMANDS=1" },
        cmake_soft_link_compile_commands = true,                                              -- if softlink compile commands json file
        cmake_build_options = {},
        cmake_console_size = 10,                                                              -- cmake output window height
        cmake_console_position = "belowright",                                                -- "belowright", "aboveleft", ...
        cmake_show_console = "always",                                                        -- "always", "only_on_error"
        cmake_dap_configuration = { name = "cpp", type = "lldb-vscode", request = "launch" }, -- dap configuration, optional
        cmake_variants_message = {
          short = { show = true },
          long = { show = true, max_length = 40 }
        }
      })
    end,
    ft = { "cpp", "c", "h", "hpp", "cxx" },
    dev = true
  },
  {
    "SmiteshP/nvim-navbuddy",
    cmd = { "Navbuddy" },
    dependencies = {
      "neovim/nvim-lspconfig",
      "SmiteshP/nvim-navic",
      "MunifTanjim/nui.nvim",
      "numToStr/Comment.nvim",
      "nvim-telescope/telescope.nvim"
    },
    keys = {
      { "<leader>ln", ":Navbuddy<CR>", desc = "Navbuddy" }
    },
    config = function()
      require("nvim-navbuddy").setup({})
    end
  },
  {
    "folke/trouble.nvim",
    cmd = "TroubleToggle",
    config = function()
      local trouble_telescope = require("trouble.providers.telescope")
      lvim.builtin.telescope.defaults.mappings.i["<C-t>"] = trouble_telescope.open_with_trouble
      lvim.builtin.telescope.defaults.mappings.n["<C-t>"] = trouble_telescope.open_with_trouble
      lvim.builtin.which_key.mappings["t"] = {
        name = "Trouble",
        r = { ":Trouble lsp_references<cr>", "References" },
        f = { ":Trouble lsp_definitions<cr>", "Definitions" },
        d = { ":Trouble document_diagnostics<cr>", "Document Diagnostics" },
        q = { ":Trouble quickfix<cr>", "QuickFix" },
        l = { ":Trouble loclist<cr>", "LocationList" },
        w = { ":Trouble workspace_diagnostics<cr>", "Workspace Diagnostics" },
      }
    end
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    "folke/todo-comments.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    config = function()
      require("todo-comments").setup()
      lvim.builtin.which_key.mappings["s"].T = {
        "<cmd>TodoTelescope<cr>", "Find TODOs",
      }
    end
  },
  {
    "alexghergh/nvim-tmux-navigation",
    config = function()
      require 'nvim-tmux-navigation'.setup {
        disable_when_zoomed = true, -- defaults to false
        keybindings = {
          left = "<C-w>h",
          down = "<C-w>j",
          up = "<C-w>k",
          right = "<C-w>l",
          last_active = "<C-w>\\",
          next = "<C-w><Space>",
        }
      }
    end
  },
  {
    "kylechui/nvim-surround",
    version = "*", -- Use for stability; omit to use `main` branch for the latest features
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({
        -- Configuration here, or leave empty to use defaults
      })
    end
  },
  { "felipec/vim-sanegx",     event = "BufRead" },
  { "windwp/nvim-ts-autotag", event = "BufRead" },
  { "tpope/vim-repeat" },
  {
    'phaazon/hop.nvim',
    cmd = { "HopPattern", "HopAnywhere", "HopWord", "HopLine" },
    branch = 'v2', -- optional but strongly recommended
    config = function()
      -- you can configure Hop the way you like here; see :h hop-config
      require 'hop'.setup()
      lvim.builtin.which_key.mappings["j"] = {
        name = "Jump To",
        p = { ":HopPattern<cr>", "pattern" },
        a = { ":HopAnywhere<cr>", "Anywhere" },
        w = { ":HopWord<cr>", "Word" },
        l = { ":HopLine<cr>", "Line" },
      }
    end
  },
  {
    "petertriho/nvim-scrollbar",
    config = function()
      require("scrollbar").setup({})
      require("scrollbar.handlers.gitsigns").setup()
    end
  },
  {
    "rmagatti/goto-preview",
    config = function()
      require("goto-preview").setup {}
      local wk = require("which-key")
      wk.register({
        ["gp"] = {
          name = "Peek",
          d = { "<cmd>lua require('goto-preview').goto_preview_definition()<CR>", "Peek Definition" },
          t = { "<cmd>lua require('goto-preview').goto_preview_type_definition()<CR>", "Peek Type Definition" },
          i = { "<cmd>lua require('goto-preview').goto_preview_implementation()<CR>", "Peek Implementation" },
          c = { "<cmd>lua require('goto-preview').close_all_win()<CR>", "Close all peek windows" },
          r = { "<cmd>lua require('goto-preview').goto_preview_references()<CR>", "Peek References" },
        },
      })
    end
  },
  {
    "folke/noice.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      require("noice").setup({
        lsp = {
          signature = { enabled = false },
          hover = { enabled = false }
        },
        presets = {
          bottom_search = true,   -- use a classic bottom cmdline for search
          command_palette = true, -- position the cmdline and popupmenu together
        },
        messages = {
          view = "mini",
          view_error = "mini",
          view_warn = "mini",
          -- view_history = "messages",
          -- view_search = "virtualtext"
        }
        -- add any options here
      })
      require("telescope").load_extension("noice")
    end,
    keys = {
      { "<leader>sN", ":Telescope noice<cr>", desc = "Noice message history" }
    },
    event = "VimEnter",
    dependencies = {
      "MunifTanjim/nui.nvim",
      -- OPTIONAL:
      --   `nvim-notify` is only needed, if you want to use the notification view.
      --   If not available, we use `mini` as the fallback
      -- "rcarriga/nvim-notify",
    },
  },
  {
    "rcarriga/nvim-notify",
    keys = {
      { "<leader>sn", "<cmd>lua require('telescope').extensions.notify.notify()<cr>", desc = "Notifications" }
    },
  },
  {
    "ThePrimeagen/harpoon",
    event = "BufRead",
    config = function()
      require("harpoon").setup()
      require("telescope").load_extension("harpoon")
      lvim.builtin.which_key.mappings["m"] = {
        name = "Marks",
        q = { "<cmd>lua require('harpoon.ui').toggle_quick_menu()<cr>", "Toggle Harpoon Quick Menu" },
        a = { "<cmd>lua require('harpoon.mark').add_file()<cr>", "Add Harpoon Mark" },
        n = { "<cmd>lua require('harpoon.ui').nav_next()<cr>", "Next Harpoon Mark" },
        p = { "<cmd>lua require('harpoon.ui').nav_prev()<cr>", "Previous Harpoon Mark" },
        c = { "<cmd>lua require('harpoon.cmd-ui').toggle_quick_menu()<cr>", "Toggle Harpoon Cmd Quick Menu" }
      }
    end,
    keys = {
      { "<leader>sm", ":Telescope harpoon marks<cr>", desc = "Search Harpoon Marks" }
    }
  },
  {
    "mbbill/undotree",
    cmd = { "UndotreeToggle", "UndotreeShow", "UndotreeFocus" },
    keys = {
      { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "UndoTree" }
    },
    config = function()
      vim.g.undotree_ShortIndicators = 1
      vim.g.undotree_SplitWidth = 30
    end
  },
  {
    "nvim-pack/nvim-spectre",
    cmd = { "Spectre" },
    config = function()
      require('spectre').setup({
        default = { find = { options = {} } }
      })
    end,
    keys = {
      { "<leader>ss", ":Spectre<cr>", desc = "Open Spectre" }
    }
  },
  { 'sindrets/diffview.nvim', dependencies = 'nvim-lua/plenary.nvim' },
  {
    "karb94/neoscroll.nvim",
    event = "WinScrolled",
    config = function()
      require('neoscroll').setup({
        -- All these keys will be mapped to their corresponding default scrolling animation
        mappings = { '<C-u>', '<C-d>', '<C-b>', '<C-f>',
          '<C-y>', '<C-e>', 'zt', 'zz', 'zb' },
        hide_cursor = true,          -- Hide cursor while scrolling
        stop_eof = true,             -- Stop at <EOF> when scrolling downwards
        use_local_scrolloff = false, -- Use the local scope of scrolloff instead of the global scope
        respect_scrolloff = false,   -- Stop scrolling when the cursor reaches the scrolloff margin of the file
        cursor_scrolls_alone = true, -- The cursor will keep on scrolling even if the window cannot scroll further
        easing_function = nil,       -- Default easing function
        pre_hook = nil,              -- Function to run before the scrolling animation starts
        post_hook = nil,             -- Function to run after the scrolling animation ends
      })
    end
  },
  -- {
  --   "f3fora/cmp-spell",
  --   dependencies = {
  --     "hrsh7th/nvim-cmp"
  --   },
  -- },
  {
    "monaqa/dial.nvim",
    keys = {
      { "<C-a>",  function() require("dial.map").inc_normal() end,  mode = "n", desc = "Increase" },
      { "<C-x>",  function() require("dial.map").dec_normal() end,  mode = "n", desc = "Decrease" },
      { "g<C-a>", function() require("dial.map").inc_gnormal() end, mode = "n", desc = "Group Increase" },
      { "g<C-x>", function() require("dial.map").dec_gnormal() end, mode = "n", desc = "Group Decrease" },
      { "<C-a>",  function() require("dial.map").inc_visual() end,  mode = "v", desc = "Increase" },
      { "<C-x>",  function() require("dial.map").dec_visual() end,  mode = "v", desc = "Decrease" },
      { "g<C-a>", function() require("dial.map").inc_gvisual() end, mode = "v", desc = "Group Increase" },
      { "g<C-x>", function() require("dial.map").dec_gvisual() end, mode = "v", desc = "Group Decrease" },
    },
    config = function()
      local augend = require("dial.augend")
      local create_date_format = function(pattern)
        return augend.date.new {
          pattern = pattern,
          default_kind = "day",
          only_valid = true,
        }
      end
      require("dial.config").augends:register_group {
        default = {
          augend.integer.alias.decimal_int,
          augend.integer.alias.hex,
          augend.integer.alias.octal,
          augend.integer.alias.binary,
          augend.date.alias["%Y/%m/%d"],
          augend.date.alias["%Y-%m-%d"],
          augend.date.alias["%m/%d/%y"],
          augend.date.alias["%m/%d"],
          augend.date.alias["%-m/%-d"],
          augend.date.alias["%H:%M"],
          augend.date.alias["%H:%M:%S"],
          create_date_format("%a"),
          create_date_format("%A"),
          create_date_format("%b"),
          create_date_format("%B"),
          create_date_format("%p"),
          augend.constant.alias.bool,
          augend.constant.alias.alpha,
          augend.constant.alias.Alpha,
          augend.constant.alias.semver,
        }
      }
    end
  },
  {
    "nvim-telescope/telescope-ui-select.nvim",
    config = function()
      require("telescope").load_extension("ui-select")
    end
  },
}


-- table.insert(lvim.builtin.cmp.sources, {
--   name = 'spell',
--   option = {
--     keep_all_entries = false,
--     enable_in_context = function()
--       return require('cmp.config.context').in_treesitter_capture('spell')
--     end,
--   },
-- })


local cmp = require("cmp")
local comp_cmp_ok, comp_cmp = pcall(require, "copilot_cmp.comparators")
local comp_clangd_ok, comp_clangd = pcall(require, "clangd_extensions.cmp_scores")
lvim.builtin.cmp.sorting = {
  comparators = {
    comp_cmp_ok and comp_cmp.prioritize or nil,
    cmp.config.compare.offset,
    cmp.config.compare.exact,
    comp_clangd_ok and comp_clangd or nil,
    cmp.config.compare.recently_used,
    cmp.config.compare.kind,
    cmp.config.compare.sort_text,
    cmp.config.compare.length,
    cmp.config.compare.order,
  }
}

lvim.builtin.which_key.mappings["sw"] = {
  ":Telescope grep_string<CR>", "Search Word"
}
lvim.builtin.which_key.vmappings["s"] = {
  "\"zy:Telescope live_grep default_text=<c-r>z<cr>", "Search Text"
}

lvim.builtin.which_key.mappings["E"] = {
  "<cmd>NvimTreeFocus<CR>", "Focus to Explorer"
}

lvim.builtin.which_key.vmappings["r"] = { name = "Refactoring" }
lvim.builtin.which_key.mappings["r"] = {
  name = "Refactoring",
  ["n"] = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" }
}

local wk = require("which-key")
wk.register({
  ["[b"] = { "<cmd>BufferLineCyclePrev<cr>", "Previous Buffer" },
  ["]b"] = { "<cmd>BufferLineCycleNext<cr>", "Next Buffer" },
  ["[t"] = { "<cmd>tabprevious<cr>", "Previous Tab" },
  ["]t"] = { "<cmd>tabnext<cr>", "Next Tab" },
})


-- vim.api.nvim_create_augroup("lvim_user", {})
-- lvim.autocommands = {
--   {
--     "BufWinEnter", {
--     pattern = { "*.cpp", "*.hpp", "*.c", "*.h" },
--     command = "setlocal tabstop=4 shiftwidth=4"
--   },
--   }
-- }


-- lvim.builtin.which_key.mappings["s"] = {
--   function()
--     local text
--   end,
--   "Find Current Word"
-- }

-- -- Autocommands (`:help autocmd`) <https://neovim.io/doc/user/autocmd.html>
-- vim.api.nvim_create_autocmd("FileType", {
--   pattern = "zsh",
--   callback = function()
--     -- let treesitter use bash highlight for zsh files as well
--     require("nvim-treesitter.highlight").attach(0, "bash")
--   end,
-- })
-- aa
--
--
