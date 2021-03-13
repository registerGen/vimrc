set nocompatible

" UI settings
if has('gui_running')
	colors evening
else
	colors desert
endif
set enc=utf-8
set bs=eol,start,indent
set nu
set ru
set cul
set mouse=a
set ts=2
set sw=2
set completeopt-=preview
if has('gui_running')
	if has('win32')
		set guifont=Cascadia\ Code\ PL::h15
	else
		set guifont=Ubuntu\ Mono\ 15
	endif
endif

" Filetype and syntax
filetype plugin on
filetype indent on
syntax enable
syntax on

" No backups
set nobackup
set noswapfile

" Compile and run codes
func! Compile(isInteractive)
	exec 'w'
	let cmd = '!'
	if &filetype == 'cpp'
		let cmd = cmd . 'g++ -Wall -Wextra -Wconversion -Wshadow -lm'
		if a:isInteractive == 1
			let cmd = cmd . ' grader.cpp'
		endif
		if has('win32')
			let cmd = cmd . ' -Wl,--stack=2147483647'
		endif
		let cmd = cmd . ' -o ' . expand('%<') . ' ' . expand('%')
	elseif &filetype == 'python'
		let cmd = cmd . 'python3 %'
	endif
	echom cmd
	exec cmd
endfunc

func! Run()
	let cmd = '!'
	if &filetype == 'cpp'
		if !has('win32')
			let cmd = cmd . './'
		endif
		let cmd = cmd . expand('%<')
	elseif &filetype == 'python'
		call Compile(0)
		return
	endif
	echom cmd
	exec cmd
endfunc

map <F8> :call Compile(1)<CR>
map <F9> :call Compile(0)<CR>
map <F12> :call Run()<CR>
imap <F8> <ESC>:call Compile(1)<CR>
imap <F9> <ESC>:call Compile(0)<CR>
imap <F12> <ESC>:call Run()<CR>
if has('win32')
	map <F11> :call Compile(0)<CR>:call Run()<CR>
	imap <F11> <ESC>:call Compile(0)<CR>:call Run()<CR>
endif

" Plugins
call plug#begin('~/.vim/plugged')
Plug 'luochen1990/rainbow'
Plug 'preservim/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'ycm-core/YouCompleteMe'
Plug 'SirVer/ultisnips'
call plug#end()

" Rainbow
let g:rainbow_active = 1

" NERDTree
let g:NERDTreeShowBookmarks = 1
let g:NERDTreeShowHidden = 1
let g:NERDTreeFileExtensionHighlightFullName = 1
let g:NERDTreeExactMatchHighlightFullName = 1
let g:NERDTreePatternMatchHighlightFullName = 1
let g:NERDTreeHighlightFolders = 1
let g:NERDTreeHighlightFoldersFullName = 1

map <F7> :NERDTreeToggle<CR>
imap <F7> <ESC><F7>

" Airline
let g:airline_theme = 'term'

" YCM & Ultisnips
" from https://blog.csdn.net/qq_20336817/article/details/51115411
func! g:UltiSnips_Complete()
	call UltiSnips#ExpandSnippet()
	if g:ulti_expand_res == 0
		if pumvisible()
			return '\<C-n>'
		else
			call UltiSnips#JumpForwards()
			if g:ulti_jump_forwards_res == 0
				return '\<TAB>'
			endif
		endif
	endif
	return ''
endfunc

func! g:UltiSnips_Reverse()
	call UltiSnips#JumpBackwards()
	if g:ulti_jump_backwards_res == 0
		return '\<C-P>'
	endif
	return ''
endfunc

if !exists('g:UltiSnipsJumpForwardTrigger')
	let g:UltiSnipsJumpForwardTrigger = '<tab>'
endif
if !exists('g:UltiSnipsJumpBackwardTrigger')
	let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'
endif

autocmd InsertEnter * exec 'inoremap <silent> ' . g:UltiSnipsExpandTrigger . ' <C-R>=g:UltiSnips_Complete()<cr>'
autocmd InsertEnter * exec 'inoremap <silent> ' . g:UltiSnipsJumpBackwardTrigger . ' <C-R>=g:UltiSnips_Reverse()<cr>'
