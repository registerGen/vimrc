set nocp " nocompatible

let s:isWin = has('win32')
let s:isGUI = has('gui_running')
if s:isWin
	let s:vimrcName = '_vimrc'
else
	let s:vimrcName = '.vimrc'
endif

" Section: UI settings {{{1
if s:isGUI
	colors evening
else
	colors desert
endif
set nobk " nobackup
set noswf " noswapfile
set enc=utf-8 " encoding
set bs=eol,start,indent " backspace
set nu " number
set ru " ruler
set cul " cursorline
set mouse=a " mouse
set ts=2 " tabstop
set sw=2 " shiftwidth
set cot-=preview " completeopt
set fdm=marker " foldmethod
if s:isGUI
	if s:isWin
		set gfn=Cascadia\ Code\ PL::h15 " guifont
	else
		set gfn=Ubuntu\ Mono\ 15 " guifont
	endif
endif

filetype plugin on
filetype indent on
syntax enable
syntax on

" Section: Compile and run codes {{{1
let b:compiled = 0
autocmd BufWrite,BufRead,BufNew * let b:compiled = 0

function! Compile(additionalArgs) " {{{2
	exec 'w'
	let b:compiled = 1
	let fileName = expand('%')
	if s:isWin
		let executableFileName = expand('%<') . '.exe'
	else
		let executableFileName = expand('%<')
	endif
	let fileType = &filetype
	let cmd = ''

	if fileType == 'cpp'
		let cmd = '!g++ -Wall -Wextra -Wconversion -Wshadow -o ' . executableFileName . ' ' . fileName
	elseif fileType == 'c'
		let cmd = '!gcc -Wall -Wextra -Wconversion -Wshadow -o ' . executableFileName . ' ' . fileName
	elseif fileType == 'python'
		if s:isWin
			let cmd = '!python ' . fileName
		else
			let cmd = '!python3 ' . fileName
		endif
	elseif fileType == 'vim'
		let cmd = 'so ' . fileName
	else
		echohl Error
		echom printf('%s::Compile(): unrecognizable file type "%s"', s:vimrcName, fileType)
		echohl None
		return
	endif
"	TODO: install xelatex on my computer
"	elseif fileType == 'tex'
"		let cmd = '!xelatex ' . fileName
"	endif

	if a:additionalArgs != ''
		let cmd .= ' ' . a:additionalArgs
	endif
	echom printf('%s::Compile(): command is "%s"', s:vimrcName, cmd)
	exec cmd
endfunction

function! Run(additionalArgs) " {{{2
	let fileName = expand('%')
	let fileNameWithoutExtension = expand('%<')
	if s:isWin
		let executableFileName = expand('%<') . '.exe'
	else
		let executableFileName = expand('%<')
	endif
	let fileType = &filetype
	let cmd = ''

	if &modified == 1
		echohl WarningMsg
		echom printf('%s::Run(): file "%s" not saved', s:vimrcName, fileName)
		echohl None
		return
	endif
	if b:compiled == 0
		echom printf('%s::Run(): file "%s" not compiled, we''ll compile it first', s:vimrcName, fileName)
		let _additionalArgs = input(printf('%s::Run(): please input additional arguments for compiling: ', s:vimrcName))
		call Compile(_additionalArgs)
	endif

	if fileType == 'cpp' || fileType == 'c'
		if s:isWin
			let cmd = '!' . executableFileName
		else
			let cmd = '!./' . executableFileName
		endif
	elseif fileType == 'python' || fileType == 'vim'
		call Compile(a:additionalArgs)
		return
	else
		echohl Error
		echom printf('%s::Run(): unrecognizable file type "%s"', s:vimrcName, fileType)
		echohl None
		return
	endif
"	TODO: install xelatex on my computer
"	elseif fileType == 'tex'
"		" Show the pdf file
"		if s:isWin
"			let cmd = '!' . fileNameWithoutExtension . '.pdf'
"		else
"			let cmd = '!xdg-open' . fileNameWithoutExtension . '.pdf'
"		endif
"	endif

	if a:additionalArgs != ''
		let cmd .= ' ' . a:additionalArgs
	endif
	echom printf('%s::Run(): command is "%s"', s:vimrcName, cmd)
	exec cmd
endfunction

" Commands and mappings {{{2
command -nargs=* Compile :call Compile(<q-args>)
command -nargs=* Run :call Run(<q-args>)
map <F9> :Compile<CR>
map <F12> :Run<CR>
imap <F9> <ESC>:Compile<CR>
imap <F12> <ESC>:Run<CR>

" Section: Plugins {{{1
" Subsection: Load Plugins {{{2
call plug#begin('~/.vim/plugged')
Plug 'luochen1990/rainbow'
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ycm-core/YouCompleteMe'
Plug 'SirVer/ultisnips'
call plug#end()

" Subsection: Rainbow {{{2
let g:rainbow_active = 1

" Subsection: NERDTree {{{2
let g:NERDTreeShowBookmarks = 1
let g:NERDTreeShowHidden = 1
let g:NERDTreeFileExtensionHighlightFullName = 1
let g:NERDTreeExactMatchHighlightFullName = 1
let g:NERDTreePatternMatchHighlightFullName = 1
let g:NERDTreeHighlightFolders = 1
let g:NERDTreeHighlightFoldersFullName = 1
map <F7> :NERDTreeToggle<CR>
imap <F7> <ESC><F7>

" Subsection: Airline {{{2
let g:airline_theme = 'term'

" Subsection: YCM & Ultisnips (from https://blog.csdn.net/qq_20336817/article/details/51115411) {{{2
function! g:UltiSnips_Complete()
	call UltiSnips#ExpandSnippet()
	if g:ulti_expand_res == 0
		if pumvisible()
			return "\<C-n>"
		else
			call UltiSnips#JumpForwards()
			if g:ulti_jump_forwards_res == 0
				return "\<TAB>"
			endif
		endif
	endif
	return ''
endfunction

function! g:UltiSnips_Reverse()
	call UltiSnips#JumpBackwards()
	if g:ulti_jump_backwards_res == 0
		return "\<C-P>"
	endif
	return ''
endfunction

if !exists('g:UltiSnipsJumpForwardTrigger')
	let g:UltiSnipsJumpForwardTrigger = '<tab>'
endif
if !exists('g:UltiSnipsJumpBackwardTrigger')
	let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'
endif

autocmd InsertEnter * exec 'inoremap <silent> ' . g:UltiSnipsExpandTrigger . ' <C-R>=g:UltiSnips_Complete()<cr>'
autocmd InsertEnter * exec 'inoremap <silent> ' . g:UltiSnipsJumpBackwardTrigger . ' <C-R>=g:UltiSnips_Reverse()<cr>'
