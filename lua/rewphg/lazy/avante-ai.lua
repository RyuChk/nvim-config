return {
    "yetone/avante.nvim",
    build = "make",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    ---@module 'avante'
    ---@type avante.Config
    opts = {
        instructions_file = "avante.md",
        provider = "litellm",
        providers = {
            litellm = {
                endpoint = "https://litellm.panthera.difa.co.th",
                model = "openrouter/x-ai/grok-code-fast-1",
                timeout = 30000,
                extra_request_body = {
                    temperature = 0,
                    max_tokens = 20480,
                },
                api_key_name = "LITELLM_API_KEY",
                __inherited_from = 'openai',
            },
        },
        windows = {
            position = "left",
        },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "echasnovski/mini.pick",     -- for file_selector provider mini.pick
        "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
        "hrsh7th/nvim-cmp",          -- autocompletion for avante commands and mentions
        "ibhagwan/fzf-lua",          -- for file_selector provider fzf
        "stevearc/dressing.nvim",    -- for input provider dressing
        "folke/snacks.nvim",         -- for input provider snacks
        "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
        {
            "HakonHarnes/img-clip.nvim",
            event = "VeryLazy",
            opts = {
                default = {
                    embed_image_as_base64 = false,
                    prompt_for_file_name = false,
                    drag_and_drop = {
                        insert_mode = true,
                    },
                    use_absolute_path = true,
                },
            },
        },
        {
            'MeanderingProgrammer/render-markdown.nvim',
            opts = {
                file_types = { "markdown", "Avante" },
            },
            ft = { "markdown", "Avante" },
        },
    },
}
