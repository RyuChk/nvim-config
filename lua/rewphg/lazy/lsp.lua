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
                        ['<C-e>'] = {},
                    },
                    signature = { enabled = true },
                    sources = {
                        default = {
                            "snippets",
                            "lsp",
                            "path",
                            "buffer",
                            "nerdfont",
                            "emoji",
                        },
                        per_filetype = { sql = { 'dadbod' } },
                        providers = {
                            snippets = {
                                score_offset = 30,
                            },
                            lazydev = {
                                name = "LazyDev",
                                module = "lazydev.integrations.blink",
                                score_offset = 100,
                            },
                            nerdfont = {
                                module = "blink-nerdfont",
                                name = "Nerd Fonts",
                                opts = { insert = true },
                            },
                            emoji = {
                                module = "blink-emoji",
                                name = "Emoji",
                                -- score_offset = 15,
                                opts = { insert = true },
                                should_show_items = function()
                                    return vim.tbl_contains({ "gitcommit", "markdown" }, vim.o.filetype)
                                end,
                            },
                        },
                        transform_items = function(_, items)
                            return vim.tbl_filter(function(item)
                                return not (
                                    item.kind == require("blink.cmp.types").CompletionItemKind.Snippet
                                    and item.source_name == "LSP"
                                )
                            end, items)
                        end,
                    },
                    appearance = {
                        nerd_font_variant = 'mono'
                    },
                    completion = {
                        menu = {
                            draw = {
                                columns = {
                                    { "kind_icon", "label", "label_description", "source_name", gap = 1 },
                                },
                                components = {
                                    label_description = {
                                        width = { max = 50 },
                                    },
                                    source_name = {
                                        text = function(ctx)
                                            return "[" .. ctx.source_name .. "]"
                                        end,
                                    },
                                },
                            },
                        },
                        list = {
                            selection = {
                                preselect = true,
                            },
                        },
                        documentation = {
                            auto_show = true,
                            -- auto_show_delay_ms = 2000,
                        },
                        ghost_text = { enabled = true },
                    },
                    fuzzy = { implementation = "prefer_rust_with_warning" }
                },
                opts_extend = { "sources.default" }
            },
        },
        config = function()
            local capabilities = vim.lsp.protocol.make_client_capabilities()

            -- setup capabilities
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

            require("fidget").setup({})
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",
                    "rust_analyzer",
                    "gopls",
                    "jdtls",
                },
            })
        end
    },
    {
        "echasnovski/mini.comment",
        event = "VeryLazy",
        opts = {
            options = {
                custom_commentstring = function()
                end,
            },
        },
    }
}
