local wezterm = require 'wezterm'

local config = wezterm.config_builder()
local act = wezterm.action

-- ─────────────────────────────────────────────
--  Shell
-- ─────────────────────────────────────────────

config.default_prog = { "/bin/zsh", "-l" }

config.set_environment_variables = {
    TERM      = "xterm-256color",
    COLORTERM = "truecolor",
}


-- ─────────────────────────────────────────────
--  Colors  (Catppuccin Mocha — rich & vibrant)
-- ─────────────────────────────────────────────

config.color_scheme      = "Catppuccin Mocha"

local c                  = {
    base    = "#1e1e2e",
    mantle  = "#181825",
    crust   = "#11111b",
    mauve   = "#cba6f7",
    blue    = "#89b4fa",
    green   = "#a6e3a1",
    yellow  = "#f9e2af",
    red     = "#f38ba8",
    text    = "#cdd6f4",
    subtext = "#a6adc8",
    overlay = "#6c7086",
}

config.initial_cols      = 120
config.initial_rows      = 28

-- ─────────────────────────────────────────────
--  Font
-- ─────────────────────────────────────────────

config.font              = wezterm.font_with_fallback({
    { family = "JetBrains Mono", weight = "Medium", italic = false },
    { family = "JetBrains Mono", weight = "Medium", italic = true },
    "Apple Color Emoji",
    "Noto Color Emoji",
})
config.font_size         = 13.5
config.line_height       = 1.25
config.cell_width        = 1.0

-- Ligatures on (looks great with JetBrains Mono)
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }


config.scrollback_lines = 15000
config.default_cwd = wezterm.home_dir

-- ─────────────────────────────────────────────
--  Window & Transparency
-- ─────────────────────────────────────────────
config.window_decorations = 'RESIZE'
config.window_background_opacity = 0.78
config.text_background_opacity = 1.0


local padding = 10
config.window_padding = {
    left = padding,
    right = padding,
    top = padding,
    bottom = padding,
}

-- ─────────────────────────────────────────────
--  Tab Bar  (bottom, compact, colourful)
-- ─────────────────────────────────────────────



config.enable_tab_bar                 = true
config.use_fancy_tab_bar              = false
config.hide_tab_bar_if_only_one_tab   = false
config.tab_max_width                  = 36
config.show_new_tab_button_in_tab_bar = true

config.colors                         = {
    tab_bar = {
        background         = c.crust,
        new_tab            = { bg_color = c.crust, fg_color = c.overlay },
        new_tab_hover      = { bg_color = c.mantle, fg_color = c.mauve, italic = true },
        active_tab         = { bg_color = c.mauve, fg_color = c.base, intensity = "Bold" },
        inactive_tab       = { bg_color = c.crust, fg_color = c.subtext },
        inactive_tab_hover = { bg_color = c.mantle, fg_color = c.text },
    },
}


-- ─────────────────────────────────────────────
--  Key Bindings
-- ─────────────────────────────────────────────
-- Leader: CTRL+Space

config.leader = { key = "Space", mods = "CTRL", timeout_milliseconds = 1500 }

config.key_tables                     = {
    -- CTRL+U clears the search pattern; used automatically on CMD+F open
    search_mode = {
        {
            key = "Escape",
            mods = "NONE",
            action = act.Multiple {
                act.CopyMode("ClearPattern"),
                act.CopyMode("Close"),
            }
        }
    },
}

config.keys                           = {
    {
        key = 't',
        mods = 'CMD',
        action = act.SpawnCommandInNewTab {
            cwd = wezterm.home_dir,
        },
    },
    {
        key = '\\',
        mods = 'CMD',
        action = act.SplitPane {
            direction = 'Right',
            command = {
                cwd = wezterm.home_dir,
            },
        },
    },
    {
        key = '\\',
        mods = 'CMD|SHIFT',
        action = act.SplitPane {
            direction = 'Down',
            command = {
                cwd = wezterm.home_dir,
            },
        },
    },
    -- skip whole line
    {
        key = 'LeftArrow',
        mods = 'CMD',
        action = wezterm.action.ActivateTabRelative(-1),
    },
    {
        key = "RightArrow",
        mods = "CMD",
        action = wezterm.action.ActivateTabRelative(1),
    },
    -- skip words
    {
        key = "LeftArrow",
        mods = "OPT",
        action = wezterm.action.SendString("\x1bb"),
    },
    {
        key = "RightArrow",
        mods = "OPT",
        action = wezterm.action.SendString("\x1bf"),
    },
    -- clear screen
    {
        key = 'k',
        mods = 'CMD',
        action = act.ClearScrollback 'ScrollbackAndViewport'
    },
}


-- ─────────────────────────────────────────────

config.quick_select_patterns = {
  "[0-9a-f]{7,40}",
  "[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}",
  "(?:/[\\w.%-]+)+",
  "\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}\\.\\d{1,3}",
}


-- ─────────────────────────────────────────────
--  Hyperlinks
-- ─────────────────────────────────────────────

config.hyperlink_rules = wezterm.default_hyperlink_rules()

table.insert(config.hyperlink_rules, {
  regex  = [[\b([a-zA-Z0-9_-]+/[a-zA-Z0-9_.-]+)\b]],
  format = "https://github.com/$1",
})


-- ─────────────────────────────────────────────
--  Dynamic tab & window titles
-- ─────────────────────────────────────────────

wezterm.on("format-tab-title", function(tab, _tabs, _panes, _cfg, _hover, max_width)
  local pane  = tab.active_pane
  local title = tab.tab_title ~= "" and tab.tab_title or pane.title
  if #title > max_width - 5 then
    title = wezterm.truncate_right(title, max_width - 6) .. "…"
  end
  local idx = tab.tab_index + 1
  return string.format(" %d: %s ", idx, title)
end)

wezterm.on("format-title", function(_window, pane)
  local cwd_uri = pane:get_current_working_dir()
  local cwd     = cwd_uri and cwd_uri.file_path or "~"
  local home    = os.getenv("HOME") or ""
  cwd           = cwd:gsub("^" .. home, "~")
  local proc    = pane:get_foreground_process_name() or ""
  proc          = proc:match("([^/]+)$") or proc
  return proc ~= "" and (proc .. "  " .. cwd) or cwd
end)


wezterm.on('gui-startup', function(cmd)
    -- Start with a main window
    local fintechWFTab, _, window = wezterm.mux.spawn_window(cmd or {
        cwd = '/path/to/place'
    })
    fintechWFTab:set_title('title1')


    local dcsTab, dcsPane, dcsWindow = window:spawn_tab {
        cwd = '/path/2/place'
    }
    dcsTab:set_title('title2')

    window:spawn_tab {
        cwd = "~"
    }

    fintechWFTab:activate()
end)





-- Finally, return the configuration to wezterm:
return config
