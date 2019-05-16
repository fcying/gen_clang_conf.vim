# gen_clang_conf.vim

plugin for [Vim](https://github.com/vim/vim)/[NeoVim](https://github.com/neovim/neovim) to ease the use `.clang_complete`.</br>

It is used for generate `.clang_complete` for [ncm2](https://github.com/ncm2/ncm2) and [deoplete.nvim](https://github.com/Shougo/deoplete.nvim), tested on Windows/Linux. </br>

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

    if set `1`, clang_config file will save in scm dir.
    default value: 0


* `g:gen_clang_conf#clang_conf_name`

    Specify clang config file name, ex: `compile_flags.txt`, `.clang_complete`.
    default value: 
    ```vim
      let g:gen_clang_conf#clang_conf_name = 'compile_flags.txt'
    ```


## Commands
* `:GenClangConf`

    Gen `.clang_complete` in scm dir, it will add all the directories
    containing the specified suffix files.
    if not found scm dir, gen `.clang_complete` in current dir.

* `:EditClangConf`

    Edit clang configuration file `.clang_complete` for this project.
    The custom configuration is written at the beginning of the file,
    Use a blank line to split custom configuration and auto gen configuration.
    Ex:
    ```
    -DTEST

    -Isrc
    -Iinc
    ```

* `:ClearClangConf`

    Remove `.clang_complete` in scm dir.
