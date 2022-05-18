# readline.nvim

[Readline](https://en.wikipedia.org/wiki/GNU_Readline) text-editing commands for Neovim.

## Summary

The [Readline](https://en.wikipedia.org/wiki/GNU_Readline) text-editing shortcuts let you do things like move the cursor or delete text by a word or a line at a time. The Readline shortcuts are enabled by default all over the place, for example in the major shells (Bash, Zsh, fish), in programming language REPLs, [even in macOS](https://support.apple.com/en-us/HT201236). readline.nvim adds Readline text-editing commands to Neovim (in Insert mode – Command-line mode support coming soon!).

## Installation

Using [vim-plug](https://github.com/junegunn/vim-plug), do `Plug 'linty-org/readline.nvim`, or use your favorite Neovim plugin manager.

## Quick start

Install readline.nvim using your favorite Neovim plugin manager, then put this into your `init.lua`:
```lua
local readline = require 'readline'
vim.keymap.set('i', '<A-f>', readline.forward_word)
vim.keymap.set('i', '<A-b>', readline.backward_word)
vim.keymap.set('i', '<C-a>', readline.beginning_of_line)
vim.keymap.set('i', '<C-e>', readline.end_of_line)
vim.keymap.set('i', '<A-d>', readline.kill_word)
vim.keymap.set('i', '<C-w>', readline.backward_kill_word)
vim.keymap.set('i', '<C-k>', readline.kill_line)
vim.keymap.set('i', '<C-u>', readline.backward_kill_line)
```

## Usage

readline.nvim provides Lua functions that implement the Readline commands, and you can create mappings executing these functions. For example:
```lua
local readline = require 'readline'
vim.keymap.set('i', '<A-f>', readline.forward_word)
vim.keymap.set('i', '<A-b>', readline.backward_word)
```
This is mainly useful in Insert and Command-line mode – in Normal mode the usual Vim Normal mode commands are available – but you can create Normal mode mappings if you want.
