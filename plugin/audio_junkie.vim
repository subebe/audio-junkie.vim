if exists("g:loaded_audiojunkie")
  finish
endif
let g:loaded_audiojunkie = 1

let s:save_cpo = &cpo
set cpo&vim

command! -nargs=+ -complete=customlist,audio_junkie#get_play_complete AudioJunkiePlay call audio_junkie#play(<f-args>)
command! AudioJunkieStop call audio_junkie#stop()
command! -nargs=1 AudioJunkieSetVolume call audio_junkie#set_volume(<f-args>)

augroup AudioJunkie
  autocmd!
  autocmd VimLeave * AudioJunkieStop
augroup END

let &cpo = s:save_cpo
unlet s:save_cpo

