--local vimrc = vim.fn.stdpath("config") .. "/vimrc.vim"
--vim.cmd.source(vimrc)

require("keybindings")

require("config.lazy");
require("lazy").setup("plugins")

vim.opt.laststatus = 2
vim.opt.showmode = false
vim.opt.wrap = true
vim.opt.number = true
vim.opt.linebreak = true
vim.opt.showbreak = ''
vim.opt.textwidth = 0
vim.opt.wrapmargin = 0
vim.opt.showmatch = true
vim.opt.list = false
vim.opt.hlsearch = true
vim.opt.smartcase = true
vim.opt.ignorecase = true
vim.opt.incsearch = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.cindent = true
vim.opt.cinkeys = '0{,0},0),0],:,0#,!^F,o,O,e'
vim.opt.cinoptions = 'g1,h1,N-s,>2'
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smarttab = true
vim.opt.softtabstop = 2
vim.opt.tabstop = 4
vim.opt.previewheight = 20
vim.opt.termguicolors = true
vim.opt.ruler = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.updatetime = 300
vim.opt.undolevels = 1000
vim.opt.backspace = 'indent,eol,start'
vim.opt.termguicolors = true
vim.opt.hidden = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.cmdheight = 0
vim.opt.colorcolumn = '80'
vim.opt.shortmess = 'ostTAcCWFSI'
vim.opt.timeoutlen = 20
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.background = 'light'

vim.g.bufferline_echo = 0
vim.g.python3_host_prog = '/usr/bin/python3'

vim.cmd('highlight LineNr ctermfg=blue')
vim.cmd('highlight MsgArea guibg=#edeada guifg=#5c6a72')

function tmux_copy(reg)
  local clipboard = reg == '+' and 'c' or 'p'
  return function(lines)
    local s = table.concat(lines, '\n')
    vim.api.nvim_chan_send(2, osc52(clipboard, vim.base64.encode(s)))
  end
end

if os.getenv("TMUX") ~= nil then
  vim.cmd(
    "let g:clipboard = {" ..
       "'name': 'Tmux Clipboard'," ..
       "'copy': {" ..
          "'+': ['tmux', 'load-buffer', '-w', '-']," ..
          "'*': ['tmux', 'load-buffer', '-']," ..
        "}," ..
       "'paste': {" ..
          "'+': ['tmux', 'save-buffer', '-']," ..
          "'*': ['tmux', 'save-buffer', '-']," ..
       "}," ..
       "'cache_enabled': 1," ..
    "}")
elseif os.getenv("ZELLIJ") ~= nil then
  vim.cmd(
    "let g:clipboard = {" ..
       "'name': 'Zellij Clipboard'," ..
       "'copy': {" ..
          "'+': ['wl-copy', '-p', '--type', 'text/plain']," ..
          "'*': ['wl-copy', '-p', '--type', 'text/plain']," ..
        "}," ..
       "'paste': {" ..
          "'+': ['wl-paste']," ..
          "'*': ['wl-paste']," ..
       "}," ..
       "'cache_enabled': 1," ..
    "}")
  vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        local copy_to_unnamedplus = require('vim.ui.clipboard.osc52').copy('+')
        copy_to_unnamedplus(vim.v.event.regcontents)
        local copy_to_unnamed = require('vim.ui.clipboard.osc52').copy('*')
        copy_to_unnamed(vim.v.event.regcontents)
    end
  })
else
  if pcall(require, 'vim.ui.clipboard.osc52') then
    vim.g.clipboard = {
      name = 'OSC 52',
      copy = {
        ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
        ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
      },
      paste = {
        ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
        ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
      },
    }
  end
end

vim.api.nvim_create_autocmd({'BufWinEnter'}, {
  desc = 'return cursor to where it was last time closing the file',
  pattern = '*',
  command = 'silent! normal! g`"zv',
})

require('mason').setup()
require('lspconfig').clangd.setup{}
require('toggle_lsp_diagnostics').init({ start_on = false })
require('config.lualine')
require('config.toggleterm')
require('config.nvim-web-devicons')
require('config.everforest')
require('everforest').load()
require("ibl").setup()
require('treesitter-context').setup{
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 3, -- How many lines the window should span. Values <= 0 mean no limit.
  min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
  line_numbers = true,
  multiline_threshold = 20, -- Maximum number of lines to show for a single context
  trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  mode = 'cursor',  -- Line used to calculate context. Choices: 'cursor', 'topline'
  -- Separator between context and content. Should be a single character string, like '-'.
  -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
  separator = nil,
  zindex = 20, -- The Z-index of the context window
  on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
}
require('notify').setup({
    fps = 24,
    render = "compact",
    max_width = 80,
    minimum_width = 10,
    stages = "fade",
    timeout = 300,
})
require('noice').setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
    },
  },
  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = true, -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = false, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false, -- add a border to hover docs and signature help
  },
  cmdline = {
    view = "cmdline",
  },
  routes = {
    {
      filter = {
        event = "msg_show",
        kind = "",
      },
      opts = { skip = true },
    },
    {
      filter = {
        event = "msg_show",
        find = "Pattern not found",
      },
      opts = { skip = true },
    },
    {
      filter = {
        event = "msg_show",
        kind = "search_count",
      },
      opts = { skip = true },
    },
  },
})
require('trim').setup({
  -- if you want to ignore markdown file.
  -- you can specify filetypes.
  ft_blocklist = {"markdown"},

  patterns = {},

  -- if you want to disable trim on write by default
  trim_on_write = true,

  -- highlight trailing spaces
  highlight = false,
  highlight_bg = '#ffe7de',
  highlight_ctermbg = 'red',
})
require('deadcolumn').setup({
    scope = 'line', ---@type string|fun(): integer
    ---@type string[]|fun(mode: string): boolean
    modes = function(mode)
        return mode:find('^[ictRss\x13]') ~= nil
    end,
    blending = {
        threshold = 0.75,
        colorcode = '#fffbef',
        hlgroup = { 'Normal', 'bg' },
    },
    warning = {
        alpha = 0.4,
        offset = 0,
        colorcode = '#bec5b2',
        hlgroup = { 'Error', 'bg' },
    },
    extra = {
        ---@type string?
        follow_tw = nil,
    },
})

local cmp = require('cmp')

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  view = {
    entries = {name = 'custom', selection_order = 'near_cursor' }
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-j>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.locally_jumpable(1) then
        luasnip.jump(1)
      else
        fallback()
      end
    end, { "i", "s" }),
    ['<C-k>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
  })
})

-- To use git you need to install the plugin petertriho/cmp-git and uncomment lines below
-- Set configuration for specific filetype.
--[[ cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'git' },
  }, {
    { name = 'buffer' },
  })
})
require("cmp_git").setup() ]]--

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  }),
  matching = { disallow_symbol_nonprefix_matching = false }
})

-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()
require('lspconfig')['clangd'].setup {
  capabilities = capabilities
}

-- gray
vim.api.nvim_set_hl(0, 'CmpItemAbbrDeprecated', { bg='NONE', strikethrough=true, fg='#808080' })
-- blue
vim.api.nvim_set_hl(0, 'CmpItemAbbrMatch', { bg='NONE', fg='#569CD6' })
vim.api.nvim_set_hl(0, 'CmpItemAbbrMatchFuzzy', { link='CmpIntemAbbrMatch' })
-- light blue
vim.api.nvim_set_hl(0, 'CmpItemKindVariable', { bg='NONE', fg='#9CDCFE' })
vim.api.nvim_set_hl(0, 'CmpItemKindInterface', { link='CmpItemKindVariable' })
vim.api.nvim_set_hl(0, 'CmpItemKindText', { link='CmpItemKindVariable' })
-- pink
vim.api.nvim_set_hl(0, 'CmpItemKindFunction', { bg='NONE', fg='#C586C0' })
vim.api.nvim_set_hl(0, 'CmpItemKindMethod', { link='CmpItemKindFunction' })
-- front
vim.api.nvim_set_hl(0, 'CmpItemKindKeyword', { bg='NONE', fg='#D4D4D4' })
vim.api.nvim_set_hl(0, 'CmpItemKindProperty', { link='CmpItemKindKeyword' })
vim.api.nvim_set_hl(0, 'CmpItemKindUnit', { link='CmpItemKindKeyword' })
