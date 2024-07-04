local M = {
    name = "build",
    version = "0.1.0",
    description = "Neovim script runner"
}

M.config = {
    scripts = {

    }
}

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})
end

function M.run(script_name)
    local script = M.config.scripts[script_name]
    if script == nil then
        print("Script not found: " .. script_name)
        return
    end

    local output = vim.fn.execute(script)
    print(output)
end

return M
