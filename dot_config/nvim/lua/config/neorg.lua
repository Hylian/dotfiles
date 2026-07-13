require('neorg').setup {
  load = {
    ["core.defaults"] = {},
    ["core.norg.dirman"] = {
      config = {
        workspaces = {
          fitbit = "~/notes/fitbit"
        },
        default_workspace = "fitbit",
        open_last_workspace = true,
        autochdir = true,
      }
    },
    ["core.keybinds"] = {
      config = {
        default_keybinds = true,
        neorg_leader = "<LocalLeader>", 
        hook = function(keybinds)
          local leader = keybinds.leader
          keybinds.map_event_to_mode("norg", {
            n = {
              { leader .. "nn", "core.norg.dirman.new.note" },
            }
          })
          keybinds.map_to_mode("all", {
            n = {
              { leader .. "mn", ":Neorg mode norg<CR>" },
              { leader .. "mh", ":Neorg mode traverse-heading<CR>" },
              { "gO", ":Neorg toc split<CR>" },
            },
            {
              silent = true,
              noremap = true,
            }
          })
          -- keybinds.map_event("norg", "n", km.leader("fl"), "core.integrations.telescope.find_linkable")
          -- keybinds.map_event("norg", "i", km.ctrl("l"), "core.integrations.telescope.insert_link")
          -- keybinds.map_event("norg", "n", km.localleader("m"), "core.looking-glass.magnify-code-block")
          -- keybinds.map_event("norg", "i", km.ctrl("m"), "core.looking-glass.magnify-code-block")
        end
      },
    },
    ["core.norg.concealer"] = {
      config = {
        dim_code_blocks = {
          enabled = true,
          width = "content",
          padding = {
            right = 2,
          },
          conceal = true,
        },
        markup_preset = "conceal",
        icon_preset = "diamond",
        icons = {
        marker = {
            enabled = true,
            icon = " ",
        },
        todo = {
            enable = true,
            recurring = {
                -- icon="ﯩ",
                icon = "",
            },
            pending = {
                -- icon = ""
                icon = "",
            },
            uncertain = {
                icon = "?",
            },
            urgent = {
                icon = "",
            },
            on_hold = {
                icon = "",
            },
            cancelled = {
                icon = "",
            },
        },
        heading = {
            enabled = true,
            level_1 = {
                icon = "◈",
            },

            level_2 = {
                icon = " ◇",
            },

            level_3 = {
                icon = "   ❖",
            },
            level_4 = {
                icon = "  ◆",
            },
            level_5 = {
                icon = "    ⟡",
            },
            level_6 = {
                icon = "     ⋄",
            },
          },
        },
      },
    },
  }
}
