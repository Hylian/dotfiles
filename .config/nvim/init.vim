call plug#begin('~/.local/share/nvim/plugged')
Plug 'lewis6991/gitsigns.nvim'
Plug 'tpope/vim-fugitive'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'chriskempson/base16-vim'
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'bfrg/vim-cpp-modern'
Plug 'tpope/vim-commentary'
Plug 'akinsho/bufferline.nvim', { 'tag': '*' }
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'antoinemadec/coc-fzf'
if !exists('g:vscode')
  Plug 'feline-nvim/feline.nvim'
  Plug 'bfredl/nvim-miniyank'
  Plug 'szw/vim-maximizer'
  Plug 'Shougo/echodoc.vim'
  Plug 'kyazdani42/nvim-web-devicons'
  Plug 'kyazdani42/nvim-tree.lua'
  Plug 'akinsho/toggleterm.nvim'
  Plug 'neoclide/coc.nvim', {'branch': 'release'}
endif
call plug#end()

set t_Co=256 
set laststatus=2
set noshowmode
set wrap
set number	
set linebreak	
set showbreak=+++
set textwidth=0
set wrapmargin=0
set showmatch	
set nolist
set hlsearch
set smartcase	
set ignorecase	
set incsearch
set autoindent	
set expandtab	
set shiftwidth=2
set smartindent	
set smarttab
set softtabstop=2
set previewheight=20
set termguicolors
set ruler	
set mouse=a
set clipboard=unnamedplus
set updatetime=300
set undolevels=1000	
set backspace=indent,eol,start	
set termguicolors
set hidden
set nobackup
set nowritebackup
set cmdheight=1
set updatetime=300
set colorcolumn=80
set shortmess=aostTA

let g:bufferline_echo = 0
let mapleader = " "

colorscheme base16-default-dark

let &runtimepath.=','.$HOME.'/.config/nvim/bundle/darkhorse.vim'
let g:python3_host_prog = '/usr/bin/python3'
 
highlight LineNr ctermfg=blue

" Automatically strip trailing whitespace
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun
autocmd FileType c,cpp,java,php,ruby,python autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
                  \| exe "normal! g'\"" | endif
endif

" Split settings

nnoremap <A-j> <C-W><C-j>
nnoremap <A-k> <C-W><C-k>
nnoremap <A-l> <C-W><C-l>
nnoremap <A-h> <C-W><C-h>
nnoremap <A-J> <C-W>+
nnoremap <A-K> <C-W>-
nnoremap <A-L> <C-W><
nnoremap <A-H> <C-W>>
nnoremap <A-;> <C-W>=

set splitbelow
set splitright
nnoremap m :MaximizerToggle<CR>

" FZF / CocFzfList Configuration and Keybinds
let g:fzf_preview_window = ['up:50%', 'ctrl-/']
let g:coc_fzf_preview = 'up:50%'

command! -bang -nargs=* Rgc
  \ call fzf#vim#grep(
  \   'rg -tc --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)

function! RipgrepCFzf(query, fullscreen)
  let command_fmt = 'rg -tc --column --line-number --no-heading --color=always --smart-case -- %s || true'
  let initial_command = printf(command_fmt, shellescape(a:query))
  let reload_command = printf(command_fmt, '{q}')
  let spec = {'options': ['--phony', '--query', a:query, '--bind', 'change:reload:'.reload_command]}
  call fzf#vim#grep(initial_command, 1, fzf#vim#with_preview(spec), a:fullscreen)
endfunction

command! -nargs=* -bang RG call RipgrepCFzf(<q-args>, <bang>0)

nmap _ :RG!<CR>
nmap ' :GitFiles!<CR>
nmap <Bar> :History!<CR>
nmap { :CocFzfList symbols<CR>
nmap } :CocFzfList outline<CR>

" Miniyank Keybinds
map p <Plug>(miniyank-startput) 
map P <Plug>(miniyank-startPut)
map <C-n> <Plug>(miniyank-cycle)
map <C-c> <Plug>(miniyank-tochar)
map <C-l> <Plug>(miniyank-toline)
map <C-b> <Plug>(miniyank-toblock)

" Rust language completion
autocmd BufReadPost *.rs setlocal filetype=rust

" Echodoc Configuration
let g:echodoc#enable_at_startup = 1
let g:echodoc#type = 'virtual'

if !exists('g:vscode')
" Coc Configuration
let g:coc_node_path='/usr/bin/node'

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

" Use <c-space> to trigger completion.
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> Gd :call CocActionAsync('jumpDefinition', 'vsplit')<CR>
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> Gi : call CocActionAsync('jumpImplementation', 'vsplit')<CR>
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> Gy : call CocActionAsync('jumpTypeDefinition', 'vsplit')<CR>
nmap <silent> gr <Plug>(coc-references)
nmap <silent> Gr : call CocActionAsync('jumpReferences', 'vsplit')<CR>
nmap <leader>rn <Plug>(coc-rename)

inoremap <expr> <C-j> pumvisible() ? "\<C-N>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-P>" : "\<C-k>"

" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end
endif
" coc configuration end

if !exists('g:vscode')
lua << EOF
require'nvim-web-devicons'.setup {
  default = true;
}
EOF

lua << EOF
require'nvim-tree'.setup {
  auto_reload_on_write = true,
  disable_netrw = true,
  hijack_cursor = true,
  hijack_netrw = true,
  hijack_unnamed_buffer_when_opening = false,
  ignore_buffer_on_setup = false,
  open_on_setup = false,
  open_on_setup_file = false,
  open_on_tab = false,
  sort_by = "name",
  update_cwd = false,
  view = {
    width = 30,
    height = 30,
    hide_root_folder = false,
    side = "left",
    preserve_window_proportions = false,
    number = false,
    relativenumber = false,
    signcolumn = "yes",
    mappings = {
      custom_only = false,
      list = {
        -- user mappings go here
      },
    },
  },
  renderer = {
    indent_markers = {
      enable = false,
      icons = {
        corner = "└ ",
        edge = "│ ",
        none = "  ",
      },
    },
    icons = {
      webdev_colors = true,
      show = {
        git = true,
        folder = true,
        file = true,
        folder_arrow = true
      },
    },
  },
  hijack_directories = {
    enable = true,
    auto_open = false,
  },
  update_focused_file = {
    enable = true,
    update_cwd = false,
    ignore_list = {},
  },
  ignore_ft_on_setup = {},
  system_open = {
    cmd = "",
    args = {},
  },
  diagnostics = {
    enable = false,
    show_on_dirs = false,
    icons = {
      hint = "",
      info = "",
      warning = "",
      error = "",
    },
  },
  filters = {
    dotfiles = false,
    custom = {},
    exclude = {},
  },
  git = {
    enable = true,
    ignore = true,
    timeout = 400,
  },
  actions = {
    use_system_clipboard = true,
    change_dir = {
      enable = true,
      global = false,
      restrict_above_cwd = false,
    },
    open_file = {
      quit_on_open = false,
      resize_window = true,
      window_picker = {
        enable = true,
        chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
        exclude = {
          filetype = { "notify", "packer", "qf", "diff", "fugitive", "fugitiveblame" },
          buftype = { "nofile", "terminal", "help" },
        },
      },
    },
  },
  trash = {
    cmd = "trash",
    require_confirm = true,
  },
  log = {
    enable = false,
    truncate = false,
    types = {
      all = false,
      config = false,
      copy_paste = false,
      diagnostics = false,
      git = false,
      profile = false,
    },
  },
}
EOF

nnoremap <C-n> :NvimTreeToggle<CR>
endif

" Bufferline Config
nnoremap <silent> gb :BufferLinePick<CR>
nnoremap <A-1> <Cmd>BufferLineGoToBuffer 1<CR>
nnoremap <A-2> <Cmd>BufferLineGoToBuffer 2<CR>
nnoremap <A-3> <Cmd>BufferLineGoToBuffer 3<CR>
nnoremap <A-4> <Cmd>BufferLineGoToBuffer 4<CR>
nnoremap <A-5> <Cmd>BufferLineGoToBuffer 5<CR>
nnoremap <A-6> <Cmd>BufferLineGoToBuffer 6<CR>
nnoremap <A-7> <Cmd>BufferLineGoToBuffer 7<CR>
nnoremap <A-8> <Cmd>BufferLineGoToBuffer 8<CR>
nnoremap <A-9> <Cmd>BufferLineGoToBuffer 9<CR>

lua << EOF
require("bufferline").setup{
  options = {
    mode = "tabs",
    numbers = "ordinal",
    tab_size = 12,
    diagnostics = "coc",
    diagnostics_update_in_insert = false,
    diagnostics_indicator = function(count, level, diagnostics_dict, context)
      return "("..count..")"
    end,
    show_buffer_icons = false,
    show_buffer_close_icons = false,
    separator_style = "slant",
    offsets = {
      {
        filetype = "NvimTree",
        text = function()
          return vim.fn.getcwd()
        end,
        highlight = "Directory",
        text_align = "left"
      }
    }
  },
  highlights = {
    buffer_selected = {
      italic = true
    },
    diagnostic_selected = {
      italic = true
    },
    info_selected = {
      italic = true
    },
    info_diagnostic_selected = {
      italic = true
    },
    warning_selected = {
      italic = true
    },
    warning_diagnostic_selected = {
      italic = true
    },
    error_selected = {
      italic = true
    },
    error_diagnostic_selected = {
      italic = true
    },
    pick_selected = {
      italic = true
    },
    pick_visible = {
      italic = true
    },
    pick = {
      italic = true
    },
  },
}
EOF

if !exists('g:vscode')
" Feline Config
lua << EOF
local vi_mode_utils = require('feline.providers.vi_mode')

local M = {
    active = {},
    inactive = {},
}

M.active[1] = {
    {
        provider = '▊ ',
        hl = {
            fg = 'skyblue',
        },
    },
    {
        provider = 'vi_mode',
        hl = function()
            return {
                name = vi_mode_utils.get_mode_highlight_name(),
                fg = vi_mode_utils.get_mode_color(),
                style = 'NONE',
            }
        end,
    },
    {
        provider = {
            name = 'file_info',
            opts = {
                type = 'relative-short',
            },
        },
        hl = {
            fg = 'white',
            bg = 'oceanblue',
            style = 'bold',
        },
        left_sep = {
            'slant_left_2',
            { str = ' ', hl = { bg = 'oceanblue', fg = 'NONE' } },
        },
        right_sep = {
            { str = ' ', hl = { bg = 'oceanblue', fg = 'NONE' } },
            'slant_right_2',
            ' ',
        },
    },
    {
        provider = 'position',
        left_sep = '',
        right_sep = {
            ' ',
        },
    },
    {
        provider = 'diagnostic_errors',
        hl = { fg = 'red' },
    },
    {
        provider = 'diagnostic_warnings',
        hl = { fg = 'yellow' },
    },
    {
        provider = 'diagnostic_hints',
        hl = { fg = 'cyan' },
    },
    {
        provider = 'diagnostic_info',
        hl = { fg = 'skyblue' },
    },
}

M.active[2] = {
    {
        provider = 'git_branch',
        hl = {
            fg = 'white',
            bg = 'black',
            style = 'bold',
        },
        right_sep = {
            str = ' ',
            hl = {
                fg = 'NONE',
                bg = 'black',
            },
        },
    },
    {
        provider = 'git_diff_added',
        hl = {
            fg = 'green',
            bg = 'black',
        },
    },
    {
        provider = 'git_diff_changed',
        hl = {
            fg = 'orange',
            bg = 'black',
        },
    },
    {
        provider = 'git_diff_removed',
        hl = {
            fg = 'red',
            bg = 'black',
        },
        right_sep = {
            str = ' ',
            hl = {
                fg = 'NONE',
                bg = 'black',
            },
        },
    },
    {
        provider = 'line_percentage',
        hl = {
            style = 'bold',
        },
        left_sep = '  ',
        right_sep = ' ',
    }
}

M.inactive[1] = {
    {
        provider = 'file_type',
        hl = {
            fg = 'white',
            bg = 'oceanblue',
            style = 'bold',
        },
        left_sep = {
            str = ' ',
            hl = {
                fg = 'NONE',
                bg = 'oceanblue',
            },
        },
        right_sep = {
            {
                str = ' ',
                hl = {
                    fg = 'NONE',
                    bg = 'oceanblue',
                },
            },
            'slant_right',
        },
    },
    -- Empty component to fix the highlight till the end of the statusline
    {},
}

require('feline').setup({
  components = M
})
EOF
endif

" Gitsigns Configuration
lua << EOF
require('gitsigns').setup {
  signs = {
    add          = {hl = 'GitSignsAdd'   , text = '│', numhl='GitSignsAddNr'   , linehl='GitSignsAddLn'},
    change       = {hl = 'GitSignsChange', text = '│', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
    delete       = {hl = 'GitSignsDelete', text = '_', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    topdelete    = {hl = 'GitSignsDelete', text = '‾', numhl='GitSignsDeleteNr', linehl='GitSignsDeleteLn'},
    changedelete = {hl = 'GitSignsChange', text = '~', numhl='GitSignsChangeNr', linehl='GitSignsChangeLn'},
  },
  signcolumn = false,  -- Toggle with `:Gitsigns toggle_signs`
  numhl      = true, -- Toggle with `:Gitsigns toggle_numhl`
  linehl     = false, -- Toggle with `:Gitsigns toggle_linehl`
  word_diff  = false, -- Toggle with `:Gitsigns toggle_word_diff`
  watch_gitdir = {
    interval = 1000,
    follow_files = true
  },
  attach_to_untracked = true,
  current_line_blame = false, -- Toggle with `:Gitsigns toggle_current_line_blame`
  current_line_blame_opts = {
    virt_text = true,
    virt_text_pos = 'right_align', -- 'eol' | 'overlay' | 'right_align'
    delay = 1000,
    ignore_whitespace = false,
  },
  current_line_blame_formatter = '<author>, <author_time:%Y-%m-%d> - <summary>',
  sign_priority = 6,
  update_debounce = 100,
  status_formatter = nil, -- Use default
  max_file_length = 40000,
  preview_config = {
    -- Options passed to nvim_open_win
    border = 'single',
    style = 'minimal',
    relative = 'cursor',
    row = 0,
    col = 1
  },
  yadm = {
    enable = false
  },
}
EOF

" Treesitter Configuration
lua << EOF
require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c" },
  sync_install = false,
  ignore_install = { "javascript" },
  highlight = {
    enable = true,
    disable = {  },
    additional_vim_regex_highlighting = false,
  },
}
EOF

if !exists('g:vscode')
" Toggleterm Configuration
lua << EOF
require("toggleterm").setup {
  size = function(term)
    if term.direction == "horizontal" then
      return 15
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    end
  end,
  open_mapping = [[<A-~>]],
  hide_numbers = true,
  shade_filetypes = {},
  shade_terminals = true,
  shading_factor = '1',
  start_in_insert = true,
  insert_mappings = true, 
  terminal_mappings = true,
  persist_size = true,
  direction = 'float',
  close_on_exit = true,
  shell = vim.o.shell,
  float_opts = {
    border = 'curved',
    width = 120,
    height = 80,
    winblend = 3,
  }
}
EOF
endif

" Open Fzf GitFiles at startup if opened without any buffers
function! IsBlank( bufnr )
  return (empty(bufname(a:bufnr)) &&
  \ getbufvar(a:bufnr, '&modified') == 0 &&
  \ empty(getbufvar(a:bufnr, '&buftype'))
  \)
endfunction

function! ExistOtherBuffers( targetBufNr )
  return ! empty(filter(range(1, bufnr('$')), 'buflisted(v:val) && v:val != a:targetBufNr'))
endfunction

function! IsEmpty()
  let l:currentBufNr = bufnr('')
  return IsBlank(l:currentBufNr) && ! ExistOtherBuffers(l:currentBufNr)
endfunction

function! OpenFzfIfEmpty()
  if IsEmpty()
    :GitFiles!
  endif
endfunction

autocmd VimEnter * :call OpenFzfIfEmpty()


let g:WorkspaceFolders = ['/home/shined/fw-darkhorse']
"autocmd User CocNvimInit :sleep 30m | call coc_fzf#lists#fzf_run(1, "symbols")
