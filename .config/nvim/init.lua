require("keybindings")
require("config.lazy")

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.python3_host_prog = '/usr/bin/python3'
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
vim.opt.cinoptions = 'g1,l1,h1,N-s,>2'
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.smarttab = true
vim.opt.softtabstop = 2
vim.opt.tabstop = 2
vim.opt.previewheight = 20
vim.opt.termguicolors = true
vim.opt.ruler = true
vim.opt.mouse = 'a'
vim.opt.clipboard = 'unnamedplus'
vim.opt.updatetime = 300
vim.opt.undolevels = 1000
vim.opt.backspace = 'indent,eol,start'
vim.opt.hidden = true
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.cmdheight = 0
vim.opt.colorcolumn = '80'
vim.opt.shortmess = 'ostTAcCWFSI'
vim.opt.timeoutlen = 250
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.background = 'light'
vim.opt.scrolloff = 4
vim.o.showtabline = 2

vim.cmd('highlight LineNr ctermfg=blue')
vim.cmd('highlight MsgArea guibg=#edeada guifg=#5c6a72')

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

function tmux_copy(reg)
  local clipboard = reg == '+' and 'c' or 'p'
  return function(lines)
    local s = table.concat(lines, '\n')
    vim.api.nvim_chan_send(2, osc52(clipboard, vim.base64.encode(s)))
  end
end

if (os.getenv("SSH_TTY") ~= nil) or (os.getenv("NVIM_SSH_OVERRIDE") ~= nil) then
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
            "'+': ['wl-paste', '-n']," ..
            "'*': ['wl-paste', '-n']," ..
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
end

local function update_wayland_display()
  --if os.getenv("ZELLIJ") ~= nil and os.getenv("SSH_TTY") ~= nil then
  if vim.env.ZELLIJ ~= nil then
    local file = io.open("/tmp/wayland_display", "r")
    if file then
      local wayland_display = file:read("*l")
      file:close()
      if wayland_display then
        vim.env.WAYLAND_DISPLAY = wayland_display
        --print(wayland_display)
      end
    else
      -- Handle the case where the file can't be opened.
      -- For example, you might print an error message or do nothing.
      print("Error: Could not open /tmp/wayland_display")
    end
  end
end

vim.api.nvim_create_autocmd({'BufEnter', 'FocusGained'}, {
  desc = 'update wayland display envvar',
  pattern = '*',
  callback = update_wayland_display,
})

vim.api.nvim_create_autocmd({'BufWinEnter'}, {
  desc = 'return cursor to where it was last time closing the file',
  pattern = '*',
  command = 'silent! normal! g`"zv',
})

require('config.everforest')
require('everforest').load()
require('toggle_lsp_diagnostics').init({ start_on = false })
require('config.lualine')
require('config.toggleterm')
require('config.nvim-web-devicons')
require("ibl").setup()
require'nvim-treesitter.configs'.setup {
  -- A list of parser names, or "all" (the listed parsers MUST always be installed)
  ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },

  -- Install parsers synchronously (only applied to `ensure_installed`)
  sync_install = false,

  -- Automatically install missing parsers when entering buffer
  -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
  auto_install = true,

  -- List of parsers to ignore installing (or "all")
  ignore_install = { "javascript" },

  ---- If you need to change the installation directory of the parsers (see -> Advanced Setup)
  -- parser_install_dir = "/some/path/to/store/parsers", -- Remember to run vim.opt.runtimepath:append("/some/path/to/store/parsers")!

  highlight = {
    enable = true,

    -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
    -- disable highlighting for the `tex` filetype, you need to include `latex` in this list as this is
    -- the name of the parser)
    -- list of language that will be disabled
    --disable = { "c", "rust" },
    -- Or use a function for more flexibility, e.g. to disable slow treesitter highlight for large files
    disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
            return true
        end
    end,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },
}
require('treesitter-context').setup{
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 3, -- How many lines the window should span. Values <= 0 mean no limit.
  min_window_height = 20, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
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
require("spider").setup {
  skipInsignificantPunctuation = false,
  consistentOperatorPending = false,
  subwordMovement = true,
  customPatterns = {},
}

local cmp = require('cmp')

cmp.setup({
  enabled = function()
    -- disable completion in comments
    local context = require 'cmp.config.context'
    -- keep command mode completion enabled when cursor is in a comment
    if vim.api.nvim_get_mode().mode == 'c' then
      return true
    else
      return not context.in_treesitter_capture("comment")
        and not context.in_syntax_group("Comment")
    end
  end,
  view = {
    entries = {name = 'custom', selection_order = 'near_cursor' }
  },
  window = {
    completion = {
      winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,Search:None",
      col_offset = -3,
      side_padding = 0,
    },
  },
  formatting = {
    fields = { "kind", "abbr", "menu" },
    format = function(entry, vim_item)
      local kind = require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)
      local strings = vim.split(kind.kind, "%s", { trimempty = true })
      kind.kind = " " .. (strings[1] or "") .. " "
      return kind
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { "i", "s" }),
    ['<C-j>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { "i", "s" }),
    ['<C-k>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    --{ name = 'rg' },
  }, {
    { name = 'buffer' },
  })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({'/', '?'}, {
  mapping = cmp.mapping.preset.cmdline({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<C-j>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { "i", "s" }),
    ['<C-k>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
  sources = cmp.config.sources({
    { name = 'nvim_lsp_document_symbol' }
  }, {
    { name = 'buffer' }
  })
})

require('mason').setup({
  PATH = "append"
})

-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()
--require('lspconfig').clangd.setup{}
require('lspconfig').clangd.setup{
  capabilities = capabilities,
  cmd = { "/usr/local/google/home/shined/pigweed/environment/cipd/packages/pigweed/bin/clangd", "--compile-commands-dir=/usr/local/google/home/shined/pigweed/.pw_ide/.stable", "--background-index", "--clang-tidy", "--query-driver=/usr/local/google/home/shined/pigweed/environment/cipd/packages/pigweed/bin/*,/usr/local/google/home/shined/pigweed/environment/cipd/packages/arm/bin/*"}
}

local theme = {
  fill = 'TabLineFill',
  head = 'TabLineSep',
  sep = 'TabLineSep',
  tabsep = 'TabLineTabSep',
  current_tab = 'TabLineCurrent',
  inactive_tab = 'TabLineInactive',
  inactive_tab_sep = 'TabLineInactiveSep',
  tab = 'TabLine',
  win = 'TabLine',
  tail = 'TabLineSep',
}
require('tabby').setup({
  line = function(line)
    return {
      {
        { '', hl = theme.head },
        { ' ', hl = theme.fill },
      },
      line.tabs().foreach(function(tab)
        if tab.is_current() then
          return {
            line.sep('', theme.tabsep, theme.current_tab),
            tab.in_jump_mode() and tab.jump_key() or tab.number(),
            tab.name(),
            line.sep('', theme.tabsep, theme.current_tab),
            hl = theme.current_tab,
            margin = ' ',
          }
        else
          return {
            line.sep('', theme.inactive_tab, theme.inactive_tab_sep),
            tab.in_jump_mode() and tab.jump_key() or tab.number(),
            tab.name(),
            line.sep('', theme.inactive_tab, theme.inactive_tab_sep),
            hl = theme.inactive_tab,
            margin = ' ',
          }
        end
      end),
      line.spacer(),
      line.wins_in_tab(line.api.get_current_tab()).foreach(function(win)
        if win.is_current() then
          return {
            line.sep('', theme.tabsep, theme.current_tab),
            win.buf_name(),
            line.sep('', theme.tabsep, theme.current_tab),
            hl = theme.current_tab,
            margin = ' ',
          }
        else
          return {
            line.sep('', theme.inactive_tab, theme.inactive_tab_sep),
            win.buf_name(),
            line.sep('', theme.inactive_tab, theme.inactive_tab_sep),
            hl = theme.inactive_tab,
            margin = ' ',
          }
        end
      end),
      {
        { ' ', hl = theme.fill },
        { '', hl = theme.head },
      },
      hl = theme.fill,
    }
  end,
  -- option = {}, -- setup modules' option,
})

require('mini.diff').setup()

require("codecompanion").setup({
  strategies = {
    chat = {
      adapter = "gemini",
      keymaps = {
        hide = {
          modes = {
            n = "}"
          },
          callback = function(chat)
            chat.ui:hide()
          end,
          description = "Hide the chat buffer",
        }
      },
    },
    inline = {
      adapter = "gemini",
    },
  },
  display = {
    action_palette = {
      provider = "telescope"
    },
    diff = {
      provider = "mini_diff",
    },
  },
  opts = {
    --log_level = "TRACE",
  },
  adapters = {
    anthropic = function()
      return require("codecompanion.adapters").extend("anthropic", {
        schema = {
          model = {
            default = "claude-3-opus-latest",
          },
        },
        env = {
          api_key = "cmd:cat ~/.anthropic",
        },
      })
    end,
    gemini = function()
      return require("codecompanion.adapters").extend("gemini", {
        schema = {
          model = {
            --default = "gemini-2.0-flash-exp",
            default = "gemini-1.5-pro"
          },
        },
        env = {
          api_key = "cmd:cat ~/.gemini",
        },
        --handlers = {
        --  form_parameters = function(self, params, messages)
        --    return {
        --      tools = {google_search = {}}
        --    }
        --  end,
        --}
      })
    end,
  },
})

vim.cmd([[cab cc CodeCompanion]])

require("focus").setup({
    enable = true, -- Enable module
    commands = false, -- Create Focus commands
    autoresize = {
        enable = true, -- Enable or disable auto-resizing of splits
        width = 0, -- Force width for the focused window
        height = 0, -- Force height for the focused window
        minwidth = 20, -- Force minimum width for the unfocused window
        minheight = 0, -- Force minimum height for the unfocused window
        height_quickfix = 10, -- Set the height of quickfix panel
    },
    split = {
        bufnew = false, -- Create blank buffer for new split windows
        tmux = false, -- Create tmux splits instead of neovim splits
    },
    ui = {
        number = false, -- Display line numbers in the focussed window only
        relativenumber = false, -- Display relative line numbers in the focussed window only
        hybridnumber = false, -- Display hybrid line numbers in the focussed window only
        absolutenumber_unfocussed = false, -- Preserve absolute numbers in the unfocussed windows

        cursorline = false, -- Display a cursorline in the focussed window only
        cursorcolumn = false, -- Display cursorcolumn in the focussed window only
        colorcolumn = {
            enable = false, -- Display colorcolumn in the foccused window only
            list = '+1', -- Set the comma-saperated list for the colorcolumn
        },
        signcolumn = true, -- Display signcolumn in the focussed window only
        winhighlight = false, -- Auto highlighting for focussed/unfocussed windows
    }
})

local ignore_filetypes = { 'NvimTree' }
local ignore_buftypes = { 'nofile', 'prompt', 'popup' }

local augroup =
    vim.api.nvim_create_augroup('FocusDisable', { clear = true })

vim.api.nvim_create_autocmd('WinEnter', {
    group = augroup,
    callback = function(_)
        if vim.tbl_contains(ignore_buftypes, vim.bo.buftype)
        then
            vim.w.focus_disable = true
        else
            vim.w.focus_disable = false
        end
    end,
    desc = 'Disable focus autoresize for BufType',
})

vim.api.nvim_create_autocmd('FileType', {
    group = augroup,
    callback = function(_)
        if vim.tbl_contains(ignore_filetypes, vim.bo.filetype) then
            vim.b.focus_disable = true
        else
            vim.b.focus_disable = false
        end
    end,
    desc = 'Disable focus autoresize for FileType',
})

require('telescope').setup {
  defaults = {
    mappings = {
      n = {
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
      },
      i = {
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
      }
    },
  },
  pickers = {
    find_files = {
      theme = "dropdown",
    },
    codecompanion = {
      theme = "ivy",
    },
  },
}
require('telescope').load_extension('fzf')

vim.api.nvim_create_autocmd("VimLeave", {
    pattern = "*",
    command = "silent !zellij action switch-mode normal"
})
