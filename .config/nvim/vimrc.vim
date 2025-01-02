" VSCode-specific Configuration
if exists('g:vscode')
  "nnoremap , :call VSCodeCall('workbench.action.toggleEditorWidths')<CR>
  "nnoremap . :call VSCodeCall('workbench.action.toggleZenMode')<CR>
  " nmap ' :Find<CR>
  " nmap { :call VSCodeCall('workbench.action.showAllSymbols')<CR>
  " nmap } :call VSCodeCall('workbench.action.gotoSymbol')<CR>
  nmap <silent> gd :call VSCodeCall('editor.action.peekDefinition')<CR>
  nmap <silent> gD :call VSCodeCall('editor.action.revealDefinition')<CR>
  nmap <silent> gr :call VSCodeCall('editor.action.referenceSearch.trigger')<CR>
  nmap <silent> gR :call VSCodeCall('references-view.findReferences')<CR>
  nmap <silent> gy :call VSCodeCall('editor.action.goToTypeDefinition')<CR>
  nmap <silent> grn :call VSCodeCall('editor.action.rename')<CR>
  nmap <silent> gp :call VSCodeCall('editor.action.marker.next')<CR>
  nnoremap <C-J> <C-W><C-J>
  nnoremap <C-K> <C-W><C-K>
  nnoremap <C-L> <C-W><C-L>
  nnoremap <C-H> <C-W><C-H>
endif

" Quit if trying to edit directory
for f in argv()
  if isdirectory(f)
    quit
  endif
endfor


highlight LineNr ctermfg=blue
highlight MsgArea guibg=#edeada guifg=#5c6a72

" search for visually hightlighted text
vnoremap <c-f> y<ESC>/<c-r>"<CR>


nmap <s-w> :call search('[A-Z]', 'W')<CR>

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
nnoremap <A-=> <C-W>=
nnoremap <A-t> <C-W>T

set splitbelow
set splitright

function! UpdateWaylandDisplay()
  if !empty($TMUX)
    let wd = system("tmux show-env WAYLAND_DISPLAY 2> /dev/null")
    let $WAYLAND_DISPLAY = trim(split(wd, "=")[1])
  elseif !empty($ZELLIJ) && !empty($SSH_TTY)
    let $WAYLAND_DISPLAY = readfile("/tmp/wayland_display", 1)[0]
  endif
endfunction

" Automatically strip trailing whitespace
fun! <SID>StripTrailingWhitespaces()
  let l = line(".")
  let c = col(".")
  %s/\s\+$//e
  call cursor(l, c)
endfun
"autocmd FileType c,cpp,java,php,ruby,python autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()
"if has("autocmd")
  "au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
                  "\| exe "normal! g'\"" | endif
"endif

" Neovim-specific Configuration

if !exists('g:vscode')
  if has('termguicolors')
    set termguicolors
  endif
  set background=light

  let g:bufferline_echo = 0

  let g:python3_host_prog = '/usr/bin/python3'

  "nnoremap m :MaximizerToggle<CR>

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

  command! -bang -nargs=? GitAllFiles call fzf#vim#gitallfiles(<q-args>, fzf#vim#with_preview(<q-args> == "?" ? { "placeholder": "" } : {}), <bang>0)

  command! -nargs=* -bang RG call RipgrepCFzf(<q-args>, <bang>0)

  nmap <Bar> :RG!<CR>
  nmap ' :GitAllFiles<CR>

  function! CheckBackspace() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~# '\s'
  endfunction


  " Rust language completion
  "autocmd BufReadPost *.rs setlocal filetype=rust

  " Echodoc Configuration
  let g:echodoc#enable_at_startup = 1
  let g:echodoc#type = 'virtual'

  " LSP Configuration
  "nmap <silent> gd <C-]>
  nnoremap gd <cmd>lua require('fzf-lua').lsp_definitions()<CR>
  nnoremap gr <cmd>lua require('fzf-lua').lsp_references()<CR>
  nnoremap ] <cmd>lua require('fzf-lua').lsp_finder()<CR>
  nnoremap { <cmd>lua require('fzf-lua').lsp_live_workspace_symbols()<CR>
  nnoremap } <cmd>lua require('fzf-lua').lsp_document_symbols()<CR>
  nnoremap [ <cmd>:ClangdSwitchSourceHeader<CR>
  nnoremap <TAB> <cmd>:ToggleDiag<CR>

  " Coc Configuration
  let g:coc_node_path='/usr/bin/node'

  "nmap { :CocFzfList symbols<CR>
  "nmap } :CocFzfList outline<CR>
  "nmap ] :CocCommand clangd.switchSourceHeader<CR>

  "inoremap <silent><expr> <TAB>
  "      \ coc#pum#visible() ? coc#pum#next(1) :
  "      \ CheckBackspace() ? "\<Tab>" :
  "      \ coc#refresh()
  "inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

  " Make <CR> to accept selected completion item or notify coc.nvim to format
  " <C-g>u breaks current undo, please make your own choice.
  "inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
  "                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"


  " Use <c-space> to trigger completion.
  "if has('nvim')
  "  inoremap <silent><expr> <c-space> coc#refresh()
  "else
  "  inoremap <silent><expr> <c-@> coc#refresh()
  "endif

  "" Make <CR> auto-select the first completion item and notify coc.nvim to
  "" format on enter, <cr> could be remapped by other vim plugin
  "inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
  "                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

  "" Use `[g` and `]g` to navigate diagnostics
  "" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
  "nmap <silent> [g <Plug>(coc-diagnostic-prev)
  "nmap <silent> ]g <Plug>(coc-diagnostic-next)

  "nmap <silent> gd <Plug>(coc-definition)
  "nmap <silent> Gd :call CocActionAsync('jumpDefinition', 'vsplit')<CR>
  "nmap <silent> gi <Plug>(coc-implementation)
  "nmap <silent> Gi : call CocActionAsync('jumpImplementation', 'vsplit')<CR>
  "nmap <silent> gy <Plug>(coc-type-definition)
  "nmap <silent> Gy : call CocActionAsync('jumpTypeDefinition', 'vsplit')<CR>
  "nmap <silent> gr <Plug>(coc-references)
  "nmap <silent> Gr : call CocActionAsync('jumpReferences', 'vsplit')<CR>
  "nmap <silent> gn <Plug>(coc-rename)

  "inoremap <expr> <C-j> pumvisible() ? "\<C-N>" : "\<C-j>"
  "inoremap <expr> <C-k> pumvisible() ? "\<C-P>" : "\<C-k>"

  "" Use K to show documentation in preview window
  "nnoremap <silent> K :call <SID>show_documentation()<CR>
  "function! s:show_documentation()
  "  if (index(['vim','help'], &filetype) >= 0)
  "    execute 'h '.expand('<cword>')
  "  elseif (coc#rpc#ready())
  "    call CocActionAsync('doHover')
  "  else
  "    execute '!' . &keywordprg . " " . expand('<cword>')
  "  endif
  "endfunction

  "" Highlight the symbol and its references when holding the cursor.
  "autocmd CursorHold * silent call CocActionAsync('highlight')

  "augroup mygroup
  "  autocmd!
  "  " Setup formatexpr specified filetype(s).
  "  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  "  " Update signature help on jump placeholder.
  "  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
  "augroup end

  " Coc Configuration End

  nnoremap <C-n> :NvimTreeToggle<CR>

  " Bufferline Config
  nnoremap <silent> gb :BufferLinePick<CR>
  nnoremap <C-A-1> <Cmd>BufferLineGoToBuffer 1<CR>
  nnoremap <C-A-2> <Cmd>BufferLineGoToBuffer 2<CR>
  nnoremap <C-A-3> <Cmd>BufferLineGoToBuffer 3<CR>
  nnoremap <C-A-4> <Cmd>BufferLineGoToBuffer 4<CR>
  nnoremap <C-A-5> <Cmd>BufferLineGoToBuffer 5<CR>
  nnoremap <C-A-6> <Cmd>BufferLineGoToBuffer 6<CR>
  nnoremap <C-A-7> <Cmd>BufferLineGoToBuffer 7<CR>
  nnoremap <C-A-8> <Cmd>BufferLineGoToBuffer 8<CR>
  nnoremap <C-A-9> <Cmd>BufferLineGoToBuffer 9<CR>

  " Open Fzf GitFiles at startup if opened without any buffers
  function! IsBlank( bufnr )
    return (empty(bufname(a:bufnr)) &&
    \ getbufvar(a:bufnr, '&modified') == 0 &&
    \ empty(getbufvar(a:bufnr, '&buftype'))
    \)
  endfunction

  let g:WorkspaceFolders = ['']

  function! ExistOtherBuffers( targetBufNr )
    return ! empty(filter(range(1, bufnr('$')), 'buflisted(v:val) && v:val != a:targetBufNr'))
  endfunction

  function! IsEmpty()
    let l:currentBufNr = bufnr('')
    return IsBlank(l:currentBufNr) && ! ExistOtherBuffers(l:currentBufNr)
  endfunction

  "function! OpenFzfIfEmpty()
    "if IsEmpty()
      ":GitAllFiles!
    "endif
  "endfunction

  "autocmd VimEnter * :call OpenFzfIfEmpty()

  function! TmuxWaylandRefresh()
    if !empty($TMUX) && !empty($WAYLAND_DISPLAY)
      let prev_display = $WAYLAND_DISPLAY
      let display = split(system("tmux show-env WAYLAND_DISPLAY 2> /dev/null"), "=")[1][:-2]
      let $WAYLAND_DISPLAY = display
      "echom "Changed $WAYLAND_DISPLAY from " . prev_display . " to " . $WAYLAND_DISPLAY
    endif
  endfunction

  "if exists('$TMUX')
    "autocmd BufEnter,FocusGained * call TmuxWaylandRefresh()
  "endif

  " Pull in lua configs
  " lua require('config.bufferline')
  " lua require('config.lualine')
  " lua require('config.gitsigns')
  " lua require('config.toggleterm')
  " "lua require('config.treesitter')
  " lua require('config.nvim-web-devicons')
  " lua require("everforest").load()
endif "if !exists('g:vscode')
