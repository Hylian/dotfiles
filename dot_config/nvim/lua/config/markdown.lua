local M = {}

local MAX_WIDTH = 80

local function display_width(str)
  return vim.api.nvim_strwidth(str)
end

local function is_blank(line)
  return line:match('^%s*$') ~= nil
end

local function match_fence(line)
  local ticks = line:match('^%s*(`+)[^`]*$')
  if ticks and #ticks >= 3 then
    return '`', #ticks
  end
  local tildes = line:match('^%s*(~+).*$')
  if tildes and #tildes >= 3 then
    return '~', #tildes
  end
  return nil, nil
end

local function is_closing_fence(line, char, min_len)
  local pat = '^%s*(' .. vim.pesc(char) .. '+)%s*$'
  local m = line:match(pat)
  return m ~= nil and #m >= min_len
end

local function is_thematic_break_or_setext(line)
  local stripped = line:match('^%s*(.-)%s*$')
  if #stripped < 3 then
    return false
  end
  if stripped:match('^[-%s]+$') then
    local _, count = stripped:gsub('-', '')
    return count >= 3
  elseif stripped:match('^[*%s]+$') then
    local _, count = stripped:gsub('%*', '')
    return count >= 3
  elseif stripped:match('^[_%s]+$') then
    local _, count = stripped:gsub('_', '')
    return count >= 3
  elseif stripped:match('^[=%s]+$') then
    local _, count = stripped:gsub('=', '')
    return count >= 3
  end
  return false
end

local function is_table_line(line)
  if line:match('^%s*|') then
    return true
  end
  local without_code = line:gsub('`[^`]*`', '')
  local _, pipes = without_code:gsub('|', '')
  return pipes >= 2
end

local function is_standalone_line(line)
  if is_blank(line) then
    return true
  end
  if line:match('^%s*#+%s+') or line:match('^%s*#+$') then
    return true
  end
  if is_thematic_break_or_setext(line) then
    return true
  end
  if is_table_line(line) then
    return true
  end
  if line:match('^%s*%[[^%]]+%]:%s+%S+') then
    return true
  end
  if line:match('^%s*</?[%a!]') then
    return true
  end
  if line:match('^%s*>+%s*%[![%u]+%]%s*$') then
    return true
  end
  return false
end

local function has_hard_break(line)
  return line:match('  +$') ~= nil or line:match('\\$') ~= nil
end

local function is_bold_metadata_line(line)
  return line:match('^%s*>?%s*%*%*[^%*]+:%*%*') ~= nil
    or line:match('^%s*>?%s*%*%*[^%*]+%*%*:') ~= nil
end

local function parse_list_item(line)
  local bq, rest = line:match('^(%s*>+%s*)(.*)$')
  if not bq then
    bq = ''
    rest = line
  end
  local indent, marker, content = rest:match('^(%s*)([-*+]%s+%[[ xX]%]%s+)(.*)$')
  if not indent then
    indent, marker, content = rest:match('^(%s*)(%d+[%.%)]%s+%[[ xX]%]%s+)(.*)$')
  end
  if not indent then
    indent, marker, content = rest:match('^(%s*)([-*+]%s+)(.*)$')
  end
  if not indent then
    indent, marker, content = rest:match('^(%s*)(%d+[%.%)]%s+)(.*)$')
  end
  if not indent or content == '' then
    return nil
  end
  local first_prefix = bq .. indent .. marker
  local cont_prefix = bq .. string.rep(' ', #indent + #marker)
  return first_prefix, cont_prefix, content
end

local function parse_prose_line(line)
  local bq, rest = line:match('^(%s*>+%s*)(.*)$')
  if bq then
    local alert, alert_rest = rest:match('^(%[![%u]+%]%s+)(.+)$')
    if alert then
      return bq .. alert, bq, alert_rest
    end
    return bq, bq, rest
  end
  local indent, content = line:match('^(%s*)(.*)$')
  if #indent >= 4 then
    return nil
  end
  return indent, indent, content
end

local function find_code_span_end(text, start_pos)
  local ticks = text:match('^(`+)', start_pos)
  if not ticks then
    return nil
  end
  local tick_len = #ticks
  local pos = start_pos + tick_len
  local n = #text
  while pos <= n do
    local s, e = text:find('`+', pos)
    if not s then
      return nil
    end
    if e - s + 1 == tick_len then
      return e
    end
    pos = e + 1
  end
  return nil
end

local function find_markdown_link_end(text, start_pos)
  local pos
  if text:sub(start_pos, start_pos) == '[' then
    pos = start_pos + 1
  elseif text:sub(start_pos, start_pos + 1) == '![' then
    pos = start_pos + 2
  else
    return nil
  end

  local n = #text
  while pos <= n do
    local ch = text:sub(pos, pos)
    if ch == '`' then
      local code_end = find_code_span_end(text, pos)
      if code_end then
        pos = code_end + 1
      else
        local _, tick_end = text:find('^`+', pos)
        pos = (tick_end or pos) + 1
      end
    elseif ch == '\\' then
      pos = pos + 2
    elseif ch == '[' then
      return nil
    elseif ch == ']' then
      local _, link_end = text:find('^%([^%s%)]+%)', pos + 1)
      if link_end then
        return link_end
      end
      return nil
    else
      pos = pos + 1
    end
  end

  return nil
end

local function scan_compound_token(text, start_pos)
  local n = #text
  local j = start_pos

  while j <= n and not text:sub(j, j):match('^%s') do
    local ch = text:sub(j, j)
    if ch == '`' then
      local code_end = find_code_span_end(text, j)
      if code_end then
        j = code_end + 1
      else
        local _, tick_end = text:find('^`+', j)
        j = (tick_end or j) + 1
      end
    elseif ch == '[' or (ch == '!' and text:sub(j + 1, j + 1) == '[') then
      local link_end = find_markdown_link_end(text, j)
      if link_end then
        j = link_end + 1
      else
        j = j + 1
      end
    else
      j = j + 1
    end
  end

  return text:sub(start_pos, j - 1)
end

local function tokenize_markdown(text, cont_width, max_width)
  local tokens = {}
  local n = #text
  local i = 1
  local max_span_width = max_width - cont_width

  while i <= n do
    local s, e = text:find('^%s+', i)
    if s then
      i = e + 1
    else
      local span = scan_compound_token(text, i)
      if display_width(span) <= max_span_width then
        table.insert(tokens, span)
      else
        for word in span:gmatch('%S+') do
          table.insert(tokens, word)
        end
      end
      i = i + #span
    end
  end

  return tokens
end

local function wrap_tokens(tokens, first_prefix, cont_prefix, max_width)
  if #tokens == 0 then
    return { (first_prefix:gsub('%s+$', '')) }
  end

  local out = {}
  local cur_prefix = first_prefix
  local cur_line = cur_prefix .. tokens[1]
  local cur_width = display_width(cur_line)

  for idx = 2, #tokens do
    local tok = tokens[idx]
    local tok_width = display_width(tok)
    if cur_width + 1 + tok_width <= max_width then
      cur_line = cur_line .. ' ' .. tok
      cur_width = cur_width + 1 + tok_width
    else
      table.insert(out, cur_line)
      cur_prefix = cont_prefix
      cur_line = cur_prefix .. tok
      cur_width = display_width(cur_line)
    end
  end
  table.insert(out, cur_line)
  return out
end

function M.format_lines(lines, max_width, cursor_lnum)
  max_width = max_width or MAX_WIDTH
  local out = {}
  local n = #lines
  local i = 1
  local new_cursor_lnum = cursor_lnum

  -- 1. YAML Frontmatter at top of file
  if n >= 1 and lines[1]:match('^---%s*$') then
    table.insert(out, lines[1])
    i = 2
    while i <= n do
      table.insert(out, lines[i])
      if lines[i]:match('^---%s*$') or lines[i]:match('^%.%.%.%s*$') then
        i = i + 1
        break
      end
      i = i + 1
    end
  end

  local in_fence = false
  local fence_char = nil
  local fence_len = 0

  while i <= n do
    local line = lines[i]

    -- Handle fenced code blocks
    if in_fence then
      table.insert(out, line)
      if cursor_lnum and i == cursor_lnum then
        new_cursor_lnum = #out
      end
      if is_closing_fence(line, fence_char, fence_len) then
        in_fence = false
        fence_char = nil
        fence_len = 0
      end
      i = i + 1
    else
      local fchar, flen = match_fence(line)
      if fchar then
        in_fence = true
        fence_char = fchar
        fence_len = flen
        table.insert(out, line)
        if cursor_lnum and i == cursor_lnum then
          new_cursor_lnum = #out
        end
        i = i + 1
      elseif is_standalone_line(line) then
        table.insert(out, line)
        if cursor_lnum and i == cursor_lnum then
          new_cursor_lnum = #out
        end
        i = i + 1
      else
        local first_prefix, cont_prefix, first_content = parse_list_item(line)
        local is_list = first_prefix ~= nil
        if not is_list then
          first_prefix, cont_prefix, first_content = parse_prose_line(line)
        end

        if not first_prefix then
          -- Indented code block or unrecognized line
          table.insert(out, line)
          if cursor_lnum and i == cursor_lnum then
            new_cursor_lnum = #out
          end
          i = i + 1
        else
          -- Collect all adjacent continuation lines for this list item, blockquote, or prose paragraph
          local parts = { vim.trim(first_content) }
          local raw_block = { line }
          local j = i + 1
          local prev_line = line

          while j <= n and not has_hard_break(prev_line) do
            local next_line = lines[j]
            if is_standalone_line(next_line) or match_fence(next_line) or is_bold_metadata_line(next_line) then
              break
            end
            if parse_list_item(next_line) then
              break
            end

            if is_list then
              -- Allow hanging-indented continuation lines (or lazy continuation lines with same blockquote prefix)
              local bq_prefix = cont_prefix:match('^(%s*>+%s*)') or ''
              local next_bq, next_rest = next_line:match('^(%s*>+%s*)(.*)$')
              if bq_prefix ~= '' then
                if next_bq == bq_prefix then
                  local indent_spaces = next_rest:match('^(%s*)')
                  local expected_indent = #cont_prefix - #bq_prefix
                  if #indent_spaces < expected_indent + 4 and vim.trim(next_rest) ~= '' then
                    table.insert(parts, vim.trim(next_rest))
                    table.insert(raw_block, next_line)
                    prev_line = next_line
                    j = j + 1
                  else
                    break
                  end
                else
                  break
                end
              else
                if not next_bq then
                  local indent_spaces = next_line:match('^(%s*)')
                  if #indent_spaces < #cont_prefix + 4 and vim.trim(next_line) ~= '' then
                    table.insert(parts, vim.trim(next_line))
                    table.insert(raw_block, next_line)
                    prev_line = next_line
                    j = j + 1
                  else
                    break
                  end
                else
                  break
                end
              end
            else
              local p_first, p_cont, p_content = parse_prose_line(next_line)
              if p_first and p_cont == cont_prefix and p_first == cont_prefix and vim.trim(p_content) ~= '' then
                table.insert(parts, vim.trim(p_content))
                table.insert(raw_block, next_line)
                prev_line = next_line
                j = j + 1
              else
                break
              end
            end
          end

          local trailing_break = ''
          if prev_line:match('  +$') then
            trailing_break = '  '
          end

          local combined = table.concat(parts, ' ')
          local tokens = tokenize_markdown(combined, display_width(cont_prefix), max_width)
          local wrapped = wrap_tokens(tokens, first_prefix, cont_prefix, max_width)
          if trailing_break ~= '' and #wrapped > 0 then
            wrapped[#wrapped] = wrapped[#wrapped] .. trailing_break
          end

          local out_start = #out
          for _, wline in ipairs(wrapped) do
            table.insert(out, wline)
          end
          if cursor_lnum and cursor_lnum >= i and cursor_lnum < j then
            local rel = cursor_lnum - i + 1
            new_cursor_lnum = math.min(#out, out_start + math.max(1, math.min(#wrapped, rel + (#wrapped - #raw_block))))
          end
          i = j
        end
      end
    end
  end

  return out, new_cursor_lnum
end

function M.format_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if vim.g.markdown_wrap_on_save == false or vim.b[bufnr].markdown_wrap_on_save == false then
    return
  end
  if not vim.bo[bufnr].modifiable or vim.bo[bufnr].buftype ~= '' then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local view = vim.fn.winsaveview()
  local cursor_lnum = view and view.lnum or nil
  local formatted, new_cursor_lnum = M.format_lines(lines, MAX_WIDTH, cursor_lnum)

  local changed = (#formatted ~= #lines)
  if not changed then
    for idx = 1, #lines do
      if formatted[idx] ~= lines[idx] then
        changed = true
        break
      end
    end
  end

  if not changed then
    return
  end

  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, formatted)
  if view then
    if new_cursor_lnum then
      view.lnum = math.max(1, math.min(#formatted, new_cursor_lnum))
    end
    vim.fn.winrestview(view)
  end
end

function M.setup()
  local group = vim.api.nvim_create_augroup('MarkdownLineLengthWrap', { clear = true })
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = group,
    pattern = { '*.md', '*.markdown' },
    desc = 'Auto-wrap Markdown prose and list items to <= 80 characters on save',
    callback = function(args)
      M.format_buffer(args.buf)
    end,
  })

  vim.api.nvim_create_user_command('MarkdownWrap', function()
    M.format_buffer(vim.api.nvim_get_current_buf())
  end, { desc = 'Reflow Markdown lines exceeding 80 characters' })
end

return M
