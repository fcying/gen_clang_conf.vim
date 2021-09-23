" ============================================================================
" File: gen_clang_conf.vim
" Author: fcying
" ============================================================================

if !exists('g:gencconf_ignore_dirs')
  let g:gencconf_ignore_dirs = ['__pycache__', 'out', 'lib', 'build', 
        \ 'cache', 'doc', 'docs']
endif

if !exists('g:gencconf_ignore_files')
  let g:gencconf_ignore_files = []
endif

if !exists('g:gencconf_scm_list')
  let g:gencconf_scm_list = ['.root', '.git', '.svn', '.hg']
endif

if !exists('g:gencconf_suffix_list')
  let g:gencconf_suffix_list = ['c', 'cc', 'cpp', 'h', 'hh']
endif

if !exists('g:gencconf_conf_name')
  let g:gencconf_conf_name = 'compile_flags.txt'
endif

if !exists('g:gencconf_conf_save_in_scm')
  let g:gencconf_conf_save_in_scm = 0
endif

if !exists('g:gencconf_default_conf')
  let g:gencconf_default_conf = ['%c -std=c11', '%cpp -std=c++14']
endif

if !exists('g:gencconf_ctags_bin')
  let g:gencconf_ctags_bin = 'ctags'
endif

if !exists('g:gencconf_ctags_opts')
  let g:gencconf_ctags_opts = '--languages=c++ --languages=+c'
endif

if !exists('g:gencconf_load_tags')
  let g:gencconf_load_tags = 1
endif

if g:gencconf_load_tags ==# 1
  call gen_clang_conf#load_tags()
endif

command! -nargs=0 GenClangConf call gen_clang_conf#gen_clang_conf()
command! -nargs=0 ClearClangConf call gen_clang_conf#clear_clang_conf()
command! -nargs=0 GenCtags call gen_clang_conf#gen_ctags()
command! -nargs=0 ClearCtags call gen_clang_conf#clear_ctags()

