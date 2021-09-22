let s:nvim_job = has('nvim')
let s:vim_job = !has('nvim') && has('job') && has('patch-7.4.1689')
let s:job_list = []

" check job list
function! s:job_check_list(cmd) abort
  for l:item in s:job_list
    if a:cmd ==# l:item['cmd']
      let l:index = index(s:job_list, l:item)
      let l:job = l:item
      break
    endif
  endfor

  if !exists('l:job')
    return 'none'
  endif

  let l:status = s:job_status(l:job['id'])

  " remove finish job
  if l:status ==# 'exit'
    call remove(s:job_list, l:index)
  endif

  return l:status
endfunction

function! s:job_start(cmd, exit_cb) abort
  "echom string(a:cmd)

  let l:job = {}

  if s:nvim_job
    let l:job.on_exit = a:exit_cb
    let l:job_id = jobstart(a:cmd, l:job)

  elseif s:vim_job
    let l:job.exit_cb = a:exit_cb
    let l:job_id = job_start(a:cmd, l:job)

  else
    if has('unix')
      let l:cmd = a:cmd . ' &'
    else
      let l:cmd = 'cmd /c start ' . a:cmd
    endif
    call system(l:cmd)
    let l:job_id = -1
  endif

  return l:job_id
endfunction

function! s:job_stop(job_id) abort
  if s:nvim_job
    call jobstop(a:job_id)
  elseif s:vim_job
    call job_stop(a:job_id)
  endif
endfunction

function! s:job_status(job_id) abort
  if s:nvim_job
    try
      call jobpid(a:job_id)
      return 'run'
    catch
      return 'exit'
    endtry
  elseif s:vim_job
    if job_status(a:job_id) ==# 'dead'
      return 'exit'
    else
      return 'run'
    endif
  endif
endfunction

function! gen_clang_conf#job#start(cmd, exit_cb) abort
  if s:job_check_list(a:cmd) ==# 'run'
    echom('The same job is still running')
    return
  end

  let l:job_id = s:job_start(a:cmd, a:exit_cb)

  if s:nvim_job || s:vim_job
    call add(s:job_list, {'id': l:job_id, 'cmd': a:cmd})
  endif
endfunction
