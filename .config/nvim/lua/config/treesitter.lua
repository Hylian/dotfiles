require'nvim-treesitter.configs'.setup {
  ensure_installed = { "c" },
  sync_install = false,
  ignore_install = { "javascript" },
  highlight = {
    enable = true,
    disable = {  },
    additional_vim_regex_highlighting = false,
  },
}
