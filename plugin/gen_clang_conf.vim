" ============================================================================
" File: gen_clang_conf.vim
" Author: fcying
" ============================================================================

py3 << EOF
import vim, sys, os.path
cwd = vim.eval('expand("<sfile>:p:h")')
sys.path.insert(0, os.path.join(cwd, '../autoload/python'))
from gen_clang_conf import *
EOF

function! s:gen_clang_conf()
py3 << EOF
GenClangConf().gen_clang_conf()
EOF
echo "GenClangConf success"
endfunction

function! s:clear_clang_conf()
py3 << EOF
GenClangConf().clear_clang_conf()
EOF
endfunction

function! s:edit_clang_ext()
py3 << EOF
file = GenClangConf().get_clang_ext_path()
if file:
  vim.command('edit ' + file)
EOF
"edit file
endfunction

command! -nargs=0 GenClangConf call s:gen_clang_conf()
command! -nargs=0 ClearClangConf call s:clear_clang_conf()
command! -nargs=0 EditClangExt call s:edit_clang_ext()

