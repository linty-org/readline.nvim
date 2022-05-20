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
vim.keymap.set('!', '<C-w>', readline.backward_kill_word)
vim.keymap.set('!', '<C-k>', readline.kill_line)
vim.keymap.set('!', '<C-u>', readline.backward_kill_line)
```

## Design

This plugin does not create any keyboard mappings. Instead, it provides Lua functions that implement the Readline motion and deletion commands in Insert and Command-line mode. Once you have these functions, it's easy to create mappings in your Neovim config implementing whatever subset of the Readline shortcuts you actually want.

Some of the Readline default shortcuts conflict with Vim defaults: for example, `<C-t>` in Readline swaps the last two characters, and `<C-t>` in Vim's Insert mode indents the current line. So, while usually I think plugin authors should just set good defaults, in this case I think there should be some user choice about which mappings to use. There are some [sample configs](#sample-configs) below that you can copy-paste from, including an [opinionated](#opinionated) one if you just want to copy-paste something and be done.

Some Readline commands, for example `<C-f>` to move the cursor forward one character, don't need to be implemented using Lua functions. They can be bound like so: `vim.keymap.set('!', '<C-f>', '<Right>')`.

## Supported Readline commands

| Readline command             | RL shortcut | readline.nvim function / Vim command |
| ---                          | ---         | ---                                  |
| `kill-line`                  | `C-k`       | `kill_line`                          |
| `backward-kill-line`         | `C-u`       | `backward_kill_line`                 |
| `kill-word`                  | `M-d`       | `kill_word`                          |
| `backward-kill-word`         | `C-w`       | `backward_kill_word`                 |
| `delete-char`                | `C-d`       | `<Delete>`                           |
| `backward-delete-char`       | `C-h`       | `<BS>`                               |
| `beginning-of-line`          | `C-a`       | `beginning_of_line`                  |
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

### References

- GNU docs
  - https://www.gnu.org/software/bash/manual/html_node/Commands-For-Moving.html
  - https://www.gnu.org/software/bash/manual/html_node/Commands-For-Text.html
  - https://www.gnu.org/software/bash/manual/html_node/Commands-For-Killing.html
- [Wikipedia](https://en.wikipedia.org/wiki/GNU_Readline)

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
vim.keymap.set('!', '<C-w>', readline.backward_kill_word)
vim.keymap.set('!', '<C-k>', readline.kill_line)
vim.keymap.set('!', '<C-u>', readline.backward_kill_line)
```

Personally I have OS-level custom keyboard mappings for the arrow keys, `<BS>`, and `<Delete>`, so I don't need the `CTRL`-key Readline versions of those commands.

### Maximal

This config creates Neovim mappings for all of the default Readline text-editing shortcuts, minus ones readline.nvim doesn't (yet) have support for, for example `transpose-chars` and `capitalize-word`. You can copy-paste this block into your `init.lua` and delete the mappings you don't want.

```lua
local readline = require 'readline'
vim.keymap.set('!', '<C-k>', readline.kill_line)
vim.keymap.set('!', '<C-u>', readline.backward_kill_line)
vim.keymap.set('!', '<M-d>', readline.kill_word)
vim.keymap.set('!', '<C-w>', readline.backward_kill_word)
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
