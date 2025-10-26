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
            table.insert(path, symbol.name)
            find_symbol_path(symbol.children, line, char, path)
            return true
        end
    end
    return false
end

local function lsp_callback(err, symbols, ctx, config)
    if err or not symbols then
        vim.wo.winbar = " "
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
            relative_path = ""
        else
            relative_path = vim.fs.relpath(root_dir, file_path) or file_path
            relative_path = relative_path:gsub("/", " > ")
        end
    end


    local breadcrumbs = { relative_path }

    find_symbol_path(symbols, cursor_line, cursor_char, breadcrumbs)

    local breadcrumb_string = table.concat(breadcrumbs, " > ")

    if breadcrumb_string ~= "" then
        vim.wo.winbar = breadcrumb_string
    else
        vim.wo.winbar = " "
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

local breadcrumbs_enabled = false
local breadcrumbs_augroup = nil

return function(enable)
    if type(enable) == "boolean" then
        breadcrumbs_enabled = enable
    else
        breadcrumbs_enabled = not breadcrumbs_enabled
    end
    if breadcrumbs_enabled then
        breadcrumbs_augroup = vim.api.nvim_create_augroup("Breadcrumbs", { clear = true })
        vim.api.nvim_create_autocmd("CursorMoved", {
            group = breadcrumbs_augroup,
            callback = breadcrumbs_set,
            desc = "Set breadcrumbs.",
        })
        vim.notify("Breadcrumbs enabled", vim.log.levels.INFO)
    else
        vim.api.nvim_clear_autocmds({ group = breadcrumbs_augroup })
        for _, win in ipairs(vim.api.nvim_list_wins()) do
            vim.api.nvim_win_call(win, function()
                vim.wo.winbar = nil
            end)
        end
        vim.notify("Breadcrumbs disabled", vim.log.levels.INFO)
    end
end
