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

py3 << EOF
import vim, sys, os.path
cwd = vim.eval('expand("<sfile>:p:h")')
sys.path.insert(0, os.path.join(cwd, '../autoload/python'))
from gen_clang_conf import GenClangConf
EOF

function! s:gen_clang_conf()
py3 << EOF
ret = GenClangConf().gen_clang_conf()
if ret == 1:
  print("GenClangConf success")
else:
  print("GenClangConf failed")
EOF
endfunction

function! s:clear_clang_conf()
py3 << EOF
GenClangConf().clear_clang_conf()
EOF
endfunction

function! s:edit_clang_conf()
py3 << EOF
file = GenClangConf().get_clang_conf_path()
if file:
  vim.command('edit ' + file)
EOF
endfunction

command! -nargs=0 GenClangConf call s:gen_clang_conf()
command! -nargs=0 ClearClangConf call s:clear_clang_conf()
command! -nargs=0 EditClangConf call s:edit_clang_conf()

