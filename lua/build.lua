local M = {
    name = "build",
    version = "0.1.0",
    description = "Neovim script runner"
}

M.config = {
    show_output = true,
    scripts = {

    }
}

M.StartWin = nil
M.Win = nil
M.Buf = nil

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

function M.create_task_window()
    M.StartWin = vim.api.nvim_get_current_win()
    vim.api.nvim_command("botright vnew")
    M.Win = vim.api.nvim_get_current_win()
    M.Buf = vim.api.nvim_get_current_buf()

    vim.api.nvim_buf_set_name(M.Buf, "Scripts #" .. M.Buf)
    vim.api.nvim_set_option_value("buftype", "nofile", { buf = M.Buf })
    vim.api.nvim_set_option_value("swapfile", false, { buf = M.Buf })
    vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = M.Buf })
    vim.api.nvim_set_option_value("filetype", "build-nvim", { buf = M.Buf })
    vim.api.nvim_win_set_width(M.Win, 20)
    vim.api.nvim_win_set_option(M.Win, 'wrap', false)
    vim.api.nvim_win_set_option(M.Win, 'cursorline', true)
    vim.api.nvim_win_set_option(M.Win, 'number', false)
    vim.api.nvim_win_set_option(M.Win, 'relativenumber', false)
    vim.api.nvim_win_set_option(M.Win, 'signcolumn', 'no')
    vim.api.nvim_set_option_value("modifiable", false, { buf = M.Buf })

    M.set_task_window_bindings()
    M.redraw_task_window()
end

function M.close_task_window()
    vim.api.nvim_win_close(M.Win, true)
    vim.api.nvim_set_current_win(M.StartWin)

    M.StartWin = nil
    M.Win = nil
    M.Buf = nil
end

function M.set_task_window_bindings()
    local mappings = {
        ["<CR>"] = "run(vim.fn.getline('.'))",
        ["q"] = "close_task_window()",
    }

    for key, cmd in pairs(mappings) do
        vim.api.nvim_buf_set_keymap(M.Buf, "n", key, ":lua require\"build\"." .. cmd .. "<cr>", { nowait = true, noremap = true, silent = true })
    end
end

function M.redraw_task_window()
    vim.api.nvim_set_option_value("modifiable", true, { buf = M.Buf })

    local items_count = vim.api.nvim_win_get_height(M.Win)
    local items = vim.tbl_keys(M.config.scripts)
    local list = {
    }

    for i = 1, items_count do
        local item = items[i]
        if item == nil then
            break
        end

        table.insert(list, item)
    end

    vim.api.nvim_buf_set_lines(M.Buf, 0, -1, false, list)

    vim.api.nvim_set_option_value("modifiable", false, { buf = M.Buf })
end

function M.run(script_name)
    local script = M.config.scripts[script_name]
    if script == nil then
        vim.notify("Build.nvim: script not found: " .. script_name, vim.log.levels.ERROR)
        return
    end

    local output = vim.fn.execute("!" .. script)
    if M.config.show_output then
        print(output)
    end
end

function M.import_file(file)
    if vim.uv.fs_stat(file) == nil then
        return
    end

    local content = io.open(file, "r"):read("*a")
    local json = vim.json.decode(content)
    M.config.scripts = vim.tbl_deep_extend("force", M.config.scripts, json)
    vim.notify("Build.nvim: imported file: " .. file, vim.log.levels.INFO)
end

vim.api.nvim_create_autocmd({"BufEnter"}, {
    pattern = { "build-nvim" },
    callback = function()
        print("reloaded")
        M.redraw_task_window()
    end
})

vim.api.nvim_create_autocmd({"VimEnter"}, {
    pattern = { "*" },
    callback = function()
        M.import_file("build.json")
    end
})

return M
