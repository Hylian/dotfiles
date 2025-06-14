return {
  { 'junegunn/fzf.vim' },
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
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
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
    --dir = "~/software/codecompanion.nvim",

    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = true
  },
  { "MeanderingProgrammer/render-markdown.nvim", ft = { "markdown", "codecompanion" } },
  {
    'https://github.com/fresh2dev/zellij.vim',
    -- tag = '0.3.*',
    lazy = false,
    init = function()
      vim.g.zellij_navigator_no_default_mappings = 1
    end,
  },
  { 'nvim-focus/focus.nvim', version = false },
  {'akinsho/toggleterm.nvim', version = "*", config = true},
  --{ 'nvim-telescope/telescope-fzf-native.nvim', build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release' },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  { 'nvim-telescope/telescope.nvim', tag = '0.1.8', dependencies = { 'nvim-lua/plenary.nvim' } },
  { 'echasnovski/mini.nvim', version = '*' },
  {
    'MagicDuck/grug-far.nvim',
    config = function()
      require('grug-far').setup({
        engine = 'rg'
      });
    end
  },
}
