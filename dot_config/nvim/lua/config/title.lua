local M = {}

local last_file_title = nil
local applied_title = nil

local function format_path(path)
  if not path or path == '' then
    return nil
  end
  local formatted = vim.fn.fnamemodify(path, ':p:~')
  if #formatted > 1 then
    formatted = formatted:gsub('/+$', '')
  end
  return (formatted:gsub('[\r\n]+', ' '))
end

local function buf_filepath(buf)
  if not buf or not vim.api.nvim_buf_is_valid(buf) then
    return nil
  end

  local name = vim.api.nvim_buf_get_name(buf)
  local buftype = vim.bo[buf].buftype
  local filetype = vim.bo[buf].filetype

  if name:match('^diffview://') or filetype:match('^Diffview') then
    local dv_lib = package.loaded['diffview.lib']
    local view = dv_lib and dv_lib.get_current_view()
    if view and view.cur_entry and view.cur_entry.absolute_path and view.cur_entry.absolute_path ~= '' then
      return format_path(view.cur_entry.absolute_path)
    end
    return nil
  end

  if name:match('^fugitive://') then
    local repo, rel = name:match('^fugitive://(.-)/%.git//[^/]*/(.+)$')
    if repo and rel then
      return format_path(repo .. '/' .. rel)
    end
    return nil
  end

  if buftype == 'help' and name ~= '' then
    return 'help: ' .. vim.fn.fnamemodify(name, ':t')
  end

  if (buftype ~= '' and buftype ~= 'acwrite') or name == '' or name:match('^%w+://') then
    return nil
  end

  return format_path(name)
end

local function resolve_title()
  local win = vim.api.nvim_get_current_win()
  local ok, win_cfg = pcall(vim.api.nvim_win_get_config, win)
  if ok and win_cfg.relative and win_cfg.relative ~= '' then
    return applied_title or last_file_title or 'nvim'
  end

  local buf = vim.api.nvim_win_get_buf(win)
  local path = buf_filepath(buf)
  if path then
    if vim.bo[buf].buftype ~= 'help' then
      last_file_title = path
    end
    return path
  end

  if vim.bo[buf].buftype == '' and vim.api.nvim_buf_get_name(buf) == '' then
    return 'nvim'
  end

  local prev_win = vim.fn.win_getid(vim.fn.winnr('#'))
  if prev_win ~= 0 and vim.api.nvim_win_is_valid(prev_win) then
    local pok, pcfg = pcall(vim.api.nvim_win_get_config, prev_win)
    if pok and (not pcfg.relative or pcfg.relative == '') then
      local p = buf_filepath(vim.api.nvim_win_get_buf(prev_win))
      if p then
        return p
      end
    end
  end

  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    local wok, wcfg = pcall(vim.api.nvim_win_get_config, w)
    if wok and (not wcfg.relative or wcfg.relative == '') then
      local p = buf_filepath(vim.api.nvim_win_get_buf(w))
      if p then
        return p
      end
    end
  end

  return last_file_title or 'nvim'
end

function M.update()
  local title = resolve_title()
  if title == applied_title then
    return
  end
  applied_title = title
  vim.o.titlestring = title:gsub('%%', '%%%%')
end

function M.setup()
  if not vim.env.ZELLIJ and not vim.env.ZELLIJ_PANE_ID then
    return
  end

  vim.opt.titlelen = 0
  M.update()
  vim.opt.title = true

  local grp = vim.api.nvim_create_augroup('ZellijPaneTitle', { clear = true })
  vim.api.nvim_create_autocmd({
    'VimEnter',
    'BufEnter',
    'BufWinEnter',
    'BufFilePost',
    'BufWritePost',
    'WinEnter',
    'TabEnter',
    'DirChanged',
  }, {
    group = grp,
    desc = 'Update Zellij pane title with current filepath',
    callback = function()
      M.update()
    end,
  })
end

return M
