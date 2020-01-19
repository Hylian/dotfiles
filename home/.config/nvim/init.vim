call plug#begin('~/.local/share/nvim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'jsfaint/gen_tags.vim'
"Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
"Plug 'roxma/nvim-completion-manager'
Plug 'bfredl/nvim-miniyank'
Plug 'tpope/vim-fugitive'
Plug 'brooth/far.vim'
"Plug '/usr/share/vim/vimfiles/plugin/fzf.vim'
"Plug 'autozimu/LanguageClient-neovim', {
    "\ 'branch': 'next',
    "\ 'do': 'bash install.sh',
    "\ }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'pbogut/fzf-mru.vim'
Plug 'vimwiki/vimwiki'
Plug 'chriskempson/base16-vim'
Plug 'airblade/vim-gitgutter'
"Plug 'zxqfl/tabnine-vim'
Plug 'szw/vim-maximizer'
"Plug 'autozimu/LanguageClient-neovim', {
"    \ 'branch': 'next',
"    \ 'do': 'bash install.sh',
"    \ }
Plug 'Shougo/echodoc.vim'
Plug 'neoclide/coc.nvim', {'tag': '*', 'branch': 'release'}
call plug#end()


set t_Co=256 
set laststatus=2
set noshowmode

set cmdheight=1

let g:airline_theme='murmur'
let g:airline_powerline_fonts = 0
"let base16colorspace=256
set termguicolors
colorscheme base16-default-dark

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

set updatetime=1000

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

let g:loaded_gentags#ctags = 0
let g:loaded_gentags#gtags = 0
let g:gen_tags#gtags_auto_gen = 1
let g:gen_tags#ctags_auto_gen = 1
let g:gen_tags#ctags_opts = ['--exclude=@/home/eshin/.ctagsignore', '--langmap=C:.c.h', '--languages=C']
let g:gen_tags#gtags_opts = ['-c', '-i']
let g:gen_tags#use_cache_dir = 0
let g:gen_tags#ctags_prune = 0
"let g:gen_tags#blacklist = ['$HOME']
let g:gen_tags#blacklist = []
let g:gen_tags#verbose = 0
let g:gen_tags#statusline = 0

"let g:fzf_tags_command = 'echo /home/eshin/fw-bison/.git/tags_dir/prj_tags'

let g:deoplete#enable_at_startup = 1
"autocmd InsertEnter * call deoplete#enable()

nmap _ :GFiles<CR>
nmap <bar> :Tags<CR>
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


" # Copy and paste the below into your vimrc or init.vim

fun! Grok()
  let abspath = expand('%:p')
  if (matchstr(abspath, "fw-bison") != "")
    let relpath = split(abspath, "fw-bison/")
    let url = "https://grok.firmwareci.fitbit.com/source/xref/fw-bison_develop/" . relpath[-1] . "#" . line('.')
    :call system('xclip -selection "clipboard"', url)
    echom "Grok URL pasted to clipboard"
  endif
endfun

nmap <C-g> :call Grok()<CR>

" Rust language completion
autocmd BufReadPost *.rs setlocal filetype=rust

" Required for operations modifying multiple buffers like rename.
set hidden

let g:LanguageClient_serverCommands = {
    \ 'rust': ['rustup', 'run', 'nightly', 'rls'],
    \ }

" Automatically start language servers.
let g:LanguageClient_autoStart = 1
let g:LanguageClient_hasSnippetSupport = 0
let g:LanguageClient_hoverPreview = "Never"

autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | silent! pclose | endif

nnoremap <F5> :call LanguageClient_contextMenu()<CR>
nnoremap <silent> K :call LanguageClient_textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
nnoremap <silent> gD :call LanguageClient#textDocument_definition({'gotoCmd': 'vsplit'})<CR>
nnoremap <silent> gx :call LanguageClient#textDocument_references()<CR>
nnoremap <silent> <F2> :call LanguageClient_textDocument_rename()<CR>
let g:echodoc#enable_at_startup = 1
let g:echodoc#type = 'signature'

set cmdheight=2
set updatetime=300
set shortmess+=c

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
inoremap <silent><expr> <c-space> coc#refresh()

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current position.
" Coc only does snippet and additional edit on confirm.
inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" Or use `complete_info` if your vim support it, like:
" inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
"
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

inoremap <expr> <C-j> pumvisible() ? "\<C-N>" : "\<C-j>"
inoremap <expr> <C-k> pumvisible() ? "\<C-P>" : "\<C-k>"
" Use K to show documentation in preview window
nnoremap <silent> K :call <SID>show_documentation()<CR>

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction


" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')


" Remap for rename current word
nmap <leader>rn <Plug>(coc-rename)

command! -nargs=0 Format :call CocAction('format')
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}


