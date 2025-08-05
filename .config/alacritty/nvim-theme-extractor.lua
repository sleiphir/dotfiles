local function get_color(group, attr)
  local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
  if hl and hl[attr] then
    return string.format("#%06x", hl[attr])
  end
  return "#000000"
end

local function write_toml(colors, scheme_name, variant)
  local lines = {
    "# Auto-generated from Neovim theme: " .. scheme_name,
    string.format("# Background: %s", variant),
    "[colors.primary]",
    string.format('background = "%s"', colors.bg),
    string.format('foreground = "%s"', colors.fg),
    "",
    "[colors.normal]",
    string.format('black = "%s"', colors.black),
    string.format('red = "%s"', colors.red),
    string.format('green = "%s"', colors.green),
    string.format('yellow = "%s"', colors.yellow),
    string.format('blue = "%s"', colors.blue),
    string.format('magenta = "%s"', colors.magenta),
    string.format('cyan = "%s"', colors.cyan),
    string.format('white = "%s"', colors.white),
    "",
    "[colors.bright]",
    string.format('black = "%s"', colors.bright_black),
    string.format('red = "%s"', colors.bright_red),
    string.format('green = "%s"', colors.bright_green),
    string.format('yellow = "%s"', colors.bright_yellow),
    string.format('blue = "%s"', colors.bright_blue),
    string.format('magenta = "%s"', colors.bright_magenta),
    string.format('cyan = "%s"', colors.bright_cyan),
    string.format('white = "%s"', colors.bright_white),
  }

  local filename = string.format("themes/%s-%s.toml", scheme_name or "unknown", variant or "dark")
  local file = io.open(filename, "w")
  if file then
    file:write(table.concat(lines, "\n"))
    file:close()
    print("Alacritty theme written to " .. filename)
  else
    print("Failed to write theme file.")
  end
end

-- Detect colorscheme and background variant
local scheme = vim.g.colors_name or "unknown"
local variant = vim.o.background or "dark"

-- Define highlight groups used for mapping
local colors = {
  bg             = get_color("Normal", "bg"),
  fg             = get_color("Normal", "fg"),
  black          = get_color("LineNr", "fg"),
  red            = get_color("Error", "fg"),
  green          = get_color("Function", "fg"),
  yellow         = get_color("String", "fg"),
  blue           = get_color("Comment", "fg"),
  magenta        = get_color("Statement", "fg"),
  cyan           = get_color("Type", "fg"),
  white          = get_color("Normal", "fg"),
  bright_black   = get_color("Comment", "fg"),
  bright_red     = get_color("DiagnosticError", "fg"),
  bright_green   = get_color("DiffAdd", "fg"),
  bright_yellow  = get_color("DiagnosticWarn", "fg"),
  bright_blue    = get_color("Identifier", "fg"),
  bright_magenta = get_color("Constant", "fg"),
  bright_cyan    = get_color("PreProc", "fg"),
  bright_white   = get_color("Normal", "fg"),
}

write_toml(colors, scheme, variant)
