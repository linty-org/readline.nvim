local M = {}

M.skip_chars = {
}

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
    if string.find(skip_chars, c, 1, true) then
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
    assert_ints_equal(forward_word_cursor('a b c', 0, whitespace), 1)
    assert_ints_equal(forward_word_cursor('a b c', 1, whitespace), 3)
    assert_ints_equal(forward_word_cursor('a b c', 2, whitespace), 3)
    assert_ints_equal(forward_word_cursor('a b c', 3, whitespace), 5)
    assert_ints_equal(forward_word_cursor('a b c', 4, whitespace), 5)
    assert_ints_equal(forward_word_cursor('a b c', 5, whitespace), 5)
    assert_ints_equal(forward_word_cursor('  ', 0, whitespace), 2)
    assert_ints_equal(forward_word_cursor('  ', 1, whitespace), 2)
    assert_ints_equal(forward_word_cursor('  ', 2, whitespace), 2)
    assert_ints_equal(forward_word_cursor(' x ', 0, whitespace), 2)
    assert_ints_equal(forward_word_cursor(' x ', 1, whitespace), 2)
    assert_ints_equal(forward_word_cursor(' x ', 2, whitespace), 3)
    assert_ints_equal(forward_word_cursor(' x ', 3, whitespace), 3)
    assert_ints_equal(forward_word_cursor('xx ', 0, whitespace), 2)
    assert_ints_equal(forward_word_cursor('xx ', 1, whitespace), 2)
    assert_ints_equal(forward_word_cursor('xx ', 2, whitespace), 3)
    assert_ints_equal(forward_word_cursor('xx ', 3, whitespace), 3)
    assert_ints_equal(forward_word_cursor(' xx', 0, whitespace), 3)
    assert_ints_equal(forward_word_cursor(' xx', 1, whitespace), 3)
    assert_ints_equal(forward_word_cursor(' xx', 2, whitespace), 3)
    assert_ints_equal(forward_word_cursor(' xx', 3, whitespace), 3)
  end

  do
    pl('Testing backward_word_cursor')
    assert_ints_equal(backward_word_cursor('hello', 5, whitespace), 0)
    assert_ints_equal(backward_word_cursor('a b c', 0, whitespace), 0)
    assert_ints_equal(backward_word_cursor('a b c', 1, whitespace), 0)
    assert_ints_equal(backward_word_cursor('a b c', 2, whitespace), 0)
    assert_ints_equal(backward_word_cursor('a b c', 3, whitespace), 2)
    assert_ints_equal(backward_word_cursor('a b c', 4, whitespace), 2)
    assert_ints_equal(backward_word_cursor('a b c', 5, whitespace), 4)
    assert_ints_equal(backward_word_cursor('  ', 0, whitespace), 0)
    assert_ints_equal(backward_word_cursor('  ', 1, whitespace), 0)
    assert_ints_equal(backward_word_cursor('  ', 2, whitespace), 0)
    assert_ints_equal(backward_word_cursor(' x ', 0, whitespace), 0)
    assert_ints_equal(backward_word_cursor(' x ', 1, whitespace), 0)
    assert_ints_equal(backward_word_cursor(' x ', 2, whitespace), 1)
    assert_ints_equal(backward_word_cursor(' x ', 3, whitespace), 1)
    assert_ints_equal(backward_word_cursor('xx ', 0, whitespace), 0)
    assert_ints_equal(backward_word_cursor('xx ', 1, whitespace), 0)
    assert_ints_equal(backward_word_cursor('xx ', 2, whitespace), 0)
    assert_ints_equal(backward_word_cursor('xx ', 3, whitespace), 0)
    assert_ints_equal(backward_word_cursor(' xx', 0, whitespace), 0)
    assert_ints_equal(backward_word_cursor(' xx', 1, whitespace), 0)
    assert_ints_equal(backward_word_cursor(' xx', 2, whitespace), 1)
    assert_ints_equal(backward_word_cursor(' xx', 3, whitespace), 1)
  end

  vim.api.nvim_echo(messages, true, {})
end

local function cursor_col()
  -- Returns zero-based.
  return vim.fn.charcol '.' - 1
end

local function last_cursor_col()
  return vim.fn.strchars(vim.fn.getline '.')
end

local function forward_cursor_col()
  return forward_word_cursor(vim.fn.getline '.', cursor_col(), vim.o.breakat)
end

local function backward_cursor_col()
  return backward_word_cursor(vim.fn.getline '.', cursor_col(), vim.o.breakat)
end

local function move_cursor(new_cursor_col)
  vim.fn.setcursorcharpos(vim.fn.line '.', new_cursor_col + 1)
end

local function kill_text(cursor_1, cursor_2)
  -- Kill the text between the cursor positions. The cursor positions are zero-based and may appear in either order.
  local cursor_start = math.min(cursor_1, cursor_2)
  local cursor_end = math.max(cursor_1, cursor_2)
  local line = vim.fn.line '.'
  local text = vim.api.nvim_buf_get_text(0, line - 1, cursor_start, line - 1, cursor_end, {})
  vim.fn.setreg('-', text, 'c')
  vim.api.nvim_buf_set_text(0, line - 1, cursor_start, line - 1, cursor_end, {})
end

function M.forward_word()
  move_cursor(forward_cursor_col())
end

function M.backward_word()
  move_cursor(backward_cursor_col())
end

function M.end_of_line()
  move_cursor(last_cursor_col())
end

function M.beginning_of_line()
  move_cursor(0)
end

function M.kill_word()
  kill_text(cursor_col(), forward_cursor_col())
end

function M.backward_kill_word()
  kill_text(cursor_col(), backward_cursor_col())
end

function M.kill_line()
  kill_text(cursor_col(), last_cursor_col())
end

function M.backward_kill_line()
  kill_text(cursor_col(), 0)
end

return M
