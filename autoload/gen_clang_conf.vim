" ============================================================================
" File: gen_clang_conf.vim
" Author: fcying
" ============================================================================

py3 << EOF
import vim, sys, os.path
cwd = vim.eval('expand("<sfile>:p:h")')
sys.path.insert(0, os.path.join(cwd, '../autoload/python'))
from gen_clang_conf import GenClangConf
EOF

function! gen_clang_conf#gen_clang_conf() abort
py3 << EOF
ret = GenClangConf().gen_clang_conf()
if ret == 0:
  print("GenClangConf success")
else:
  print("GenClangConf failed")
EOF
endfunction

function! gen_clang_conf#clear_clang_conf() abort
py3 << EOF
GenClangConf().clear_clang_conf()
EOF
endfunction

function! gen_clang_conf#edit_clang_ext() abort
py3 << EOF
file = GenClangConf().get_ext_conf_path()
if file:
  vim.command('edit ' + file)
EOF
endfunction
