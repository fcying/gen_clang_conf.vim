" ============================================================================
" File: gen_clang_conf.vim
" Author: fcying
" ============================================================================

if exists('g:gencconf_loaded')
    finish
else
    let g:gencconf_loaded = 1
endif

if !exists('g:gencconf_autoload_tag')
  let g:gencconf_autoload_tag = 1
endif

if g:gencconf_autoload_tag ==# 1
  call gen_clang_conf#load_tags()
endif

command! -nargs=0 GenClangConf call gen_clang_conf#gen_clang_conf()
command! -nargs=0 ClearClangConf call gen_clang_conf#clear_clang_conf()
command! -bang -nargs=? GenCtags call gen_clang_conf#gen_ctags(<bang>0,<f-args>)
command! -nargs=0 ClearCtags call gen_clang_conf#clear_ctags()

