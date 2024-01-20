-- see ~/.local/share/nvim/lazy/LazyVim/lua/lazyvim/plugins/extras/lang/clangd.lua

return {
  {
    "Badhi/nvim-treesitter-cpp-tools",
    cmd = { "TsCppDefineClassFunc", "TSCppMakeConcreteClass", "TSCppRuleOf3", "TSCppRuleOf5" },
    ft = { "cpp", "c", "h", "hpp", "cxx" },
    dependencies = {
      { "nvim-treesitter/nvim-treesitter" },
    },
    config = function()
      require("nt-cpp-tools").setup({
        preview = {
          quit = "q", -- optional keymapping for quit preview
          accept = "<tab>", -- optional keymapping for accept preview
        },
        header_extension = "h", -- optional
        source_extension = "cpp", -- optional
        custom_define_class_function_commands = {
          -- optional
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
      })
      vim.keymap.set("x", "<leader>rd", ":TsCppDefineClassFunc<cr>", { desc = "Define Class Functions" })
      vim.keymap.set("x", "<leader>rc", ":TSCppMakeConcreteClass<cr>", { desc = "Make Concrete Class" })
      vim.keymap.set("x", "<leader>r3", ":TSCppRuleOf3<cr>", { desc = "Make To Obey Rule of Three" })
      vim.keymap.set("x", "<leader>r5", ":TSCppRuleOf5<cr>", { desc = "Make To Obey Rule of Five" })
    end,
  },
  {
    "p00f/clangd_extensions.nvim",
    command = { "ClangdMemoryUsage", "ClangdTypeHierarchy", "ClangdSymbolInfo", "ClangdAST" },
    config = function()
      require("clangd_extensions").setup({
        memory_usage = { border = "rounded" },
        symbol_info = { border = "rounded" },
      })

      vim.keymap.set("n", "<leader>cm", ":ClangdMemoryUsage<cr>", { desc = "Show Clangd Memory Usage (Clangd)" })
      vim.keymap.set("n", "<leader>ch", ":ClangdTypeHierarchy<cr>", { desc = "Type Hierachy (Clangd)" })
      vim.keymap.set("n", "<leader>co", ":ClangdSymbolInfo<cr>", { desc = "Symbol Info (Clangd)" })
      vim.keymap.set({ "n", "x" }, "<leader>cT", ":ClangdAST<cr>", { desc = "AST (Clangd)" })
    end,
    ft = { "cpp", "c", "h", "hpp", "cxx" },
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    opts = {
      config = {
        cpp = "// %s",
      },
    },
  },
  -- {
  --   "folke/which-key.nvim",
  --   opts = {
  --     defaults = {
  --       ["<leader>C"] = { name = "+Clangd Extensions" },
  --     },
  --   },
  -- },
}
