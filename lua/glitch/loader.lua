-- Glitch Plugin - Dynamic Module Loader
-- Handles dynamic loading of config, themes, and other modules

local M = {}

-- Module cache
local _modules = {}
local _config = nil
local _themes = nil

-- Safe require function with error handling
local function safe_require(module_name, optional)
  local ok, result = pcall(require, module_name)
  if not ok then
    if not optional then
      vim.notify("Failed to load module: " .. module_name .. "\nError: " .. result, vim.log.levels.ERROR)
    end
    return nil
  end
  return result
end

-- Load and cache module
function M.load_module(module_name, force_reload)
  if not force_reload and _modules[module_name] then
    return _modules[module_name]
  end
  
  local module = safe_require(module_name, false)
  if module then
    _modules[module_name] = module
  end
  
  return module
end

-- Get configuration system
function M.get_config()
  if not _config then
    _config = M.load_module("config.config")
  end
  return _config
end

-- Get themes system  
function M.get_themes()
  if not _themes then
    _themes = M.load_module("themes.themes")
  end
  return _themes
end

-- Initialize configuration with user options
function M.init_config(user_opts)
  local config = M.get_config()
  if not config then
    vim.notify("Config module not available, using defaults", vim.log.levels.WARN)
    return {}
  end
  
  -- Update configuration with user options
  if user_opts then
    config.update(user_opts)
  end
  
  return config.current
end

-- Initialize themes with selected theme
function M.init_themes(theme_name)
  local themes = M.get_themes()
  if not themes then
    vim.notify("Themes module not available", vim.log.levels.WARN)
    return false
  end
  
  if theme_name then
    return themes.apply_theme(theme_name)
  else
    -- Apply default theme
    return themes.apply_theme(themes.current_theme)
  end
end

-- Get dashboard module
function M.get_dashboard()
  return M.load_module("glitch.dashboard", true)
end

-- Check if module is available
function M.is_available(module_name)
  local ok, _ = pcall(require, module_name)
  return ok
end

-- Hot reload modules (for development)
function M.reload_all()
  -- Clear module cache
  for module_name, _ in pairs(_modules) do
    package.loaded[module_name] = nil
  end
  
  _modules = {}
  _config = nil
  _themes = nil
  
  vim.notify("All modules reloaded", vim.log.levels.INFO)
end

-- Get module status
function M.get_status()
  local status = {
    config = M.is_available("config.config"),
    themes = M.is_available("themes.themes"),
    dashboard = M.is_available("glitch.dashboard"),
    loaded_modules = vim.tbl_keys(_modules)
  }
  
  return status
end

-- Debug function
function M.debug_info()
  local status = M.get_status()
  
  print("=== Glitch Plugin Module Status ===")
  print("Config available: " .. tostring(status.config))
  print("Themes available: " .. tostring(status.themes))
  print("Dashboard available: " .. tostring(status.dashboard))
  print("Loaded modules: " .. table.concat(status.loaded_modules, ", "))
  
  if status.config then
    local config = M.get_config()
    print("Current plugin mode: " .. (config.get("plugin.mode") or "unknown"))
  end
  
  if status.themes then
    local themes = M.get_themes()
    print("Current theme: " .. themes.current_theme)
  end
end

return M