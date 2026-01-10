return {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
        "MunifTanjim/nui.nvim",
    },
    opts = {
        window = {
            position = "right",
            mappings = {
                ["Y"] = "none",
            },
        },
        filesystem = {
            filtered_items = {
                hide_dotfiles = false,
                hide_by_name = {
                    ".git",
                    ".DS_Store",
                },
                always_show = {
                    ".env",
                },
            },
        },
    },
}
