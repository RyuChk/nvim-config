# CLAUDE.md

Personal Neovim configuration. Namespace `rewphg` (ThePrimeagen-style layout).
Pure Lua, managed by [lazy.nvim](https://github.com/folke/lazy.nvim).

**Requires Neovim 0.11+** — `lazy/lsp.lua` uses the `vim.lsp.config()` / `vim.lsp.enable()` API.

## Structure & load order

```
init.lua                     → require("rewphg")
lua/rewphg/
├── init.lua                 orchestrator ONLY: requires set → remap → autocmds → lazy_init
├── set.lua                  vim.opt editor settings + netrw/omni_sql g:vars + diagnostic.config
├── remap.lua                leader (Space) + core keymaps
├── autocmds.lua             global autocmds + filetype.add
├── lazy_init.lua            lazy.nvim bootstrap + setup
└── lazy/                    one file per plugin, each returns a lazy spec
    ├── init.lua             inline base specs (plenary, cellular-automaton)
    └── <plugin>.lua         e.g. lsp.lua, blink.lua, conform.lua, telescope.lua …
```

- **Editor options** live in `set.lua`: 4-space `expandtab`, `relativenumber`, persistent
  undo (`~/.vim/undodir`), `colorcolumn=80`, `laststatus=3`, `signcolumn=yes`, `updatetime=50`;
  also the `netrw_*` and `omni_sql_no_default_maps` globals.
- **Global keymaps** live in `remap.lua`. Leader = `<Space>`. Examples: `<leader>pv` netrw,
  `<leader>y` system-clipboard yank, `<C-b>` toggle Neotree, move-selection `J`/`K`.
- **Global autocmds** live in `autocmds.lua`: trim trailing whitespace on `BufWritePre`,
  highlight-on-yank, and `filetype.add` (templ). Colorscheme `tokyonight` is set in
  `lazy/colors.lua`. (Per-buffer LSP keymaps live in `lazy/lsp.lua` — see below.)

## Plugin manager (lazy.nvim)

- Bootstrapped in `lazy_init.lua`; clones lazy.nvim into `stdpath("data")` if missing.
- `require("lazy").setup({ spec = "rewphg.lazy", ... })` imports **every file in
  `lua/rewphg/lazy/`** as a plugin spec. Defaults: `lazy = false` (eager), `version = false`
  (latest git commit).
- Versions pinned in `lazy-lock.json` (committed, ~65 plugins).
- Manage with `:Lazy` (install/sync/update), `:Mason` (LSP/tool installs), `:checkhealth`.

## Adding or editing a plugin

Create `lua/rewphg/lazy/<name>.lua` returning a lazy spec. No registration needed elsewhere —
it is auto-imported.

```lua
return {
    "owner/repo",
    dependencies = { ... },
    opts = { ... },              -- passed to the plugin's setup()
    config = function(_, opts) ... end,
    -- event / cmd / keys / ft for lazy-loading
}
```

File names are kebab-case roughly matching the plugin (`mini-comment.lua` → mini.comment).

## LSP & completion

- **`lazy/lsp.lua`**: nvim-lspconfig + mason + mason-lspconfig + fidget. Servers declared in
  `opts.servers`: `sourcekit` (manual, via `xcrun` — Swift/iOS), `lua_ls`, `rust_analyzer`,
  `gopls` (mason-managed; `ensure_installed` is derived from this list, sans sourcekit).
  Each server is set up via `vim.lsp.config(server, opts)` + `vim.lsp.enable(server)`.
  Completion capabilities come from blink.cmp.
- **Per-buffer LSP keymaps** live in the `LspAttach` autocmd inside `lazy/lsp.lua`'s `config`:
  `gd`, `gr`, `K`, `<leader>vws`, `<leader>vd`, `<leader>.` (code action),
  `<leader>vrn` (rename), `<C-h>` (signature, insert), `[d`/`]d`.
- **`lazy/blink.lua`**: blink.cmp `v1.*` + LuaSnip + friendly-snippets. SQL uses dadbod
  completion; Lua uses lazydev. Keys: `<Tab>`/`<CR>` accept, `<C-j>`/`<C-k>` navigate.

## Formatting

`lazy/conform.lua` — conform.nvim, triggered by `<leader>f`. It reads an optional
`.conform.json` from the buffer's **git root** (`formatters_by_ft` + per-formatter `args`);
if absent, falls back to built-in defaults: `stylua` (lua), `prettier` (json/yaml/markdown),
`isort`+`yapf` (python). There is no committed `stylua.toml` / `.editorconfig`.

## Conventions

- Lua, **4-space indent** (matches `set.lua` and `.luarc.json`).
- `.luarc.json` declares the `vim` global and disables `missing-fields`.
- Put editor options in `set.lua`, global keymaps in `remap.lua`, autocmds in `autocmds.lua`,
  and anything plugin-specific in its own `lazy/<name>.lua`. `init.lua` is orchestration only.
- No tests, CI, or build step. Validate changes by launching Neovim and watching for lazy /
  LSP errors (`:Lazy`, `:checkhealth`).
