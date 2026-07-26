-- Ghostty follows the system light/dark theme, but its mode 2031 notifications
-- never reach Lua: nvim's TUI swallows private CSI responses. So ask the
-- terminal for its background color instead and read the answer's luminance.
local QUERY_INTERVAL_MS = 5000

local function background_of(sequence)
  local red, green, blue = tostring(sequence):match("^\27%]11;rgba?:(%x+)/(%x+)/(%x+)")
  if not red then
    return nil
  end

  local function channel(component)
    return tonumber(component, 16) / tonumber(string.rep("f", #component), 16)
  end

  local luminance = 0.299 * channel(red) + 0.587 * channel(green) + 0.114 * channel(blue)
  return luminance < 0.5 and "dark" or "light"
end

local function follow_terminal_background()
  local group = vim.api.nvim_create_augroup("modus_follow_terminal", { clear = true })

  vim.api.nvim_create_autocmd("TermResponse", {
    group = group,
    callback = function(event)
      local background = background_of(event.data.sequence)
      if background and background ~= vim.o.background then
        vim.o.background = background
      end
    end,
  })

  vim.api.nvim_create_autocmd("OptionSet", {
    group = group,
    pattern = "background",
    callback = function()
      vim.cmd.colorscheme("modus")
    end,
  })

  local timer = assert(vim.uv.new_timer())
  timer:start(
    0,
    QUERY_INTERVAL_MS,
    vim.schedule_wrap(function()
      pcall(vim.api.nvim_ui_send, "\27]11;?\7")
    end)
  )

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      timer:stop()
      timer:close()
    end,
  })
end

return {
  {
    "miikanissi/modus-themes.nvim",
    lazy = false,
    priority = 1000,
    opts = { style = "auto" },
    config = function(_, opts)
      require("modus-themes").setup(opts)
      follow_terminal_background()
    end,
  },

  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "modus" },
  },
}
