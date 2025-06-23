-- Basic settings
vim.opt.number = true          -- Show line numbers
vim.opt.relativenumber = true  -- Relative line numbers
vim.opt.expandtab = true       -- Use spaces instead of tabs
vim.opt.shiftwidth = 2         -- Indent size
vim.opt.tabstop = 2            -- Tab size
vim.opt.smartindent = true     -- Auto indent
vim.opt.termguicolors = true   -- Enable true color support

-- Set leader key
vim.g.mapleader = " "

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable",
    "https://github.com/folke/lazy.nvim.git",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
vim.opt.clipboard = "unnamedplus"

-- Plugins with lazy.nvim
require("lazy").setup({
  -- Core dependencies
  { "nvim-lua/plenary.nvim" },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "go", "gomod", "gowork", "gosum" } },
  },
  {
    'bettervim/yugen.nvim',
    config = function()
        vim.cmd.colorscheme('yugen')
    end,
  },
  -- LSP Support
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Common `on_attach` function for all LSP servers
      local on_attach = function(client, bufnr)
        local buf_map = function(mode, lhs, rhs, opts)
          opts = vim.tbl_extend("force", { noremap = true, silent = true }, opts or {})
          vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
        end

        -- LSP keybindings
        buf_map("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
        buf_map("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
        buf_map("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>")
        buf_map("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")
        buf_map("n", "[d", "<cmd>lua vim.diagnostic.goto_prev()<CR>")
        buf_map("n", "]d", "<cmd>lua vim.diagnostic.goto_next()<CR>")

        -- Autoformat on save (if supported by the LSP server)
        if client.server_capabilities.documentFormattingProvider then
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ async = false })
            end,
          })
        end
      end

      -- Configuration for C++ (`clangd`)
      lspconfig.clangd.setup({
        capabilities = capabilities,
        on_attach = on_attach,
      })

      -- Configuration for Go (`gopls`)
      lspconfig.gopls.setup({
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          gopls = {
            gofumpt = true, -- Use `gofumpt` for formatting
            staticcheck = true, -- Enable additional checks
            analyses = {
              unusedparams = true, -- Warn about unused parameters
            },
          },
        },
      })
    end,
  },
-- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = {
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        },
        sources = {
          { name = "nvim_lsp" },
        },
      })
    end,
  },
  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup()
    end,
  },
  {
    "crispgm/nvim-go",
    config = function()
      require("go").setup({
        lint_prompt_style = "float", -- Show lint errors in a floating window
      })
    end,
  },
})

-- Keybindings for convenience
vim.api.nvim_set_keymap('n', '<leader>ff', ':Telescope find_files<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>fg', ':Telescope live_grep<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>y', '"+y', { noremap = true, silent = true }) -- Yank selected text to clipboard
vim.api.nvim_set_keymap('v', '<leader>y', '"+y', { noremap = true, silent = true }) -- Yank visual selection to clipboard
vim.api.nvim_set_keymap('n', '<leader>Y', 'gg"+yG', { noremap = true, silent = true }) -- Yank entire file to clipboard
vim.api.nvim_set_keymap('n', '<leader>fs', ':Telescope lsp_document_symbols<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ff', ':Telescope find_files<CR>', { noremap = true, silent = true })
