-- Glitch Dashboard Module - Dynamic dashboard implementation with module loading
-- Integrates with the main glitch plugin for consistent theming and animation

local M = {}

-- Load the dynamic module loader
local loader = require("glitch.loader")

-- Dashboard state
local dashboard_state = {
  buffer = nil,
  window = nil,
  active = false,
  timer = nil,
  animation_frame = 0,
  is_animating = false,
  glitch_state = {},
  stats = {},
  config = nil,
  themes = nil,
}

-- Get current configuration
local function get_config()
  if not dashboard_state.config then
    dashboard_state.config = loader.get_config()
  end
  return dashboard_state.config
end

-- Get themes system
local function get_themes()
  if not dashboard_state.themes then
    dashboard_state.themes = loader.get_themes()
  end
  return dashboard_state.themes
end

-- Get dashboard config values with fallbacks
local function get_dashboard_config()
  local config = get_config()
  if config and config.get then
    -- Get header from logo config, with fallback
    local header = config.get("logo.header")
    if not header then
      -- Fallback to default xu1e logo
      header = {
        "██╗  ██╗    ██╗   ██╗     ██╗    ███████╗",
        "╚██╗██╔╝    ██║   ██║    ███║    ██╔════╝",
        " ╚███╔╝     ██║   ██║    ╚██║    █████╗  ",
        " ██╔██╗     ██║   ██║     ██║    ██╔══╝  ",
        "██╔╝ ██╗    ╚██████╔╝     ██║    ███████╗",
        "╚═╝  ╚═╝     ╚═════╝      ╚═╝    ╚══════╝",
      }
    end
    
    return {
      padding_top = config.get("dashboard.padding_top") or 4,
      padding_header = config.get("dashboard.padding_header") or 2,
      padding_menu = config.get("dashboard.padding_menu") or 3,
      padding_footer = config.get("dashboard.padding_footer") or 2,
      animation = config.get("animation") or {
        enabled = true,
        type = "rgb",
        glitch_intensity = 0.003,
        wave_delay = 800,
        rgb_cycle_speed = 8,
      },
      header = header,
      menu = config.get("dashboard.menu") or {
        { key = "f", icon = "󰈞", desc = "Find Files", cmd = "Telescope find_files" },
        { key = "e", icon = "󰈔", desc = "New File", cmd = "ene | startinsert" },
        { key = "r", icon = "󰋚", desc = "Recent Files", cmd = "Telescope oldfiles" },
        { key = "l", icon = "󰒲", desc = "Lazy", cmd = "Lazy" },
        { key = "q", icon = "󰩈", desc = "Quit", cmd = "qa" },
      },
      footer_quotes = config.get("dashboard.footer_quotes") or {
        "🚀 Ready to code something amazing?",
        "✨ Every bug is a feature in disguise",
        "🔥 Code like there's no tomorrow",
        "⚡ Debugging is twice as hard as writing code",
        "🌟 The best code is no code at all",
        "💡 Simplicity is the ultimate sophistication",
      }
    }
  else
    -- Fallback configuration if config module not available
    return {
      padding_top = 4,
      padding_header = 2,
      padding_menu = 3,
      padding_footer = 2,
      animation = {
        enabled = true,
        type = "rgb",
        glitch_intensity = 0.003,
        wave_delay = 800,
        rgb_cycle_speed = 8,
      },
      header = {
        "██╗  ██╗    ██╗   ██╗     ██╗    ███████╗",
        "╚██╗██╔╝    ██║   ██║    ███║    ██╔════╝",
        " ╚███╔╝     ██║   ██║    ╚██║    █████╗  ",
        " ██╔██╗     ██║   ██║     ██║    ██╔══╝  ",
        "██╔╝ ██╗    ╚██████╔╝     ██║    ███████╗",
        "╚═╝  ╚═╝     ╚═════╝      ╚═╝    ╚══════╝",
      },
      menu = {
        { key = "f", icon = "󰈞", desc = "Find Files", cmd = "Telescope find_files" },
        { key = "e", icon = "󰈔", desc = "New File", cmd = "ene | startinsert" },
        { key = "r", icon = "󰋚", desc = "Recent Files", cmd = "Telescope oldfiles" },
        { key = "l", icon = "󰒲", desc = "Lazy", cmd = "Lazy" },
        { key = "q", icon = "󰩈", desc = "Quit", cmd = "qa" },
      },
      footer_quotes = {
        "🚀 Ready to code something amazing?",
        "✨ Every bug is a feature in disguise",
        "🔥 Code like there's no tomorrow",
      }
    }
  end
end

-- Center text utility
local function center_text(text, width)
  local text_width = vim.fn.strdisplaywidth(text)
  local padding = math.max(0, math.floor((width - text_width) / 2))
  return string.rep(" ", padding) .. text
end

-- Setup dashboard colors using themes system
local function setup_dashboard_colors()
  local themes = get_themes()
  if themes then
    -- Use themes system to apply colors
    themes.apply_theme(themes.current_theme)
  else
    -- Fallback colors if themes not available
    vim.api.nvim_set_hl(0, "GlitchDashboardHeader", { fg = "#ffffff", bold = true })
    vim.api.nvim_set_hl(0, "GlitchDashboardIcon", { fg = "#22c55e", bold = true })
    vim.api.nvim_set_hl(0, "GlitchDashboardKey", { fg = "#ff6b35", bold = true })
    vim.api.nvim_set_hl(0, "GlitchDashboardDesc", { fg = "#0cb1c7" })
    vim.api.nvim_set_hl(0, "GlitchDashboardFooter", { fg = "#a855f7", italic = true })
    vim.api.nvim_set_hl(0, "GlitchDashboardStats", { fg = "#10b981" })
    
    -- RGB spectrum for animations
    local rgb_colors = {
      "#ff0000", "#ff4000", "#ff8000", "#ffbf00", "#ffff00", "#bfff00",
      "#80ff00", "#40ff00", "#00ff00", "#00ff40", "#00ff80", "#00ffbf",
      "#00ffff", "#00bfff", "#0080ff", "#0040ff", "#0000ff", "#4000ff",
      "#8000ff", "#bf00ff", "#ff00ff", "#ff00bf", "#ff0080", "#ff0040"
    }
    
    for i, color in ipairs(rgb_colors) do
      vim.api.nvim_set_hl(0, "GlitchDashboardRGB" .. i, { fg = color, bold = true })
    end
  end
end

-- Generate glitch effects for a line
local function apply_glitch_to_line(line, config)
  if math.random() < config.animation.glitch_intensity then
    local glitch_patterns = {
      "████████████████████████████████████████",
      "▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓",
      "▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒",
      "░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░",
      "■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■■",
      "▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀▀",
      "▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄▄",
      "██░░██░░██░░██░░██░░██░░██░░██░░██░░██░░",
      "▓▒▓▒▓▒▓▒▓▒▓▒▓▒▓▒▓▒▓▒▓▒▓▒▓▒▓▒▓▒▓▒▓▒▓▒▓▒▓▒",
      "◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇◆◇"
    }
    
    local pattern = glitch_patterns[math.random(#glitch_patterns)]
    return pattern:sub(1, math.min(#line, #pattern)), true
  end
  return line, false
end

-- Generate dashboard content
local function generate_dashboard_content()
  local width = vim.o.columns
  local content = {}
  local config = get_dashboard_config()
  
  -- Top padding
  for _ = 1, config.padding_top do
    table.insert(content, "")
  end
  
  -- Header/Logo with potential glitch effects
  for i, line in ipairs(config.header) do
    local display_line = line
    if config.animation.enabled and config.animation.type == "glitch" then
      display_line, _ = apply_glitch_to_line(line, config)
    end
    table.insert(content, center_text(display_line, width))
  end
  
  -- Header padding
  for _ = 1, config.padding_header do
    table.insert(content, "")
  end
  
  -- Menu items
  for _, item in ipairs(config.menu) do
    local menu_line = string.format("%-5s  %s  [%27s]", item.icon, item.desc, item.key)
    table.insert(content, center_text(menu_line, width))
  end
  
  -- Menu padding
  for _ = 1, config.padding_menu do
    table.insert(content, "")
  end
  
  -- Stats footer
  local stats_line = ""
  if dashboard_state.stats.loaded then
    stats_line = string.format("⚡ Loaded %d/%d plugins in %.2fms", 
                              dashboard_state.stats.loaded, 
                              dashboard_state.stats.count, 
                              dashboard_state.stats.startuptime or 0)
  else
    stats_line = "⚡ Loading plugins..."
  end
  table.insert(content, center_text(stats_line, width))
  
  -- Footer padding
  for _ = 1, config.padding_footer do
    table.insert(content, "")
  end
  
  -- Random quote
  local quote = config.footer_quotes[math.random(#config.footer_quotes)]
  table.insert(content, center_text(quote, width))
  
  return content
end

-- Apply dashboard highlights
local function apply_dashboard_highlights(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local config = get_dashboard_config()
  
  for i, line in ipairs(lines) do
    local line_num = i - 1
    
    -- Header lines (logo)
    local header_start = config.padding_top + 1
    local header_end = header_start + #config.header - 1
    
    if i >= header_start and i <= header_end then
      local header_index = i - header_start + 1
      
      if config.animation.enabled and config.animation.type == "rgb" then
        -- RGB cycling animation
        local rgb_cycle = ((dashboard_state.animation_frame / config.animation.rgb_cycle_speed) + header_index * 2) % 24 + 1
        local rgb_color = "GlitchDashboardRGB" .. math.floor(rgb_cycle)
        vim.api.nvim_buf_add_highlight(buf, -1, rgb_color, line_num, 0, -1)
      elseif config.animation.enabled and config.animation.type == "glitch" then
        -- Glitch mode with rapid color changes
        local rapid_cycle = (dashboard_state.animation_frame / 2 + header_index) % 24 + 1
        local rgb_color = "GlitchDashboardRGB" .. math.floor(rapid_cycle)
        vim.api.nvim_buf_add_highlight(buf, -1, rgb_color, line_num, 0, -1)
      else
        -- Static header color
        vim.api.nvim_buf_add_highlight(buf, -1, "GlitchDashboardHeader", line_num, 0, -1)
      end
    end
    
    -- Menu items
    for _, item in ipairs(config.menu) do
      if line:find(vim.pesc(item.icon)) then
        -- Highlight icon
        local icon_start, icon_end = line:find(vim.pesc(item.icon))
        if icon_start then
          vim.api.nvim_buf_add_highlight(buf, -1, "GlitchDashboardIcon", line_num, icon_start - 1, icon_end)
        end
        
        -- Highlight key in brackets
        local key_pattern = "%[" .. vim.pesc(item.key) .. "%]"
        local key_start, key_end = line:find(key_pattern)
        if key_start then
          vim.api.nvim_buf_add_highlight(buf, -1, "GlitchDashboardKey", line_num, key_start - 1, key_end)
        end
        
        -- Highlight description
        local desc_start = line:find(vim.pesc(item.desc))
        if desc_start then
          vim.api.nvim_buf_add_highlight(buf, -1, "GlitchDashboardDesc", line_num, desc_start - 1, -1)
        end
        break
      end
    end
    
    -- Stats line
    if line:match("⚡.*plugins") then
      vim.api.nvim_buf_add_highlight(buf, -1, "GlitchDashboardStats", line_num, 0, -1)
    end
    
    -- Footer quotes
    for _, quote in ipairs(config.footer_quotes) do
      if line:find(vim.pesc(quote:sub(3))) then -- Skip emoji for pattern matching
        vim.api.nvim_buf_add_highlight(buf, -1, "GlitchDashboardFooter", line_num, 0, -1)
        break
      end
    end
  end
end

-- Start dashboard animation
local function start_dashboard_animation()
  local config = get_dashboard_config()
  if not config.animation.enabled or dashboard_state.is_animating then return end
  
  dashboard_state.is_animating = true
  dashboard_state.animation_frame = 0
  
  dashboard_state.timer = vim.loop.new_timer()
  dashboard_state.timer:start(config.animation.wave_delay, config.animation.wave_delay, vim.schedule_wrap(function()
    if not dashboard_state.is_animating or not dashboard_state.buffer or not vim.api.nvim_buf_is_valid(dashboard_state.buffer) then
      return
    end
    
    dashboard_state.animation_frame = dashboard_state.animation_frame + 1
    
    -- Generate new content
    local content = generate_dashboard_content()
    
    -- Update buffer
    vim.api.nvim_buf_set_option(dashboard_state.buffer, "modifiable", true)
    vim.api.nvim_buf_set_lines(dashboard_state.buffer, 0, -1, false, content)
    vim.api.nvim_buf_set_option(dashboard_state.buffer, "modifiable", false)
    
    -- Reapply highlights
    apply_dashboard_highlights(dashboard_state.buffer)
  end))
end

-- Stop dashboard animation
local function stop_dashboard_animation()
  dashboard_state.is_animating = false
  if dashboard_state.timer then
    dashboard_state.timer:stop()
    dashboard_state.timer:close()
    dashboard_state.timer = nil
  end
end

-- Setup keymaps for dashboard
local function setup_dashboard_keymaps(buf)
  local opts = { buffer = buf, silent = true }
  local config = get_dashboard_config()
  
  for _, item in ipairs(config.menu) do
    vim.keymap.set("n", item.key, function()
      M.close_dashboard()
      vim.schedule(function()
        vim.cmd(item.cmd)
      end)
    end, opts)
  end
  
  -- General navigation keys
  vim.keymap.set("n", "<Esc>", M.close_dashboard, opts)
  vim.keymap.set("n", "q", M.close_dashboard, opts)
  vim.keymap.set("n", "<CR>", function()
    local line = vim.api.nvim_get_current_line()
    for _, item in ipairs(config.menu) do
      if line:find(vim.pesc(item.desc)) then
        M.close_dashboard()
        vim.schedule(function()
          vim.cmd(item.cmd)
        end)
        break
      end
    end
  end, opts)
end

-- Create dashboard buffer
local function create_dashboard_buffer()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  vim.api.nvim_buf_set_option(buf, "filetype", "glitch-dashboard")
  vim.api.nvim_buf_set_name(buf, "[Glitch Dashboard]")
  return buf
end

-- Show dashboard
function M.show_dashboard()
  if dashboard_state.active then return end
  
  local buf = create_dashboard_buffer()
  local content = generate_dashboard_content()
  
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  
  dashboard_state.buffer = buf
  dashboard_state.window = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(dashboard_state.window, buf)
  
  -- Window settings
  vim.wo[dashboard_state.window].number = false
  vim.wo[dashboard_state.window].relativenumber = false
  vim.wo[dashboard_state.window].cursorline = false
  vim.wo[dashboard_state.window].signcolumn = "no"
  vim.wo[dashboard_state.window].statuscolumn = ""
  vim.wo[dashboard_state.window].colorcolumn = ""
  
  apply_dashboard_highlights(buf)
  setup_dashboard_keymaps(buf)
  
  dashboard_state.active = true
  
  -- Start animation if enabled
  start_dashboard_animation()
end

-- Close dashboard
function M.close_dashboard()
  if not dashboard_state.active then return end
  
  stop_dashboard_animation()
  
  if dashboard_state.buffer and vim.api.nvim_buf_is_valid(dashboard_state.buffer) then
    vim.api.nvim_buf_delete(dashboard_state.buffer, { force = true })
  end
  
  dashboard_state.buffer = nil
  dashboard_state.window = nil
  dashboard_state.active = false
end

-- Update stats (for lazy loading info)
function M.update_stats(stats)
  dashboard_state.stats = stats
  
  if dashboard_state.active and dashboard_state.buffer and vim.api.nvim_buf_is_valid(dashboard_state.buffer) then
    local content = generate_dashboard_content()
    vim.api.nvim_buf_set_option(dashboard_state.buffer, "modifiable", true)
    vim.api.nvim_buf_set_lines(dashboard_state.buffer, 0, -1, false, content)
    vim.api.nvim_buf_set_option(dashboard_state.buffer, "modifiable", false)
    apply_dashboard_highlights(dashboard_state.buffer)
  end
end

-- Toggle animation type
function M.toggle_animation()
  local config = get_config()
  if config and config.set then
    local types = {"none", "rgb", "glitch", "wave"}
    local current_type = config.get("animation.type") or "rgb"
    local current_index = 1
    
    for i, type in ipairs(types) do
      if current_type == type then
        current_index = i
        break
      end
    end
    
    local next_index = (current_index % #types) + 1
    local next_type = types[next_index]
    
    config.set("animation.type", next_type)
    vim.notify("Dashboard animation: " .. next_type, vim.log.levels.INFO)
  else
    vim.notify("Config module not available for animation toggle", vim.log.levels.WARN)
  end
end

-- Setup dashboard with user options
function M.setup(opts)
  -- Update configuration if provided
  if opts then
    local config = get_config()
    if config then
      config.update(opts)
    end
  end
  
  setup_dashboard_colors()
  
  -- Commands
  vim.api.nvim_create_user_command("GlitchDashboard", M.show_dashboard, {})
  vim.api.nvim_create_user_command("Dashboard", M.show_dashboard, {})
  vim.api.nvim_create_user_command("GlitchToggleAnimation", M.toggle_animation, {})
end

-- Public API
M.show = M.show_dashboard
M.close = M.close_dashboard
M.is_active = function() return dashboard_state.active end
M.get_config = get_dashboard_config

return M
