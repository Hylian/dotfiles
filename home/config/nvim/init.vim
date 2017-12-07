call plug#begin('~/.local/share/nvim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'jsfaint/gen_tags.vim'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
"Plug 'roxma/nvim-completion-manager'
Plug 'bfredl/nvim-miniyank'
Plug 'tpope/vim-fugitive'
Plug '~/.fzf'
call plug#end()

set t_Co=256
set laststatus=2
set noshowmode

let g:airline_theme='murmur'
let g:airline_powerline_fonts = 0

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

set mouse=a
 
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

let g:loaded_gentags#ctags = 0
let g:loaded_gentags#gtags = 1
let g:gen_tags#gtags_auto_gen = 1
let g:gen_tags#ctags_auto_gen = 1
let g:gen_tags#ctags_opts = '--langmap=c:.c.h --languages=c'
let g:gen_tags#use_cache_dir = 0
let g:gen_tags#ctags_prune = 0
let g:gen_tags#blacklist = ['$HOME']
let g:gen_tags#verbose = 1

let g:deoplete#enable_at_startup = 0
autocmd InsertEnter * call deoplete#enable()

nmap <bar> :FZF<CR>

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
