syntax enable
colorscheme onedark
filetype plugin indent on

set ruler " show position of cursor
set number " show line numbers
set hidden " buffers hide instead of close when opening new ones without saving changes
set noswapfile " no backup files
set clipboard=unnamed " if there's no clipboard, every yank will be sent to osx's clipboard
set expandtab " use spaces

let $NVIM_TUI_ENABLE_TRUE_COLOR=1 " true color
set termguicolors " true color
let g:netrw_dirhistmax = 0 " stop polluting the clipboard
let g:jsx_ext_required = 0 " highlight jsx on al js files

" text expands
iabbrev trace; import ipdb;ipdb.set_trace()

" focus on the new splits
set splitbelow
set splitright

" Pmenu colors
highlight Pmenu guibg=brown
highlight PmenuSel gui=reverse guifg=#c5c8c6 guibg=#373b41

" MAPPINGS ======

" previous buffer
map ,1 :bp<ENTER>
" next buffer
map ,2 :bn<ENTER>
" close buffer without closing the window: http://stackoverflow.com/a/8585343/19329
map ,w :bp<bar>sp<bar>bn<bar>bd<CR>
" return to last buffer
nmap <tab> :b#<cr>
" fuzzy search
nmap <C-P> :FZF<cr>
" commenting
map <leader>/ <plug>NERDCommenterToggle<cr>
" turn off highlighting temporarily
map ,h :noh<cr>
" Dash.app
map ,d :Dash<cr>

" PLUGINS =====

call plug#begin('~/.config/nvim/plugged')

function! DoRemote(arg)
  UpdateRemotePlugins
endfunction

Plug 'airblade/vim-gitgutter'
Plug 'bling/vim-bufferline'
Plug 'Shougo/deoplete.nvim', { 'do': function('DoRemote') }
Plug 'ervandew/supertab'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'editorconfig/editorconfig-vim'
Plug 'nvie/vim-flake8'
Plug 'scrooloose/nerdcommenter'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'rizzatti/dash.vim'
Plug 'eugen0329/vim-esearch'
Plug 'wakatime/vim-wakatime'
Plug 'tpope/vim-fugitive'
Plug 'metakirby5/codi.vim'
Plug 'solarnz/thrift.vim'
Plug 'jiangmiao/auto-pairs'

call plug#end()

" autocompletion
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_ignore_case = 1
let g:SuperTabDefaultCompletionType = "<c-n>"

" global search
let g:esearch = {
  \ 'adapter': 'pt',
  \ 'backend': 'nvim',
  \ 'out': 'win',
  \ 'batch_size': 1000,
  \ 'use': ['visual', 'hlsearch', 'last'],
\ }

let g:esearch#out#win#open = 'enew'
