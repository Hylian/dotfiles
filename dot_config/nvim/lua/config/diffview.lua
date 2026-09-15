-- Diffview Configuration
local ok, diffview = pcall(require, "diffview")
if not ok then
  return
end

local actions = require("diffview.actions")

diffview.setup({
  diff_binaries = false,
  enhanced_diff_hl = true,
  use_icons = true,
  icons = {
    folder_closed = "",
    folder_open = "",
  },
  signs = {
    fold_closed = "",
    fold_open = "",
    done = "✓",
  },
  view = {
    default = {
      layout = "diff2_horizontal",
      winbar_info = false,
    },
    merge_tool = {
      layout = "diff3_mixed",
      disable_diagnostics = true,
      winbar_info = true,
    },
    file_history = {
      layout = "diff2_horizontal",
      winbar_info = false,
    },
  },
  file_panel = {
    listing_style = "tree",
    tree_options = {
      flatten_dirs = true,
      folder_statuses = "only_folded",
    },
    win_config = {
      position = "left",
      width = 35,
    },
  },
  default_args = {
    DiffviewOpen = {},
    DiffviewFileHistory = {},
  },
  hooks = {},
  keymaps = {
    disable_defaults = false,
    view = {
      { "n", "<Bar>", actions.toggle_files, { desc = "Toggle files panel sidebar" } },
      { "n", "q", actions.close, { desc = "Close diffview" } },
      { "n", "<leader>q", actions.close, { desc = "Close diffview" } },
      { "n", "[c", "<cmd>normal! [c<CR>", { desc = "Previous diff hunk" } },
      { "n", "]c", "<cmd>normal! ]c<CR>", { desc = "Next diff hunk" } },
      { "n", "[x", actions.prev_conflict, { desc = "Previous conflict" } },
      { "n", "]x", actions.next_conflict, { desc = "Next conflict" } },
      { "n", "<leader>co", actions.conflict_choose("ours"), { desc = "Choose OURS" } },
      { "n", "<leader>ct", actions.conflict_choose("theirs"), { desc = "Choose THEIRS" } },
      { "n", "<leader>cb", actions.conflict_choose("base"), { desc = "Choose BASE" } },
      { "n", "<leader>ca", actions.conflict_choose("all"), { desc = "Choose ALL" } },
      { "n", "<leader>c0", actions.conflict_choose("none"), { desc = "Choose NONE" } },
    },
    file_panel = {
      { "n", "<Bar>", actions.toggle_files, { desc = "Toggle files panel sidebar" } },
      { "n", "q", actions.close, { desc = "Close diffview" } },
      { "n", "<leader>q", actions.close, { desc = "Close diffview" } },
      { "n", "<cr>", actions.select_entry, { desc = "Open diff for file" } },
      { "n", "-", actions.toggle_stage_entry, { desc = "Stage / unstage entry" } },
      { "n", "s", actions.toggle_stage_entry, { desc = "Stage / unstage entry" } },
      { "n", "S", actions.stage_all, { desc = "Stage all entries" } },
      { "n", "U", actions.unstage_all, { desc = "Unstage all entries" } },
      { "n", "X", actions.restore_entry, { desc = "Restore entry to working copy" } },
      { "n", "R", actions.refresh_files, { desc = "Refresh file list" } },
      { "n", "[c", actions.prev_conflict, { desc = "Go to previous conflict" } },
      { "n", "]c", actions.next_conflict, { desc = "Go to next conflict" } },
      { "n", "[x", actions.prev_conflict, { desc = "Go to previous conflict" } },
      { "n", "]x", actions.next_conflict, { desc = "Go to next conflict" } },
    },
    file_history_panel = {
      { "n", "<Bar>", actions.toggle_files, { desc = "Toggle files panel sidebar" } },
      { "n", "q", actions.close, { desc = "Close diffview" } },
      { "n", "<leader>q", actions.close, { desc = "Close diffview" } },
    },
  },
})
