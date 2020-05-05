"
"              _
"  Matt's     (_)
"       __   ___ _ __ ___  _ __ ___
"       \ \ / / | '_ ` _ \| '__/ __|
"        \ V /| | | | | | | | | (__
"       (_)_/ |_|_| |_| |_|_|  \___|
"
"
" ==============================================================================
"
" ========== START ===============================

" Cause fuck Vi nigga, Vim is the mack daddy
set nocompatible

" Mainstream for dayyys
set encoding=utf-8


" ========== VUNDLE SETUP ========================

" Vundle Help
" :PluginList          - lists configured plugins
" :PluginInstall       - installs plugins; append `!` to update
" :PluginUpdate        - updates plugins
" :PluginSearch foo    - searchesLC for foo; append `!` to refresh local cache
" :PluginClean         - confirms removal of unused plugins

" Uncomment this block to use a separate file to hold plugin bundles
" if filereadable(expand("~/.vim/bundles"))
"   source ~/.vim/bundles
" endif

" Configure and start Vundle
filetype on  " Necessary to prevent a zero exit later on
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Let Vundle manage Vundle (require@?d)
Plugin 'VundleVim/Vundle.vim'

" Plugins to Add
Plugin 'altercation/vim-colors-solarized'
Plugin 'airblade/vim-gitgutter'
Plugin 'ap/vim-css-color'
Plugin 'ervandew/supertab'
Plugin 'scrooloose/nerdcommenter'
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

" All plugins must be added before this line
call vundle#end()

" Required
filetype plugin indent on


" ========== STATUSBAR SETUP =========================

" ========== AIRLINE ==========
" Plugin added in vundle setup
"let g:airline_theme='light'
let g:airline_powerline_fonts=1


" Always display the statusline
set laststatus=2

" Always show the tabline
set showtabline=2

" Hide the default mode text i.e. `__ INSERT --`
set noshowmode

" ========== MOVEMENT SETUP =====================

" Enable mouse usage
set mouse=a

" Support mouse resizing in tmux
if exists('$TMUX')
  set ttymouse=xterm2
endif


" ========== COMMENT SETUP =========================
" Nerdcommenter added as Plugin above

" Add spaces after comment delimiters
let g:NERDSpaceDelims=1

" ========== GIT SETUP =========================
" Enable spell check and text wrapping on Git commits
autocmd Filetype gitcommit setlocal spell textwidth=72


" ========== UI SETUP =========================

" Use 256 colors in terminal
set t_Co=256

" Colors are pretty
colorscheme solarized

" Code is hard, do yourself a favor
syntax enable

" Turn on line numbering
set number

" Highlight matching [{()}] when selected
set showmatch

" Show last command in status bar
set showcmd

" Show where you are
set ruler

" Highlight current line
set cursorline

" Scroll like a normal person for fuck's sake
set scrolloff=3

" Colorise 81st column to keep code short
set colorcolumn=81

" Visual autocompletion for command menu
set wildignore=log/**,node_modules/**,target/**,tmp/**,*.rbc
set wildmenu
set wildmode=longest,list,full

" Fix cursor in TMUX
if exists('$TMUX')
  let &t_SI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>Ptmux;\<Esc>\<Esc>]50;CursorShape=0\x7\<Esc>\\"
else
  let &t_SI = "\<Esc>]50;CursorShape=1\x7\<Esc>\\"
  let &t_EI = "\<Esc>]50;CursorShape=1\x7\<Esc>\\"
endif


" ========== SEARCH SETUP =====================

" Search as characters are entered
set incsearch

" Ignore case in search (use smartcase if caps present)
set ignorecase
set smartcase

" Highlight search matches
set hlsearch

" Cancel a search with ESC
"nnoremap <silent> <Esc> :nohlsearch<Bar>:echo<CR>


" ========== TAB SETUP =====================

" Turn on autoindent (indent after pressing enter key)
set autoindent

" Number of visual spaces per tab
set tabstop=4

" Actual number of spaces in tab when editing
set softtabstop=2

" Set normal mode indentation command spaces
set shiftwidth=2

" Turn tabs into spaces
set expandtab

" Show tabs and trailing spaces
set list
set listchars=tab:▸\ ,trail:▫

" Fix backspace not behaving properly
set backspace=2


" ========== CONFIG SETUP =====================

" Reload files when changed on disk
set autoread

" Yank and paste with system clipboard
set clipboard=unnamed

" Don't use backups and swapfiles
set nobackup
set noswapfile


" ========== KEYMAP SETUP =====================

" Set <leader> key for commands
let mapleader = ','

" Use jj as <Esc> in insert mode
inoremap jj <ESC>

" Move between windows using h, j, k, l
noremap <C-h> <C-w>h
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-l> <C-w>l

" Move between tabs using h and l in normal mode
nnoremap <leader>h :tabp<CR>
nnoremap <leader>l :tabn<CR>

" In case of permissions issues
cnoremap w!! %!sudo tee > /dev/null %

" Reload Vim config with `V`
noremap <silent> <leader>V :source ~/.vimrc<CR>:filetype detect<CR>:exe "echo '.vimrc reloaded'"<CR>