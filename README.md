# gen_clang_conf.vim

plugin for [Vim](https://github.com/vim/vim)/[NeoVim](https://github.com/neovim/neovim) to easy use clang config.</br>

It is used for generate simple config file for `clangd`, `ccls`, `ycm`, tested on Windows/Linux. </br>

get file list default use `rg`, if not have, use vim script(may be slow). </br>

## Installation
* [vim-plug](https://github.com/junegunn/vim-plug)

    `Plug 'fcying/gen_clang_conf.vim'`

## Options
* `g:gencconf_ignore_dir`

    Specify the directories you want to exclude while generate config or tags.</br>
    default value:
    ```vim
    let g:gencconf_ignore_dir = ['__pycache__', 'out', 'lib', 'build',
        \ 'cache', 'doc', 'docs']
    ```


* `g:gencconf_ignore_file`

    Specify the files you want to exclude while generate config or tags.</br>
    default value:
    ```vim
    let g:gencconf_ignore_file = []
    ```


* `g:gencconf_root_markers`

    Specify the which directoriy is root_marker dir.</br>
    default value:
    ```vim
    let g:gencconf_root_markers = ['.root', '.git', '.svn', '.hg']
    ```


* `g:gencconf_suffix_list`

    Specify the which suffix file will be found.</br>
    default value:
    ```vim
    let g:gencconf_suffix_list = { 'c': ['c'], 'cpp': ['cc', 'cpp'], 'h': ['h', 'hh']}
    ```


* `g:gencconf_storein_rootmarker`

    `1`, config will save in root_marker dir, `0`, save in root_marker's parent dir.</br>
    default value: 1


* `g:gencconf_relative_path`

    `0`: full path, `1`: relative path.</br>
    default value: 1

* `g:gencconf_tag_relative`

    `0`: full path, `1`: ctags set --tag-relative</br>
    default value: 1

* `g:gencconf_default_option`

    Default options, add before autogen config.</br>
    only`compile_commands.json` use `cpp` options.

    default value:
    ```vim
    let g:gencconf_default_option = {
        \ 'c': ['gcc', '-c', '-std=c11'],
        \ 'cpp': ['g++', '-c', '-std=c++14'],
        \ '*': ['-ferror-limit=0']
        \ }
    ```


* `g:gencconf_conf_name`

    Specify clang config file name, ex: `compile_commands.json`, `compile_flags.txt`, `.ccls`, `.ycm_extra_conf.py`.</br>
    default value: 
    ```vim
      let g:gencconf_conf_name = 'compile_commands.json'
    ```


* `g:gencconf_ctags_bin`

    Set path of ctags bin.</br>
    default value: `ctags`


* `g:gencconf_ctags_option`

    Set ctags option.</br>
    default value: ``


* `g:gencconf_autoload_tag`

    Auto load tags in root_marker.</br>
    default value: `1`


## Commands
* `:GenClangConf`

    Gen `compile_flags.txt` in root_marker's parent dir, it will add all the directories</br>
    containing the specified suffix files.</br>
    if not found root_marker dir, gen `compile_flags.txt` in current dir.

* `:ClearClangConf`

    Remove the generated file.

* `:GenCtags languages`

    Gen `tags` in root_marker's dir.</br>
    if not found root_marker dir, gen in current dir.</br>
    parameter is used to set the `languages` option, if not provided, not set `languages`.</br>
    If the tags file exists, only incremental updates to the current file,</br>
    else the whole project will be updated, or you can use the `-bang` option force update whole project</br>
    `:GenCtags! languages`

* `:ClearCtags`

    Remove the generated tags.

