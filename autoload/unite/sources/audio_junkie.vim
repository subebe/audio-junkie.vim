scriptencoding utf-8
let s:save_cpo = &cpo
set cpo&vim

function! unite#sources#audio_junkie#define()
  return s:source
endfunction

let s:source = {
      \   'name' : 'audio-junkie',
      \   'hooks' : {},
      \   'action_table' : {
      \     'play' : {
      \       'description' : 'Play this radio',
      \     }
      \   },
      \   'default_action' : 'play',
      \   '__counter' : 0
      \ }

function! s:source.action_table.play.func(candidate)
  call audio_junkie#play(a:candidate.action__service, a:candidate.action__channel)
endfunction

function! s:source.gather_candidates(args, context)
  let candidates = []
  let service_list = audio_junkie#get_service_list()
  for service in service_list
    let channel_list = audio_junkie#get_channel_list(service)
    for channel in channel_list
      let candidates += [{
            \'word': service . '/' . channel,
            \'action__service': service,
            \'action__channel': channel,
            \}]
    endfor
  endfor

  let a:context.source.unite__cached_candidates = []
  return candidates
endfunction


let &cpo = s:save_cpo
unlet s:save_cpo
