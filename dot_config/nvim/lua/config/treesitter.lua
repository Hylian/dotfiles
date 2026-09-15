local ok_main, ts_main = pcall(require, 'nvim-treesitter')
local ok_configs, ts_configs = pcall(require, 'nvim-treesitter.configs')

if ok_main and ts_main.setup then
  -- Modern main branch (Neovim 0.12+)
  ts_main.setup({
    install_dir = vim.fs.joinpath(vim.fn.stdpath('data'), 'site'),
  })
  local ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" }
  local installed = ts_main.get_installed and ts_main.get_installed() or {}
  local missing = vim.tbl_filter(function(lang)
    return not vim.list_contains(installed, lang)
  end, ensure_installed)
  if #missing > 0 and ts_main.install then
    ts_main.install(missing)
  end
elseif ok_configs and ts_configs.setup then
  -- Legacy master branch fallback (Neovim <= 0.11)
  ts_configs.setup({
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "markdown", "markdown_inline" },
    auto_install = true,
    highlight = {
      enable = true,
      disable = function(lang, buf)
        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall((vim.uv or vim.loop).fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          return true
        end
      end,
      additional_vim_regex_highlighting = false,
    },
  })
end

-- 100 KB buffer size guard for native treesitter highlighting in Neovim 0.12+
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("treesitter_filesize_guard", { clear = true }),
  callback = function(args)
    local max_filesize = 100 * 1024 -- 100 KB
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
    if ok and stats and stats.size > max_filesize then
      pcall(vim.treesitter.stop, args.buf)
    end
  end,
})
require('treesitter-context').setup{
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 3, -- How many lines the window should span. Values <= 0 mean no limit.
  min_window_height = 20, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
  line_numbers = true,
  multiline_threshold = 20, -- Maximum number of lines to show for a single context
  trim_scope = 'outer', -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  mode = 'cursor',  -- Line used to calculate context. Choices: 'cursor', 'topline'
  -- Separator between context and content. Should be a single character string, like '-'.
  -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
  separator = nil,
  zindex = 20, -- The Z-index of the context window
  on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
}
