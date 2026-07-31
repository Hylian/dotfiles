return {
  { 'junegunn/fzf.vim', event = "VeryLazy" },
  {
    'ibhagwan/fzf-lua',
    branch = 'main',
    event = "VeryLazy",
    config = function()
      require('config.fzf-lua')
    end,
  },
  { 'tpope/vim-commentary', event = "VeryLazy" },
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup {
        view = {
          width = 30,
        },
      }
    end,
  },
  {
    'nanozuki/tabby.nvim',
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      -- configs...
    end,
  },
  { 'nvim-lualine/lualine.nvim' },
  { 'nvim-tree/nvim-web-devicons' },
  {
    'neanias/everforest-nvim',
    version = false,
    lazy = false,
    priority = 1000, -- make sure to load this before all the other start plugins
    config = function()
      require("everforest").setup({
        -- Your config here
      })
    end,
  },
  { 'tpope/vim-fugitive', event = "VeryLazy" },
  { 'tpope/vim-sleuth', event = { "BufReadPost", "BufNewFile" } },
  {
    'lewis6991/gitsigns.nvim',
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require('config.gitsigns')
    end,
  },
  { 'bfrg/vim-cpp-modern', event = { "BufReadPost", "BufNewFile" } },
  { 'szw/vim-maximizer', event = "VeryLazy" },
  { 'Shougo/echodoc.vim', event = "VeryLazy" },
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    lazy = false,
    build = ':TSUpdate',
  },
  { 'nvim-treesitter/nvim-treesitter-context' },
  {
    'rcarriga/nvim-notify',
    opts = {
      fps = 26,
      render = "minimal",
      max_width = 20,
      minimum_width = 10,
      stages = "fade",
      timeout = 200,
    }
  },
  {
    'folke/noice.nvim',
    event = "VeryLazy",
    opts = {
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
    },
    dependencies = {
      'MunifTanjim/nui.nvim',
      'rcarriga/nvim-notify',
    }
  },
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },
  { 'neovim/nvim-lspconfig' },
  { 'WhoIsSethDaniel/toggle-lsp-diagnostics.nvim' },
  { 'sindrets/diffview.nvim', cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" } },
  {
    'cappyzawa/trim.nvim',
    event = "BufWritePre",
    config = function()
      require('config.trim')
    end,
  },
  {
    'Bekaboo/deadcolumn.nvim',
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require('config.deadcolumn')
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = {
      'hrsh7th/cmp-nvim-lsp',
      'saadparwaiz1/cmp_luasnip',
      'lukas-reineke/cmp-rg',
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-nvim-lsp-document-symbol',
      'onsails/lspkind.nvim',
      'L3MON4D3/LuaSnip',
    },
    config = function()
      require('config.cmp')
    end,
  },
  {
    'chrisgrieser/nvim-spider',
    keys = {
      { "W", "<cmd>lua require('spider').motion('w')<CR>", mode = { "n", "o", "x" }, desc = "Spider-w" },
      { "E", "<cmd>lua require('spider').motion('e')<CR>", mode = { "n", "o", "x" }, desc = "Spider-e" },
      { "B", "<cmd>lua require('spider').motion('b')<CR>", mode = { "n", "o", "x" }, desc = "Spider-b" },
    },
    config = function()
      require('config.spider')
    end,
  },
  { 'declancm/maximize.nvim', lazy = true, config = true },
  {
    "olimorris/codecompanion.nvim",
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require('config.codecompanion')
    end,
  },
  { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
  {
    'https://github.com/fresh2dev/zellij.vim',
    lazy = false,
    init = function()
      vim.g.zellij_navigator_no_default_mappings = 1
    end,
  },
  {
    'nvim-focus/focus.nvim',
    version = false,
    event = "VeryLazy",
    config = function()
      require('config.focus')
    end,
  },
  {
    'akinsho/toggleterm.nvim',
    version = "*",
    event = "VeryLazy",
    config = function()
      require('config.toggleterm')
    end,
  },
  {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.8',
    cmd = "Telescope",
    dependencies = {
      'nvim-lua/plenary.nvim',
      { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
    },
    config = function()
      require('config.telescope')
    end,
  },
  {
    'echasnovski/mini.nvim',
    version = '*',
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require('mini.diff').setup()
    end,
  },
  {
    'MagicDuck/grug-far.nvim',
    cmd = "GrugFar",
    event = "VeryLazy",
    config = function()
      require('grug-far').setup({
        engine = 'rg'
      });
    end
  },
}
