hi GitRed ctermfg=124
hi GitGreen ctermfg=115
hi GitOrange ctermfg=166

function! GitStatus()
	let status_output = system('git status -s')
	let output_lines = split(status_output, '\v\n')
	if len(output_lines) == 0
		echon 'Up to date'
		return
	endif
	let c = 0
	while c < len(output_lines)
		let s = split(output_lines[c], '\v +')
		if c != 0
			echon ' | '
		endif
		if s[0] == 'A' " Ready to commit
			echohl GitGreen
		elseif s[0] == '??' " New
			echohl GitRed
		elseif s[0] == 'M' " Modified
			echohl GitOrange
		endif
		echon s[1]
		echohl None
		let c += 1
	endwhile
	echohl None
endfunction


noremap <Leader>vs :call GitStatus()<CR>
