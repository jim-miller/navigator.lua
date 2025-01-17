local lsp = vim.lsp
local util = lsp.util
local M = {}
function M.handler(_, result, ctx, config)
  config = config or {}
  config.focus_id = ctx.method
  config.zindex = 53
  if not (result and result.contents) then
    vim.notify('No information available')
    return
  end
  local ft = vim.bo.ft
  -- require('navigator.util').log(result)
  local markdown_lines = util.convert_input_to_markdown_lines(result.contents)
  markdown_lines = util.trim_empty_lines(markdown_lines)
  if vim.tbl_isempty(markdown_lines) then
    vim.notify('No information available')
    return
  end

  local opts = {}
  opts.wrap = true -- wrapping by default
  opts.stylize_markdown = true
  opts.focus = true

  local contents = lsp.util._trim(markdown_lines, opts)

  -- applies the syntax and sets the lines to the buffer
  local bufnr, winnr = util.open_floating_preview(markdown_lines, 'markdown', config)

  vim.api.nvim_buf_set_option(bufnr, 'modifiable', true)
  contents = lsp.util.stylize_markdown(bufnr, contents, opts)
  vim.api.nvim_buf_set_option(bufnr, 'modifiable', false)
  if _NgConfigValues.lsp.hover.keymaps then
    for key, v in pairs(_NgConfigValues.lsp.hover.keymaps) do
      if v[ft] == nil or v[ft] == true then
        local f = v.default or function() end
        vim.keymap.set('n', key, f, { noremap = true, silent = true, buffer = bufnr })
      else
        local f = v[ft]
        vim.keymap.set('n', key, f, { noremap = true, silent = true, buffer = bufnr })
      end
    end
  end
  return bufnr, winnr
end

return M
