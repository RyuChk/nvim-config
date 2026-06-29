return {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    branch = 'main',
    build = ':TSUpdate',
    config = function()
        local ts = require('nvim-treesitter')

        -- Core parsers to keep installed.
        local ensure = {
            'go',
            'yaml',
            'swift',
            'bash',
            'comment',
            'css',
            'diff',
            'fish',
            'git_config',
            'git_rebase',
            'gitcommit',
            'gitignore',
            'html',
            'javascript',
            'json',
            'latex',
            'lua',
            'luadoc',
            'make',
            'markdown',
            'markdown_inline',
            'query',
            'regex',
            'scss',
            'toml',
            'tsx',
            'typescript',
            'typst',
            'vim',
            'vimdoc',
            'vue',
            'xml',
        }

        -- Lookup sets, built once.
        local available = {}
        for _, lang in ipairs(ts.get_available()) do
            available[lang] = true
        end

        local installed = {}
        for _, lang in ipairs(ts.get_installed()) do
            installed[lang] = true
        end

        -- Install any missing core parsers (async, no-op if already present).
        ts.install(ensure)

        local ignore_filetypes = {
            'checkhealth',
            'lazy',
            'mason',
            'snacks_dashboard',
            'snacks_notif',
            'snacks_win',
        }

        -- Enable highlighting + treesitter indentation for a buffer.
        local function ts_start(buf, lang)
            if not vim.api.nvim_buf_is_valid(buf) then
                return
            end
            pcall(vim.treesitter.start, buf, lang)
            vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end

        vim.api.nvim_create_autocmd('FileType', {
            group = vim.api.nvim_create_augroup('rewphg.treesitter', { clear = true }),
            desc = 'Enable treesitter highlighting and indentation (auto-install)',
            callback = function(ev)
                if vim.tbl_contains(ignore_filetypes, ev.match) then
                    return
                end

                local lang = vim.treesitter.language.get_lang(ev.match) or ev.match

                -- No parser exists upstream for this language; nothing to do.
                if not available[lang] then
                    return
                end

                if installed[lang] then
                    ts_start(ev.buf, lang)
                else
                    -- Install once, then start highlighting in the callback.
                    ts.install(lang):await(vim.schedule_wrap(function(err)
                        if err then
                            return
                        end
                        installed[lang] = true
                        ts_start(ev.buf, lang)
                    end))
                end
            end,
        })
    end,
}
