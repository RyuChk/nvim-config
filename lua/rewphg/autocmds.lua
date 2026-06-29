local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

local RewphgGroup = augroup('Rewphg', {})
local yank_group = augroup('HighlightYank', {})

vim.filetype.add({
    extension = {
        templ = 'templ',
    }
})

autocmd('TextYankPost', {
    group = yank_group,
    pattern = '*',
    callback = function()
        vim.hl.on_yank({
            higroup = 'IncSearch',
            timeout = 40,
        })
    end,
})

autocmd({ "BufWritePre" }, {
    group = RewphgGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})
