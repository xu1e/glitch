-- Test script to verify dashboard loading
-- Run this with: nvim -l test_dashboard.lua

-- Add current directory to runtime path
vim.opt.runtimepath:prepend('.')

-- Test dashboard loading
print("Testing Glitch Dashboard...")

-- Test 1: Load the main glitch module
local ok, glitch = pcall(require, 'glitch')
if not ok then
  print("ERROR: Failed to load glitch module:", glitch)
  return
end
print("✓ Glitch module loaded successfully")

-- Test 2: Load dashboard module directly
local ok, dashboard = pcall(require, 'glitch.dashboard')
if not ok then
  print("ERROR: Failed to load dashboard module:", dashboard)
  return
end
print("✓ Dashboard module loaded successfully")

-- Test 3: Test dashboard setup
local ok, err = pcall(function()
  dashboard.setup({
    animation = { enabled = true, type = "rgb" }
  })
end)
if not ok then
  print("ERROR: Failed to setup dashboard:", err)
  return
end
print("✓ Dashboard setup completed")

-- Test 4: Test dashboard show (briefly)
print("Testing dashboard display...")
local ok, err = pcall(function()
  dashboard.show_dashboard()
end)
if not ok then
  print("ERROR: Failed to show dashboard:", err)
  return
end
print("✓ Dashboard displayed successfully")

-- Test 5: Close dashboard
vim.defer_fn(function()
  dashboard.close_dashboard()
  print("✓ Dashboard closed successfully")
  print("All tests passed! Dashboard is working correctly.")
  vim.cmd('quit')
end, 1000)