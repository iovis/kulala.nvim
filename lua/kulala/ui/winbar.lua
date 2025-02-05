local UICallbacks = require("kulala.ui.callbacks")
local CONFIG = require("kulala.config")
local M = {}

local winbar_info = {
  body = {
    desc = "Body (B)",
    action = function()
      require("kulala.ui").show_body()
    end,
    keymap = "B",
  },
  headers = {
    desc = "Headers (H)",
    action = function()
      require("kulala.ui").show_headers()
    end,
    keymap = "H",
  },
  headers_body = {
    desc = "All (A)",
    action = function()
      require("kulala.ui").show_headers_body()
    end,
    keymap = "A",
  },
  verbose = {
    desc = "Verbose (V)",
    action = function()
      require("kulala.ui").show_verbose()
    end,
    keymap = "V",
  },
  script_output = {
    desc = "Script Output (O)",
    action = function()
      require("kulala.ui").show_script_output()
    end,
    keymap = "O",
  },
  stats = {
    desc = "Stats (S)",
    action = function()
      require("kulala").show_stats()
    end,
    keymap = "S",
  },
}

---set winbar highlight
M.winbar_sethl = function()
  vim.api.nvim_set_hl(0, "KulalaTab", { link = "TabLine" })
  vim.api.nvim_set_hl(0, "KulalaTabSel", { link = "TabLineSel" })
end

---set local key mapping
---@param buf integer|nil Buffer
M.winbar_set_key_mapping = function(buf)
  if buf and CONFIG.get().winbar then
    for _, value in pairs(winbar_info) do
      vim.keymap.set("n", value.keymap, value.action, { silent = true, buffer = buf })
    end
  end
end

---@param buf integer Buffer id
---@param win_id integer|nil Window id
---@param view string Body or headers
M.toggle_winbar_tab = function(buf, win_id, view)
  if not (win_id and CONFIG.get().winbar) then
    return
  end

  local winbar = CONFIG.get().default_winbar_panes
  local winbar_title = {}

  for _, key in ipairs(winbar) do
    local info = winbar_info[key]

    if info ~= nil then
      local desc = info.desc .. " %*"

      if view == key then
        desc = "%#KulalaTabSel# " .. desc
      else
        desc = "%#KulalaTab# " .. desc
      end

      table.insert(winbar_title, desc)
    end
  end

  local value = table.concat(winbar_title, " ")
  vim.api.nvim_set_option_value("winbar", value, { win = win_id })

  M.winbar_sethl()
  M.winbar_set_key_mapping(buf)
end

UICallbacks.add("on_replace_buffer", function(_, new_buffer)
  M.winbar_set_key_mapping(new_buffer)
end)

return M
