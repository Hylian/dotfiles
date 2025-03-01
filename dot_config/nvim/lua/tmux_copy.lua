function tmux_copy(reg)
  local clipboard = reg == '+' and 'c' or 'p'
  return function(lines)
    local s = table.concat(lines, '\n')
    vim.api.nvim_chan_send(2, osc52(clipboard, vim.base64.encode(s)))
  end
end
