return {
    "doums/tenaille.nvim",
    config = function()
        require("tenaille").setup({
            default_mapping = true,
            pairs = {
                { '"', '"' },
                { "'", "'" },
                { "`", "`" },
                { "{", "}" },
                { "[", "]" },
                { "(", ")" },
                { "<", ">" },
            },
        })
    end,
}
