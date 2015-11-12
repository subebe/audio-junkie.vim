let s:V = vital#of('audiojunkie')
let s:HTTP = s:V.import('Web.HTTP')
let s:JSON = s:V.import('Web.JSON')
let s:PM = s:V.import('ProcessManager')

let g:audio_junkie#define = get(g:, 'audio_junkie#define', {
\ 'di': {
\   'url': 'di.fm',
\   'use_stream': 'public3',
\ },
\ 'radiotunes': {
\   'url': 'radiotunes.com',
\   'use_stream': 'public3',
\ },
\ 'jazzradio': {
\   'url': 'jazzradio.com',
\   'use_stream': 'public3',
\ },
\ 'rockradio': {
\   'url': 'rockradio.com',
\   'use_stream': 'public3',
\ },
\})
let g:audio_junkie#label = get(g:, 'audio_junkie#label', 'audio_junkie')
let g:audio_junkie#play_command = get(g:, 'audio_junkie#play_command', 'mplayer -slave -really-quiet -playlist %%URL%%')

function! audio_junkie#get_play_complete(ArgLead, CmdLine, CusorPos)
  let l:cmd = split(a:CmdLine)
  let l:len_cmd = len(l:cmd)
  if a:ArgLead != ''
    let l:len_cmd -= 1
  endif
  let l:filter_cmd = printf('v:val =~ "^%s"', a:ArgLead)

  if l:len_cmd == 1
    return filter(audio_junkie#get_service_list(), l:filter_cmd)
  elseif l:len_cmd == 2
    let l:service = l:cmd[1]
    return filter(audio_junkie#get_channel_list(l:service), l:filter_cmd)
  endif
  return []
endfunction

function! audio_junkie#get_service_list()
  return keys(g:audio_junkie#define)
endfunction

function! audio_junkie#get_channel_list(service)
  let l:url = audio_junkie#get_listen_url(a:service)
  let l:json = s:HTTP.request('get', l:url,).content

  let l:data = s:JSON.decode(l:json)
  return map(l:data, 'v:val.key')
endfunction

function! audio_junkie#get_listen_url(service, ...)
  let l:channel = get(a:, 1, '')

  let l:setting = g:audio_junkie#define[a:service]
  let l:url = 'http://listen.' . l:setting['url'] . '/' . l:setting['use_stream']

  if l:channel != ''
    let l:url .= '/' . l:channel . '.pls'
  endif

  return l:url
endfunction

function! audio_junkie#play(service, channel)
  let l:playlist = audio_junkie#get_listen_url(a:service, a:channel)
  let l:play_command = substitute(g:audio_junkie#play_command, '%%URL%%', l:playlist, '')
  call audio_junkie#stop()
  call s:PM.touch(g:audio_junkie#label, l:play_command)
endfunction

function! audio_junkie#stop()
  let l:status = ''
  try
    let l:status = s:PM.status(g:audio_junkie#label)
  catch
  endtry

  if l:status == 'inactive' || l:status == 'active'
    return s:PM.kill(g:audio_junkie#label)
  endif
endfunction

