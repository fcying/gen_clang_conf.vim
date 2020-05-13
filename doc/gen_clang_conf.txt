# gen_clang_conf.vim

plugin for [Vim](https://github.com/vim/vim)/[NeoVim](https://github.com/neovim/neovim) to easy use clang config.</br>

It is used for generate config(`compile_flags.txt` or `ccls`) for `clangd` or `ccls`, tested on Windows/Linux. </br>

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


* `g:gen_clang_conf#clang_conf_name`

    Specify clang config file name, ex: `compile_flags.txt`, `.ccls`, `.clang_complete`.
    default value: 
    ```vim
      let g:gen_clang_conf#clang_conf_name = 'compile_flags.txt'
    ```


## Commands
* `:GenClangConf`

    Gen `compile_flags.txt` in scm's parent dir, it will add all the directories
    containing the specified suffix files.
    if not found scm dir, gen `compile_flags.txt` in current dir.

* `:EditClangExt`  

    Edit an extend configuration file `.clang_ext` for this project in scm dir,  
    after call `:GenClangConf`, it will add to the top of `compile_flags.txt`.  
    Use a blank line to split options(rewrite `g:gen_clang_conf#ignore_dirs`  
    `g:gen_clang_conf#default_conf` `g:gen_clang_conf#default_conf` for this project)  
    and clang config.  

    Ex:
    ```
    ignore_dirs=out,build
    suffix_list=.c,.h
    default_conf=%c -std=c11,%cpp -std=c++14

    -DDebug
    -I$HOME/test/include
    -I/usr/local/include
    ```

* `:ClearClangConf`

    Remove `compile_flags.txt`.
