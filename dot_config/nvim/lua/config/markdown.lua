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
      local matched = false

      -- 1. Atomic inline code span (`...`) if it fits on a continuation line
      if text:sub(i, i) == '`' then
        local ticks = text:match('^(`+)', i)
        local close_pat = '^(' .. ticks .. '.-' .. ticks .. '[.,;:!?)%]]*)'
        local span = text:match(close_pat, i)
        if span and display_width(span) <= max_span_width then
          table.insert(tokens, span)
          i = i + #span
          matched = true
        end
      end

      -- 2. Atomic Markdown link/image ([label](url) or ![alt](url)) if it fits on a continuation line
      if not matched and (text:sub(i, i) == '[' or text:sub(i, i + 1) == '![') then
        local span = text:match('^(!?%[[^%]]+%]%([^%s%)]+%)[.,;:!?)%]]*)', i)
        if span and display_width(span) <= max_span_width then
          table.insert(tokens, span)
          i = i + #span
          matched = true
        end
      end

      -- 3. Default whitespace-delimited token
      if not matched then
        local word = text:match('^%S+', i)
        if word then
          table.insert(tokens, word)
          i = i + #word
        else
          break
        end
      end
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
        elseif not is_list and display_width(line) <= max_width then
          -- Plain prose line already <= max_width; keep untouched
          table.insert(out, line)
          if cursor_lnum and i == cursor_lnum then
            new_cursor_lnum = #out
          end
          i = i + 1
        else
          -- Collect continuation lines for this list item or overlong prose block
          local parts = { vim.trim(first_content) }
          local raw_block = { line }
          local block_overlong = display_width(line) > max_width
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
              if next_line:sub(1, #cont_prefix) == cont_prefix then
                local rest = next_line:sub(#cont_prefix + 1)
                if not rest:match('^    ') and vim.trim(rest) ~= '' then
                  table.insert(parts, vim.trim(rest))
                  table.insert(raw_block, next_line)
                  if display_width(next_line) > max_width then
                    block_overlong = true
                  end
                  prev_line = next_line
                  j = j + 1
                else
                  break
                end
              else
                break
              end
            else
              local p_first, p_cont, p_content = parse_prose_line(next_line)
              if p_first and p_cont == cont_prefix and p_first == cont_prefix and vim.trim(p_content) ~= '' then
                table.insert(parts, vim.trim(p_content))
                table.insert(raw_block, next_line)
                if display_width(next_line) > max_width then
                  block_overlong = true
                end
                prev_line = next_line
                j = j + 1
              else
                break
              end
            end
          end

          if not block_overlong then
            for idx, rline in ipairs(raw_block) do
              table.insert(out, rline)
              if cursor_lnum and (i + idx - 1) == cursor_lnum then
                new_cursor_lnum = #out
              end
            end
          else
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
  local has_overlong = false
  for _, line in ipairs(lines) do
    if display_width(line) > MAX_WIDTH then
      has_overlong = true
      break
    end
  end
  if not has_overlong then
    return
  end

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
