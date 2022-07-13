# readline.nvim

Readline motions and deletions in Neovim.

## Introduction

The [Readline](https://en.wikipedia.org/wiki/GNU_Readline) text-editing shortcuts let you do things like move the cursor or delete text by a word or a line at a time. The Readline shortcuts are enabled by default all over the place: for example, in the major shells (Bash, Zsh, fish), in programming language REPLs, and [even in macOS](https://support.apple.com/en-us/HT201236). So you should probably use them if you aren't already!

This plugin adds support for Readline text-editing shortcuts in Neovim in Insert mode, as well as in Command-line mode (when entering a command with `:`, when searching with `/` or `?`, etc.).

## Quick start

Install readline.nvim using [vim-plug](https://github.com/junegunn/vim-plug) with `Plug 'linty-org/readline.nvim'`, or use your favorite Neovim plugin manager. Requires at least Neovim 0.7.

Then add the following code block to your `init.lua` to enable some of the most-useful Readline shortcuts in Insert and Command-line mode, for moving or deleting by a word at a time, or to beginning/end-of-line.
```lua
local readline = require 'readline'
vim.keymap.set('!', '<M-f>', readline.forward_word)
vim.keymap.set('!', '<M-b>', readline.backward_word)
vim.keymap.set('!', '<C-a>', readline.beginning_of_line)
vim.keymap.set('!', '<C-e>', readline.end_of_line)
vim.keymap.set('!', '<M-d>', readline.kill_word)
vim.keymap.set('!', '<M-BS>', readline.backward_kill_word)
vim.keymap.set('!', '<C-w>', readline.unix_word_rubout)
vim.keymap.set('!', '<C-k>', readline.kill_line)
vim.keymap.set('!', '<C-u>', readline.backward_kill_line)
```

## Design

This plugin does not create any keyboard mappings. Instead, it provides Lua functions that implement the Readline motion and deletion commands in Insert and Command-line mode. Once you have these functions, it's easy to create mappings in your Neovim config implementing whatever subset of the Readline shortcuts you actually want. There are some [sample configs](#sample-configs) below that you can copy-paste from, including an [opinionated](#opinionated) one if you just want to copy-paste something and be done.

Some of the Readline default shortcuts conflict with Vim defaults: for example, `<C-t>` in Readline swaps the last two characters, and `<C-t>` in Vim's Insert mode indents the current line. So, while usually I think plugin authors should just set good defaults, in this case I think there should be some user choice about which mappings to use.

Some Readline commands, for example `<C-f>` to move the cursor forward one character, have identical or nearly-identical Vim equivalents, and don't need to be implemented using Lua functions. They can be bound like so: `vim.keymap.set('!', '<C-f>', '<Right>')`.

## Supported Readline commands

| Readline command             | RL shortcut | readline.nvim function / Vim command |
| ---                          | ---         | ---                                  |
| `kill-line`                  | `C-k`       | `kill_line`                          |
| `backward-kill-line`         | `C-u`       | `backward_kill_line`                 |
| `kill-word`                  | `M-d`       | `kill_word`                          |
| `backward-kill-word`         | `M-BS`      | `backward_kill_word`                 |
| `unix-word-rubout`           | `C-w`       | `unix_word_rubout`                   |
| `delete-char`                | `C-d`       | `<Delete>`                           |
| `backward-delete-char`       | `C-h`       | `<BS>`                               |
| `beginning-of-line`          | `C-a`       | `beginning_of_line`                  |
| `back-to-indentation`        | `M-m`       | `back_to_indentation`                |
| `end-of-line`                | `C-e`       | `end_of_line`                        |
| `forward-word`               | `M-f`       | `forward_word`                       |
| `backward-word`              | `M-b`       | `backward_word`                      |
| `forward-char`               | `C-f`       | `<Right>`                            |
| `backward-char`              | `C-b`       | `<Left>`                             |
| `next-line`                  | `C-n`       | `<Down>`                             |
| `previous-line`              | `C-p`       | `<Up>`                               |
| `transpose-chars`            | `C-t`       | [Ask if desired][issues]             |
| `transpose-words`            | `M-t`       | [Ask if desired][issues]             |
| `quoted-insert`              | `C-v`       | `<C-v>`                              |
| `yank` (called `put` in Vim) | `C-y`       | [Ask if desired][issues]             |
| `yank-pop`                   | `M-y`       | [Ask if desired][issues]             |
| `undo`                       | `C-_`       | [Ask if desired][issues]             |
| `upcase-word`                | `M-u`       | [Ask if desired][issues]             |
| `downcase-word`              | `M-l`       | [Ask if desired][issues]             |
| `capitalize-word`            | `M-c`       | [Ask if desired][issues]             |

[issues]: https://github.com/linty-org/readline.nvim/issues

## Additional commands

| Emacs command                        | Emacs shortcut | readline.nvim function / Vim command |
| ---                                  | ---            | ---                                  |
| [`back-to-indentation`][emacsindent] | `M-m`          | `back_to_indentation`                |

[emacsindent]: https://www.gnu.org/software/emacs/manual/html_node/emacs/Indentation-Commands.html

### References

- GNU docs
  - https://www.gnu.org/software/bash/manual/html_node/Commands-For-Moving.html
  - https://www.gnu.org/software/bash/manual/html_node/Commands-For-Text.html
  - https://www.gnu.org/software/bash/manual/html_node/Commands-For-Killing.html
- [Wikipedia](https://en.wikipedia.org/wiki/GNU_Readline)

## Configuring word characters

Readline motions that operate a-word-at-a-time (`forward-word`, etc.) advance the cursor until arriving at a "word character", then advance until arriving at the first non-word character. Deletion-by-word works similarly. The default set of word characters in Readline consists of [letters and digits](https://www.gnu.org/software/bash/manual/html_node/Commands-For-Moving.html).

What should count as a "word character" can be context-dependent: for example, in C, one may wish to take the word characters to be the alphanumeric characters (`abc…zABC…Z0123…9`) and the underscore (`_`) – those characters that can be used in C variable/symbol names.

This plugin allows you to configure what counts as a word character in two ways:
- You can set the buffer variable `readline_word_chars` to a string consisting of the word characters for the current buffer.
  - `readline.alphanum` is provided for convenience, and consists of the characters `abc…zABC…Z0123…9`.
  - For example, `vim.b.readline_word_chars = readline.alphanum .. '_-'` will cause alphanumerics, hyphens, and underscores to be treated as word characters in the current buffer.
- You can set `readline.word_chars.YOUR_FILETYPE = YOUR_STRING`.
  - For example, `readline.word_chars.bash = readline.alphanum .. '_-'` will cause alphanumerics, hyphens, and underscores to be treated as word characters when `filetype=bash`.
  - The value of `vim.b.readline_word_chars` takes precedence in a buffer (if it's set).

If neither of the above is set, we fall back to `readline.default_word_chars`, which you can set to whatever you like, but which by default is equal to `'abc…zABC…Z0123…9'`.

## Sample configs

### Opinionated

This is the same as the [quick-start](#quick-start) config above. This just enables some of the most-useful Readline shortcuts, for moving or deleting by a word at a time, or to beginning/end-of-line.
```lua
local readline = require 'readline'
vim.keymap.set('!', '<M-f>', readline.forward_word)
vim.keymap.set('!', '<M-b>', readline.backward_word)
vim.keymap.set('!', '<C-a>', readline.beginning_of_line)
vim.keymap.set('!', '<C-e>', readline.end_of_line)
vim.keymap.set('!', '<M-d>', readline.kill_word)
vim.keymap.set('!', '<M-BS>', readline.backward_kill_word)
vim.keymap.set('!', '<C-w>', readline.unix_word_rubout)
vim.keymap.set('!', '<C-k>', readline.kill_line)
vim.keymap.set('!', '<C-u>', readline.backward_kill_line)
```

Personally, I have OS-level custom keyboard mappings for the arrow keys, `<BS>`, and `<Delete>` to make them easier to type, so I don't need the `CTRL`-key Readline versions of those commands.

### Maximal

This config creates Neovim mappings for all of the default Readline text-editing shortcuts, minus ones readline.nvim doesn't (yet) have support for, for example `transpose-chars` and `capitalize-word`. You can copy-paste this block into your `init.lua` and delete the mappings you don't want.

```lua
local readline = require 'readline'
vim.keymap.set('!', '<C-k>', readline.kill_line)
vim.keymap.set('!', '<C-u>', readline.backward_kill_line)
vim.keymap.set('!', '<M-d>', readline.kill_word)
vim.keymap.set('!', '<M-BS>', readline.backward_kill_word)
vim.keymap.set('!', '<C-w>', readline.unix_word_rubout)
vim.keymap.set('!', '<C-d>', '<Delete>')  -- delete-char
vim.keymap.set('!', '<C-h>', '<BS>')      -- backward-delete-char
vim.keymap.set('!', '<C-a>', readline.beginning_of_line)
vim.keymap.set('!', '<C-e>', readline.end_of_line)
vim.keymap.set('!', '<M-f>', readline.forward_word)
vim.keymap.set('!', '<M-b>', readline.backward_word)
vim.keymap.set('!', '<C-f>', '<Right>') -- forward-char
vim.keymap.set('!', '<C-b>', '<Left>')  -- backward-char
vim.keymap.set('!', '<C-n>', '<Down>')  -- next-line
vim.keymap.set('!', '<C-p>', '<Up>')    -- previous-line
```

## Similar plugins

- https://github.com/tpope/vim-rsi
- https://github.com/ryvnf/readline.vim
