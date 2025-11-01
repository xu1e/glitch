-- glitch - Dynamic Logo Plugin with Module Loading

local M = {}

-- Load the dynamic module loader
local loader = require("glitch.loader")

-- State
local state = {
  buffer = nil,
  window = nil,
  active = false,
  timer = nil,
  animation_frame = 0,
  is_animating = false,
  glitch_state = {},  -- Track glitch effects per line
  config = nil,       -- Will be loaded dynamically
  themes = nil,       -- Will be loaded dynamically
}

-- Get current configuration
local function get_config()
  if not state.config then
    state.config = loader.get_config()
  end
  return state.config
end

-- Get themes system
local function get_themes()
  if not state.themes then
    state.themes = loader.get_themes()
  end
  return state.themes
end

-- Get logo from config
local function get_logo()
  local config = get_config()
  if config and config.get then
    return config.get("logo.header") or {
      "██╗  ██╗    ██╗   ██╗     ██╗    ███████╗",
      "╚██╗██╔╝    ██║   ██║    ███║    ██╔════╝",
      " ╚███╔╝     ██║   ██║    ╚██║    █████╗  ",
      " ██╔██╗     ██║   ██║     ██║    ██╔══╝  ",
      "██╔╝ ██╗    ╚██████╔╝     ██║    ███████╗",
      "╚═╝  ╚═╝     ╚═════╝      ╚═╝    ╚══════╝"
    }
  else
    -- Fallback logo if config not available
    return {
      "██╗  ██╗    ██╗   ██╗     ██╗    ███████╗",
      "╚██╗██╔╝    ██║   ██║    ███║    ██╔════╝",
      " ╚███╔╝     ██║   ██║    ╚██║    █████╗  ",
      " ██╔██╗     ██║   ██║     ██║    ██╔══╝  ",
      "██╔╝ ██╗    ╚██████╔╝     ██║    ███████╗",
      "╚═╝  ╚═╝     ╚═════╝      ╚═╝    ╚══════╝"
    }
  end
end

-- Get menu from config
local function get_menu()
  local config = get_config()
  if config and config.get then
    local dashboard_menu = config.get("dashboard.menu")
    if dashboard_menu then
      -- Convert dashboard menu format to logo menu format
      local logo_menu = {}
      for _, item in ipairs(dashboard_menu) do
        table.insert(logo_menu, {
          key = item.key,
          desc = item.desc,
          cmd = item.cmd
        })
      end
      return logo_menu
    end
  end
  
  -- Fallback menu
  return {
    { key = "f", desc = "Find file", cmd = "Telescope find_files" },
    { key = "e", desc = "New file", cmd = "ene | startinsert" },
    { key = "b", desc = "File Browser", cmd = "NvimTreeToggle" },
    { key = "r", desc = "Recently used", cmd = "Telescope oldfiles" },
    { key = "l", desc = "Lazy", cmd = "Lazy" },
    { key = "q", desc = "Quit", cmd = "qa" },
  }
end

-- Colors - use themes system if available
local function setup_colors()
  local themes = get_themes()
  if themes then
    -- Use themes system to apply colors
    themes.apply_theme(themes.current_theme)
  else
    -- Fallback colors if themes not available
    vim.api.nvim_set_hl(0, "glitchLogoGreen", { fg = "#22c55e", bold = true })
    vim.api.nvim_set_hl(0, "glitchMenuNeon", { fg = "#0cb1c7" })
    vim.api.nvim_set_hl(0, "glitchLogoNormal", { fg = "#ffffff" })
    vim.api.nvim_set_hl(0, "glitchMenuKey", { fg = "#db3600", bold = true })
    
    -- RGB Glitch colors - dynamic spectrum
    local colors = {
      "#ff0000", "#ff4000", "#ff8000", "#ffbf00", "#ffff00", "#bfff00",
      "#80ff00", "#40ff00", "#00ff00", "#00ff40", "#00ff80", "#00ffbf",
      "#00ffff", "#00bfff", "#0080ff", "#0040ff", "#0000ff", "#4000ff",
      "#8000ff", "#bf00ff", "#ff00ff", "#ff00bf", "#ff0080", "#ff0040"
    }
    
    for i, color in ipairs(colors) do
      vim.api.nvim_set_hl(0, "glitchRGB" .. i, { fg = color, bold = true })
    end
  end
end

-- Center text
local function center_text(text, width)
  local text_width = vim.fn.strdisplaywidth(text)
  local padding = math.max(0, math.floor((width - text_width) / 2))
  return string.rep(" ", padding) .. text
end

-- Create buffer
local function create_buffer()
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  vim.api.nvim_buf_set_option(buf, "buftype", "nofile")
  vim.api.nvim_buf_set_option(buf, "swapfile", false)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  return buf
end

-- Generate content
local function generate_content()
  local width = vim.o.columns
  local content = {}
  local config = get_config()
  local logo = get_logo()
  local menu = get_menu()
  
  -- Get padding from config or use defaults
  local padding_top = (config and config.get and config.get("logo.padding_top")) or 8
  local padding_menu = (config and config.get and config.get("logo.padding_menu")) or 3
  
  -- Top padding
  for _ = 1, padding_top do
    table.insert(content, "")
  end
  
  -- Logo
  for _, line in ipairs(logo) do
    table.insert(content, center_text(line, width))
  end
  
  -- Menu padding
  for _ = 1, padding_menu do
    table.insert(content, "")
  end
  
  -- Menu
  for _, item in ipairs(menu) do
    local menu_line = item.key .. "  " .. item.desc
    table.insert(content, center_text(menu_line, width))
  end
  
  return content
end

-- Generate animated content with smooth flowing effect (Ghostty-style)
local function generate_animated_content()
  local width = vim.o.columns
  local content = {}
  local config = get_config()
  local logo = get_logo()
  local menu = get_menu()
  
  -- Get config values or use defaults
  local animation_config = (config and config.get and config.get("animation")) or { 
    enabled = true, 
    type = "glitch", 
    glitch_intensity = 0.001 
  }
  local padding_top = (config and config.get and config.get("logo.padding_top")) or 8
  local padding_menu = (config and config.get and config.get("logo.padding_menu")) or 3
  
  -- Top padding
  for _ = 1, padding_top do
    table.insert(content, "")
  end
  
  -- Static logo with glitch effects
  for i, line in ipairs(logo) do
    local animated_line = line
    
    if animation_config.enabled and state.is_animating and animation_config.type == "glitch" then
      -- Line-based glitch trigger (affects entire lines)
      local line_should_glitch = math.random() < (animation_config.glitch_intensity or 0.001)
      
      if line_should_glitch then
        -- Line corruption glitch - replace entire line segments
        if animation_config.glitch_line_corruption ~= false then
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
          }
          
          -- Replace with glitch pattern of similar length
          local pattern = glitch_patterns[math.random(#glitch_patterns)]
          animated_line = pattern:sub(1, math.min(#line, #pattern))
        end
        
        -- Character-level corruption within the line
        if animation_config.glitch_chars ~= false and animation_config.glitch_line_corruption == false then
          local glitch_chars = {"█", "▓", "▒", "░", "▀", "▄", "▌", "▐", "■", "□", "▪", "▫", "◆", "◇", "◈"}
          local corrupted_line = ""
          
          for j = 1, #line do
            local char = line:sub(j, j)
            if math.random() < 0.5 then  -- 50% chance to corrupt each character in glitched lines
              char = glitch_chars[math.random(#glitch_chars)]
            end
            corrupted_line = corrupted_line .. char
          end
          animated_line = corrupted_line
        end
        
        -- Line position offset glitch
        if animation_config.glitch_offset ~= false then
          local offset = math.random(-3, 3)
          if offset > 0 then
            animated_line = string.rep(" ", offset) .. animated_line
          elseif offset < 0 then
            -- Truncate from beginning for negative offset
            local start_pos = math.min(math.abs(offset) + 1, #animated_line)
            animated_line = animated_line:sub(start_pos)
          end
        end
        
        -- Mark this line as glitched for RGB coloring
        state.glitch_state[i] = { is_glitched = true, rgb_highlight = "glitchRGB" .. math.random(1, 24) }
      else
        -- RGB cycling animation for normal lines
        local rgb_cycle = ((state.animation_frame / 8) + i * 3) % 24 + 1  -- Cycle through 24 RGB colors
        local rgb_hl = "glitchRGB" .. math.floor(rgb_cycle)
        
        -- Store RGB highlight for this line
        state.glitch_state[i] = { is_glitched = false, rgb_highlight = rgb_hl }
      end
    end
    
    -- Add the line (glitched or normal) to content
    table.insert(content, center_text(animated_line, width))
  end
  
  -- Menu padding
  for _ = 1, padding_menu do
    table.insert(content, "")
  end
  
  -- Formatted and centered menu
  local max_desc_length = 0
  for _, item in ipairs(menu) do
    max_desc_length = math.max(max_desc_length, #item.desc)
  end
  
  for _, item in ipairs(menu) do
    -- Format: [key] Description with consistent spacing
    local padded_desc = item.desc .. string.rep(" ", max_desc_length - #item.desc)
    local menu_line = string.format("[%s]  %s", item.key, padded_desc)
    table.insert(content, center_text(menu_line, width))
  end
  
  return content
end

-- Start wave animation
local function start_animation()
  local config = get_config()
  local animation_config = (config and config.get and config.get("animation")) or { enabled = true, wave_delay = 0.001 }
  
  if not animation_config.enabled or state.is_animating then return end
  
  state.is_animating = true
  state.animation_frame = 0
  
  state.timer = vim.loop.new_timer()
  local delay = animation_config.wave_delay or 0.001
  state.timer:start(delay, delay, vim.schedule_wrap(function()
    if not state.is_animating or not state.buffer or not vim.api.nvim_buf_is_valid(state.buffer) then
      return
    end
    
    state.animation_frame = state.animation_frame + (animation_config.wave_delay or 0.001)
    
    -- Generate new animated content
    local content = generate_animated_content()
    
    -- Update buffer
    vim.api.nvim_buf_set_option(state.buffer, "modifiable", true)
    vim.api.nvim_buf_set_lines(state.buffer, 0, -1, false, content)
    vim.api.nvim_buf_set_option(state.buffer, "modifiable", false)
    
    -- Reapply highlights (call the function that exists later)
    if M.apply_highlights then
      M.apply_highlights(state.buffer)
    end
  end))
end

-- Stop animation
local function stop_animation()
  state.is_animating = false
  if state.timer then
    state.timer:stop()
    state.timer:close()
    state.timer = nil
  end
end

-- Apply highlights
function M.apply_highlights(buf)
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  
  for i, line in ipairs(lines) do
    local line_num = i - 1
    
    -- Logo lines with RGB highlighting
    if line:match("█") or line:match("╗") or line:match("╔") or line:match("▓") or line:match("▒") or line:match("░") then
      local config = get_config()
      local animation_config = (config and config.get and config.get("animation")) or { type = "glitch" }
      local padding_top = (config and config.get and config.get("logo.padding_top")) or 8
      local logo_line_index = i - padding_top
      
      -- Check if this is a glitched line (contains corruption characters)
      local is_glitched = line:match("▓") or line:match("▒") or line:match("░") or 
                         line:match("■") or line:match("▪") or line:match("▀") or line:match("▄")
      
      if animation_config.type == "glitch" and state.is_animating then
        -- Use stored glitch state for each line
        local logo = get_logo()
        if logo_line_index >= 1 and logo_line_index <= #logo and state.glitch_state[logo_line_index] then
          local glitch_info = state.glitch_state[logo_line_index]
          local rgb_highlight = glitch_info.rgb_highlight or "glitchRGB1"
          
          if glitch_info.is_glitched then
            -- Rapid color cycling for glitched lines
            local rapid_cycle = (state.animation_frame / 3) % 24 + 1
            rgb_highlight = "glitchRGB" .. math.floor(rapid_cycle)
          end
          
          vim.api.nvim_buf_add_highlight(buf, -1, rgb_highlight, line_num, 0, -1)
        else
          -- Fallback RGB cycling
          local rgb_cycle = ((state.animation_frame / 8) + logo_line_index * 3) % 24 + 1
          local rgb_color = "glitchRGB" .. math.floor(rgb_cycle)
          vim.api.nvim_buf_add_highlight(buf, -1, rgb_color, line_num, 0, -1)
        end
      else
        -- Static RGB cycling when not in glitch mode
        local logo = get_logo()
        if logo_line_index >= 1 and logo_line_index <= #logo then
          local rgb_cycle = ((state.animation_frame / 8) + logo_line_index * 3) % 24 + 1
          local rgb_color = "glitchRGB" .. math.floor(rgb_cycle)
          vim.api.nvim_buf_add_highlight(buf, -1, rgb_color, line_num, 0, -1)
        end
      end
    end
    
    -- Menu lines with new format [key] Description
    local menu = get_menu()
    for _, item in ipairs(menu) do
      local bracket_pattern = "%[" .. vim.pesc(item.key) .. "%]"
      if line:match(bracket_pattern) then
        -- Highlight the [key] part
        local bracket_start, bracket_end = line:find(bracket_pattern)
        if bracket_start then
          vim.api.nvim_buf_add_highlight(buf, -1, "glitchMenuKey", line_num, bracket_start - 1, bracket_end)
          -- Highlight the description part
          vim.api.nvim_buf_add_highlight(buf, -1, "glitchMenuNeon", line_num, bracket_end + 2, -1)
        end
        break
      end
    end
  end
end

-- Setup keymaps
local function setup_keymaps(buf)
  local opts = { buffer = buf, silent = true }
  local menu = get_menu()
  
  for _, item in ipairs(menu) do
    vim.keymap.set("n", item.key, function()
      M.close()
      vim.schedule(function()
        vim.cmd(item.cmd)
      end)
    end, opts)
  end
  
  vim.keymap.set("n", "<Esc>", M.close, opts)
  vim.keymap.set("n", "q", M.close, opts)
end

-- Show logo
function M.show()
  if state.active then return end
  
  local buf = create_buffer()
  local content = generate_animated_content()
  
  vim.api.nvim_buf_set_option(buf, "modifiable", true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
  vim.api.nvim_buf_set_option(buf, "modifiable", false)
  
  state.buffer = buf
  state.window = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(state.window, buf)
  
  -- Window settings
  vim.wo[state.window].number = false
  vim.wo[state.window].relativenumber = false
  vim.wo[state.window].cursorline = false
  vim.wo[state.window].signcolumn = "no"
  
  M.apply_highlights(buf)
  setup_keymaps(buf)
  
  state.active = true
  
  -- Start animation
  start_animation()
end

-- Close logo
function M.close()
  if not state.active then return end
  
  -- Stop animation
  stop_animation()
  
  if state.buffer and vim.api.nvim_buf_is_valid(state.buffer) then
    vim.api.nvim_buf_delete(state.buffer, { force = true })
  end
  
  state.buffer = nil
  state.window = nil
  state.active = false
end

-- Process user-friendly configuration
local function process_user_config(user_opts)
  if not user_opts then return {} end
  
  local processed = {}
  
  -- Handle direct logo in plugin config (user-friendly format)
  if user_opts.plugin and user_opts.plugin.logo then
    processed.logo = processed.logo or {}
    processed.logo.header = user_opts.plugin.logo
    processed.dashboard = processed.dashboard or {}
    processed.dashboard.enabled = true -- Enable dashboard if logo provided
  end
  
  -- Handle direct mode setting
  if user_opts.plugin and user_opts.plugin.mode then
    processed.plugin = processed.plugin or {}
    processed.plugin.mode = user_opts.plugin.mode
    
    -- Auto-enable dashboard if mode is dashboard
    if user_opts.plugin.mode == "dashboard" then
      processed.dashboard = processed.dashboard or {}
      processed.dashboard.enabled = true
    end
  end
  
  -- Copy other settings as-is
  for key, value in pairs(user_opts) do
    if key ~= "plugin" or not user_opts.plugin.logo then
      processed[key] = value
    else
      -- Merge plugin settings but preserve processed logo
      processed.plugin = processed.plugin or {}
      for pkey, pvalue in pairs(value) do
        if pkey ~= "logo" then
          processed.plugin[pkey] = pvalue
        end
      end
    end
  end
  
  return processed
end

-- Setup
function M.setup(opts)
  -- Process user-friendly configuration format
  local processed_opts = process_user_config(opts)
  
  -- Initialize configuration with processed options
  local config = loader.init_config(processed_opts)
  
  -- Initialize themes
  loader.init_themes()
  
  -- Setup colors
  setup_colors()
  
  -- Check if dashboard is enabled and available
  local dashboard_enabled = config.dashboard and config.dashboard.enabled
  local dashboard_available = loader.is_available("glitch.dashboard")
  
  if dashboard_enabled and dashboard_available then
    -- Dashboard mode - auto-show on startup and create commands
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        if vim.fn.argc() == 0 then
          vim.schedule(function()
            local dashboard = loader.get_dashboard()
            if dashboard then
              dashboard.show_dashboard()
            else
              -- Fallback to logo if dashboard not available
              M.show()
            end
          end)
        end
      end,
    })
    
    vim.api.nvim_create_user_command("GlitchLogo", M.show, { desc = "Show Glitch Logo" })
    vim.api.nvim_create_user_command("GlitchDashboard", function()
      local dashboard = loader.get_dashboard()
      if dashboard then
        dashboard.show_dashboard()
      else
        vim.notify("Dashboard module not available", vim.log.levels.WARN)
      end
    end, { desc = "Show Glitch Dashboard" })
  else
    -- Standalone logo mode
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        if vim.fn.argc() == 0 then
          vim.schedule(M.show)
        end
      end,
    })
    
    vim.api.nvim_create_user_command("GlitchLogo", M.show, { desc = "Show Glitch Logo" })
  end
  
  -- Global commands available in both modes
  vim.api.nvim_create_user_command("GlitchToggle", function()
    if state.active then
      M.close()
    else
      M.show()
    end
  end, { desc = "Toggle Glitch Display" })
  
  -- Theme commands
  vim.api.nvim_create_user_command("GlitchTheme", function()
    local themes = get_themes()
    if themes then
      themes.pick_theme()
    else
      vim.notify("Themes module not available", vim.log.levels.WARN)
    end
  end, { desc = "Pick Glitch Theme" })
  
  vim.api.nvim_create_user_command("GlitchCycleTheme", function()
    local themes = get_themes()
    if themes then
      themes.cycle_theme()
    else
      vim.notify("Themes module not available", vim.log.levels.WARN)
    end
  end, { desc = "Cycle Glitch Theme" })
  
  -- Debug command
  vim.api.nvim_create_user_command("GlitchDebug", function()
    loader.debug_info()
  end, { desc = "Show Glitch Debug Info" })
end

-- Add public API for external access
M.get_config = function() return get_config() end
M.get_themes = function() return get_themes() end
M.reload_modules = function() return loader.reload_all() end

return M