# 🎭 Glitch Dashboard Plugin

A beautiful Neovim dashboard plugin with animated logos, multiple themes, and easy customization.

## ✨ Features

- 🎨 **5 Built-in Themes** - Neon Glitch, Cyberpunk RGB, Matrix Flow, Retro Wave, Minimal Clean
- ⚡ **3 Animation Types** - RGB cycling, Glitch effects, Wave patterns
- 📊 **Dashboard Mode** - Full alpha.nvim compatibility with menus and footers
- 🔧 **Easy Setup** - Simple configuration with sensible defaults
- 🚀 **Fast Loading** - Dynamic module loading with smart caching

## 📦 Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "xu1e/glitch",
  event = "VimEnter",
  priority = 1000,
  config = function()
    require("glitch").setup({
      plugin = {
        mode = "dashboard",
        logo = {
          "██╗   ██╗ ██████╗ ██╗   ██╗██████╗ ",
          "╚██╗ ██╔╝██╔═══██╗██║   ██║██╔══██╗",
          " ╚████╔╝ ██║   ██║██║   ██║██████╔╝",
          "  ╚██╔╝  ██║   ██║██║   ██║██╔══██╗",
          "   ██║   ╚██████╔╝╚██████╔╝██║  ██║",
          "   ╚═╝    ╚═════╝  ╚═════╝ ╚═╝  ╚═╝",
        }
      }
    })
  end,
}
```

## 🚀 Quick Start

### Simple Logo Replacement

The easiest way to customize the plugin is to replace the logo:

```lua
require("glitch").setup({
  plugin = {
    mode = "dashboard",
    logo = {
      "Your Custom",
      "ASCII Art",
      "Goes Here"
    }
  }
})
```

### Choose a Theme

```lua
require("glitch").setup({
  plugin = {
    mode = "dashboard",
    logo = { "Your Logo" }
  },
  colors = {
    scheme = "cyberpunk_rgb"  -- neon_glitch, matrix_flow, retro_wave, minimal_clean
  }
})
```

### Add Animations

```lua
require("glitch").setup({
  plugin = {
    mode = "dashboard",
    logo = { "Your Logo" }
  },
  animation = {
    type = "rgb",        -- "rgb", "glitch", "wave", "none"
    wave_delay = 100,    -- Speed in milliseconds
  }
})
```

## 🎨 Available Themes

- **neon_glitch** - Bright neon colors with glitch effects
- **cyberpunk_rgb** - Hot pink/cyan cyberpunk aesthetic  
- **matrix_flow** - Classic matrix green
- **retro_wave** - Synthwave-inspired retro colors
- **minimal_clean** - Clean monochrome design

## ⚡ Animation Types

- **rgb** - Smooth color cycling through spectrum
- **glitch** - Digital corruption effects
- **wave** - Flowing wave-like animations
- **none** - Static display

## 🎮 Commands

```vim
:GlitchDashboard      " Show dashboard
:GlitchLogo           " Show logo only  
:GlitchToggle         " Toggle display
:GlitchTheme          " Interactive theme picker
:GlitchCycleTheme     " Cycle through themes
```

## 📝 More Examples

### Logo Only Mode

Display just the logo without dashboard menus and footers:

```lua
require("glitch").setup({
  plugin = {
    mode = "logo",
    logo = {
      "   ██████╗ ██╗     ██╗████████╗ ██████╗██╗  ██╗",
      "  ██╔════╝ ██║     ██║╚══██╔══╝██╔════╝██║  ██║",
      "  ██║  ███╗██║     ██║   ██║   ██║     ███████║",
      "  ██║   ██║██║     ██║   ██║   ██║     ██╔══██║",
      "  ╚██████╔╝███████╗██║   ██║   ╚██████╗██║  ██║",
      "   ╚═════╝ ╚══════╝╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝",
    }
  },
  colors = {
    scheme = "neon_glitch"
  },
  animation = {
    type = "rgb",
    wave_delay = 150
  }
})
```

Perfect for startup screens or when you want a clean, distraction-free logo display.

### Custom Menu

```lua
require("glitch").setup({
  plugin = {
    mode = "dashboard",
    logo = { "Your Logo" }
  },
  dashboard = {
    menu = {
      { key = "f", icon = "󰈞", desc = "Find Files", cmd = "Telescope find_files" },
      { key = "r", icon = "󰋚", desc = "Recent", cmd = "Telescope oldfiles" },
      { key = "p", icon = "󰉋", desc = "Projects", cmd = "Telescope projects" },
      { key = "c", icon = "󰒓", desc = "Config", cmd = "e ~/.config/nvim/" },
      { key = "q", icon = "󰩈", desc = "Quit", cmd = "qa" },
    }
  }
})
```

### Glitch Heavy

```lua
require("glitch").setup({
  plugin = {
    mode = "dashboard",
    logo = { "Your Logo" }
  },
  animation = {
    type = "glitch",
    glitch_intensity = 0.01  -- Higher = more glitchy
  },
  colors = {
    scheme = "neon_glitch"
  }
})
```

That's it! 🎉 The plugin is designed to be simple to use while providing powerful customization options when needed.

## 📄 License

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for details.
