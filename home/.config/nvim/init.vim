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
Plug 'vimwiki/vimwiki', { 'branch': 'dev' }
Plug 'chriskempson/base16-vim'
Plug 'airblade/vim-gitgutter'
"Plug 'zxqfl/tabnine-vim'
Plug 'szw/vim-maximizer'
call plug#end()


set t_Co=256 
set laststatus=2
set noshowmode

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

let g:python3_host_prog = '/usr/bin/python3.7'

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

let g:LanguageClient_serverCommands = {
    \ 'cpp': ['cquery', '--log-file=/tmp/cq.log'],
    \ 'c': ['cquery', '--log-file=/tmp/cq.log'],
    \ }

let g:LanguageClient_loadSettings = 1 " Use an absolute configuration path if you want system-wide settings
let g:LanguageClient_settingsPath = '/home/eshin/.config/nvim/settings.json'
set completefunc=LanguageClient#complete
set formatexpr=LanguageClient_textDocument_rangeFormatting()

nnoremap <silent> gh :call LanguageClient#textDocument_hover()<CR>
nnoremap <silent> gd :call LanguageClient#textDocument_definition()<CR>
nnoremap <silent> gr :call LanguageClient#textDocument_references()<CR>
nnoremap <silent> gs :call LanguageClient#textDocument_documentSymbol()<CR>
nnoremap <silent> <F2> :call LanguageClient#textDocument_rename()<CR>
