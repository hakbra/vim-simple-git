hi GitRed ctermfg=124
hi GitGreen ctermfg=115
hi GitOrange ctermfg=166

function! s:getchar()
	let a:c = getchar()
	if a:c =~ '^\d\+$'
		let a:c = nr2char(a:c)
	endif
	return a:c
endfunction

function! GitStatus() 
	let a:status_output = system('git status -s')
	let a:output_lines = split(a:status_output, '\v\n')

	if len(a:output_lines) == 0
		echon 'Up to date'
		return
	endif

	if len(a:output_lines) == 1 && a:output_lines[0] =~ 'Not a git repository'
		echon 'Not a git repository'
		return
	endif

	let a:c = 0
	while a:c < len(a:output_lines)
		let a:line = a:output_lines[a:c]
		let a:file = split(a:line, '\v +')[1]

		" Output separator if not first
		if a:c != 0
			echon ' | '
		endif

		" Set highlight
		if a:line[1] == 'M' " Modified
			echohl GitOrange
		elseif a:line[0] == 'A' || a:line[0] == 'M' " Ready to commit
			echohl GitGreen
		elseif a:line[0] == '?' " New
			echohl GitRed
		else
			echohl WarningMsg
			let a:file = a:line
		endif

		" Output file and reset hl
		echon a:file
		echohl None

		let a:c += 1
	endwhile
	echohl None
endfunction

function! GitAdd()
	let a:status_output = system('git status -s')
	let a:output_lines = split(a:status_output, '\v\n')

	if len(a:output_lines) == 0
		echon 'Nothing to add'
		return
	endif

	if len(a:output_lines) == 1 && a:output_lines[0] =~ 'Not a git repository'
		echon 'Not a git repository'
		return
	endif

	let a:all = 0
	let a:c = 0
	let a:added = 0
	while a:c < len(a:output_lines)
		let a:line = a:output_lines[a:c]
		let a:file = split(a:line, '\v +')[1]
		let a:c += 1

		if a:line[1] == ' '
			continue
		endif

		let a:added += 1

		if a:all == 0
			echon 'Add '.a:file.'? (a/y/n) '
			let a:input = s:getchar()
			if a:input == 'y'
				execute 'silent !git add' a:file
			elseif a:input == 'a'
				let a:all = 1
			endif
		endif
		if a:all == 1
			execute 'silent !git add' a:file
		endif
	endwhile
	redraw!
	if a:added > 0
		echon 'Files added'
	else 
		echon 'No files to add'
	endif
endfunction

function! GitCommit()
	let a:status_output = system('git status -s')
	let a:output_lines = split(a:status_output, '\v\n')

	let a:num = 0
	let a:c = 0
	while a:c < len(a:output_lines)
		let a:line = a:output_lines[a:c]
		let a:c += 1

		if a:line[0] == ' '
			continue
		endif

		let a:num += 1
	endwhile

	if a:num == 0
		echon 'Nothing to commit'
		return
	endif

	if len(a:output_lines) == 1 && a:output_lines[0] =~ 'Not a git repository'
		echon 'Not a git repository'
		return
	endif

	let msg = input('Enter commit message: ')
	let msg = '"'.msg.'"'

	execute 'silent !git commit -m ' msg
endfunction

function! GitPush()
	echon 'Git push'
	let s:success = 1
	function! GitPushError(job_id, data, event)
		for line in a:data
			if line =~ '^Fatal'
				echom line
				let s:success = 0
			endif
		endfor
	endfunction
	function! GitPushExit(job_id, data, event)
		if s:success == 1
			echom 'Push successful'
		endif
	endfunction

	let a:callbacks = {
	\ 'on_stderr': function('GitPushError'),
	\ 'on_exit': function('GitPushExit')
	\ }

	call jobstart(['git', 'push'], a:callbacks)
endfunction

noremap <Leader>vs :call GitStatus()<CR>
noremap <Leader>va :call GitAdd()<CR>
noremap <Leader>vc :call GitCommit()<CR>
noremap <Leader>vp :call GitPush()<CR>
