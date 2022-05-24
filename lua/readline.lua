local readline = {}

local alphanum = 'abcdefghijklmnopqrstuvwxyz' ..
                 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' ..
                 '0123456789'

readline.alphanum = alphanum
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

local function command_line_mode()
  return vim.fn.mode() == 'c'
end

local function current_line()
  if command_line_mode() then
    return vim.fn.getcmdline()
  else
    return vim.fn.getline '.'
  end
end

local function current_cursor_col()
  -- Returns zero-based.
  if command_line_mode() then
    local byte_index = vim.fn.getcmdpos() - 1 -- Zero-based.
    local line = current_line()
    if byte_index == vim.fn.strlen(line) then
      return vim.fn.strchars(line)
    end
    return vim.fn.charidx(line, byte_index)
  else
    return vim.fn.charcol '.' - 1
  end
end

local function last_cursor_col()
  return vim.fn.strchars(current_line())
end

local function get_word_chars()
  if command_line_mode() then
    return readline.word_chars['c'] -- Hmm, we can probably do better than this.
  end
  return readline.word_chars[vim.bo.filetype]
      or vim.b.readline_word_chars
      or readline.word_chars['c']
end

local function forward_cursor_col()
  return forward_word_cursor(current_line(), current_cursor_col(), get_word_chars())
end

local function backward_cursor_col()
  return backward_word_cursor(current_line(), current_cursor_col(), get_word_chars())
end

local function feed_keys(s)
  -- The idea is that this accepts strings like '<Left><CR>xyz' and does the right thing.
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(s, true, true, true), '', false)
  -- Is there really no better way of doing this?
end

local function move_non_command_line_cursor(new_cursor_col)
  vim.fn.setcursorcharpos(vim.fn.line '.', new_cursor_col + 1)
end

local function command_line_motion(new_cursor_col, motion)
  local old_cursor_col = current_cursor_col()
  if new_cursor_col < old_cursor_col then
    local key = (motion == 'move') and '<Left>' or '<BS>'
    feed_keys(string.rep(key, old_cursor_col - new_cursor_col))
  elseif old_cursor_col < new_cursor_col then
    local key = (motion == 'move') and '<Right>' or '<Del>'
    feed_keys(string.rep(key, new_cursor_col - old_cursor_col))
  end
end

local function move_cursor_to(cursor_col)
  if command_line_mode() then
    command_line_motion(cursor_col, 'move')
  else
    move_non_command_line_cursor(cursor_col)
  end
end

local function kill_text_to(cursor_col)
  -- Kill the text to the cursor positions. The cursor positrion is zero-based. The cursor will be left in the correct place.

  local cursor_start = current_cursor_col()
  if cursor_col == cursor_start then
    return
  end

  local line = current_line()
  local cursor_left = math.min(cursor_start, cursor_col)
  local cursor_right = math.max(cursor_start, cursor_col)
  local killed_text = current_line():sub(cursor_left+1, cursor_right)
  vim.fn.setreg('-', killed_text, 'c')

  if command_line_mode() then
    command_line_motion(cursor_col, 'delete')
  else
    local line_nr = vim.fn.line '.'
    local cursor_left_byte = vim.fn.byteidx(line, cursor_left)
    local cursor_right_byte = vim.fn.byteidx(line, cursor_right)
    vim.api.nvim_buf_set_text(0, line_nr - 1, cursor_left_byte, line_nr - 1, cursor_right_byte, {})
    move_non_command_line_cursor(cursor_left)
  end
end

function readline.forward_word()
  move_cursor_to(forward_cursor_col())
end

function readline.backward_word()
  move_cursor_to(backward_cursor_col())
end

function readline.end_of_line()
  move_cursor_to(last_cursor_col())
end

function readline.beginning_of_line()
  move_cursor_to(0)
end

function readline.kill_word()
  kill_text_to(forward_cursor_col())
end

function readline.backward_kill_word()
  kill_text_to(backward_cursor_col())
end

function readline.kill_line()
  kill_text_to(last_cursor_col())
end

function readline.backward_kill_line()
  kill_text_to(0)
end

return readline
