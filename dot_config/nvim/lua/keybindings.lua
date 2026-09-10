local function map(mode, combo, mapping, opts)
  local options = {noremap = true, silent = true}
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, combo, mapping, options)
end

vim.g.mapleader = ';'
vim.g.maplocalleader = ';;'

-- Disable Ctrl+Z process suspension in all modes
map({ 'n', 'i', 'v', 'x', 's', 'o', 't', 'c' }, '<C-z>', '<Nop>')

-- Zellij-related Bindings
local function zellij(...)
  vim.system({ 'zellij', 'action', ... })
end

local zellij_modes = { 'n', 'i', 'v', 't' }

-- Track active and previous Zellij tabs so <A-`> can toggle between them
local zellij_last_tab = nil
local zellij_curr_tab = nil

local function update_zellij_tab(cb)
  if not vim.env.ZELLIJ then return end
  vim.system({ 'zellij', 'action', 'current-tab-info' }, { text = true }, function(obj)
    if obj.code == 0 and obj.stdout then
      local pos = tonumber(obj.stdout:match("position:%s*(%d+)"))
      if pos then
        local tab_idx = pos + 1
        if zellij_curr_tab and zellij_curr_tab ~= tab_idx then
          zellij_last_tab = zellij_curr_tab
        end
        zellij_curr_tab = tab_idx
      end
    end
    if cb then vim.schedule(cb) end
  end)
end

local function zellij_goto_tab(idx)
  if zellij_curr_tab and zellij_curr_tab ~= idx then
    zellij_last_tab = zellij_curr_tab
  end
  zellij_curr_tab = idx
  zellij('go-to-tab', tostring(idx))
end

local function zellij_toggle_tab()
  if zellij_last_tab then
    local target = zellij_last_tab
    zellij_last_tab = zellij_curr_tab
    zellij_curr_tab = target
    zellij('go-to-tab', tostring(target))
  else
    update_zellij_tab(function()
      if zellij_last_tab then
        local target = zellij_last_tab
        zellij_last_tab = zellij_curr_tab
        zellij_curr_tab = target
        zellij('go-to-tab', tostring(target))
      else
        zellij('go-to-previous-tab')
      end
    end)
  end
end

vim.api.nvim_create_autocmd({ "FocusGained", "VimEnter" }, {
  callback = function()
    update_zellij_tab()
  end,
})

-- Smart splits navigation (seamless across Neovim splits and Zellij panes)
map(zellij_modes, '<A-h>',         function() require('smart-splits').move_cursor_left() end)
map(zellij_modes, '<A-j>',         function() require('smart-splits').move_cursor_down() end)
map(zellij_modes, '<A-k>',         function() require('smart-splits').move_cursor_up() end)
map(zellij_modes, '<A-l>',         function() require('smart-splits').move_cursor_right() end)

map(zellij_modes, '<A-C-h>',       function() require('smart-splits').resize_left() end)
map(zellij_modes, '<A-C-j>',       function() require('smart-splits').resize_down() end)
map(zellij_modes, '<A-C-k>',       function() require('smart-splits').resize_up() end)
map(zellij_modes, '<A-C-l>',       function() require('smart-splits').resize_right() end)

-- Zellij tab navigation
map(zellij_modes, '<A-Left>',      function() zellij('go-to-previous-tab'); vim.defer_fn(update_zellij_tab, 100) end)
map(zellij_modes, '<A-Right>',     function() zellij('go-to-next-tab'); vim.defer_fn(update_zellij_tab, 100) end)
map(zellij_modes, '<A-C-Left>',    function() zellij('move-tab', 'left') end)
map(zellij_modes, '<A-C-Right>',   function() zellij('move-tab', 'right') end)
map(zellij_modes, '<A-`>',         zellij_toggle_tab)
map(zellij_modes, '<A-~>',         zellij_toggle_tab)
map(zellij_modes, '<A-S-`>',       zellij_toggle_tab)
map(zellij_modes, '<A-1>',         function() zellij_goto_tab(1) end)
map(zellij_modes, '<A-2>',         function() zellij_goto_tab(2) end)
map(zellij_modes, '<A-3>',         function() zellij_goto_tab(3) end)
map(zellij_modes, '<A-4>',         function() zellij_goto_tab(4) end)
map(zellij_modes, '<A-5>',         function() zellij_goto_tab(5) end)
map(zellij_modes, '<A-6>',         function() zellij_goto_tab(6) end)
map(zellij_modes, '<A-7>',         function() zellij_goto_tab(7) end)
map(zellij_modes, '<A-8>',         function() zellij_goto_tab(8) end)
map(zellij_modes, '<A-9>',         function() zellij_goto_tab(9) end)
map(zellij_modes, '<A-0>',         function() zellij_goto_tab(10) end)

-- Zellij pane movement & layouts
map(zellij_modes, '<A-S-h>',       function() zellij('move-pane', 'left') end)
map(zellij_modes, '<A-S-l>',       function() zellij('move-pane', 'right') end)
map(zellij_modes, '<A-S-j>',       function() zellij('move-pane', 'down') end)
map(zellij_modes, '<A-S-k>',       function() zellij('move-pane', 'up') end)
map(zellij_modes, '<A-S-[>',       function() zellij('previous-swap-layout') end)
map(zellij_modes, '<A-S-]>',       function() zellij('next-swap-layout') end)
map(zellij_modes, '<A-{>',         function() zellij('previous-swap-layout') end)
map(zellij_modes, '<A-}>',         function() zellij('next-swap-layout') end)
map(zellij_modes, '<A-[>',         function() zellij('break-pane-left') end)
map(zellij_modes, '<A-]>',         function() zellij('break-pane-right') end)
map(zellij_modes, '<A-+>',         function() zellij('resize', 'increase') end)
map(zellij_modes, '<A-=>',         function() zellij('resize', 'increase') end)
map(zellij_modes, '<A-->',         function() zellij('resize', 'decrease') end)
map(zellij_modes, '<A-z>',         function() zellij('switch-mode', 'normal') end)

-- Zellij pane creation & actions
map(zellij_modes, '<A-s>',         function() zellij('new-pane', '-d', 'right', '--cwd', vim.fn.getcwd()) end)
map(zellij_modes, '<A-n>',         function()
  local cwd = vim.fn.getcwd()
  local name = cwd == vim.env.HOME and '~' or vim.fn.fnamemodify(cwd, ':t')
  if name == '' then name = '/' end
  zellij('new-tab', '--cwd', cwd, '--name', name)
end)
map(zellij_modes, '<A-f>',         function() zellij('toggle-fullscreen') end)

-- Window / Pane management & quit
map({ 'n', 't' }, '<A-S-s>',       function() require('focus').split_command('l') end)
map({ 'n', 't' }, '<A-S-e>',       function() require('focus').focus_equalise() end)
map({ 'n', 't' }, '<A-S-r>',       function() require('focus').focus_autoresize() end)
map({ 'n', 't' }, '<A-S-f>',       function() require('maximize').toggle() end)
map({ 'n', 'i', 'v' }, '<A-w>',    "<cmd>w<CR>")
map({ 'n', 'v' }, '<A-d>',         "<cmd>q<CR>")
map({ 'n', 'v' }, '<A-q>',         "<cmd>q<CR>")
map('t', '<A-d>', function()
  if vim.api.nvim_win_get_config(0).relative ~= "" then
    vim.api.nvim_win_close(0, true)
  else
    zellij('close-pane')
  end
end)
map('t', '<A-q>', function()
  if vim.api.nvim_win_get_config(0).relative ~= "" then
    vim.api.nvim_win_close(0, true)
  else
    vim.cmd('q')
  end
end)
map({ 'n', 'v', 't' }, '<A-S-q>',  "<cmd>q!<CR>")
map({ 'n', 'v', 't' }, '<A-Q>',    "<cmd>q!<CR>")
map(zellij_modes, '<A-C-S-]>',     "<C-w>r")
map(zellij_modes, '<A-S-n>',       "<cmd>$tabnew<CR>")
map(zellij_modes, '<A-S-d>',       "<cmd>NvimTreeClose<CR><cmd>tabclose<CR>")

-- Neovim internal tab navigation (mapped across all modes)
map(zellij_modes, '<A-S-Left>',    "<cmd>tabp<CR>")
map(zellij_modes, '<A-S-Right>',   "<cmd>tabn<CR>")
map(zellij_modes, '<A-S-1>',       "<cmd>1gt<CR>")
map(zellij_modes, '<A-S-2>',       "<cmd>2gt<CR>")
map(zellij_modes, '<A-S-3>',       "<cmd>3gt<CR>")
map(zellij_modes, '<A-S-4>',       "<cmd>4gt<CR>")
map(zellij_modes, '<A-S-5>',       "<cmd>5gt<CR>")
map(zellij_modes, '<A-S-6>',       "<cmd>6gt<CR>")
map(zellij_modes, '<A-S-7>',       "<cmd>7gt<CR>")
map(zellij_modes, '<A-S-8>',       "<cmd>8gt<CR>")
map(zellij_modes, '<A-S-9>',       "<cmd>9gt<CR>")
map(zellij_modes, '<A-S-0>',       "<cmd>10gt<CR>")

map(zellij_modes, '<A-!>',         "<cmd>1gt<CR>")
map(zellij_modes, '<A-@>',         "<cmd>2gt<CR>")
map(zellij_modes, '<A-#>',         "<cmd>3gt<CR>")
map(zellij_modes, '<A-$>',         "<cmd>4gt<CR>")
map(zellij_modes, '<A-%>',         "<cmd>5gt<CR>")
map(zellij_modes, '<A-^>',         "<cmd>6gt<CR>")
map(zellij_modes, '<A-&>',         "<cmd>7gt<CR>")
map(zellij_modes, '<A-*>',         "<cmd>8gt<CR>")
map(zellij_modes, '<A-(>',         "<cmd>9gt<CR>")
map(zellij_modes, '<A-)>',         "<cmd>10gt<CR>")

map(zellij_modes, '<C-A-S-Left>',  "<cmd>-tabmove<CR>")
map(zellij_modes, '<C-A-S-Right>', "<cmd>+tabmove<CR>")
map('n', '<leader>t',     ":Tabby jump_to_tab<CR>")
map('n', '<leader>w',     ":Tabby pick_window<CR>")
map('n', '<leader>nh',    "<cmd>Noice history<CR>")
map('n', '<leader>nl',    "<cmd>Noice last<CR>")
map('n', '<leader>ne',    "<cmd>Noice errors<CR>")
map('n', '<leader>nd',    "<cmd>Noice dismiss<CR>")
map('n', '\\',            ":NvimTreeFindFileToggle<CR>")

map('n', '<C-p>',     ":set paste<CR>o<ESC>p:set nopaste<CR>")
map('n', '<C-S-p>',   ":set paste<CR>O<ESC>p:set nopaste<CR>")
map('n', '<CR>',      ":noh<CR><CR>")
-- Switch between source and header file (clangd LSP with filesystem fallback)
local function fallback_switch_source_header()
  local file = vim.api.nvim_buf_get_name(0)
  if file == '' then return false end

  local ext = vim.fn.fnamemodify(file, ':e'):lower()
  local dir = vim.fn.fnamemodify(file, ':h')
  local stem = vim.fn.fnamemodify(file, ':t:r')

  local source_exts = { 'c', 'cc', 'cpp', 'cxx', 'm', 'mm', 's' }
  local header_exts = { 'h', 'hh', 'hpp', 'hxx', 'inc' }

  local is_source = vim.tbl_contains(source_exts, ext)
  local is_header = vim.tbl_contains(header_exts, ext)
  if not is_source and not is_header then return false end

  local target_exts = is_source and header_exts or source_exts

  -- 1. Same directory
  local root = vim.fn.fnamemodify(file, ':r')
  for _, e in ipairs(target_exts) do
    local target = root .. '.' .. e
    if vim.uv.fs_stat(target) then
      vim.cmd.edit(target)
      return true
    end
  end

  -- 2. Sister include/src directories
  local candidate_dirs = {}
  if is_source then
    table.insert(candidate_dirs, (dir:gsub('/src$', '/include')))
    table.insert(candidate_dirs, (dir:gsub('/src$', '/inc')))
    table.insert(candidate_dirs, dir .. '/../include')
    table.insert(candidate_dirs, dir .. '/../inc')
    table.insert(candidate_dirs, dir .. '/include')
  else
    table.insert(candidate_dirs, (dir:gsub('/include$', '/src')))
    table.insert(candidate_dirs, (dir:gsub('/inc$', '/src')))
    table.insert(candidate_dirs, dir .. '/../src')
    table.insert(candidate_dirs, dir .. '/src')
  end

  for _, cdir in ipairs(candidate_dirs) do
    for _, e in ipairs(target_exts) do
      local target = cdir .. '/' .. stem .. '.' .. e
      if vim.uv.fs_stat(target) then
        vim.cmd.edit(vim.fs.normalize(target))
        return true
      end
    end
  end

  return false
end

local function switch_source_header()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = 'clangd' })
  if #clients > 0 then
    local client = clients[1]
    local method = 'textDocument/switchSourceHeader'
    local params = vim.lsp.util.make_text_document_params(bufnr)
    client:request(method, params, function(err, result)
      if err then
        vim.notify(tostring(err), vim.log.levels.ERROR)
        return
      end
      if not result or result == '' then
        if not fallback_switch_source_header() then
          vim.notify('Corresponding source/header file cannot be determined', vim.log.levels.WARN)
        end
        return
      end
      vim.cmd.edit(vim.uri_to_fname(result))
    end, bufnr)
    return
  end

  if vim.fn.exists(':LspClangdSwitchSourceHeader') == 2 then
    vim.cmd('LspClangdSwitchSourceHeader')
    return
  end

  if vim.fn.exists(':ClangdSwitchSourceHeader') == 2 then
    vim.cmd('ClangdSwitchSourceHeader')
    return
  end

  if not fallback_switch_source_header() then
    vim.notify('No corresponding header or source file found', vim.log.levels.WARN)
  end
end

map('n', 'gd',        "<cmd>lua require('fzf-lua').lsp_definitions()<CR>")
map('n', 'gD',        "<cmd>lua require('fzf-lua').lsp_definitions({ jump1_action = require('fzf-lua.actions').file_tabedit, actions = { enter = require('fzf-lua.actions').file_tabedit } })<CR>")
map('n', 'gr',        "<cmd>lua require('fzf-lua').lsp_references()<CR>")
map('n', 'gh',        switch_source_header, { desc = "Switch between header and source" })
map('n', '[',         switch_source_header, { desc = "Switch between header and source" })
map('n', ']',         "<cmd>lua require('fzf-lua').lsp_finder()<CR>")
map('n', '{',         "<cmd>lua require('fzf-lua').lsp_document_symbols()<CR>")
map('n', '\"',        "<cmd>lua require('fzf-lua').oldfiles({ cwd_only = true })<CR>")
map('n', '<C-S-\'>',  "<cmd>lua require('fzf-lua').oldfiles()<CR>")
map('n', '\'',        "<cmd>lua require('fzf-lua').files()<CR>")
--map('n', '\'',        "<cmd>lua require('fzf-lua').grep_curbuf()<CR>")
--map('n', '\"',        "<cmd>lua require('fzf-lua').grep_project()<CR>")
--map('n', '<C-\'>',    "<cmd>lua require('fzf-lua').grep_cword()<CR>")

-- Interactive git changed files picker with <C-g> mode cycling (All -> Worktree -> HEAD)
local GitChangedPreviewer = nil
local function get_git_changed_previewer()
  if GitChangedPreviewer then return GitChangedPreviewer end
  local fzf_previewer = require("fzf-lua.previewer.fzf")
  GitChangedPreviewer = fzf_previewer.base:extend()

  function GitChangedPreviewer:fzf_delimiter()
    return "[\t]"
  end

  function GitChangedPreviewer:preview_window()
    local cols = vim.o.columns or 120
    return (cols >= 180) and "right:55%" or "right:50%"
  end

  function GitChangedPreviewer:cmdline(o)
    o = o or {}
    local act = function(items, fzf_lines, fzf_columns)
      if not items or not items[1] then
        return require("fzf-lua.utils").shell_nop()
      end
      local entry_str = items[1]
      local utils = require("fzf-lua.utils")
      local clean = utils.strip_ansi_coloring(entry_str)
      local file = clean:match("\t[^\t]+\t(.*)$") or clean:match("\t(.*)$")
      if not file or file == "" then
        return utils.shell_nop()
      end

      local root = self.opts.cwd or vim.fn.getcwd()
      local tag = clean:match("(%b[])") or ""
      local head_base = self.opts.head_base or "HEAD~1"

      local git_cmd
      if tag:find("NEW") then
        git_cmd = string.format("git -C %s --no-optional-locks diff --color=always --no-index /dev/null -- %s",
          vim.fn.shellescape(root), vim.fn.shellescape(file))
      elseif tag:find("H%*") then
        git_cmd = string.format("git -C %s --no-optional-locks diff --color=always %s -- %s",
          vim.fn.shellescape(root), head_base, vim.fn.shellescape(file))
      elseif tag:find("HEAD") then
        git_cmd = string.format("git -C %s --no-optional-locks diff --color=always %s HEAD -- %s",
          vim.fn.shellescape(root), head_base, vim.fn.shellescape(file))
      else
        git_cmd = string.format("git -C %s --no-optional-locks diff --color=always HEAD -- %s",
          vim.fn.shellescape(root), vim.fn.shellescape(file))
      end

      local pager = ""
      if vim.fn.executable("delta") == 1 then
        local bg = (vim.o.background == "dark") and "--dark" or "--light"
        local cols = (tonumber(fzf_columns) and tonumber(fzf_columns) > 0) and fzf_columns or "${FZF_PREVIEW_COLUMNS:-${COLUMNS:-80}}"
        pager = string.format("| delta --width=%s %s", tostring(cols), bg)
      elseif vim.fn.executable("bat") == 1 then
        pager = "| bat --style=plain --color=always"
      end

      local cmd = string.format("%s 2>/dev/null %s", git_cmd, pager)
      local env = {
        ["LINES"] = fzf_lines,
        ["COLUMNS"] = fzf_columns,
        ["FZF_PREVIEW_LINES"] = fzf_lines,
        ["FZF_PREVIEW_COLUMNS"] = fzf_columns,
      }
      return { cmd = cmd, env = env }
    end
    return { fn = act, type = "cmd", field_index = "{} {q}" }
  end

  return GitChangedPreviewer
end

local function truncate_left(str, max_len)
  if vim.fn.strdisplaywidth(str) <= max_len then
    return str
  end
  if max_len <= 1 then
    return "…"
  end
  local target_suffix_width = max_len - 1
  local len = #str
  for i = 1, len do
    local suffix = str:sub(i)
    if vim.fn.strdisplaywidth(suffix) <= target_suffix_width then
      return "…" .. suffix
    end
  end
  return "…"
end

local function shorten_path(path, max_len)
  if not max_len or max_len <= 0 or vim.fn.strdisplaywidth(path) <= max_len then
    return path
  end

  local parts = vim.split(path, "/", { plain = true })
  local n = #parts
  if n <= 1 then
    return truncate_left(parts[1], max_len)
  end

  local filename = parts[n]
  if n == 2 then
    local c1 = "…/" .. filename
    if vim.fn.strdisplaywidth(c1) <= max_len then
      return c1
    end
    if vim.fn.strdisplaywidth(filename) <= max_len then
      return filename
    end
    return truncate_left(filename, max_len)
  end

  local head_idx = 1
  local tail_idx = n - 1

  local function build_candidate(h, t)
    local head_str = table.concat(parts, "/", 1, h)
    local tail_str = table.concat(parts, "/", t, n)
    if h >= t - 1 then
      return head_str .. "/" .. tail_str
    end
    return head_str .. "/…/" .. tail_str
  end

  local base = build_candidate(head_idx, tail_idx)
  if vim.fn.strdisplaywidth(base) <= max_len then
    local best = base
    local prefer_tail = true
    while head_idx < tail_idx - 1 do
      local expanded = false
      if prefer_tail then
        local cand = build_candidate(head_idx, tail_idx - 1)
        if vim.fn.strdisplaywidth(cand) <= max_len then
          best = cand
          tail_idx = tail_idx - 1
          expanded = true
        else
          cand = build_candidate(head_idx + 1, tail_idx)
          if vim.fn.strdisplaywidth(cand) <= max_len then
            best = cand
            head_idx = head_idx + 1
            expanded = true
          end
        end
      else
        local cand = build_candidate(head_idx + 1, tail_idx)
        if vim.fn.strdisplaywidth(cand) <= max_len then
          best = cand
          head_idx = head_idx + 1
          expanded = true
        else
          cand = build_candidate(head_idx, tail_idx - 1)
          if vim.fn.strdisplaywidth(cand) <= max_len then
            best = cand
            tail_idx = tail_idx - 1
            expanded = true
          end
        end
      end
      if not expanded then
        break
      end
      prefer_tail = not prefer_tail
    end
    return best
  end

  local c_parent = "…/" .. parts[n - 1] .. "/" .. filename
  if vim.fn.strdisplaywidth(c_parent) <= max_len then
    return c_parent
  end

  local c_start = parts[1] .. "/…/" .. filename
  if vim.fn.strdisplaywidth(c_start) <= max_len then
    return c_start
  end

  local c_file = "…/" .. filename
  if vim.fn.strdisplaywidth(c_file) <= max_len then
    return c_file
  end

  if vim.fn.strdisplaywidth(filename) <= max_len then
    return filename
  end

  return truncate_left(filename, max_len)
end

local function git_changed_picker(mode, opts)
  opts = opts or {}
  mode = mode or "both"

  local root = vim.fn.systemlist("git rev-parse --show-toplevel 2>/dev/null")[1]
  if not root or root == "" then
    vim.notify("Not in a git repository", vim.log.levels.WARN)
    return
  end

  local fzf = require("fzf-lua")
  local devicons = require("fzf-lua.devicons")
  devicons.load()

  -- Check if HEAD~1 exists (repository has at least 2 commits)
  vim.fn.system("git rev-parse --verify --quiet HEAD~1")
  local head_base = (vim.v.shell_error == 0) and "HEAD~1" or "4b825dc642cb6eb9a060e54bf8d69288fbee4904"

  local head_files = {}
  if mode == "head" or mode == "both" then
    head_files = vim.fn.systemlist("git --no-optional-locks diff-tree --no-commit-id --name-only -r --root HEAD 2>/dev/null")
  end

  local status_lines = {}
  if mode == "worktree" or mode == "both" then
    status_lines = vim.fn.systemlist("git -c color.status=false --no-optional-locks status --porcelain=v1 -u 2>/dev/null")
  end

  local files_map = {}
  local order = {}

  local function record(path, tag_text, tag_color)
    if not files_map[path] then
      table.insert(order, path)
    end
    files_map[path] = { text = tag_text, color = tag_color }
  end

  if mode == "head" or mode == "both" then
    for _, p in ipairs(head_files) do
      if #p > 0 then
        record(p, "[HEAD]", "\27[35m") -- Magenta
      end
    end
  end

  if mode == "worktree" or mode == "both" then
    for _, line in ipairs(status_lines) do
      if #line >= 4 then
        local x = line:sub(1, 1)
        local y = line:sub(2, 2)
        local p = line:sub(4):gsub('^.* %-> ', ''):gsub('^"', ''):gsub('"$', '')

        local tag_text, tag_color
        if x == '?' then
          tag_text = "[NEW]"
          tag_color = "\27[36m" -- Cyan
        elseif files_map[p] and mode == "both" then
          tag_text = "[H*]"
          tag_color = "\27[1;35m" -- Bold Magenta (in HEAD + modified in worktree)
        elseif x == 'D' or y == 'D' then
          tag_text = "[DEL]"
          tag_color = "\27[31m" -- Red
        elseif x ~= ' ' and y ~= ' ' then
          tag_text = "[SM]"
          tag_color = "\27[1;33m" -- Bold Yellow (staged + unstaged)
        elseif x ~= ' ' then
          tag_text = "[STAGED]"
          tag_color = "\27[32m" -- Green
        else
          tag_text = "[MOD]"
          tag_color = "\27[33m" -- Yellow
        end
        record(p, tag_text, tag_color)
      end
    end
  end

  if mode == "both" and #order == 0 and not opts._is_cycle then
    vim.notify("No files changed in HEAD or working tree", vim.log.levels.INFO)
    return
  end

  local cols = vim.o.columns or 120
  local float_width = math.floor(cols * 0.90)
  local inner_width = float_width - 2 -- rounded border
  local prev_ratio = (cols >= 180) and 0.55 or 0.50
  local prev_cols = math.floor(inner_width * prev_ratio)
  local list_cols = inner_width - prev_cols - 1 -- preview divider
  -- Gutter/pointer (2) + badge (8) + space (1) + devicon (~2) + tab (~4) + margin/scrollbar (3) = 20
  local prefix_and_margin = 20
  local max_path_len = math.max(16, list_cols - prefix_and_margin)

  local entries = {}
  for _, p in ipairs(order) do
    local info = files_map[p]
    local icon, _ = devicons.get_devicon(p)
    icon = icon or " "
    local padded_tag = string.format("%-8s", info.text)
    local colored_tag = string.format("%s%s\27[0m", info.color, padded_tag)
    local col1 = string.format("%s %s", colored_tag, icon)
    local disp = shorten_path(p, max_path_len)
    table.insert(entries, string.format("%s\t%s\t%s", col1, disp, p))
  end

  local mode_info = {
    both = {
      title = "Git Active (All)",
      prompt = "Git Active (All)> ",
      header = ":: <C-g>: Cycle Scope [All ➔ Worktree ➔ HEAD] | <C-d>/<C-u>: Scroll Preview",
      next = "worktree",
    },
    worktree = {
      title = (#entries == 0) and "Git Working Tree (Clean)" or "Git Working Tree",
      prompt = (#entries == 0) and "Git Working Tree (Clean)> " or "Git Working Tree> ",
      header = ":: <C-g>: Cycle Scope [Worktree ➔ HEAD ➔ All] | <C-d>/<C-u>: Scroll Preview",
      next = "head",
    },
    head = {
      title = "Git HEAD Commit",
      prompt = "Git HEAD Commit> ",
      header = ":: <C-g>: Cycle Scope [HEAD ➔ All ➔ Worktree] | <C-d>/<C-u>: Scroll Preview",
      next = "both",
    },
  }

  local cur_info = mode_info[mode]

  local fzf_actions = vim.tbl_deep_extend("force", fzf.defaults.actions.files, {
    ["ctrl-g"] = {
      fn = function()
        local next_mode = cur_info.next
        git_changed_picker(next_mode, {
          query = fzf.get_last_query() or "",
          _is_cycle = true,
        })
      end,
      reuse = true,
      header = false,
    },
  })

  fzf.fzf_exec(entries, {
    cwd = root,
    head_base = head_base,
    query = opts.query or "",
    prompt = cur_info.prompt,
    actions = fzf_actions,
    keymap = {
      builtin = {
        ["<c-d>"] = "preview-half-page-down",
        ["<c-u>"] = "preview-half-page-up",
      },
      fzf = {
        ["ctrl-d"] = "preview-half-page-down",
        ["ctrl-u"] = "preview-half-page-up",
      },
    },
    previewer = {
      _ctor = get_git_changed_previewer,
    },
    fzf_opts = {
      ["--delimiter"] = "[\t]",
      ["--with-nth"] = "1,2",
      ["--header"] = cur_info.header,
    },
    _fmt = {
      from = function(x)
        return x:match("\t[^\t]+\t(.*)$") or x:match("\t(.*)$") or x
      end,
    },
    winopts = {
      width = 0.90,
      height = 0.85,
      title = " " .. cur_info.title .. " ",
    },
  })
end

map('n', '<leader>g', function() git_changed_picker('both') end, { desc = "Git changed files (HEAD + worktree)" })

vim.api.nvim_create_user_command('GitChanged', function(cmd_opts)
  local m = (cmd_opts.args ~= "") and cmd_opts.args or "both"
  git_changed_picker(m)
end, {
  nargs = '?',
  complete = function() return { 'both', 'worktree', 'head' } end,
  desc = "Fuzzy picker for git changed files with <C-g> mode cycling",
})

-- grug-far.nvim bindings
-- current cursor word, current file
map('n', '_', "<cmd>lua require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>'), paths = vim.fn.expand('%') }})<CR>")
-- current visual selection, current file
map('v', '_', "<cmd>lua require('grug-far').with_visual_selection({ prefills = { search = vim.fn.expand('<cword>'), paths = vim.fn.expand('%') }})<CR>")
-- current cursor word
--map('n', '\"', "<cmd>lua require('grug-far').open({ prefills = { search = vim.fn.expand('<cword>') } })<CR>")
-- current visual selection
--map('v', '\"', "<cmd>lua require('grug-far').with_visual_selection()<CR>")

map('n', '.',   "ms*")
map('n', ',',   "ms#")
map('n', '<Esc>', ":noh<CR>")

map('n', '<',      "<<", {noremap = true})
map('n', '>',      ">>", {noremap = true})

map('v', '<',      "<gv", {noremap = true})
map('v', '>',      ">gv", {noremap = true})

map('i', '', '<C-W>')
map('i', '<C-Del>', '<C-o>dw')

map('n', 'yp', '<cmd>lua vim.fn.setreg("\\\"", vim.fn.expand("%:p:h"))<CR>')

map('v', 'r', '"_dp')

-- Prompt navigation motions (Zellij scrollback & terminal buffers)
local function jump_prompt(backwards)
  local flags = backwards and 'bW' or 'W'
  local found = vim.fn.search([[❯]], flags)
  if found == 0 then
    vim.fn.search([[\v(^\s*[\$#%] |❯)]], flags)
  end
end

vim.keymap.set({ 'n', 'v', 'o' }, '<C-k>', function() jump_prompt(true) end, { desc = 'Jump to previous prompt' })
vim.keymap.set({ 'n', 'v', 'o' }, '<C-j>', function() jump_prompt(false) end, { desc = 'Jump to next prompt' })

-- File-level jumplist navigation (skip intra-file jumps & ghost/deleted files)
local function is_valid_jump_target(bufnr, cur_buf)
  if bufnr == cur_buf or not vim.api.nvim_buf_is_valid(bufnr) then
    return false
  end
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == '' then
    return false
  end
  if vim.api.nvim_buf_is_loaded(bufnr) then
    local buftype = vim.api.nvim_get_option_value('buftype', { buf = bufnr })
    if buftype ~= '' and buftype ~= 'help' then
      return false
    end
    if vim.uv.fs_stat(name) or vim.api.nvim_get_option_value('modified', { buf = bufnr }) then
      return true
    end
    return false
  end
  return vim.uv.fs_stat(name) ~= nil
end

local function jump_file(direction)
  local jumps, idx = unpack(vim.fn.getjumplist())
  local cur_buf = vim.api.nvim_get_current_buf()

  if direction == 'backward' then
    for i = idx, 1, -1 do
      local j = jumps[i]
      if is_valid_jump_target(j.bufnr, cur_buf) then
        local count = idx - (i - 1)
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(count .. '<C-o>', true, false, true), 'nx', false)
        return true
      end
    end
    vim.notify('No previous file in jumplist', vim.log.levels.INFO)
    return false
  else
    local target_buf = nil
    local target_idx = nil
    for i = idx + 2, #jumps do
      local j = jumps[i]
      if not target_buf then
        if is_valid_jump_target(j.bufnr, cur_buf) then
          target_buf = j.bufnr
          target_idx = i
        end
      else
        if j.bufnr == target_buf then
          target_idx = i
        else
          break
        end
      end
    end

    if target_idx then
      local count = (target_idx - 1) - idx
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(count .. '<C-i>', true, false, true), 'nx', false)
      return true
    end

    vim.notify('No next file in jumplist', vim.log.levels.INFO)
    return false
  end
end


map('n', '<leader>o', function() jump_file('backward') end, { desc = 'Jump to previous file in jumplist' })
map('n', '<leader>i', function() jump_file('forward') end, { desc = 'Jump to next file in jumplist' })

vim.keymap.set(
	{ "n" },
	"M",
	"<cmd>lua require('maximize').toggle()<CR>",
	{ desc = "MaximizekToggle" }
)

vim.keymap.set(
	{ "n", "o", "x" },
	"W",
	"<cmd>lua require('spider').motion('w')<CR>",
	{ desc = "Spider-w" }
)
vim.keymap.set(
	{ "n", "o", "x" },
	"E",
	"<cmd>lua require('spider').motion('e')<CR>",
	{ desc = "Spider-e" }
)
vim.keymap.set(
	{ "n", "o", "x" },
	"B",
	"<cmd>lua require('spider').motion('b')<CR>",
	{ desc = "Spider-b" }
)
