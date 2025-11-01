-- Dashboard connector - integrates with the dynamic glitch dashboard module
-- This file connects the alpha-nvim style setup with the custom glitch dashboard

local M = {}

-- Load the dynamic glitch dashboard module
local glitch_dashboard = require("glitch.dashboard")

-- Dashboard setup function
local function setup_dashboard()
  -- Configure the glitch dashboard with custom settings
  glitch_dashboard.setup({
    padding_top = 4,
    padding_header = 2,
    padding_menu = 3,
    padding_footer = 2,
    animation = {
      enabled = true,
      type = "rgb", -- Start with RGB animation
      glitch_intensity = 0.005,
      wave_delay = 80,
      rgb_cycle_speed = 8,
    },
    -- Customize menu items
    menu = {
      { key = "f", icon = "󰈞", desc = "Find Files", cmd = "Telescope find_files" },
      { key = "e", icon = "󰈔", desc = "New File", cmd = "ene | startinsert" },
      { key = "r", icon = "󰋚", desc = "Recent Files", cmd = "Telescope oldfiles" },
      { key = "t", icon = "󰺮", desc = "Find Text", cmd = "Telescope live_grep" },
      { key = "l", icon = "󰒲", desc = "Lazy", cmd = "Lazy" },
      { key = "a", icon = "🎭", desc = "Toggle Animation", cmd = "GlitchToggleAnimation" },
      { key = "q", icon = "󰩈", desc = "Quit", cmd = "qa" },
    },
  })
  
  -- Auto-show dashboard on VimEnter if no files are opened
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      -- Only show if no arguments and buffer is empty
      if vim.fn.argc() == 0 and vim.fn.line2byte("$") == -1 then
        vim.schedule(function()
          glitch_dashboard.show_dashboard()
        end)
      end
    end,
  })
  
  -- Update stats when Lazy is loaded
  vim.api.nvim_create_autocmd("User", {
    pattern = "LazyVimStarted",
    callback = function()
      local lazy_ok, lazy = pcall(require, "lazy")
      if lazy_ok then
        local stats = lazy.stats()
        local ms = math.floor(stats.startuptime * 100 + 0.5) / 100
        glitch_dashboard.update_stats({
          loaded = stats.loaded,
          count = stats.count,
          startuptime = ms
        })
      end
    end,
  })
  
  -- Close dashboard when opening a file
  vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
      local buf = vim.api.nvim_get_current_buf()
      local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
      
      -- Close dashboard if we're entering a real file buffer
      if glitch_dashboard.is_active() and filetype ~= "glitch-dashboard" and vim.api.nvim_buf_get_name(buf) ~= "" then
        glitch_dashboard.close_dashboard()
      end
    end,
  })
end

-- Public API to match alpha-nvim style usage
M.setup = setup_dashboard

-- Expose dashboard functions for external use
M.show = function() glitch_dashboard.show_dashboard() end
M.close = function() glitch_dashboard.close_dashboard() end
M.toggle_animation = function() glitch_dashboard.toggle_animation() end
M.is_active = function() return glitch_dashboard.is_active() end

-- Initialize if called directly (comment out auto-init to prevent conflicts)
-- if not M._initialized then
--   M._initialized = true
--   setup_dashboard()
-- end

return M
