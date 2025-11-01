-- Glitch Plugin Configuration System
-- Centralized configuration management for the glitch plugin and dashboard

local M = {}

-- Default configuration
M.defaults = {
  -- Main plugin settings
  plugin = {
    name = "glitch",
    version = "1.0.0",
    mode = "dashboard", -- "logo", "dashboard", or "hybrid"
  },
  
  -- Logo display settings
  logo = {
    padding_top = 8,
    padding_menu = 3,
    header = {
      "██╗  ██╗    ██╗   ██╗     ██╗    ███████╗",
      "╚██╗██╔╝    ██║   ██║    ███║    ██╔════╝",
      " ╚███╔╝     ██║   ██║    ╚██║    █████╗  ",
      " ██╔██╗     ██║   ██║     ██║    ██╔══╝  ",
      "██╔╝ ██╗    ╚██████╔╝     ██║    ███████╗",
      "╚═╝  ╚═╝     ╚═════╝      ╚═╝    ╚══════╝",
    },
  },
  
  -- Animation settings
  animation = {
    enabled = true,
    type = "rgb", -- "glitch", "rgb", "wave", or "none"
    wave_delay = 100, -- milliseconds between logo animation updates (doubled speed again)
    footer_delay = 2800, -- milliseconds between footer quotes updates (50% slower than before)
    glitch_intensity = 0.003, -- probability of line glitch per frame
    glitch_line_corruption = true, -- enable full line corruption patterns
    glitch_chars = true, -- enable character corruption
    glitch_colors = true, -- enable RGB color corruption
    glitch_offset = true, -- enable line position glitches
    rgb_cycle_speed = 8, -- frames per RGB color change
  },
  
  -- Dashboard settings
  dashboard = {
    enabled = true,
    show_on_start = true,
    auto_close = true,
    padding_top = 4,
    padding_header = 2,
    padding_menu = 3,
    padding_footer = 2,
    menu = {
      { key = "f", icon = "󰈞", desc = "Find Files", cmd = "Telescope find_files" },
      { key = "e", icon = "󰈔", desc = "New File", cmd = "ene | startinsert" },
      { key = "r", icon = "󰋚", desc = "Recent Files", cmd = "Telescope oldfiles" },
      { key = "t", icon = "󰺮", desc = "Find Text", cmd = "Telescope live_grep" },
      { key = "b", icon = "󰙅", desc = "File Browser", cmd = "Telescope file_browser" },
      { key = "l", icon = "󰒲", desc = "Lazy", cmd = "Lazy" },
      { key = "c", icon = "󰒓", desc = "Config", cmd = "e $MYVIMRC" },
      { key = "q", icon = "󰩈", desc = "Quit", cmd = "qa" },
    },
    footer_quotes = {
      "🚀 Ready to code something amazing?",
      "✨ Every bug is a feature in disguise",
      "🔥 Code like there's no tomorrow",
      "⚡ Debugging is twice as hard as writing code",
      "🌟 The best code is no code at all",
      "💡 Simplicity is the ultimate sophistication",
      "🎯 Make it work, make it right, make it fast",
      "🛠️  Good code is its own best documentation",
      "🎨 Code is poetry written in logic",
      "🚀 Premature optimization is the root of all evil",
      "🎭 Code never lies, comments sometimes do",
      "🔮 Any sufficiently advanced bug is indistinguishable from a feature",
    }
  },
  
  -- Color scheme settings
  colors = {
    scheme = "neon", -- "neon", "cyberpunk", "matrix", "custom"
    custom = {
      header = "#ffffff",
      icon = "#22c55e",
      key = "#ff6b35",
      desc = "#0cb1c7",
      footer = "#a855f7",
      stats = "#10b981",
    }
  }
}

-- Current configuration
M.current = vim.deepcopy(M.defaults)

-- Merge configurations
function M.merge(user_config)
  if not user_config then return M.current end
  return vim.tbl_deep_extend("force", M.current, user_config)
end

-- Update current configuration
function M.update(user_config)
  M.current = M.merge(user_config)
  return M.current
end

-- Get configuration value by path (dot notation)
function M.get(path)
  if not path then return M.current end
  
  local keys = vim.split(path, ".", { plain = true })
  local value = M.current
  
  for _, key in ipairs(keys) do
    if type(value) == "table" and value[key] ~= nil then
      value = value[key]
    else
      return nil
    end
  end
  
  return value
end

-- Set configuration value by path (dot notation)
function M.set(path, value)
  if not path then return false end
  
  local keys = vim.split(path, ".", { plain = true })
  local config = M.current
  
  -- Navigate to parent table
  for i = 1, #keys - 1 do
    local key = keys[i]
    if type(config[key]) ~= "table" then
      config[key] = {}
    end
    config = config[key]
  end
  
  -- Set the value
  config[keys[#keys]] = value
  return true
end

-- Validate configuration
function M.validate(config)
  local errors = {}
  
  -- Validate plugin mode
  local valid_modes = { "logo", "dashboard", "hybrid" }
  local mode = config.plugin and config.plugin.mode
  if mode and not vim.tbl_contains(valid_modes, mode) then
    table.insert(errors, "Invalid plugin mode: " .. mode)
  end
  
  -- Validate animation type
  local valid_types = { "glitch", "rgb", "wave", "none" }
  local anim_type = config.animation and config.animation.type
  if anim_type and not vim.tbl_contains(valid_types, anim_type) then
    table.insert(errors, "Invalid animation type: " .. anim_type)
  end
  
  -- Validate color scheme
  local valid_schemes = { "neon", "cyberpunk", "matrix", "custom" }
  local color_scheme = config.colors and config.colors.scheme
  if color_scheme and not vim.tbl_contains(valid_schemes, color_scheme) then
    table.insert(errors, "Invalid color scheme: " .. color_scheme)
  end
  
  return #errors == 0, errors
end

-- Export configuration for other modules
function M.export()
  return {
    logo = M.get("logo"),
    animation = M.get("animation"),
    dashboard = M.get("dashboard"),
    colors = M.get("colors"),
  }
end

-- Configuration presets
M.presets = {
  minimal = {
    animation = { enabled = false },
    dashboard = { enabled = false },
    plugin = { mode = "logo" }
  },
  
  dashboard_only = {
    plugin = { mode = "dashboard" },
    dashboard = { enabled = true },
    animation = { type = "rgb" }
  },
  
  glitch_heavy = {
    animation = {
      type = "glitch",
      glitch_intensity = 0.01,
      wave_delay = 50, -- Ultra-fast logo animation (doubled again)
      footer_delay = 1400 -- Footer quotes 50% slower than before
    }
  },
  
  smooth_rgb = {
    animation = {
      type = "rgb",
      rgb_cycle_speed = 12,
      wave_delay = 150, -- Very fast logo animation (doubled again)
      footer_delay = 4200 -- Footer quotes 50% slower than before
    }
  }
}

-- Apply preset
function M.apply_preset(preset_name)
  local preset = M.presets[preset_name]
  if not preset then
    return false, "Preset not found: " .. preset_name
  end
  
  M.current = M.merge(preset)
  return true
end

return M
