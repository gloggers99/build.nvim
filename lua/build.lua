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

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

function M.run(script_name)
    local script = M.config.scripts[script_name]
    if script == nil then
        vim.notify("Build.nvim: script not found: " .. script_name, vim.log.levels.ERROR)
        return
    end

    local output = vim.fn.execute(script)
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

vim.api.nvim_create_autocmd({"VimEnter"}, {
        pattern = { "*" },
        callback = function()
            M.import_file("build.json")
        end
    })

return M
