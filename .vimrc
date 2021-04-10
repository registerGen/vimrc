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
let g:tex_flavor = 'latex'

if &t_Co > 2 || s:isGUI
	syntax enable
	syntax on
endif

" Section: Mappings {{{1
let mapleader = '_'
" Edit and source vimrc {{{2
if s:isWin
	noremap <silent> <leader>ev :e ~\_vimrc<CR>
	noremap <silent> <leader>sv :so ~\_vimrc<CR>
else
	noremap <silent> <leader>ev :e ~/.vimrc<CR>
	noremap <silent> <leader>sv :so ~/.vimrc<CR>
endif

" Use the damn hjkl!!! {{{2
noremap <UP> <NOP>
noremap <DOWN> <NOP>
noremap <LEFT> <NOP>
noremap <RIGHT> <NOP>
inoremap <UP> <NOP>
inoremap <DOWN> <NOP>
inoremap <LEFT> <NOP>
inoremap <RIGHT> <NOP>

" Compile and run codes {{{2
noremap <silent> <F10> :Compile<CR>
noremap <silent> <F12> :Run<CR>
inoremap <silent> <F10> <ESC>:Compile<CR>
inoremap <silent> <F12> <ESC>:Run<CR>

" NERDTree {{{2
map <silent> <F9> :NERDTreeToggle<CR>
imap <silent> <F9> <ESC><F7>

" Combination with cf-tool {{{2
noremap <silent> <leader>g :call CF_gen()<CR>
noremap <silent> <leader>t :call CF_test()<CR>
noremap <silent> <leader>T :call CF_ToggleDiffWindow()<CR>
"noremap <silent> <leader>s :call CF_submit()<CR>

" Section: Compile and run codes {{{1
let b:compiled = 0
autocmd BufWrite,BufRead,BufNew * let b:compiled = 0

function! CheckExecutable(executableName) " {{{2
	if !executable(a:executableName)
		echohl WarningMsg
		echo printf('%s::CheckExecutable(): executable "%s" not found', s:vimrcName, a:executableName)
		echohl None
		return 0
	endif
	return 1
endfunction

function! Compile(additionalArgs) " {{{2
	exec 'silent w'
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
		if CheckExecutable('g++')
			let cmd = '!g++ -Wall -Wextra -Wconversion -Wshadow -o ' . executableFileName . ' ' . fileName
		else
			return
		endif
	elseif fileType == 'c'
		if CheckExecutable('gcc')
			let cmd = '!gcc -Wall -Wextra -Wconversion -Wshadow -o ' . executableFileName . ' ' . fileName
		else
			return
		endif
	elseif fileType == 'python'
		if CheckExecutable('python')
			let cmd = '!python ' . fileName
		elseif CheckExecutable('python3')
			let cmd = '!python3 ' . fileName
		else
			return
		endif
	elseif fileType == 'vim'
		let cmd = 'so ' . fileName
	elseif fileType == 'tex'
		if CheckExecutable('xelatex')
			let cmd = '!xelatex ' . fileName
		else
			return
		endif
	else
		echohl Error
		echom printf('%s::Compile(): unrecognizable file type "%s"', s:vimrcName, fileType)
		echohl None
		return
	endif

	if a:additionalArgs != ''
		let cmd .= ' ' . a:additionalArgs
	endif
	echohl None
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
		echohl None
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
	elseif fileType == 'tex'
		" Show the pdf file
		if s:isWin
			let cmd = '!' . fileNameWithoutExtension . '.pdf'
		else
			if CheckExecutable('xdg-open')
				let cmd = '!xdg-open ' . fileNameWithoutExtension . '.pdf'
			else
				return
			endif
		endif
	else
		echohl Error
		echom printf('%s::Run(): unrecognizable file type "%s"', s:vimrcName, fileType)
		echohl None
		return
	endif

	if a:additionalArgs != ''
		let cmd .= ' ' . a:additionalArgs
	endif
	echohl None
	echom printf('%s::Run(): command is "%s"', s:vimrcName, cmd)
	exec cmd
endfunction

" Commands {{{2
command! -nargs=* Compile call Compile(<q-args>)
command! -nargs=* Run call Run(<q-args>)

" Section: Plugins {{{1
" Subsection: Load Plugins {{{2
call plug#begin('~/.vim/plugged')
Plug 'luochen1990/rainbow'
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ycm-core/YouCompleteMe'
Plug 'SirVer/ultisnips'
Plug 'vim/killersheep'
Plug 'instant-markdown/vim-instant-markdown', {'for': 'markdown'}
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

" Section: Combination with cf tool (https://github.com/xalanq/cf-tool) {{{1
let s:CF_DiffWindowOpened = 0

function! CF_gen() " {{{2
	if CheckExecutable('cf')
		echom printf('%s::CF_gen(): command is "cf gen"', s:vimrcName)
		let output = systemlist('cf gen')[-1]
		if output !~ '^Generated! See'
			echohl WarningMsg
			echom printf('%s::CF_gen(): generation failed', s:vimrcName)
			echohl None
		else
			echom printf('%s::CF_gen(): generated file name is "%s"', s:vimrcName, split(output)[-1])
			exec 'silent e ' . split(output)[-1]
			echom printf('%s::CF_gen(): file "%s" opened', s:vimrcName, split(output)[-1])
		endif
	endif
endfunction

function! CF_ToggleDiffWindow(sampleID) " {{{2
	if type(a:sampleID) == 1
		let sampleID = str2nr(a:sampleID)
	elseif type(a:sampleID) == 0
		let sampleID = a:sampleID
	else
		echohl Error
		echom printf('%s::CF_ToggleDiffWindow(): argument type not correct', s:vimrcName)
		echohl None
	endif
	let files = [printf('in%d.txt', sampleID), printf('out%d.txt', sampleID), printf('ans%d.txt', sampleID)]
	for file in files
		if buflisted(file)
			exec printf('silent bdelete %d', bufnr(file))
		endif
	endfor
	if s:CF_DiffWindowOpened
		let s:CF_DiffWindowOpened = 0
	else
		for file in files
			if !filereadable(file)
				echohl Error
				echom printf('%s::CF_ToggleDiffWindow(): file %s not found', s:vimrcName, file)
				echohl None
				return
			endif
		endfor
		exec 'silent sp ' . files[0]
		exec 'silent vsp ' . files[1]
		exec 'silent vertical diffsp ' . files[2]
		let s:CF_DiffWindowOpened = 1
	endif
endfunction

function! CF_test() " {{{2
	if CheckExecutable('cf')
		echom printf('%s::CF_test(): command is "cf test"', s:vimrcName)
		let output = systemlist('cf test')
		for str in output
			" Because of YCM, I will not consider compilation errors
			if str =~ '^Passed #[1-9][0-9]*'
				let sampleID = str2nr(split(str)[1][1:])
				echohl Type " In colorscheme desert (in terminal) or evening (in GUI), highlight group 'Type' is green
				echom printf('%s::CF_test(): passed sample #%d', s:vimrcName, sampleID)
				echohl None
			elseif str =~ '^Failed #[1-9][0-9]*'
				let sampleID = str2nr(split(str)[1][1:])
				echohl WarningMsg
				echom printf('%s::CF_test(): failed sample #%d', s:vimrcName, sampleID)
				echohl None
				if s:isWin
					call system(printf('%s.exe <in%d.txt >out%d.txt', expand('%<'), sampleID, sampleID))
				else
					call system(printf('./%s <in%d.txt >out%d.txt', expand('%<'), sampleID, sampleID))
				endif
				call CF_ToggleDiffWindow(sampleID)
				echom printf('%s::CF_test(): diff is shown above', s:vimrcName)
			endif
		endfor
	endif
endfunction

" Commands {{{2
command! -nargs=1 CFToggleDiffWindow call CF_ToggleDiffWindow(<f-args>)
