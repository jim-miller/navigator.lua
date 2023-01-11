local vfn = vim.fn

local library = {}

local on_attach = require('navigator.lspclient.attach').on_attach
local sumneko_cfg = {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  on_attach = on_attach,
  flags = { allow_incremental_sync = true, debounce_text_changes = 500 },
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      diagnostics = {
        enable = true,
        -- Get the language server to recognize the `vim` global
        globals = { 'vim', 'describe', 'it', 'before_each', 'after_each', 'teardown', 'pending' },
      },
      completion = { callSnippet = 'Both' },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = library,
        maxPreload = 2000,
        preloadFileSize = 40000,
      },
      telemetry = { enable = false },
    },
  },
  on_new_config = function(cfg, root)
    local libs = vim.schedule(function()
      vim.tbl_deep_extend('force', {}, library)
    end)
    libs[root] = nil
    cfg.settings.Lua.workspace.library = libs
    return cfg
  end,
}

local function add(lib)
  for _, p in pairs(vfn.expand(lib, false, true)) do
    p = vim.loop.fs_realpath(p)
    if p then
      library[p] = true
    end
  end
end
local function sumneko_lua()
  -- add runtime
  -- add plugins it may be very slow to add all in path
  add('$VIMRUNTIME')
  -- add your config
  -- local home = vfn.expand("$HOME")
  add(vfn.stdpath('config'))

  library[vfn.expand('$VIMRUNTIME/lua')] = true
  library[vfn.expand('$VIMRUNTIME/lua/vim')] = true
  library[vfn.expand('$VIMRUNTIME/lua/vim/lsp')] = true

  local luadevcfg = {
    library = {
      enabled = true, -- runtime path
      runtime = true,
      types = true, -- full signature, docs and completion of vim.api, vim.treesitter, vim.lsp and others
      plugins = { 'nvim-treesitter', 'plenary.nvim' },
    },
    setup_jsonls = true,
  }
  return sumneko_cfg
end

return {
  sumneko_lua = sumneko_lua,
}
