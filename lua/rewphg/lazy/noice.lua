return {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
        "MunifTanjim/nui.nvim",
        -- routing notifications through nvim-notify (noice's default notify view)
        "rcarriga/nvim-notify",
    },
    opts = {
        lsp = {
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
