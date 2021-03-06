function! plum#fso#OpenFso()
  return [ { a, b -> plum#fso#BestInterp(plum#fso#ReadActivePath()) }
        \, { p, i -> plum#fso#Act(p, i.key[0:0] ==# 'S') } ]
endfunction

function! plum#fso#Act(path, is_alt)
  let cwd = getcwd()
  let path = a:path
  let is_alt = a:is_alt
  let is_directory = isdirectory(path[0])

  if is_directory
    if !is_alt
      execute 'lcd ' . path[0]
    else
      call plum#layout#Open({-> execute('edit ' . path[0])})
    endif
    return
  endif

  if is_alt
    execute 'tabe ' . path[0]
  else
    call plum#layout#Open({-> execute('edit ' . path[0])})
    execute 'lcd ' . cwd
  endif
  if len(path) > 1
    let parts = split(path[1], ',')
    if len(parts) == 2
      call plum#fso#SelectLines(parts[0], parts[1])
    else
      execute parts[0]
    endif
  endif
endfunction

function! plum#fso#BestInterp(original)
  let original = a:original
  if !len(original)
    return [original, v:false]
  endif
  let paths = filter(plum#fso#OrderedInterps(original),
        \ { _, p -> filereadable(p[0]) || isdirectory(p[0]) })
  if !len(paths)
    return [original, v:false]
  endif
  return [paths[0], v:true]
endfunction

function! plum#fso#SelectLines(start, end)
  let [start, end] = [a:start, a:end]
  call cursor(start, 0)
  execute 'normal! v'
  call cursor(end, 0)
  execute 'normal! $'
endfunction

function! plum#fso#OrderedInterps(original)
  let original = a:original
  if !len(original)
    return []
  endif
  let paths = []
  if trim(original[0][0:0]) != '/'
    " add abs
    let absf = copy(original)
    let cwd = getcwd()
    let absf[0] = simplify(cwd . '/' . absf[0])
    call add(paths, absf)

    " add relative to cur file
    let relf = copy(original)
    let file_dir = expand('%:p:h')
    let relf[0] = simplify(file_dir . '/' . relf[0])
    call add(paths, relf)
  else
    call add(paths, original)
  endif
  return paths
endfunction

function! plum#fso#ReadActivePath()
  let p = join(plum#util#ReadVSel(), ' ')
  if !len(p)
    let p = plum#util#path()
  endif
  return plum#fso#ParsePath(p)
endfunction

function! plum#fso#ParsePath(str)
  let str = a:str
  if len(str)
    return split(str, ':')
  endif
  return []
endfunction
