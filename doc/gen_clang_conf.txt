# gen_clang_conf.vim

plugin for [Vim](https://github.com/vim/vim)/[NeoVim](https://github.com/neovim/neovim) to easy use clang config.</br>

It is used for generate simple config file for `clangd`, `ccls`, `ycm`, tested on Windows/Linux. </br>

get file list default use `rg`, if not have, use vim script(may be slow). </br>

## Installation
* [vim-plug](https://github.com/junegunn/vim-plug)

    `Plug 'fcying/gen_clang_conf.vim'`

## Options
* `g:gen_clang_conf#ignore_dirs`

    Specify the directories you want to exclude while generate config or tags.</br>
    default value:
    ```vim
    let g:gen_clang_conf#ignore_dirs = ['__pycache__', 'out', 'lib', 'build',
        \ 'cache', 'doc', 'docs']
    ```


* `g:gen_clang_conf#ignore_files`

    Specify the files you want to exclude while generate config or tags.</br>
    default value:
    ```vim
    let g:gen_clang_conf#ignore_dirs = ['__pycache__', 'out', 'lib', 'build',
        \ 'cache', 'doc', 'docs']
    ```


* `g:gen_clang_conf#scm_list`

    Specify the which directoriy is scm dir.</br>
    default value:
    ```vim
    let g:gen_clang_conf#scm_list = ['.root', '.git', '.svn', '.hg']
    ```


* `g:gen_clang_conf#suffix_list`

    Specify the which suffix file will be found.</br>
    default value:
    ```vim
    let g:gen_clang_conf#suffix_list = ['.c', '.cc', '.cpp', '.h', '.hh']
    ```


* `g:gen_clang_conf#conf_save_in_scm`

    `1`, config will save in scm dir, `0`, save in scm's parent dir.</br>
    default value: 0


* `g:gen_clang_conf#default_conf`

    Default config, add before autogen config.</br>
    default value:
    ```vim
    let g:gen_clang_conf#default_conf = ['%c -std=c11', '%cpp -std=c++14']
    ```


* `g:gen_clang_conf#conf_name`

    Specify clang config file name, ex: `compile_flags.txt`, `.ccls`, `.clang_complete`, `.ycm_extra_conf.py`.</br>
    default value: 
    ```vim
      let g:gen_clang_conf#conf_name = 'compile_flags.txt'
    ```


* `g:gen_clang_conf#ctags_bin`

    Set path of ctags bin.</br>
    default value: `ctags`


* `g:gen_clang_conf#ctags_opts`

    Set ctags options.</br>
    default value: `''`


## Commands
* `:GenClangConf`

    Gen `compile_flags.txt` in scm's parent dir, it will add all the directories</br>
    containing the specified suffix files.</br>
    if not found scm dir, gen `compile_flags.txt` in current dir.

* `:ClearClangConf`

    Remove the generated file.

* `:GenCtags`

    Gen `tags` in scm's dir.</br>
    if not found scm dir, gen in current dir.

* `:ClearCtags`

    Remove the generated tags.

