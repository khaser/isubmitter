" Variables "{{{
let s:host = 'informatics.msk.ru'
let s:proto = 'https'
let s:login = 0
let g:cookie_path = '~/.vim/.isubmitter_cookies'

"}}}
function! isubmitter#Login() "{{{
	let s:uname = input('username: ')
	let s:passwd = inputsecret('password: ')

	let s:response = system(printf("curl --silent --cookie-jar %s %s://%s/login/index.php -F username=%s -F password=%s",  g:cookie_path, s:proto, s:host, s:uname, s:passwd))
	echon "\r\r"
	if empty(matchstr(s:response, 'Вы не прошли идентификацию'))
		echom "login: ok"
		let s:login = 1
	else
		echom "login: failed"
	endif
	echon "\r\r"
endfunction

"}}}
function! isubmitter#Submit() "{{{
:   w
    while !s:login
        call isubmitter#Login()
    endwhile

    let task = expand('%:t:r')
    let path = expand('%:p')
    let s:response = system(printf('curl --silent --cookie %s -F "file=@%s" -F "lang_id=3" https://informatics.msk.ru/py/problem/%s/submit', g:cookie_path, path, task))
    echon "\r\r"
    if empty(matchstr(s:response, 'success'))
        echom "submit: failed"
    else
        echom "submit: ok"
    endif
endfunction

"}}}

" vim:foldmethod=marker:foldlevel=0
