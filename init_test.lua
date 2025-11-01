-- Minimal init for testing glitch dashboard
-- Save this as ~/.config/nvim/init_test.lua and run with: nvim -u ~/.config/nvim/init_test.lua

-- Add glitch plugin to runtimepath
vim.opt.runtimepath:prepend('/Users/xu1e/Developments/glitch')

-- Setup the glitch plugin
require('glitch').setup({
  plugin = {
    mode = "dashboard"
  },
  dashboard = {
    enabled = true,
    show_on_start = true
  },
  animation = {
    enabled = true,
    type = "rgb"
  }
})

-- Manual command to show dashboard
vim.api.nvim_create_user_command("TestDashboard", function()
  require('glitch.dashboard').show_dashboard()
end, { desc = "Test show dashboard" })

print("Glitch dashboard initialized! Type :TestDashboard to show manually.")