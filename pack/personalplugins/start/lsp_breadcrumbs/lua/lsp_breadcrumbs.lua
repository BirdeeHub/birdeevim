local devicons_ok, devicons = pcall(require, "nvim-web-devicons")
local folder_icon = "%#File#" .. "󰉋" .. "%#WinBar#"
local file_icon = "󰈙"
local kind_icons = {
    "%#File#" .. file_icon .. "%#WinBar#", -- file
    "%#Module#" .. "" .. "%#WinBar#", -- module
    "%#Structure#" .. "" .. "%#WinBar#", -- namespace
    "%#Keyword#" .. "󰌋" .. "%#WinBar#", -- keyword
    "%#Class#" .. "󰠱" .. "%#WinBar#", -- class
    "%#Method#" .. "󰆧" .. "%#WinBar#", -- method
    "%#Property#" .. "󰜢" .. "%#WinBar#", -- property
    "%#Field#" .. "󰇽" .. "%#WinBar#", -- field
    "%#Function#" .. "" .. "%#WinBar#", -- constructor
    "%#Enum#" .. "" .. "%#WinBar#", -- enum
    "%#Type#" .. "" .. "%#WinBar#", -- interface
    "%#Function#" .. "󰊕" .. "%#WinBar#", -- function
    "%#None#" .. "󰂡" .. "%#WinBar#", -- variable
    "%#Constant#" .. "󰏿" .. "%#WinBar#", -- constant
    "%#String#" .. "" .. "%#WinBar#", -- string
    "%#Number#" .. "" .. "%#WinBar#", -- number
    "%#Boolean#" .. "" .. "%#WinBar#", -- boolean
    "%#Array#" .. "" .. "%#WinBar#", -- array
    "%#Class#" .. "" .. "%#WinBar#", -- object
    "", -- package
    "󰟢", -- null
    "", -- enum-member
    "%#Struct#" .. "" .. "%#WinBar#", -- struct
    "", -- event
    "", -- operator
    "󰅲", -- type-parameter
    "",
    "",
    "󰎠",
    "",
    "󰏘",
    "",
    "󰉋",
}

local function range_contains_pos(range, line, char)
    local start = range.start
    local stop = range['end']

    if line < start.line or line > stop.line then
        return false
    end

    if line == start.line and char < start.character then
        return false
    end

    if line == stop.line and char > stop.character then
        return false
    end

    return true
end

local function find_symbol_path(symbol_list, line, char, path)
    if not symbol_list or #symbol_list == 0 then
        return false
    end

    for _, symbol in ipairs(symbol_list) do
        if range_contains_pos(symbol.range, line, char) then
            local icon = kind_icons[symbol.kind] or ""
            table.insert(path, icon .. " " .. symbol.name)
            find_symbol_path(symbol.children, line, char, path)
            return true
        end
    end
    return false
end

local breadcrumbs_enabled = false
local function lsp_callback(err, symbols, ctx, config)
    if not breadcrumbs_enabled then
        vim.wo.winbar = nil
        return
    end
    if err or not symbols then
        vim.wo.winbar = nil
        return
    end

    local pos = vim.api.nvim_win_get_cursor(0)
    local cursor_line = pos[1] - 1
    local cursor_char = pos[2]

    local file_path = vim.fn.bufname(ctx.bufnr) or ""
    if file_path == "" then
        vim.wo.winbar = "[No Name]"
        return
    end

    local relative_path

    local clients = vim.lsp.get_clients({ bufnr = ctx.bufnr })

    if #clients > 0 and clients[1].root_dir then
        local root_dir = clients[1].root_dir
        if root_dir == nil then
            relative_path = file_path
        else
            relative_path = vim.fs.relpath(root_dir, file_path)
        end
    else
        local root_dir = vim.fn.getcwd(0)
        relative_path = vim.fs.relpath(root_dir, file_path)
    end

    local breadcrumbs = {}

    local path_components = vim.split(relative_path or "", "[/\\]", { trimempty = true })
    local num_components = #path_components
    for i, component in ipairs(path_components) do
        local iconstr
        if i == num_components then
            local icon, icon_hl
            if devicons_ok then
                icon, icon_hl = devicons.get_icon(component)
            end
            iconstr = "%#" .. (icon_hl or "File") .. "#" .. (icon or file_icon) .. "%#WinBar#"
        else
            iconstr = folder_icon
        end
        table.insert(breadcrumbs, iconstr .. " " .. component)
    end

    find_symbol_path(symbols, cursor_line, cursor_char, breadcrumbs)

    local breadcrumb_string = table.concat(breadcrumbs, " > ")

    if breadcrumb_string ~= "" then
        vim.wo.winbar = breadcrumb_string
    else
        vim.wo.winbar = nil
    end
end

local function breadcrumbs_set()
    local bufnr = vim.api.nvim_get_current_buf()
    local uri = vim.lsp.util.make_text_document_params(bufnr)["uri"]
    if not uri then
        return
    end

    local params = {
        textDocument = {
            uri = uri
        }
    }
    vim.lsp.buf_request(
        bufnr,
        'textDocument/documentSymbol',
        params,
        lsp_callback
    )
end

local breadcrumbs_augroup = nil

return function(enable, winbar_highlight)
    if type(enable) == "boolean" then
        breadcrumbs_enabled = enable
    else
        breadcrumbs_enabled = not breadcrumbs_enabled
    end
    if breadcrumbs_enabled then
        vim.api.nvim_set_hl(0, "WinBar", winbar_highlight or { link = "Normal" })
        breadcrumbs_augroup = vim.api.nvim_create_augroup("LspBreadcrumbs", { clear = true })
        vim.api.nvim_create_autocmd("CursorMoved", {
            group = breadcrumbs_augroup,
            callback = breadcrumbs_set,
            desc = "Set breadcrumbs.",
        })
        vim.api.nvim_create_autocmd("BufLeave", {
            group = breadcrumbs_augroup,
            callback = function(ctx)
                vim.api.nvim_set_option_value("winbar", nil, { win = vim.fn.bufwinid(ctx.buf or 0) })
            end,
            desc = "Clear breadcrumbs on hidden buffers.",
        })
        vim.notify("Breadcrumbs enabled", vim.log.levels.INFO)
    else
        vim.api.nvim_clear_autocmds({ group = breadcrumbs_augroup })
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            vim.api.nvim_set_option_value("winbar", nil, { win = win })
        end
        vim.notify("Breadcrumbs disabled", vim.log.levels.INFO)
    end
end
