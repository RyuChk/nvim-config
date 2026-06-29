return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
        {
            "rcarriga/nvim-notify",
            opts = {
                top_down = false,   -- stack from bottom-right upward
                render = "compact",
            },
        },
    },
    opts = {
        -- LSP progress format; {spinner} animates through `name` frames
        format = {
            lsp_progress = {
                {
                    "{progress} ",
                    key = "progress.percentage",
                    contents = {
                        { "{data.progress.message} " },
                    },
                },
                "({data.progress.percentage}%) ",
                { "{spinner} ", name = "dots", hl_group = "NoiceLspProgressSpinner" },
                { "{data.progress.title} ", hl_group = "NoiceLspProgressTitle" },
                { "{data.progress.client} ", hl_group = "NoiceLspProgressClient" },
            },
        },
        -- notify-backed progress view; replace+merge updates one popup in place
        views = {
            notify_progress = {
                backend = "notify",
                replace = true,
                merge = true,
            },
        },
        lsp = {
            progress = {
                enabled = true,
                view = "notify_progress",
            },
            -- override markdown rendering so that LSP docs use Treesitter
            override = {
                ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                ["vim.lsp.util.stylize_markdown"] = true,
                -- NOTE: this repo uses blink.cmp, not nvim-cmp, so the
                -- cmp.entry.get_documentation override is intentionally omitted.
            },
        },
        -- presets for easier configuration
        presets = {
            bottom_search = true,      -- classic bottom cmdline for search
            command_palette = true,    -- position cmdline and popupmenu together
            long_message_to_split = true, -- long messages go to a split
            inc_rename = false,        -- input dialog for inc-rename.nvim
            lsp_doc_border = false,    -- border on hover docs / signature help
        },
    },
}
