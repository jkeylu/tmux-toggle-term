if !exists('$TMUX') || has('gui_running')
  finish
endif

if exists('g:loaded_tmux_toggle_term') && g:loaded_tmux_toggle_term
  finish
endif
let g:loaded_tmux_toggle_term = 1

let s:script = expand('~/.tmux/plugins/tmux-toggle-term/scripts/tmux-toggle-term.sh')
if !filereadable(s:script)
  let s:script = expand('<sfile>:p:h:h') . '/scripts/tmux-toggle-term.sh'
endif

function s:toggle_term()
  call system(s:script . ' --from vim --dir ' . getcwd())
endfunction

if !exists('g:tmux_toggle_term_key') || empty(g:tmux_toggle_term_key)
  let g:tmux_toggle_term_key = 'C-j'
endif

execute 'nnoremap <silent> <' . g:tmux_toggle_term_key . '> :call <SID>toggle_term()<CR>'
