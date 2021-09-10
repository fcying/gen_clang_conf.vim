# gen_clang_conf.vim

plugin for [Vim](https://github.com/vim/vim)/[NeoVim](https://github.com/neovim/neovim) to easy use clang config.</br>

It is used for generate simple config file for `clangd`, `ccls`, `ycm`, tested on Windows/Linux. </br>

## Installation
* [vim-plug](https://github.com/junegunn/vim-plug)

    `Plug 'fcying/gen_clang_conf.vim'`

## Options
* `g:gen_clang_conf#ignore_dirs`

    Specify the directories you want to exclude while `GenClangConf`, ignore case.
    default value:
    ```vim
    let g:gen_clang_conf#ignore_dirs = ['__pycache__', 'out', 'lib', 'build',
        \ 'cache', 'doc', 'docs']
    ```


* `g:gen_clang_conf#scm_list`

    Specify the which directoriy is scm dir.
    default value:
    ```vim
    let g:gen_clang_conf#scm_list = ['.root', '.git', '.svn', '.hg']
    ```


* `g:gen_clang_conf#suffix_list`

    Specify the which suffix file will be found.
    default value:
    ```vim
    let g:gen_clang_conf#suffix_list = ['.c', '.cc', '.cpp', '.h', '.hh']
    ```


* `g:gen_clang_conf#conf_save_in_scm`

    `1`, config will save in scm dir, `0`, save in scm's parent dir.
    default value: 0


* `g:gen_clang_conf#default_conf`

    Default config, add before autogen config.
    default value:
    ```vim
    let g:gen_clang_conf#default_conf = ['%c -std=c11', '%cpp -std=c++14']
    ```


* `g:gen_clang_conf#conf_name`

    Specify clang config file name, ex: `compile_flags.txt`, `.ccls`, `.clang_complete`, `.ycm_extra_conf.py`.
    default value: 
    ```vim
      let g:gen_clang_conf#conf_name = 'compile_flags.txt'
    ```


## Commands
* `:GenClangConf`

    Gen `compile_flags.txt` in scm's parent dir, it will add all the directories
    containing the specified suffix files.
    if not found scm dir, gen `compile_flags.txt` in current dir.

* `:ClearClangConf`

    Remove the generated file.
