return {
    {
        {
            "nvim-neotest/neotest",
            dependencies = {
                "nvim-neotest/nvim-nio",
                "nvim-lua/plenary.nvim",
                "antoinemadec/FixCursorHold.nvim",
                "nvim-treesitter/nvim-treesitter",
                {
                    "fredrikaverpil/neotest-golang",
                    version = "*",
                    dependencies = {
                        "leoluz/nvim-dap-go",
                    },
                },
                "nvim-neotest/neotest-plenary",
                "marilari88/neotest-vitest",
            },
            config = function()
                local goConfig = {
                    go_test_args = {
                        "-v",
                        "-race",
                        "-count=1",
                        "-coverprofile=" .. vim.fn.getcwd() .. "/coverage.out",
                    },
                    runner = "gotestsum",
                    testify_enabled = true,
                }

                local neotest = require("neotest")
                neotest.setup({
                    adapters = {
                        require("neotest-vitest"),
                        require("neotest-plenary").setup({
                            -- this is my standard location for minimal vim rc
                            -- in all my projects
                            min_init = "./scripts/tests/minimal.vim",
                        }),
                        require("neotest-golang")(goConfig), -- Registration
                    },
                    summary = {
                        animated = true,
                        enabled = true,
                        expand_errors = true,
                        follow = true,
                        mappings = {
                            attach = "a",
                            clear_marked = "M",
                            clear_target = "T",
                            debug = "d",
                            debug_marked = "D",
                            expand = { "<CR>", "<2-LeftMouse>" },
                            expand_all = "e",
                            help = "?",
                            jumpto = "i",
                            mark = "m",
                            next_failed = "J",
                            output = "o",
                            prev_failed = "K",
                            run = "r",
                            run_marked = "R",
                            short = "O",
                            stop = "u",
                            target = "t",
                            watch = "w"
                        },
                        open = "topleft vsplit | vertical resize 50"
                    },
                })
            end,
            keys = {
                { "<leader>ta", function() require("neotest").run.attach() end,                                      desc = "[t]est [a]ttach" },
                { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end,                       desc = "[t]est run [f]ile" },
                { "<leader>tA", function() require("neotest").run.run(vim.uv.cwd()) end,                             desc = "[t]est [A]ll files" },
                { "<leader>tS", function() require("neotest").run.run({ suite = true }) end,                         desc = "[t]est [S]uite" },
                { "<leader>tn", function() require("neotest").run.run() end,                                         desc = "[t]est [n]earest" },
                { "<leader>tl", function() require("neotest").run.run_last() end,                                    desc = "[t]est [l]ast" },
                { "<leader>ts", function() require("neotest").summary.toggle() end,                                  desc = "[t]est [s]ummary" },
                { "<leader>to", function() require("neotest").output.open({ enter = true, auto_close = true }) end,  desc = "[t]est [o]utput" },
                { "<leader>tO", function() require("neotest").output_panel.toggle() end,                             desc = "[t]est [O]utput panel" },
                { "<leader>tt", function() require("neotest").run.stop() end,                                        desc = "[t]est [t]erminate" },
                { "<leader>td", function() require("neotest").run.run({ suite = false, strategy = "dap" }) end,      desc = "Debug nearest test" },
                { "<leader>tD", function() require("neotest").run.run({ vim.fn.expand("%"), strategy = "dap" }) end, desc = "Debug current file" },
            },
        },
    },
    {
        "andythigpen/nvim-coverage",
        version = "*",
        config = function()
            local coverage = require("coverage")
            coverage.setup({
                auto_reload = true,
                commands = true,
            })

            vim.keymap.set("n", "<leader>tr", function()
                coverage.load()
                coverage.show()
                vim.notify("test coverage reloaded!")
            end)
        end,
    }
}
