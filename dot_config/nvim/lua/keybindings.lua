local function map(mode, combo, mapping, opts)
  local options = {noremap = true, silent = true}
  if opts then
    options = vim.tbl_extend('force', options, opts)
  end
  vim.keymap.set(mode, combo, mapping, options)
end

vim.g.mapleader = ';'
vim.g.maplocalleader = ';;'

-- Zellij-related Bindings
local function zellij(...)
  vim.system({ 'zellij', 'action', ... })
end

map('n', '<A-h>',         function() require('smart-splits').move_cursor_left() end)
map('n', '<A-j>',         function() require('smart-splits').move_cursor_down() end)
map('n', '<A-k>',         function() require('smart-splits').move_cursor_up() end)
map('n', '<A-l>',         function() require('smart-splits').move_cursor_right() end)

map('n', '<A-C-h>',       function() require('smart-splits').resize_left() end)
map('n', '<A-C-j>',       function() require('smart-splits').resize_down() end)
map('n', '<A-C-k>',       function() require('smart-splits').resize_up() end)
map('n', '<A-C-l>',       function() require('smart-splits').resize_right() end)

map('n', '<A-Left>',      function() zellij('go-to-previous-tab') end)
map('n', '<A-Right>',     function() zellij('go-to-next-tab') end)
map('n', '<A-S-h>',       function() zellij('move-pane', 'left') end)
map('n', '<A-S-l>',       function() zellij('move-pane', 'right') end)
map('n', '<A-S-j>',       function() zellij('move-pane', 'down') end)
map('n', '<A-S-k>',       function() zellij('move-pane', 'up') end)
map('n', '<A-C-Left>',    function() zellij('move-tab', 'left') end)
map('n', '<A-C-Right>',   function() zellij('move-tab', 'right') end)
map('n', '<A-S-[>',       function() zellij('previous-swap-layout') end)
map('n', '<A-S-]>',       function() zellij('next-swap-layout') end)
map('n', '<A-1>',         function() zellij('go-to-tab', '1') end)
map('n', '<A-2>',         function() zellij('go-to-tab', '2') end)
map('n', '<A-3>',         function() zellij('go-to-tab', '3') end)
map('n', '<A-4>',         function() zellij('go-to-tab', '4') end)
map('n', '<A-5>',         function() zellij('go-to-tab', '5') end)
map('n', '<A-6>',         function() zellij('go-to-tab', '6') end)
map('n', '<A-7>',         function() zellij('go-to-tab', '7') end)
map('n', '<A-8>',         function() zellij('go-to-tab', '8') end)
map('n', '<A-9>',         function() zellij('go-to-tab', '9') end)
map('n', '<A-0>',         function() zellij('go-to-tab', '10') end)
map('n', '<A-s>',         function() zellij('new-pane', '-d', 'right', '--cwd', vim.fn.getcwd()) end)
map('n', '<A-n>',         function() zellij('new-tab', '--cwd', vim.fn.getcwd()) end)
map('n', '<A-f>',         function() zellij('toggle-fullscreen') end)
--map('n', '<A-S-s>',       function() require('focus').split_nicely() end)
map('n', '<A-S-s>',       function() require('focus').split_command('l') end)
map('n', '<A-S-e>',       function() require('focus').focus_equalise() end)
map('n', '<A-S-r>',       function() require('focus').focus_autoresize() end)
--map('n', '<A-S-f>',       function() require('focus').focus_max_or_equal() end)
map('n', '<A-S-f>',       function() require('maximize').toggle() end)
map('n', '<A-w>',         ":w<CR>")
map('n', '<A-d>',         ":q<CR>")
map('n', '<A-q>',         ":q<CR>")
map('n', '<A-S-q>',       ":q!<CR>")
map('n', '<A-Q>',         ":q!<CR>")
--map('n', '<A-]>',         ":tab split<CR>")
map('n', '<A-C-S-]>',       "<C-w>r")
map('n', '<A-S-n>',       ":$tabnew<CR>")
map('n', '<A-S-d>',       "<cmd>NvimTreeClose<CR><cmd>tabclose<CR>")
map('n', '<A-S-Left>',    ":tabp<CR>")
map('n', '<A-S-Right>',   ":tabn<CR>")
map('n', '<A-S-1>',       "1gt")
map('n', '<A-S-2>',       "2gt")
map('n', '<A-S-3>',       "3gt")
map('n', '<A-S-4>',       "4gt")
map('n', '<A-S-5>',       "5gt")
map('n', '<A-S-6>',       "6gt")
map('n', '<A-S-7>',       "7gt")
map('n', '<A-S-8>',       "8gt")
map('n', '<A-S-9>',       "9gt")
map('n', '<A-S-0>',       "10gt")

map('n', '<A-!>',         "1gt")
map('n', '<A-@>',         "2gt")
map('n', '<A-#>',         "3gt")
map('n', '<A-$>',         "4gt")
map('n', '<A-%>',         "5gt")
map('n', '<A-^>',         "6gt")
map('n', '<A-&>',         "7gt")
map('n', '<A-*>',         "8gt")
map('n', '<A-(>',         "9gt")
map('n', '<A-)>',         "10gt")

map('n', '<A-S-`>',       "g<Tab>")
map('n', '<A-~>',         "g<Tab>")
map('n', '<C-A-S-Left>',  ":-tabmove<CR>")
map('n', '<C-A-S-Right>', ":+tabmove<CR>")
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
  local builtin_previewer = require("fzf-lua.previewer.builtin")
  GitChangedPreviewer = builtin_previewer.base:extend()

  function GitChangedPreviewer:gen_winopts()
    local winopts = {
      wrap = false,
      cursorline = false,
      number = false,
    }
    return vim.tbl_extend("keep", winopts, self.winopts or {})
  end

  function GitChangedPreviewer:populate_preview_buf(entry_str)
    if not self.win or not self.win:validate_preview() then return end
    local utils = require("fzf-lua.utils")
    local clean = utils.strip_ansi_coloring(entry_str)
    local file = clean:match("\t(.*)$")
    if not file then return end

    local root = self.opts.cwd or vim.fn.getcwd()
    local fullpath = (file:sub(1, 1) == "/") and file or (root .. "/" .. file)
    local tag = clean:match("(%b[])") or ""
    local head_base = self.opts.head_base or "HEAD~1"
    local buf = self:get_tmp_buffer()

    local lines = {}
    local ft = "diff"

    if tag:find("NEW") then
      if vim.uv.fs_stat(fullpath) then
        local ok, content = pcall(vim.fn.readfile, fullpath)
        if ok then
          lines = content
          ft = vim.filetype.match({ filename = fullpath }) or "text"
        end
      end
    elseif tag:find("H%*") then
      local diff_cmd = string.format("git -C %s --no-optional-locks diff %s -- %s", vim.fn.shellescape(root), head_base, vim.fn.shellescape(file))
      lines = vim.fn.systemlist(diff_cmd)
    elseif tag:find("HEAD") then
      local diff_cmd = string.format("git -C %s --no-optional-locks diff %s HEAD -- %s", vim.fn.shellescape(root), head_base, vim.fn.shellescape(file))
      lines = vim.fn.systemlist(diff_cmd)
    else
      local diff_cmd = string.format("git -C %s --no-optional-locks diff HEAD -- %s", vim.fn.shellescape(root), vim.fn.shellescape(file))
      lines = vim.fn.systemlist(diff_cmd)
    end

    -- Fallback to reading file if diff is empty
    if #lines == 0 and vim.uv.fs_stat(fullpath) then
      local ok, content = pcall(vim.fn.readfile, fullpath)
      if ok then
        lines = content
        ft = vim.filetype.match({ filename = fullpath }) or "text"
      end
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].filetype = ft
    self:set_preview_buf(buf)
    self.win:update_preview_title(string.format(" %s %s ", tag, file))
    self.win:update_preview_scrollbar()
    return true
  end

  return GitChangedPreviewer
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

  local entries = {}
  for _, p in ipairs(order) do
    local info = files_map[p]
    local icon, _ = devicons.get_devicon(p)
    icon = icon or " "
    local padded_tag = string.format("%-8s", info.text)
    local colored_tag = string.format("%s%s\27[0m", info.color, padded_tag)
    local col1 = string.format("%s %s", colored_tag, icon)
    table.insert(entries, string.format("%s\t%s", col1, p))
  end

  local mode_info = {
    both = {
      title = "Git Active (All)",
      prompt = "Git Active (All)> ",
      header = ":: <C-g>: Cycle Scope [All ➔ Worktree ➔ HEAD]",
      next = "worktree",
    },
    worktree = {
      title = (#entries == 0) and "Git Working Tree (Clean)" or "Git Working Tree",
      prompt = (#entries == 0) and "Git Working Tree (Clean)> " or "Git Working Tree> ",
      header = ":: <C-g>: Cycle Scope [Worktree ➔ HEAD ➔ All]",
      next = "head",
    },
    head = {
      title = "Git HEAD Commit",
      prompt = "Git HEAD Commit> ",
      header = ":: <C-g>: Cycle Scope [HEAD ➔ All ➔ Worktree]",
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
        return x:match("\t(.*)$") or x
      end,
    },
    winopts = {
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
