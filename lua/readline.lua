local M = {}

local whitespace = ' 	'

local function new_cursor(s, i, dir, skip_chars)
  local length = vim.fn.strchars(s)
  local next_char_idx = function(j)
    return (dir == -1) and (j - 1) or j
  end
  local can_advance = function(j)
    local jp = next_char_idx(j)
    return 0 <= jp and jp < length
  end
  local consumed_anything = false
  while can_advance(i) do
    local c = vim.fn.nr2char(vim.fn.strgetchar(s, next_char_idx(i)))
    if string.find(skip_chars, c) then
      if consumed_anything then
        break
      end
    else
      consumed_anything = true
    end
    i = i + dir
  end
  return i
end

local function forward_word_cursor(s, i, skip_chars)
  return new_cursor(s, i, 1, skip_chars)
end

local function backward_word_cursor(s, i, skip_chars)
  return new_cursor(s, i, -1, skip_chars)
end

function M._run_tests()
  local messages = {}
  local function pl(s) table.insert(messages, {s .. '\n'}) end
  pl('Running tests')

  local function assert_ints_equal(actual, expected)
    if actual == expected then
      pl(string.format('Ok %d == %d', actual, expected))
    else
      pl(string.format('❌ Expected %d, got %d', expected, actual))
    end
  end

  do
    pl('Testing forward_word_cursor')
    assert_ints_equal(forward_word_cursor('hello', 0, whitespace), 5)
  end

  do
    pl('Testing backward_word_cursor')
    assert_ints_equal(backward_word_cursor('hello', 5, whitespace), 0)
  end

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
