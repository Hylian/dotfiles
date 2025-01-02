local palettes = require("everforest.colours")
local config = require("everforest").config

local palette = palettes.generate_palette(config, vim.o.background)

local everforest_theme = {
  normal = {
    a = { bg = palette.statusline1, fg = palette.bg0, gui = "bold" },
    b = { bg = palette.bg3, fg = palette.grey2 },
    c = { bg = palette.bg1, fg = palette.grey1 },
  },
  insert = {
    a = { bg = palette.statusline2, fg = palette.bg0, gui = "bold" },
    b = { bg = palette.bg3, fg = palette.fg },
    c = { bg = palette.bg1, fg = palette.fg },
  },
  visual = {
    a = { bg = palette.statusline3, fg = palette.bg0, gui = "bold" },
    b = { bg = palette.bg3, fg = palette.fg },
    c = { bg = palette.bg1, fg = palette.fg },
  },
  replace = {
    a = { bg = palette.orange, fg = palette.bg0, gui = "bold" },
    b = { bg = palette.bg3, fg = palette.fg },
    c = { bg = palette.bg1, fg = palette.fg },
  },
  command = {
    a = { bg = palette.aqua, fg = palette.bg0, gui = "bold" },
    b = { bg = palette.bg3, fg = palette.fg },
    c = { bg = palette.bg1, fg = palette.fg },
  },
  terminal = {
    a = { bg = palette.purple, fg = palette.bg0, gui = "bold" },
    b = { bg = palette.bg3, fg = palette.fg },
    c = { bg = palette.bg1, fg = palette.fg },
  },
  inactive = {
    a = { bg = palette.bg1, fg = palette.grey1 },
    b = { bg = palette.bg1, fg = palette.grey1 },
    c = { bg = palette.bg1, fg = palette.grey1 },
  },
}

local function maximize_status()
  return vim.t.maximized and '   ' or ''
end

local function blank()
  return ''
end

local M = require("lualine.component"):extend()

M.processing = false
M.spinner_index = 1

local spinner_symbols = {
  "⠋",
  "⠙",
  "⠹",
  "⠸",
  "⠼",
  "⠴",
  "⠦",
  "⠧",
  "⠇",
  "⠏",
}
local spinner_symbols_len = 10

-- Initializer
function M:init(options)
  M.super.init(self, options)

  local group = vim.api.nvim_create_augroup("CodeCompanionHooks", {})

  vim.api.nvim_create_autocmd({ "User" }, {
    pattern = "CodeCompanionRequest*",
    group = group,
    callback = function(request)
      if request.match == "CodeCompanionRequestStarted" then
        self.processing = true
      elseif request.match == "CodeCompanionRequestFinished" then
        self.processing = false
      end
    end,
  })
end

-- Function that runs every time statusline is updated
function M:update_status()
  if self.processing then
    self.spinner_index = (self.spinner_index % spinner_symbols_len) + 1
    return spinner_symbols[self.spinner_index]
  else
    return nil
  end
end

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = everforest_theme,
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 200,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {{ 'mode', separator = { left = '', right = '' } }},
    lualine_b = {
      {
        require("noice").api.statusline.mode.get,
        cond = require("noice").api.statusline.mode.has,
      }
    },
    lualine_c = {
      {
        maximize_status,
        color = { fg = '#f3f5d9', bg = '#3a94c5', gui ='bold' },
        separator = { right = '' }
      },
      {
        'filename',
        file_status = true,      -- Displays file status (readonly status, modified status)
        newfile_status = false,  -- Display new file status (new file means no write after created)
        path = 3,                -- 0: Just the filename
                                 -- 1: Relative path
                                 -- 2: Absolute path
                                 -- 3: Absolute path, with tilde as the home directory
                                 -- 4: Filename and parent dir, with tilde as the home directory

        shorting_target = 40,    -- Shortens path to leave 40 spaces in the window
                                 -- for other components. (terrible name, any suggestions?)
        symbols = {
          modified = '[+]',      -- Text to show when the file is modified.
          readonly = '[-]',      -- Text to show when the file is non-modifiable or readonly.
          unnamed = '[No Name]', -- Text to show for unnamed buffers.
          newfile
        },
        color = { bg = '#f3f5d9' }
      },
    },
    lualine_x = {
      {M, function() return M.update_status() end},
      'branch',
      'diff',
    },
    lualine_y = {
      'searchcount',
    },
    lualine_z = {
      'progress',
      {'location', separator = { right = '' } }
    }
  },
  inactive_sections = {
    lualine_a = {
      {
        blank,
        draw_empty = true,
        separator = { left = '' },
        color = { fg = '#f3f5d9', bg = nil }
      }
    },
    lualine_b = {},
    lualine_c = {
      {
        'filename',
        file_status = true,      -- Displays file status (readonly status, modified status)
        newfile_status = false,  -- Display new file status (new file means no write after created)
        path = 3,                -- 0: Just the filename
                                 -- 1: Relative path
                                 -- 2: Absolute path
                                 -- 3: Absolute path, with tilde as the home directory
                                 -- 4: Filename and parent dir, with tilde as the home directory

        shorting_target = 40,    -- Shortens path to leave 40 spaces in the window
                                 -- for other components. (terrible name, any suggestions?)
        symbols = {
          modified = '[+]',      -- Text to show when the file is modified.
          readonly = '[-]',      -- Text to show when the file is non-modifiable or readonly.
          unnamed = '[No Name]', -- Text to show for unnamed buffers.
          newfile
        }
      }
    },
    lualine_x = {},
    lualine_y = {},
    lualine_z = {
      {
        blank,
        draw_empty = true,
        separator = { right = '' },
        color = { fg = '#f3f5d9', bg = nil }
      }
    }
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = { }
}
