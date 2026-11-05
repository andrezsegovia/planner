" ==============================================================================
" planner.vim — Vim side of this repository
" ==============================================================================
" Sourced by the block install.sh writes into ~/.vimrc. The repository can be
" cloned anywhere: everything is derived from this file's location.
"
" Keys (leader is whatever you set in your vimrc):
"   <leader>pt  today's plan        <leader>pw  weekly review
"   <leader>pi  inbox               <leader>pn  new project
"   <leader>pf  fuzzy-find files    <leader>pl  open tasks (quickfix)
"   <leader>tc  toggle checkbox on the current line
"
" Needs: the `plan` script (same repo) and, for <leader>pf, fzf.vim.

let s:root = expand('<sfile>:p:h:h:h')
let s:bin = s:root . '/bin/plan'

function! s:run(...) abort
  if !executable(s:bin)
    throw 'planner: not executable: ' . s:bin
  endif
  let l:args = join(map(copy(a:000), 'shellescape(v:val)'), ' ')
  return trim(system(shellescape(s:bin) . ' ' . l:args))
endfunction

function! s:open(kind) abort
  try
    let l:path = s:run('path', a:kind)
  catch
    echohl ErrorMsg | echomsg v:exception | echohl None
    return
  endtry
  if empty(l:path)
    echohl ErrorMsg | echomsg 'planner: cannot open ' . a:kind | echohl None
    return
  endif
  execute 'edit ' . fnameescape(l:path)
endfunction

function! s:new() abort
  let l:title = input('Project name: ')
  if empty(trim(l:title))
    return
  endif
  try
    let l:path = s:run('new', l:title, '--path')
  catch
    echohl ErrorMsg | echomsg v:exception | echohl None
    return
  endtry
  if v:shell_error != 0 || empty(l:path)
    echohl ErrorMsg | echomsg 'planner: could not create ' . l:title | echohl None
    return
  endif
  execute 'edit ' . fnameescape(l:path)
endfunction

function! s:toggle() abort
  let l:line = getline('.')
  if l:line =~# '^\s*- \[ \]'
    call setline('.', substitute(l:line, '\[ \]', '[x]', ''))
  elseif l:line =~# '^\s*- \[x\]'
    call setline('.', substitute(l:line, '\[x\]', '[ ]', ''))
  elseif l:line =~# '^\s*$'
    call setline('.', '- [ ] ')
  elseif l:line =~# '^\s*- '
    call setline('.', substitute(l:line, '^\(\s*\)- ', '\1- [ ] ', ''))
  else
    call setline('.', '- [ ] ' . l:line)
  endif
endfunction

function! s:quickfix() abort
  let l:ef = &errorformat
  try
    let &errorformat = '%f:%l:%c:%m'
    cgetexpr systemlist(shellescape(s:bin) . ' qf')
  catch
    echohl ErrorMsg | echomsg v:exception | echohl None
    return
  finally
    let &errorformat = l:ef
  endtry
  if empty(getqflist())
    echomsg 'planner: no open tasks'
    return
  endif
  copen
endfunction

" Used by the :Plan command; <SID> does not expand inside :command definitions.
function! PlannerOpen(kind) abort
  call s:open(a:kind)
endfunction

nnoremap <leader>pt :call <SID>open('today')<CR>
nnoremap <leader>pw :call <SID>open('week')<CR>
nnoremap <leader>pi :call <SID>open('inbox')<CR>
nnoremap <leader>pn :call <SID>new()<CR>
nnoremap <leader>pl :call <SID>quickfix()<CR>
nnoremap <leader>tc :call <SID>toggle()<CR>
execute 'nnoremap <leader>pf :Files ' . escape(s:root, ' \') . '<CR>'
command! -nargs=1 Plan call PlannerOpen(<q-args>)
