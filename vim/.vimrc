" Enable filetype plugins
filetype plugin on
filetype indent on

" Set 7 lines to the cursor - when moving vertically using j/k
set so=7

" Show line numbers
set number

" Add additional column for signs
set signcolumn=auto

" Always show current position
set ruler

" Height of the command bar
set cmdheight=1

" Ignore case when searching
set ignorecase

" Highlight search results
set hlsearch

" Makes search act like search in modern browsers
set incsearch

" Show matching brackets when text indicator is over them
set showmatch

" How many tenths of a second to blink when matching brackets
set mat=2

" Enable syntax highlighting
syntax enable

" Use spaces instead of tabs
set expandtab

" Be smart when using tabs
set smarttab

" 1 tab == 2 spaces
set shiftwidth=2
set tabstop=2

set ai "Auto indent
set si "Smart indent
set wrap "Wrap lines

" Change terminal cursor shape based on mode
let &t_EI = "\e[2 q"
let &t_SI = "\e[6 q"
let &t_SR = "\e[4 q"

" Always show the status line
set laststatus=2

