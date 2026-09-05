local M = {}

-- Cache resolved roots by directory to keep checks fast
local root_cache = {}

--- Find the project root for a given path or buffer.
--- Searches for:
--- 1. Nearest compilation database or config (compile_commands.json, .compile_commands, .clangd)
--- 2. Build directory compilation databases (build/compile_commands.json, out/compile_commands.json)
--- 3. Top-level Git repository (traversing up through submodules to the superproject)
--- 4. Standard project markers (.git, Cargo.toml, pyproject.toml, package.json)
---@param path? string
---@return string
function M.find_project_root(path)
  if not path or path == "" then
    path = vim.fn.getcwd()
  end

  -- If path is a file, use its directory
  if vim.fn.isdirectory(path) == 0 then
    path = vim.fs.dirname(path)
  end

  if not path or path == "" then
    return vim.fn.getcwd()
  end
  path = vim.fs.normalize(path)

  if root_cache[path] then
    return root_cache[path]
  end

  -- 1. Search upwards for compile_commands.json, .compile_commands, or .clangd FIRST
  local comp_db = vim.fs.find({ 'compile_commands.json', '.compile_commands', '.clangd' }, { upward = true, path = path })
  if #comp_db > 0 then
    local root = vim.fs.dirname(comp_db[1])
    root_cache[path] = root
    return root
  end

  -- 2. Search upwards for build/compile_commands.json or out/compile_commands.json
  local build_db = vim.fs.find({ 'build/compile_commands.json', 'out/compile_commands.json' }, { upward = true, path = path })
  if #build_db > 0 then
    local root = vim.fs.dirname(vim.fs.dirname(build_db[1]))
    root_cache[path] = root
    return root
  end

  -- 3. Check for Git repository root (including superproject if in a submodule)
  local git_out = vim.fn.systemlist(string.format('git -C %s rev-parse --show-superproject-working-tree --show-toplevel 2>/dev/null', vim.fn.shellescape(path)))
  if git_out and #git_out > 0 then
    local top = nil
    if git_out[1] and git_out[1] ~= '' then
      top = git_out[1]
      while true do
        local super = vim.fn.systemlist(string.format('git -C %s rev-parse --show-superproject-working-tree 2>/dev/null', vim.fn.shellescape(top)))[1]
        if super and super ~= '' then
          top = super
        else
          break
        end
      end
    elseif git_out[2] and git_out[2] ~= '' then
      top = git_out[2]
    end
    if top and top ~= '' then
      root_cache[path] = top
      return top
    end
  end

  -- 4. Fallback to standard project markers
  local marker_root = vim.fs.root(path, { '.git', 'Cargo.toml', 'pyproject.toml', 'package.json' })
  local root = marker_root or path
  root_cache[path] = root
  return root
end

--- Automatically change Neovim's working directory to the project root.
---@param bufnr? integer
---@return string?
function M.auto_root(bufnr)
  bufnr = bufnr or 0
  local buftype = vim.bo[bufnr].buftype
  if buftype ~= '' then return nil end

  local fname = vim.api.nvim_buf_get_name(bufnr)
  -- Ignore empty names or special URI schemes (fugitive://, oil://, etc.)
  if fname:match('^%w+://') then return nil end

  local path = (fname ~= '') and fname or vim.fn.getcwd()
  local root = M.find_project_root(path)
  if root and root ~= '' and root ~= vim.fn.getcwd() then
    vim.fn.chdir(root)
  end
  return root
end

-- Set up autocmds to maintain project root on VimEnter and buffer reads
function M.setup()
  local grp = vim.api.nvim_create_augroup('ProjectAutoRoot', { clear = true })
  vim.api.nvim_create_autocmd({ 'VimEnter', 'BufReadPost' }, {
    group = grp,
    callback = function(ev)
      M.auto_root(ev.buf)
    end,
  })
end

return M
