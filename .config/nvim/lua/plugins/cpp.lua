return {
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd-18",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            -- "--log=verbose",
            "-j=8",
          },
        },
      },
      handlers = {
        clangd = function(server, opts)
          vim.opt_local.shiftwidth = 4
          vim.opt_local.tabstop = 4
          require("lspconfig")[server].setup(opts)
        end,
      },
    },
  },
  {
    "Badhi/nvim-treesitter-cpp-tools",
    cmd = { "TsCppDefineClassFunc", "TSCppMakeConcreteClass", "TSCppRuleOf3", "TSCppRuleOf5" },
    -- ft = { "cpp", "c", "h", "hpp", "cxx" },
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
    },
    opts = function()
      return {
        preview = {
          quit = "q", -- optional keymapping for quit preview
          accept = "<tab>", -- optional keymapping for accept preview
        },
        header_extension = { "h", "hpp" }, -- optional
        source_extension = "cpp", -- optional
        custom_define_class_function_commands = { -- optional
          TSCppImplWrite = {
            output_handle = require("nt-cpp-tools.output_handlers").get_add_to_cpp(),
          },
          --[[
                <your impl function custom command name> = {
                    output_handle = function (str, context)
                        -- string contains the class implementation
                        -- do whatever you want to do with it
                    end
                }
                ]]
        },
      }
    end,
    config = true,
    keys = {
      { "<leader>rD", ":TSCppDefineClassFunc<cr>", mode = "x", desc = "Define Class Functions (C++)" },
      { "<leader>rC", ":TSCppMakeConcreteClass<cr>", mode = "x", desc = "Make Concrete Class (C++)" },
      { "<leader>r3", ":TSCppRuleOf3<cr>", mode = "x", desc = "Make To Obey Rule of Three (C++)" },
      { "<leader>r5", ":TSCppRuleOf5<cr>", mode = "x", desc = "Make To Obey Rule of Five (C++)" },
    },
  },
  {
    "p00f/clangd_extensions.nvim",
    config = function()
      require("clangd_extensions").setup {
        memory_usage = { border = "rounded" },
        symbol_info = { border = "rounded" },
      }
    end,
    keys = {
      { "<leader>lH", ":ClangdTypeHierarchy<cr>", mode = "n", desc = "Type Hierachy (Clangd)" },
      { "<leader>lT", ":ClangdAST<cr>", mode = { "n", "x" }, desc = "AST (Clangd)" },
    },
    --   ft = { "cpp", "c", "h", "hpp", "cxx" },
  },
}
