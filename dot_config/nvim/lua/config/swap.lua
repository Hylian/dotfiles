local M = {}

--- Setup intelligent non-blocking swap file management:
--- 1. Live PID: Open read-only and notify to avoid concurrent collision.
--- 2. Orphaned + Dirty: Edit anyway, preserve swap file as backup, and notify.
--- 3. Orphaned + Clean: Delete stale swap file automatically to prevent clutter.
function M.setup()
  local group = vim.api.nvim_create_augroup('SwapHandler', { clear = true })

  vim.api.nvim_create_autocmd('SwapExists', {
    group = group,
    pattern = '*',
    callback = function()
      local sname = vim.v.swapname
      local info = vim.fn.swapinfo(sname)

      -- Check if swap belongs to an active process on the current host
      local is_alive = false
      local current_host = vim.fn.hostname()
      local same_host = (not info.host or info.host == '' or info.host == current_host)

      if same_host and info.pid and info.pid > 0 and info.pid ~= vim.fn.getpid() then
        local success = vim.uv.kill(info.pid, 0)
        if success == 0 then
          is_alive = true
        end
      end

      if is_alive then
        -- Another active Neovim session owns this file: open read-only to prevent collisions
        vim.v.swapchoice = 'o'
        vim.schedule(function()
          vim.notify(
            string.format('File is open in another Neovim session (PID %d). Opened read-only.', info.pid),
            vim.log.levels.WARN,
            { title = 'Swap' }
          )
        end)
      elseif info.dirty == 1 then
        -- Orphaned crash/kill swap file with unsaved changes: keep backup, edit anyway, and notify
        vim.v.swapchoice = 'e'
        vim.schedule(function()
          vim.notify(
            'Orphaned swap file found with unsaved changes. Run :recover if needed.',
            vim.log.levels.INFO,
            { title = 'Swap' }
          )
        end)
      else
        -- Orphaned clean swap file: delete it automatically to prevent clutter
        vim.v.swapchoice = 'd'
      end
    end,
  })
end

return M
