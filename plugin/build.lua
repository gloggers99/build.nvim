vim.api.nvim_command("command! -nargs=1 BuildRun lua require('build').run(<f-args>)")
vim.api.nvim_command("command! -nargs=0 Build lua require('build').create_task_window()")
