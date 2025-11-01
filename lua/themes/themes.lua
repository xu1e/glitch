-- Glitch Plugin Themes System
-- Color schemes and visual themes for the glitch plugin

local M = {}

-- Color palette definitions
M.palettes = {
  neon = {
    header = "#ffffff",
    icon = "#22c55e",     -- Bright green
    key = "#ff6b35",      -- Orange-red
    desc = "#0cb1c7",     -- Cyan
    footer = "#a855f7",   -- Purple
    stats = "#10b981",    -- Emerald green
    rgb_spectrum = {
      "#ff0000", "#ff4000", "#ff8000", "#ffbf00", "#ffff00", "#bfff00",
      "#80ff00", "#40ff00", "#00ff00", "#00ff40", "#00ff80", "#00ffbf",
      "#00ffff", "#00bfff", "#0080ff", "#0040ff", "#0000ff", "#4000ff",
      "#8000ff", "#bf00ff", "#ff00ff", "#ff00bf", "#ff0080", "#ff0040"
    }
  },
  
  cyberpunk = {
    header = "#ff00ff",   -- Hot pink
    icon = "#00ffff",     -- Cyan
    key = "#ffff00",      -- Yellow
    desc = "#ff0080",     -- Hot pink
    footer = "#0080ff",   -- Blue
    stats = "#80ff00",    -- Lime green
    rgb_spectrum = {
      "#ff00ff", "#ff0080", "#ff0040", "#ff4000", "#ff8000", "#ffbf00",
      "#ffff00", "#80ff00", "#00ff00", "#00ff80", "#00ffff", "#0080ff",
      "#0040ff", "#0000ff", "#4000ff", "#8000ff", "#bf00ff", "#ff00bf",
      "#ff0080", "#ff0040", "#ff4000", "#ff8000", "#ffbf00", "#ffff00"
    }
  },
  
  matrix = {
    header = "#00ff00",   -- Matrix green
    icon = "#008000",     -- Dark green
    key = "#00ff80",      -- Light green
    desc = "#40ff40",     -- Medium green
    footer = "#80ff80",   -- Pale green
    stats = "#00ff40",    -- Bright green
    rgb_spectrum = {
      "#004000", "#006000", "#008000", "#00a000", "#00c000", "#00e000",
      "#00ff00", "#20ff20", "#40ff40", "#60ff60", "#80ff80", "#a0ffa0",
      "#c0ffc0", "#e0ffe0", "#ffffff", "#e0ffe0", "#c0ffc0", "#a0ffa0",
      "#80ff80", "#60ff60", "#40ff40", "#20ff20", "#00ff00", "#00e000"
    }
  },
  
  retro = {
    header = "#ff8c00",   -- Dark orange
    icon = "#ffd700",     -- Gold
    key = "#ff69b4",      -- Hot pink
    desc = "#00ced1",     -- Dark turquoise
    footer = "#9370db",   -- Medium purple
    stats = "#32cd32",    -- Lime green
    rgb_spectrum = {
      "#ff8c00", "#ffa500", "#ffb347", "#ffc649", "#ffd700", "#f0e68c",
      "#bdb76b", "#9acd32", "#7cfc00", "#7fff00", "#adff2f", "#98fb98",
      "#90ee90", "#00ff7f", "#00fa9a", "#40e0d0", "#48d1cc", "#00ced1",
      "#5f9ea0", "#4682b4", "#6495ed", "#7b68ee", "#9370db", "#ba55d3"
    }
  },
  
  monochrome = {
    header = "#ffffff",
    icon = "#d0d0d0",
    key = "#a0a0a0",
    desc = "#808080",
    footer = "#606060",
    stats = "#c0c0c0",
    rgb_spectrum = {
      "#000000", "#111111", "#222222", "#333333", "#444444", "#555555",
      "#666666", "#777777", "#888888", "#999999", "#aaaaaa", "#bbbbbb",
      "#cccccc", "#dddddd", "#eeeeee", "#ffffff", "#eeeeee", "#dddddd",
      "#cccccc", "#bbbbbb", "#aaaaaa", "#999999", "#888888", "#777777"
    }
  }
}

-- Theme configurations
M.themes = {
  neon_glitch = {
    name = "Neon Glitch",
    palette = "neon",
    animation = {
      type = "glitch",
      glitch_intensity = 0.005,
      wave_delay = 60,
    },
    special_effects = {
      scanlines = false,
      chromatic_aberration = true,
      flicker = true,
    }
  },
  
  cyberpunk_rgb = {
    name = "Cyberpunk RGB",
    palette = "cyberpunk",
    animation = {
      type = "rgb",
      rgb_cycle_speed = 6,
      wave_delay = 80,
    },
    special_effects = {
      scanlines = true,
      chromatic_aberration = false,
      flicker = false,
    }
  },
  
  matrix_flow = {
    name = "Matrix Flow",
    palette = "matrix",
    animation = {
      type = "wave",
      wave_delay = 120,
    },
    special_effects = {
      scanlines = false,
      chromatic_aberration = false,
      flicker = false,
    }
  },
  
  retro_wave = {
    name = "Retro Wave",
    palette = "retro",
    animation = {
      type = "rgb",
      rgb_cycle_speed = 15,
      wave_delay = 150,
    },
    special_effects = {
      scanlines = true,
      chromatic_aberration = true,
      flicker = false,
    }
  },
  
  minimal_clean = {
    name = "Minimal Clean",
    palette = "monochrome",
    animation = {
      type = "none",
    },
    special_effects = {
      scanlines = false,
      chromatic_aberration = false,
      flicker = false,
    }
  }
}

-- Current theme
M.current_theme = "neon_glitch"

-- Apply color palette to vim highlights
function M.apply_palette(palette_name)
  local palette = M.palettes[palette_name]
  if not palette then
    vim.notify("Unknown palette: " .. palette_name, vim.log.levels.WARN)
    return false
  end
  
  -- Main highlights
  vim.api.nvim_set_hl(0, "GlitchDashboardHeader", { fg = palette.header, bold = true })
  vim.api.nvim_set_hl(0, "GlitchDashboardIcon", { fg = palette.icon, bold = true })
  vim.api.nvim_set_hl(0, "GlitchDashboardKey", { fg = palette.key, bold = true })
  vim.api.nvim_set_hl(0, "GlitchDashboardDesc", { fg = palette.desc })
  vim.api.nvim_set_hl(0, "GlitchDashboardFooter", { fg = palette.footer, italic = true })
  vim.api.nvim_set_hl(0, "GlitchDashboardStats", { fg = palette.stats })
  
  -- RGB spectrum highlights
  for i, color in ipairs(palette.rgb_spectrum) do
    vim.api.nvim_set_hl(0, "GlitchDashboardRGB" .. i, { fg = color, bold = true })
    vim.api.nvim_set_hl(0, "glitchRGB" .. i, { fg = color, bold = true })
  end
  
  return true
end

-- Apply complete theme
function M.apply_theme(theme_name)
  local theme = M.themes[theme_name]
  if not theme then
    vim.notify("Unknown theme: " .. theme_name, vim.log.levels.WARN)
    return false
  end
  
  M.current_theme = theme_name
  
  -- Apply color palette
  M.apply_palette(theme.palette)
  
  -- Return theme settings for plugin configuration
  return {
    animation = theme.animation,
    special_effects = theme.special_effects,
    palette = theme.palette
  }
end

-- Get available themes
function M.get_themes()
  local theme_list = {}
  for name, theme in pairs(M.themes) do
    table.insert(theme_list, {
      name = name,
      display_name = theme.name,
      palette = theme.palette
    })
  end
  return theme_list
end

-- Get available palettes
function M.get_palettes()
  local palette_list = {}
  for name, _ in pairs(M.palettes) do
    table.insert(palette_list, name)
  end
  return palette_list
end

-- Create custom theme
function M.create_custom_theme(name, config)
  if not name or not config then
    return false, "Name and config required"
  end
  
  local default_theme = {
    name = config.display_name or name,
    palette = config.palette or "neon",
    animation = config.animation or { type = "rgb" },
    special_effects = config.special_effects or {}
  }
  
  M.themes[name] = default_theme
  return true
end

-- Theme picker function
function M.pick_theme()
  local themes = M.get_themes()
  local items = {}
  
  for _, theme in ipairs(themes) do
    table.insert(items, theme.display_name .. " (" .. theme.name .. ")")
  end
  
  vim.ui.select(items, {
    prompt = "Select theme:",
  }, function(choice, idx)
    if choice and idx then
      local selected_theme = themes[idx]
      M.apply_theme(selected_theme.name)
      vim.notify("Applied theme: " .. selected_theme.display_name, vim.log.levels.INFO)
    end
  end)
end

-- Cycle through themes
function M.cycle_theme()
  local theme_names = vim.tbl_keys(M.themes)
  local current_idx = 1
  
  for i, name in ipairs(theme_names) do
    if name == M.current_theme then
      current_idx = i
      break
    end
  end
  
  local next_idx = (current_idx % #theme_names) + 1
  local next_theme = theme_names[next_idx]
  
  M.apply_theme(next_theme)
  vim.notify("Theme: " .. M.themes[next_theme].name, vim.log.levels.INFO)
end

-- Initialize with default theme
M.apply_theme(M.current_theme)

return M
