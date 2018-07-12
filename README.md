# gen_clang_conf.vim

plugin for [Vim](https://github.com/vim/vim)/[NeoVim](https://github.com/neovim/neovim) to ease the use `.clang_complete`.</br>

It is used for generate `.clang_complete` for [ncm2](https://github.com/ncm2/ncm2) and [deoplete.nvim](https://github.com/Shougo/deoplete.nvim), tested on Windows/Linux. </br>

## Installation
* [vim-plug](https://github.com/junegunn/vim-plug)

    `Plug 'fcying/gen_clang_conf.vim'`

## Options
* `g:gen_clang_conf#ignore_dirs`

    Specify the directories you want to exclude while `GenClangConf`, ignore case.
    ```vim
    let g:gen_clang_conf#ignore_dirs = ['__pycache__', 'out', 'lib', 'build', 
        \ 'cache', 'doc', 'docs']
    ```

## Commands
* `:GenClangConf`  

    Gen `.clang_complete` in scm dir(`.root`, `.git`, `.svn`, `.hg`), it will join all folders with contain (`c`, `cpp`, `h`) file
    if not found scm dir, gen `.clang_complete` in current dir.

* `:EditClangExt`  

    Edit an extend configuration file `.clang_ext` for this project, after call `:GenClangConf`, it will 
    add to the top of `.clang_complete`.

* `:ClearClangConf`  

    Remove `.clang` and `.clang_ext` in scm dir.
