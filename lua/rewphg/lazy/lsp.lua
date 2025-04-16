return {
    {
        'neovim/nvim-lspconfig',
        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            'rafamadriz/friendly-snippets',
            'j-hui/fidget.nvim',
            'mfussenegger/nvim-jdtls',
            'kristijanhusak/vim-dadbod-ui',
            { 'L3MON4D3/LuaSnip', version = 'v2.*' },
            { 'tpope/vim-dadbod',                     lazy = true },
            { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
            {
                'saghen/blink.cmp',
                version = "1.*",
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
                    sources = {
                        default = { 'lsp', 'path', 'snippets', 'buffer' },
                        per_filetype = { sql = { 'dadbod' } },
                        providers = {
                            dadbod = { module = "vim_dadbod_completion.blink" },
                        },
                    }
                },
            },
        },
        config = function()
            local cmp = require('blink.cmp')
            local capabilities = vim.tbl_deep_extend(
                "force",
                {},
                vim.lsp.protocol.make_client_capabilities(),
                cmp.get_lsp_capabilities())

            require("fidget").setup({})
            require("mason").setup()
            require("mason-lspconfig").setup({
                ensure_installed = {
                    "lua_ls",
                    "rust_analyzer",
                    "gopls",
                    "jdtls",
                },
                handlers = {
                    function(server_name) -- default handler (optional)
                        require("lspconfig")[server_name].setup {
                            capabilities = capabilities
                        }
                    end,

                    zls = function()
                        local lspconfig = require("lspconfig")
                        lspconfig.zls.setup({
                            root_dir = lspconfig.util.root_pattern(".git", "build.zig", "zls.json"),
                            settings = {
                                zls = {
                                    enable_inlay_hints = true,
                                    enable_snippets = true,
                                    warn_style = true,
                                },
                            },
                        })
                        vim.g.zig_fmt_parse_errors = 0
                        vim.g.zig_fmt_autosave = 0
                    end,

                    ["lua_ls"] = function()
                        local lspconfig = require("lspconfig")
                        lspconfig.lua_ls.setup {
                            capabilities = capabilities,
                            settings = {
                                Lua = {
                                    runtime = { version = "Lua 5.1" },
                                    diagnostics = {
                                        globals = { "bit", "vim", "it", "describe", "before_each", "after_each" },
                                    }
                                }
                            }
                        }
                    end,

                    ["yamlls"] = function()
                        local lspconfig = require('lspconfig')
                        lspconfig.yamlls.setup {
                            capabilities = capabilities,
                            settings = {
                                yaml = {
                                    validate = true,
                                    schemaStore = {
                                        enable = false,
                                        url = "",
                                    },
                                    schemas = {
                                    }
                                }
                            }
                        }
                    end,

                    ["jdtls"] = function()
                        local lspconfig = require('lspconfig')
                        lspconfig.jdtls.setup {
                            cmd = { vim.fn.expand('~/.local/share/nvim/mason/bin/jdtls') },
                            root_dir = require('lspconfig').util.root_pattern('.git', 'pom.xml', 'build.gradle'),
                            settings = {
                                java = {
                                    signatureHelp = { enabled = true },
                                    -- contentProvider = { preferred = 'fernflower' },
                                }
                            }
                        }
                    end
                }
            })

            vim.diagnostic.config({
                -- update_in_insert = true,
                float = {
                    focusable = false,
                    style = "minimal",
                    border = "rounded",
                    source = "always",
                    header = "",
                    prefix = "",
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
