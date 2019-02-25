" ============================================================================
" File: gen_clang_conf.vim
" Author: fcying
" ============================================================================

if !exists('g:gen_clang_conf#ignore_dirs')
  let g:gen_clang_conf#ignore_dirs = ['__pycache__', 'out', 'lib', 'build', 
        \ 'cache', 'doc', 'docs']
endif

if !exists('g:gen_clang_conf#scm_list')
  let g:gen_clang_conf#scm_list = ['.root', '.git', '.svn', '.hg']
endif

if !exists('g:gen_clang_conf#suffix_list')
  let g:gen_clang_conf#suffix_list = ['.c', '.cc', '.cpp', '.h', '.hh']
endif

command! -nargs=0 GenClangConf call gen_clang_conf#gen_clang_conf()
command! -nargs=0 ClearClangConf call gen_clang_conf#clear_clang_conf()
command! -nargs=0 EditClangConf call gen_clang_conf#edit_clang_conf()

