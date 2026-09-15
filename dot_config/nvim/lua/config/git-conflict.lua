-- Git Conflict Configuration
local ok, git_conflict = pcall(require, 'git-conflict')
if not ok then
  return
end

git_conflict.setup({
  default_mappings = true, -- binds: co (ours), ct (theirs), cb (both), c0 (none), [x, ]x
  default_commands = true,
  disable_diagnostics = false,
  list_opener = 'copen',
  highlights = {
    incoming = 'DiffAdd',
    current = 'DiffText',
  },
})
