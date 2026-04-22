return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'rafamadriz/friendly-snippets',
            'j-hui/fidget.nvim',
            'kristijanhusak/vim-dadbod-ui',
            { 'L3MON4D3/LuaSnip',                     version = 'v2.*' },
            { 'tpope/vim-dadbod',                     lazy = true },
            { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
            {
                "folke/lazydev.nvim",
                ft = "lua",
                opts = {
                    library = {
                        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                    },
                },
            },
            {
                'saghen/blink.cmp',
                dependencies = {
                    "rafamadriz/friendly-snippets",
                    "MahanRahmati/blink-nerdfont.nvim",
                    "moyiz/blink-emoji.nvim",
                },
                version = '1.*',
                ---@module 'blink.cmp'
                ---@type blink.cmp.Config
                opts = {
                    snippets = { preset = 'luasnip' },
                    keymap = {
                        preset = 'default',
                        ['<C-k>'] = { 'select_prev', 'fallback' },
                        ['<C-j>'] = { 'select_next', 'fallback' },
                        ['<tab>'] = { 'accept', 'fallback' },
                        ['<ENTER>'] = { 'accept', 'fallback' },
                        ['<C-space>'] = { function(cmp) cmp.show({ providers = { 'snippets' } }) end },
                    },
                    signature = { enabled = true },
                    sources = {
                        default = { "snippets", "lsp", "path", "buffer", "nerdfont", "emoji" },
                        per_filetype = { sql = { 'dadbod' } },
                        providers = {
                            snippets = { score_offset = 30 },
                            lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
                            nerdfont = { module = "blink-nerdfont", name = "Nerd Fonts", opts = { insert = true } },
                            emoji = {
                                module = "blink-emoji",
                                name = "Emoji",
                                opts = { insert = true },
                                should_show_items = function()
                                    return vim.tbl_contains({ "gitcommit", "markdown" }, vim.o.filetype)
                                end,
                            },
                        },
                        transform_items = function(_, items)
                            return vim.tbl_filter(function(item)
                                return not (item.kind == require("blink.cmp.types").CompletionItemKind.Snippet and item.source_name == "LSP")
                            end, items)
                        end,
                    },
                    appearance = { nerd_font_variant = 'mono' },
                    completion = {
                        menu = {
                            draw = {
                                columns = { { "kind_icon", "label", "label_description", "source_name", gap = 1 } },
                                components = {
                                    label_description = { width = { max = 50 } },
                                    source_name = { text = function(ctx) return "[" .. ctx.source_name .. "]" end },
                                },
                            },
                        },
                        list = { selection = { preselect = true } },
                        documentation = { auto_show = true },
                        ghost_text = { enabled = true },
                    },
                    fuzzy = { implementation = "prefer_rust_with_warning" }
                },
                opts_extend = { "sources.default" }
            },
        },
        opts = {
            servers = {
                -- 1. SourceKit (Manual Configuration)
                sourcekit = {
                    cmd = { "xcrun", "sourcekit-lsp" },
                    filetypes = { "swift", "objc", "objcpp", "c", "cpp" },
                    root_dir = function(fname)
                        local util = require("lspconfig.util")
                        -- Priority 1: buildServer.json (iOS/Xcode)
                        local root = util.root_pattern("buildServer.json")(fname)
                        if root then return root end

                        -- Priority 2: Standard Swift Package
                        root = util.root_pattern("Package.swift", ".git")(fname)
                        if root then return root end

                        -- Priority 3: Xcode Project Fallback
                        local xcode_root = vim.fs.find(function(name)
                            return name:match("%.xcodeproj$") or name:match("%.xcworkspace$")
                        end, { path = fname, upward = true })[1]

                        if xcode_root then return vim.fs.dirname(xcode_root) end
                        return vim.fs.dirname(fname)
                    end,
                },
                -- 2. Other Servers (Managed by Mason)
                lua_ls = {},
                rust_analyzer = {},
                gopls = {},
                jdtls = {},
            },
        },
        -- The Fix: config now accepts 'opts' and uses it to setup servers
        config = function(_, opts)
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            local masonConfig = require('mason-lspconfig')

            require("fidget").setup({})
            require("mason").setup()

            -- 1. Prepare Mason Ensure Installed List
            -- We exclude sourcekit because we manage it manually (via xcrun)
            local ensure_installed = {}
            for server, _ in pairs(opts.servers) do
                if server ~= "sourcekit" then
                    table.insert(ensure_installed, server)
                end
            end

            masonConfig.setup({
                ensure_installed = ensure_installed,
            })

            capabilities = vim.tbl_deep_extend('force', capabilities,
                require('blink.cmp').get_lsp_capabilities({}, false))

            capabilities = vim.tbl_deep_extend("force", capabilities, {
                textDocument = {
                    foldingRange = {
                        dynamicRegistration = false,
                        lineFoldingOnly = true
                    }
                }
            })

            -- 2. Iterate over ALL servers in opts.servers and setup them
            -- This ensures SourceKit gets setup, AND Mason servers get setup
            for server, server_opts in pairs(opts.servers) do
                server_opts.capabilities = vim.tbl_deep_extend("force", capabilities, server_opts.capabilities or {})
                vim.lsp.config(server, { server_opts })
                vim.lsp.enable(server)
            end
        end
    },
    {
        "echasnovski/mini.comment",
        event = "VeryLazy",
        opts = {
            options = {
                custom_commentstring = function() end,
            },
        },
    }
}
