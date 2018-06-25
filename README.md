# gen_clang_conf.vim

plugin for [Vim](https://github.com/vim/vim)/[NeoVim](https://github.com/neovim/neovim) to ease the use of clang_config(`.clang` or `.clang_complete`).</br>

It is used for generate and maintain clang_config and provide a clang completion source for [nvim-completion-manager](https://github.com/roxma/nvim-completion-manager) and [deoplete.nvim](https://github.com/Shougo/deoplete.nvim), tested on Windows/Linux. </br>

`gen_clang_conf.vim` will detect SCM(git, hg, svn) root and use it as the project root path.

## Installation
* [vim-plug](https://github.com/junegunn/vim-plug)
    `Plug 'fcying/gen_clang_conf.vim'`

## Commands
* `:GenClangConf`  

    gen `.clang` in scm dir, it will join all folders with contain (`c`, `cpp`, `h`) file

* `:EditClangExt`  

    Edit an extend configuration file `.clang_ext` for this project, it will load before `.clang` file.

* `:ClearClangConf`  

    remove `.clang` and `.clang_ext` in scm dir.
