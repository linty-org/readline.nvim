local readline = {}

local alphanum = 'abcdefghijklmnopqrstuvwxyz' ..
                 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ..
                 '0123456789'

readline.word_chars = {
  c = alphanum .. '_',
}

local function new_cursor(s, i, dir, word_chars)
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
    if not string.find(word_chars, c, 1, true) then
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

local function forward_word_cursor(s, i, word_chars)
  return new_cursor(s, i, 1, word_chars)
end

local function backward_word_cursor(s, i, word_chars)
  return new_cursor(s, i, -1, word_chars)
end

function readline._run_tests()
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
    assert_ints_equal(forward_word_cursor('hello', 0, alphanum), 5)
    assert_ints_equal(forward_word_cursor('a b c', 0, alphanum), 1)
    assert_ints_equal(forward_word_cursor('a b c', 1, alphanum), 3)
    assert_ints_equal(forward_word_cursor('a b c', 2, alphanum), 3)
    assert_ints_equal(forward_word_cursor('a b c', 3, alphanum), 5)
    assert_ints_equal(forward_word_cursor('a b c', 4, alphanum), 5)
    assert_ints_equal(forward_word_cursor('a b c', 5, alphanum), 5)
    assert_ints_equal(forward_word_cursor('  ', 0, alphanum), 2)
    assert_ints_equal(forward_word_cursor('  ', 1, alphanum), 2)
    assert_ints_equal(forward_word_cursor('  ', 2, alphanum), 2)
    assert_ints_equal(forward_word_cursor(' x ', 0, alphanum), 2)
    assert_ints_equal(forward_word_cursor(' x ', 1, alphanum), 2)
    assert_ints_equal(forward_word_cursor(' x ', 2, alphanum), 3)
    assert_ints_equal(forward_word_cursor(' x ', 3, alphanum), 3)
    assert_ints_equal(forward_word_cursor('xx ', 0, alphanum), 2)
    assert_ints_equal(forward_word_cursor('xx ', 1, alphanum), 2)
    assert_ints_equal(forward_word_cursor('xx ', 2, alphanum), 3)
    assert_ints_equal(forward_word_cursor('xx ', 3, alphanum), 3)
    assert_ints_equal(forward_word_cursor(' xx', 0, alphanum), 3)
    assert_ints_equal(forward_word_cursor(' xx', 1, alphanum), 3)
    assert_ints_equal(forward_word_cursor(' xx', 2, alphanum), 3)
    assert_ints_equal(forward_word_cursor(' xx', 3, alphanum), 3)
  end

  do
    pl('Testing backward_word_cursor')
    assert_ints_equal(backward_word_cursor('hello', 5, alphanum), 0)
    assert_ints_equal(backward_word_cursor('a b c', 0, alphanum), 0)
    assert_ints_equal(backward_word_cursor('a b c', 1, alphanum), 0)
    assert_ints_equal(backward_word_cursor('a b c', 2, alphanum), 0)
    assert_ints_equal(backward_word_cursor('a b c', 3, alphanum), 2)
    assert_ints_equal(backward_word_cursor('a b c', 4, alphanum), 2)
    assert_ints_equal(backward_word_cursor('a b c', 5, alphanum), 4)
    assert_ints_equal(backward_word_cursor('  ', 0, alphanum), 0)
    assert_ints_equal(backward_word_cursor('  ', 1, alphanum), 0)
    assert_ints_equal(backward_word_cursor('  ', 2, alphanum), 0)
    assert_ints_equal(backward_word_cursor(' x ', 0, alphanum), 0)
    assert_ints_equal(backward_word_cursor(' x ', 1, alphanum), 0)
    assert_ints_equal(backward_word_cursor(' x ', 2, alphanum), 1)
    assert_ints_equal(backward_word_cursor(' x ', 3, alphanum), 1)
    assert_ints_equal(backward_word_cursor('xx ', 0, alphanum), 0)
    assert_ints_equal(backward_word_cursor('xx ', 1, alphanum), 0)
    assert_ints_equal(backward_word_cursor('xx ', 2, alphanum), 0)
    assert_ints_equal(backward_word_cursor('xx ', 3, alphanum), 0)
    assert_ints_equal(backward_word_cursor(' xx', 0, alphanum), 0)
    assert_ints_equal(backward_word_cursor(' xx', 1, alphanum), 0)
    assert_ints_equal(backward_word_cursor(' xx', 2, alphanum), 1)
    assert_ints_equal(backward_word_cursor(' xx', 3, alphanum), 1)
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

local function get_word_chars()
  return readline.word_chars[vim.bo.filetype]
      or vim.b.readline_word_chars
      or readline.word_chars['c']
end

local function forward_cursor_col()
  return forward_word_cursor(vim.fn.getline '.', cursor_col(), get_word_chars())
end

local function backward_cursor_col()
  return backward_word_cursor(vim.fn.getline '.', cursor_col(), get_word_chars())
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

function readline.forward_word()
  move_cursor(forward_cursor_col())
end

function readline.backward_word()
  move_cursor(backward_cursor_col())
end

function readline.end_of_line()
  move_cursor(last_cursor_col())
end

function readline.beginning_of_line()
  move_cursor(0)
end

function readline.kill_word()
  kill_text(cursor_col(), forward_cursor_col())
end

function readline.backward_kill_word()
  kill_text(cursor_col(), backward_cursor_col())
end

function readline.kill_line()
  kill_text(cursor_col(), last_cursor_col())
end

function readline.backward_kill_line()
  kill_text(cursor_col(), 0)
end

return readline
