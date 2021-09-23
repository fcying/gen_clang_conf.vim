" ============================================================================
" File: gen_clang_conf.vim
" Author: fcying
" ============================================================================


let s:scm_dir = ''
let s:root_dir = ''
let s:is_win = has('win32')
let s:ctags_name = '/prj_tags'

let s:file_list = []
let s:dir_list = []

if s:is_win
  let s:delimiter = '\'
else
  let s:delimiter = '/'
endif

function! s:get_root_dir()
  for l:item in g:gencconf_scm_list
    let l:dir = finddir(l:item, '.;')
    if !empty(l:dir)
      break
    endif
  endfor
  if !empty(l:dir)
    let s:scm_dir = fnamemodify(l:dir, ':p:h')
    let s:root_dir = fnamemodify(l:dir, ':p:h:h')
  else
    let s:scm_dir = getcwd()
    let s:root_dir = getcwd()
  endif
  if !exists('s:ignore_dirs')
    let s:ignore_dirs = g:gencconf_ignore_dirs
    call extend(s:ignore_dirs, g:gencconf_scm_list)
  endif
endfunction

function! s:get_conf_path()
  call s:get_root_dir()
  if g:gencconf_conf_save_in_scm ==# 1
    let s:conf_path = s:scm_dir . s:delimiter . g:gencconf_conf_name
  else
    let s:conf_path = s:root_dir . s:delimiter . g:gencconf_conf_name
  endif
endfunction

function! s:vim_get_filelist(root_dir)
  let l:path_list = split(a:root_dir, s:delimiter)
  for dir in s:ignore_dirs
    if l:path_list[-1] ==# dir
      return
    endif
  endfor
  for str in readdir(a:root_dir)
    let l:full_path = a:root_dir . s:delimiter . str
    if file_readable(l:full_path)
      for ignore_file in g:gencconf_ignore_files
      endfor
      for suffix in g:gencconf_suffix_list
        if fnamemodify(str, ':e') == suffix
          let l:file_name = fnamemodify(str, ':t')
          let l:is_ignore_file = 0
          for ignore_file in g:gencconf_ignore_files
            if l:file_name == ignore_file
              let l:is_ignore_file = 1
              break
            endif
          endfor
          if l:is_ignore_file ==# 0
            call add(s:file_list, l:full_path)
          endif
          break
        endif
      endfor
    elseif isdirectory(l:full_path)
      call s:vim_get_filelist(l:full_path)
    endif
  endfor
endfunction

function! s:get_file_list()
  if executable('rg')
    let l:cmd = 'rg --no-messages --no-config --files '
    for str in s:ignore_dirs
      if s:is_win
        let l:cmd = l:cmd . '-g="!' . str . '" '
      else
        let l:cmd = l:cmd . "-g='!" . str . "' "
      endif
    endfor
    for str in g:gencconf_suffix_list
      if s:is_win
        let l:cmd = l:cmd . '-g="*.' . str . '" '
      else
        let l:cmd = l:cmd . "-g='*." . str . "' "
      endif
    endfor
    for str in g:gencconf_ignore_files
      if s:is_win
        let l:cmd = l:cmd . '-g="!' . str . '" '
      else
        let l:cmd = l:cmd . "-g='!" . str . "' "
      endif
    endfor
    let l:cmd = l:cmd . ' ' . fnamemodify(s:root_dir, ':p')
    "echom l:cmd
    let s:file_list = systemlist(l:cmd)
  else
    let s:file_list = []
    call s:vim_get_filelist(s:root_dir)
  endif
  "echom s:file_list
endfunction

function! s:get_dir_list()
  let s:dir_list = []
  call s:get_file_list()
  for str in s:file_list
    let l:rel_path = substitute(str, s:root_dir . s:delimiter , '', '')
    call add(s:dir_list, '-I' . substitute(fnamemodify(l:rel_path, ':h'), '\\', '/', 'g'))
  endfor
  call sort(s:dir_list)
  call uniq(s:dir_list)
  "echom s:dir_list
endfunction

function! gen_clang_conf#gen_clang_conf() abort
  call s:get_conf_path()

  let l:conf_list = []

  "default config
  for str in g:gencconf_default_conf
    call add(l:conf_list, str)
  endfor

  "gen config
  call s:get_dir_list()
  if empty(s:dir_list)
    echom 'not found files with suffix_list'
    return
  endif
  for config in s:dir_list
    call add(l:conf_list, config)
  endfor

  "add special config
  if g:gencconf_conf_name ==# '.ccls'
    call insert(l:conf_list, 'clang')
  elseif g:gencconf_conf_name ==# '.ycm_extra_conf.py'
    for index in range(len(l:conf_list))
      let l:conf_list[index] = "'" . l:conf_list[index] . "',"
    endfor
    call insert(l:conf_list, "flags = { 'flags': [")
    call add(l:conf_list, ']}')
    call add(l:conf_list, 'def Settings( **kwargs ):')
    call add(l:conf_list, '    return flags')
  endif

  "write config
  "echom l:conf_list
  call writefile(l:conf_list, s:conf_path)

  echom 'GenClangConf success'
  redraw
endfunction

function! gen_clang_conf#clear_clang_conf() abort
  call s:get_conf_path()
  call delete(s:conf_path)
  echom 'ClearClangConf success'
  redraw
endfunction

function! gen_clang_conf#gen_ctags() abort
  call s:get_root_dir()
  let l:cmd = ''
  for str in s:ignore_dirs
    let l:cmd = l:cmd . '--exclude="' . str . '" '
  endfor
  for str in g:gencconf_ignore_files
    let l:cmd = l:cmd . '--exclude="' . str . '" '
  endfor
  "echom l:cmd
  if executable(g:gencconf_ctags_bin)
    call gen_clang_conf#job#start(g:gencconf_ctags_bin .
          \ ' -R -f ' . s:scm_dir . s:ctags_name .
          \ ' ' . g:gencconf_ctags_opts .
          \ ' ' . l:cmd . ' ' . s:root_dir,
          \ function('s:gen_ctags_end'))
    if filereadable(expand(g:scm_dir . s:ctags_name)) != 0
      exec 'set tags^=' . g:scm_dir . s:ctags_name
    endif
  else
    echom "need install ctags"
  endif
endfunction

function! s:gen_ctags_end(...) abort
  call gen_clang_conf#load_tags()
  echom "GenCtags success"
  redraw
endfunction

function! gen_clang_conf#load_tags() abort
  call s:get_root_dir()
  if filereadable(expand(g:scm_dir . s:ctags_name)) != 0
    exec 'set tags^=' . g:scm_dir . s:ctags_name
  endif
endfunction

function! gen_clang_conf#clear_ctags() abort
  call s:get_root_dir()
  call delete(s:scm_dir . s:ctags_name)
  echom 'ClearCtags success'
  redraw
endfunction
