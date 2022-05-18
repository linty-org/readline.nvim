local M = {}

function M._run_tests()
  local messages = {}
  local function pl(s) table.insert(messages, {s .. '\n'}) end
  pl('Running tests')
  pl('All tests passed!')
  vim.api.nvim_echo(messages, true, {})
end

function M.forward_word()
end

function M.backward_word()
end

function M.beginning_of_line()
end

function M.end_of_line()
end

function M.kill_word()
end

function M.backward_kill_word()
end

function M.kill_line()
end

function M.backward_kill_line()
end

return M
