require("fzf-lua").setup{
  keymap = {
    builtin = {
      ["<c-d>"] = "preview-half-page-down",
      ["<c-u>"] = "preview-half-page-up",
    },
    fzf = {
      ["ctrl-d"] = "preview-half-page-down",
      ["ctrl-u"] = "preview-half-page-up",
    },
  },
  files = {
    oldfiles = {
      include_current_session = true,
    },
  }
}
