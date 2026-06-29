return {
    'neovim/nvim-lspconfig',
    dependencies = {
        'williamboman/mason.nvim',
        'williamboman/mason-lspconfig.nvim',
        'j-hui/fidget.nvim',
        'saghen/blink.cmp', -- bare ref: capabilities + load order (full spec in blink.lua)
    },
    opts = {
        servers = {
            -- 1. SourceKit (Manual Configuration)
            sourcekit = {
                cmd = { "xcrun", "sourcekit-lsp" },
                filetypes = { "swift", "objc", "objcpp", "c", "cpp" },
                root_dir = function(fname)
                    -- Priority 1: buildServer.json (iOS/Xcode)
                    -- Priority 2: Standard Swift Package (Package.swift / .git)
                    local root = vim.fs.root(fname, { "buildServer.json" })
                        or vim.fs.root(fname, { "Package.swift", ".git" })
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
        },
    },
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
            vim.lsp.config(server, server_opts)
            vim.lsp.enable(server)
        end
    end
}
