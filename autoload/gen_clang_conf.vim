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

if !exists('g:gencconf_root_markers')
  let g:gencconf_root_markers = ['.root', '.git', '.svn', '.hg']
endif

if !exists('g:gencconf_suffix_list')
  let g:gencconf_suffix_list = { 'c': ['c'], 'cpp': ['cc', 'cpp'], 'h': ['h', 'hh']}
endif

if !exists('g:gencconf_conf_name')
  let g:gencconf_conf_name = 'compile_commands.json'
endif

if !exists('g:gencconf_storein_rootmarker')
  let g:gencconf_storein_rootmarker = 1
endif

if !exists('g:gencconf_default_options')
  let g:gencconf_default_options = {'c': ['gcc', '-c', '-std=c11'], 'cpp': ['g++', '-c', '-std=c++14']}
endif

if !exists('g:gencconf_ctags_bin')
  let g:gencconf_ctags_bin = 'ctags'
endif

if !exists('g:gencconf_ctags_opts')
  let g:gencconf_ctags_opts = '--languages=c++ --languages=+c'
endif

if !exists('g:gencconf_relative_path')
  let g:gencconf_relative_path = 1
endif

let s:root_marker = ''
let s:root_dir = ''
let s:is_win = has('win32')
let s:ctags_name = 'prj_tags'

let s:file_list = []
let s:dir_list = []
let s:suffix_list_all = g:gencconf_suffix_list.c + g:gencconf_suffix_list.cpp + g:gencconf_suffix_list.h

if s:is_win
  let s:delimiter = '\'
else
  let s:delimiter = '/'
endif

function! s:get_root_dir()
  for l:item in g:gencconf_root_markers
    let l:dir = finddir(l:item, '.;')
    if !empty(l:dir)
      break
    endif
  endfor
  if !empty(l:dir)
    let s:root_marker = fnamemodify(l:dir, ':p:h')
    let s:root_dir = fnamemodify(l:dir, ':p:h:h')
  else
    let s:root_marker = getcwd()
    let s:root_dir = getcwd()
  endif
  if !exists('s:ignore_dirs')
    let s:ignore_dirs = g:gencconf_ignore_dirs
    call extend(s:ignore_dirs, g:gencconf_root_markers)
  endif
endfunction

function! s:get_conf_path()
  call s:get_root_dir()
  if g:gencconf_storein_rootmarker ==# 1
    let s:conf_path = s:root_marker . s:delimiter . g:gencconf_conf_name
    let s:ctags_path = s:root_marker . s:delimiter . s:ctags_name
    let s:cache_path = s:root_marker . '/.cache/clangd'
  else
    let s:conf_path = s:root_dir . s:delimiter . g:gencconf_conf_name
    let s:ctags_path = s:root_dir . s:delimiter . s:ctags_name
    let s:cache_path = s:root_dir . '/.cache/clangd'
  endif
endfunction

function! s:vim_get_filelist(root_dir)
  "check ignore dirs
  let l:path_list = split(a:root_dir, s:delimiter)
  if index(s:ignore_dirs, l:path_list[-1]) != -1
    return
  endif

  for str in readdir(a:root_dir)
    let l:full_path = a:root_dir . s:delimiter . str
    if file_readable(l:full_path)
      " check suffix
      let l:suffix = fnamemodify(str, ':e')
      if index(s:suffix_list_all, l:suffix) != -1
        " check ignore files
        if index(g:gencconf_ignore_files, fnamemodify(str, ':t')) != -1
          continue
        endif
        call add(s:file_list, l:full_path)
      endif
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
    for str in s:suffix_list_all
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
  for i in range(len(s:file_list))
    if g:gencconf_relative_path ==# 1
      let s:file_list[i] = substitute(s:file_list[i], s:root_dir . s:delimiter , '', '')
    endif
    call add(s:dir_list, '-I' . substitute(fnamemodify(s:file_list[i], ':h'), '\\', '/', 'g'))
  endfor
  call sort(s:dir_list)
  call uniq(s:dir_list)
  "echom s:dir_list
endfunction

function! gen_clang_conf#gen_clang_conf() abort
  call s:get_conf_path()

  let l:conf_list = []

  if g:gencconf_conf_name ==# 'compile_commands.json'
      "get default options
      let l:default_c_options = []
      for str in g:gencconf_default_options.c
        call add(l:default_c_options, '      "' . str . '",')
      endfor
      let l:default_cpp_options = []
      for str in g:gencconf_default_options.cpp
        call add(l:default_cpp_options, '      "' . str . '",')
      endfor

      "get include dirs
      call s:get_dir_list()
      let l:include_dirs = []
      for dir in s:dir_list
        call add(l:include_dirs, '      "' . dir . '",')
      endfor

      "gen compile_commands.json
      call add(l:conf_list, '[')
      for file in s:file_list
        let l:suffix = fnamemodify(file, ':e')

        "ignore h file
        if index(g:gencconf_suffix_list.h, l:suffix) != -1
          continue
        endif

        call add(l:conf_list, '  {')
        call add(l:conf_list, '    "arguments": [')
        if index(g:gencconf_suffix_list.c, l:suffix) != -1
          call extend(l:conf_list, l:default_c_options)
        else
          call extend(l:conf_list, l:default_cpp_options)
        endif
        call extend(l:conf_list, l:include_dirs)
        call add(l:conf_list, '      "' . file . '"')
        call add(l:conf_list, '    ],')
        call add(l:conf_list, '    "directory": "' . s:root_dir . '",')
        call add(l:conf_list, '    "file": "' . file . '"')
        call add(l:conf_list, '  },')
      endfor
      call add(l:conf_list, ']')
  else
    "default options
    call extend(l:conf_list, g:gencconf_default_options.c)

    "gen config
    call s:get_dir_list()
    if empty(s:dir_list)
      echom 'not found files with suffix_list'
      return
    endif
    call extend(l:conf_list, s:dir_list)

    "add special config
    if g:gencconf_conf_name ==# '.ccls'
      call insert(l:conf_list, 'clang')
    elseif g:gencconf_conf_name ==# '.ycm_extra_conf.py'
      for i in range(len(l:conf_list))
        let l:conf_list[i] = "'" . l:conf_list[i] . "',"
      endfor
      call insert(l:conf_list, "flags = { 'flags': [")
      call add(l:conf_list, ']}')
      call add(l:conf_list, 'def Settings( **kwargs ):')
      call add(l:conf_list, '    return flags')
    endif
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
  if g:gencconf_conf_name ==# 'compile_commands.json'
    call delete(s:cache_path, 'rf')
  endif
  echom 'ClearClangConf success'
  redraw
endfunction

function! gen_clang_conf#gen_ctags() abort
  call s:get_conf_path()
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
          \ ' -R -f ' . s:ctags_path .
          \ ' ' . g:gencconf_ctags_opts .
          \ ' ' . l:cmd . ' ' . s:root_dir,
          \ function('s:gen_ctags_end'))
    if filereadable(expand(s:ctags_path)) != 0
      exec 'set tags^=' . s:ctags_path
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
  call s:get_conf_path()
  exec 'set tags^=' . s:ctags_path
endfunction

function! gen_clang_conf#clear_ctags() abort
  call s:get_conf_path()
  call delete(s:ctags_path)
  echom 'ClearCtags success'
  redraw
endfunction
