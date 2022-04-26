call plug#begin('~/.local/share/nvim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'jsfaint/gen_tags.vim'
Plug 'bfredl/nvim-miniyank'
Plug 'tpope/vim-fugitive'
"Plug 'brooth/far.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'pbogut/fzf-mru.vim'
Plug 'vimwiki/vimwiki'
Plug 'chriskempson/base16-vim'
Plug 'airblade/vim-gitgutter'
Plug 'szw/vim-maximizer'
Plug 'Shougo/echodoc.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'kyazdani42/nvim-web-devicons' " for file icons
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'bfrg/vim-cpp-modern'
Plug 'tpope/vim-commentary'
call plug#end()

set t_Co=256 
set laststatus=2
set noshowmode

let g:airline_theme='murmur'
let g:airline_powerline_fonts = 0
let g:airline#extensions#coc#enabled = 1
let g:bufferline_echo = 0
"let base16colorspace=256
set termguicolors
colorscheme base16-default-dark

let &runtimepath.=','.$HOME.'/.config/nvim/bundle/darkhorse.vim'

"hi DiffAdd guifg=NONE ctermfg=NONE guibg=#464632 ctermbg=238 gui=NONE cterm=NONE
"hi DiffChange guifg=NONE ctermfg=NONE guibg=#335261 ctermbg=239 gui=NONE cterm=NONE
"hi DiffDelete guifg=#f43753 ctermfg=203 guibg=#79313c ctermbg=237 gui=NONE cterm=NONE
"hi DiffText guifg=NONE ctermfg=NONE guibg=NONE ctermbg=NONE gui=reverse cterm=reverse

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

set mouse=a

set clipboard=unnamedplus

set updatetime=300

let g:gitgutter_enabled=1
"let g:gitgutter_signs=1
 
set ruler	
highlight LineNr ctermfg=blue
 
set undolevels=1000	
set backspace=indent,eol,start	

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

let g:python3_host_prog = '/usr/bin/python3'

"let g:loaded_gentags#ctags = 0
"let g:loaded_gentags#gtags = 0
"let g:gen_tags#gtags_auto_gen = 0
"let g:gen_tags#ctags_auto_gen = 0
"let g:gen_tags#ctags_opts = ['--exclude=@/home/eshin/.ctagsignore', '--langmap=C:.c.h', '--languages=C']
"let g:gen_tags#gtags_opts = ['-c', '-i']
"let g:gen_tags#use_cache_dir = 0
"let g:gen_tags#ctags_prune = 0
"let g:gen_tags#blacklist = ['$HOME']
"let g:gen_tags#blacklist = []
"let g:gen_tags#verbose = 0
"let g:gen_tags#statusline = 0

"let g:fzf_tags_command = 'echo /home/eshin/fw-bison/.git/tags_dir/prj_tags'

"let g:deoplete#enable_at_startup = 1
"autocmd InsertEnter * call deoplete#enable()

nmap _ :GFiles<CR>
nmap <bar>f :cs find f <C-R>=expand("<cfile>")<CR><CR>	
"nmap <C-S-\> :BTags<CR>
"nmap ' :Hist<CR>
nmap ' :FZFMru<CR>

nmap <C-[>s :cs find s <C-R>=expand("<cword>")<CR><CR>	
nmap <C-[>g :cs find g <C-R>=expand("<cword>")<CR><CR>	
nmap <C-[>c :cs find c <C-R>=expand("<cword>")<CR><CR>	
nmap <C-[>t :cs find t <C-R>=expand("<cword>")<CR><CR>	
nmap <C-[>e :cs find e <C-R>=expand("<cword>")<CR><CR>	
nmap <C-[>f :cs find f <C-R>=expand("<cfile>")<CR><CR>	
nmap <C-[>i :cs find i ^<C-R>=expand("<cfile>")<CR>$<CR>
nmap <C-[>d :cs find d <C-R>=expand("<cword>")<CR><CR>	

map p <Plug>(miniyank-startput) 
map P <Plug>(miniyank-startPut)
map <C-n> <Plug>(miniyank-cycle)
map <C-c> <Plug>(miniyank-tochar)
map <C-l> <Plug>(miniyank-toline)
map <C-b> <Plug>(miniyank-toblock)

" Split settings
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>
set splitbelow
set splitright
nnoremap m :MaximizerToggle<CR>

" Rust language completion
autocmd BufReadPost *.rs setlocal filetype=rust

" Required for operations modifying multiple buffers like rename.
set hidden

let g:echodoc#enable_at_startup = 1
let g:echodoc#type = 'virtual'

set nobackup
set nowritebackup
set cmdheight=2
set updatetime=300
"set shortmess+=c

let g:coc_node_path='/usr/bin/node'

inoremap <silent><expr> <TAB>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<TAB>" :
      \ coc#refresh()
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

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

" Or use `complete_info` if your vim support it, like:
" inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
"
"nmap <silent> gd <Plug>(coc-definition)

nmap <silent> gd <Plug>(coc-definition)
nmap <silent> Gd : call CocActionAsync('jumpDeclaration', 'vsplit')<CR>
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> Gi : call CocActionAsync('jumpImplementation', 'vsplit')<CR>
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> Gy : call CocActionAsync('jumpTypeDefinition', 'vsplit')<CR>
nmap <silent> gr <Plug>(coc-references)
nmap <silent> Gr : call CocActionAsync('jumpReferences', 'vsplit')<CR>

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

" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Use CTRL-S for selections ranges.
" Requires 'textDocument/selectionRange' support of language server.
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" Add `:Format` command to format current buffer.
command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call     CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

" Add (Neo)Vim's native statusline support.
" NOTE: Please see `:h coc-status` for integrations with external plugins that
" provide custom statusline: lightline.vim, vim-airline.
"set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" Mappings for CoCList
" Show all diagnostics.
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
" Manage extensions.
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
" Show commands.
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
" Find symbol of current document.
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
" Search workspace symbols.
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
" Do default action for next item.
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
" Do default action for previous item.
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
" Resume latest coc list.
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

set termguicolors " this variable must be enabled for colors to be applied properly
