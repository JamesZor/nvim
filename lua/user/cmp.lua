local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
  return
end

local snip_status_ok, luasnip = pcall(require, "luasnip")
if not snip_status_ok then
  return
end

require("luasnip/loaders/from_vscode").lazy_load()

local check_backspace = function()
  local col = vim.fn.col "." - 1
  return col == 0 or vim.fn.getline("."):sub(col, col):match "%s"
end

--   פּ ﯟ   some other good icons
local kind_icons = {
  Text = "󰊄",
  Method = "m",
  Function = "󰊕",
  Constructor = "",
  Field = "",
  Variable = "󰫧",
  Class = "",
  Interface = "",
  Module = "",
  Property = "",
  Unit = "",
  Value = "",
  Enum = "",
  Keyword = "󰌆",
  Snippet = "",
  Color = "",
  File = "",
  Reference = "",
  Folder = "",
  EnumMember = "",
  Constant = "",
  Struct = "",
  Event = "",
  Operator = "",
  TypeParameter = "󰉺",
}
-- find more here: https://www.nerdfonts.com/cheat-sheet
--
-- Kind filtering system
local kind_filter_state = {
  current_index = 1,
  filters = {
    { name = "All", kinds = nil },  -- nil means no filter
    { name = "Variables", kinds = { cmp.lsp.CompletionItemKind.Variable, cmp.lsp.CompletionItemKind.Field, cmp.lsp.CompletionItemKind.Property } },
    { name = "Functions", kinds = { cmp.lsp.CompletionItemKind.Function, cmp.lsp.CompletionItemKind.Method } },
    { name = "Classes", kinds = { cmp.lsp.CompletionItemKind.Class, cmp.lsp.CompletionItemKind.Constructor } },
--    { name = "Keywords", kinds = { cmp.lsp.CompletionItemKind.Keyword } },
--    { name = "Snippets", kinds = { cmp.lsp.CompletionItemKind.Snippet } },
--    { name = "Constants", kinds = { cmp.lsp.CompletionItemKind.Constant, cmp.lsp.CompletionItemKind.Enum, cmp.lsp.CompletionItemKind.EnumMember } },
  }
}

-- Function to get current filter
local function get_current_filter()
  return kind_filter_state.filters[kind_filter_state.current_index]
end

-- Function to create entry filter
local function create_entry_filter()
  local current_filter = get_current_filter()
  if not current_filter.kinds then
    return nil  -- No filter, show all
  end
  
  return function(entry, ctx)
    local kind = entry:get_completion_item().kind
    for _, allowed_kind in ipairs(current_filter.kinds) do
      if kind == allowed_kind then
        return true
      end
    end
    return false
  end
end

-- Function to cycle to next filter
local function cycle_filter_forward()
  kind_filter_state.current_index = kind_filter_state.current_index + 1
  if kind_filter_state.current_index > #kind_filter_state.filters then
    kind_filter_state.current_index = 1
  end
  
  local current_filter = get_current_filter()
  vim.notify("CMP Filter: " .. current_filter.name, vim.log.levels.INFO, { title = "Completion" })
  
  if cmp.visible() then
    cmp.close()
    cmp.complete({
      config = {
        sources = {
          { 
            name = 'nvim_lsp',
            entry_filter = create_entry_filter()
          },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }
      }
    })
  end
end

-- Function to cycle to previous filter
local function cycle_filter_backward()
  kind_filter_state.current_index = kind_filter_state.current_index - 1
  if kind_filter_state.current_index < 1 then
    kind_filter_state.current_index = #kind_filter_state.filters
  end
  
  local current_filter = get_current_filter()
  vim.notify("CMP Filter: " .. current_filter.name, vim.log.levels.INFO, { title = "Completion" })
  
  if cmp.visible() then
    cmp.close()
    cmp.complete({
      config = {
        sources = {
          { 
            name = 'nvim_lsp',
            entry_filter = create_entry_filter()
          },
          { name = 'luasnip' },
          { name = 'buffer' },
          { name = 'path' },
        }
      }
    })
  end
end
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  mapping = {
    ["<C-k>"] = cmp.mapping.select_prev_item(),
		["<C-j>"] = cmp.mapping.select_next_item(),
    ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
    ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
    ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
    ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ["<C-e>"] = cmp.mapping {
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    },
    -- Accept currently selected item. If none selected, `select` first item.
    -- Set `select` to `false` to only confirm explicitly selected items.
    ["<CR>"] = cmp.mapping.confirm { select = true },
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expandable() then
        luasnip.expand()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif check_backspace() then
        fallback()
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, {
      "i",
      "s",
    }),
  -- Updated mappings for kind filtering
  ["<C-l>"] = cmp.mapping(function()
    cycle_filter_forward()
  end, { "i", "c" }),

  ["<C-h>"] = cmp.mapping(function()
    cycle_filter_backward()
  end, { "i", "c" }),
  },
  formatting = {
    fields = { "kind", "abbr", "menu" },
    format = function(entry, vim_item)
    -- Truncate long completion items
    local max_width = 50  -- Adjust this number to your preference
    if string.len(vim_item.abbr) > max_width then
      vim_item.abbr = string.sub(vim_item.abbr, 1, max_width - 1) .. "…"
    end
      -- Kind icons
      vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
      -- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
      vim_item.menu = ({
        nvim_lsp = "[LSP]",
        luasnip = "[Snippet]",
        buffer = "[Buffer]",
        path = "[Path]",
        cmdline = "[CMD]", 
      })[entry.source.name]
      return vim_item
    end,
  },
  sources = {
  { 
    name = "nvim_lsp",
    entry_filter = create_entry_filter()  -- Apply the current filter
  },
  { name = "luasnip" },
  { name = "buffer" },
  { name = "path" },
},
  confirm_opts = {
    behavior = cmp.ConfirmBehavior.Replace,
    select = false,
  },
  window = {
    documentation = cmp.config.window.bordered(),
    max_width = 60,
    max_height = 15,
  },
  experimental = {
    ghost_text = false,
    native_menu = false,
  },
}

-- Enhanced completion for shell files (CLI editing)
cmp.setup.filetype('sh', {
  sources = cmp.config.sources({
    { name = 'nvim_lsp', priority = 1000 },
    { name = 'path', priority = 750 },
    { name = 'buffer', keyword_length = 2, priority = 500 },
    { name = 'luasnip', priority = 250 },
  })
})

-- Command-line completion (optional, for : commands)
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' },
    { name = 'cmdline' }
  })
})

-- Search completion (optional, for / and ? searches)
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

vim.api.nvim_create_user_command('CmpResetFilter', function()
  kind_filter_state.current_index = 1
  vim.notify("CMP Filter reset to: All", vim.log.levels.INFO, { title = "Completion" })
end, {})
