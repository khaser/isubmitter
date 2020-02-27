" Variables "{{{
let s:cf_host = 'informatics.msk.ru'
let s:cf_proto = 'http'
let s:cf_path_regexp = '\([0-9]\+\)\/\?\([a-zA-Z][0-9]*\)\/\?[^/.]*\(\.[^.]\+\)$'

"}}}
function! myplugin#CFApplySubstitutions(text, text_substitutions) "{{{
    let l:text = a:text
    for [pat, sub] in items(a:text_substitutions)
        let l:text = substitute(l:text, pat, sub, "g")
    endfor
    return l:text
endfunction

"}}}
function! myplugin#CFGetToken(page) "{{{
    let g:ppage = a:page
    let match = matchlist(a:page, 'name=''csrf_token'' value=''\([^'']\{-}\)''')
    return match[1]
endfunction

"}}}
function! myplugin#CFLogin() "{{{
    let s:cf_uname = input('username: ')
    let s:cf_passwd = inputsecret('password: ')
    let remember = input('remember? [Y/n] ')
    if remember ==? "Y"
        let s:cf_remember = 1
    else
        let s:cf_remember = 0
    endif

    let cf_response = system(printf("curl --silent --cookie-jar %s '%s://%s/login/index.php'", g:cf_cookies_file, s:cf_proto, s:cf_host))
    let csrf_token = myplugin#CFGetToken(cf_response)
    let cf_response = system(printf("curl --location --silent --cookie-jar %s --cookie %s --data 'action=enter&handleOrEmail=%s&remember=%s&csrf_token=%s' --data-urlencode 'password=%s' '%s://%s/enter'", g:cf_cookies_file, g:cf_cookies_file, s:cf_uname, s:cf_remember, csrf_token, s:cf_passwd, s:cf_proto, s:cf_host))
    echon "\r\r"
    if empty(matchstr(cf_response, '"error for__password"'))
        echom "login: ok"
    else
        echom "login: failed"
    endif
endfunction

"}}}
function! myplugin#CFLogout() "{{{
    if filereadable(g:cf_cookies_file)
        call delete(g:cf_cookies_file)
    endif
    echom "logout: ok"
endfunction

"}}}
function! myplugin#CFSubmit() "{{{
    if empty(myplugin#CFLoggedInAs()) 
        call myplugin#CFLogin()
    endif

    let path = expand('%:p')
    let match = matchlist(path, s:cf_path_regexp)

    if empty(match)
        echon "\r\r"
        echom "submit: file name not recognized"
    else
        let contest = match[1]
        let problem = match[2]
        let extension = match[3]

        let language = g:cf_default_language
        if has_key(g:cf_pl_by_ext_custom, extension)
            let language = get(g:cf_pl_by_ext_custom, extension)
        elseif has_key(g:cf_pl_by_ext, extension)
            let language = get(g:cf_pl_by_ext, extension)
        endif

        let cf_response = system(printf("curl --silent --cookie-jar %s --cookie %s '%s://%s/contest/%s/submit'", g:cf_cookies_file, g:cf_cookies_file, s:cf_proto, s:cf_host, contest))
        let csrf_token = myplugin#CFGetToken(cf_response)

        let temp_file = expand("~/.cf_temp_file")
        silent call myplugin#CFLog(join(getline(1,'$'), "\n"), temp_file)
        let cf_response = system(printf("curl --location --silent --cookie-jar %s --cookie %s -F 'csrf_token=%s' -F 'action=submitSolutionFormSubmitted' -F 'submittedProblemIndex=%s' -F 'programTypeId=%s' -F \"source=@%s\" '%s://%s/contest/%s/submit?csrf_token=%s'", g:cf_cookies_file, g:cf_cookies_file, csrf_token, problem, language, temp_file, s:cf_proto, s:cf_host, contest, csrf_token))
        call delete(temp_file)
        echon "\r\r"
		if empty(cf_response)
			echom "submit: failed"
		else
			echom printf("submit: ok [by %s to %s/%s]", myplugin#CFLoggedInAs(), contest, problem)
        endif
    endif
endfunction

"}}}

" vim:foldmethod=marker:foldlevel=0
