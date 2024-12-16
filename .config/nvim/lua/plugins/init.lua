return {
  { 'ibhagwan/fzf-lua', branch='main' },
  { 'tpope/vim-commentary' },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
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
    -- event = 'VimEnter', -- if you want lazy load, see below
    dependencies = 'nvim-tree/nvim-web-devicons',
    config = function()
      -- configs...
    end,
  },
  { 'nvim-lualine/lualine.nvim' },
  { 'nvim-tree/nvim-web-devicons' },
  { 'neanias/everforest-nvim',
    version = false,
    lazy = false,
    priority = 1000, -- make sure to load this before all the other start plugins
    -- Optional; default configuration will be used if setup isn't called.
    config = function()
      require("everforest").setup({
        -- Your config here
      })
    end,
  },
  { 'tpope/vim-fugitive' },
  { 'tpope/vim-sleuth' },
  { 'lewis6991/gitsigns.nvim' },
  { 'bfrg/vim-cpp-modern' },
  { 'szw/vim-maximizer' },
  { 'Shougo/echodoc.vim' },
  { 'nvim-treesitter/nvim-treesitter', build=':TSUpdate' },
  { 'nvim-treesitter/nvim-treesitter-context' },
  { 'folke/noice.nvim' },
  { 'MunifTanjim/nui.nvim' },
  { 'rcarriga/nvim-notify' },
  { 'williamboman/mason.nvim' },
  { 'williamboman/mason-lspconfig.nvim' },
  { 'neovim/nvim-lspconfig' },
  { 'WhoIsSethDaniel/toggle-lsp-diagnostics.nvim' },
  { 'sindrets/diffview.nvim' },
  { 'cappyzawa/trim.nvim', opts = {} },
  { 'Bekaboo/deadcolumn.nvim' },
  { 'hrsh7th/nvim-cmp' },
  { 'hrsh7th/cmp-nvim-lsp' },
  { 'saadparwaiz1/cmp_luasnip' },
  { 'lukas-reineke/cmp-rg' },
  { 'hrsh7th/cmp-buffer' },
  { 'hrsh7th/cmp-nvim-lsp-document-symbol' },
  { 'onsails/lspkind.nvim' },
  { 'L3MON4D3/LuaSnip' },
  { 'chrisgrieser/nvim-spider' },
  { 'declancm/maximize.nvim', lazy = true, config = true },
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = true
  },
  { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
  {
    "https://git.sr.ht/~swaits/zellij-nav.nvim",
    lazy = true,
    event = "VeryLazy",
    keys = {
      { "<A-h>", "<cmd>ZellijNavigateLeftTab<cr>",  { silent = true, desc = "navigate left or tab"  } },
      { "<A-j>", "<cmd>ZellijNavigateDown<cr>",  { silent = true, desc = "navigate down"  } },
      { "<A-k>", "<cmd>ZellijNavigateUp<cr>",    { silent = true, desc = "navigate up"    } },
      { "<A-l>", "<cmd>ZellijNavigateRightTab<cr>", { silent = true, desc = "navigate right or tab" } },
    },
    opts = {},
  },
  { 'nvim-focus/focus.nvim', version = false },
  {'akinsho/toggleterm.nvim', version = "*", config = true}
}
