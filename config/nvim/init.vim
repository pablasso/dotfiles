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
let g:netrw_dirhistmax = 0 " stop polluting the clipboard
let g:jsx_ext_required = 0 " highlight jsx on al js files

" MAPPINGS ======

" previous buffer
map ,1 :bp<ENTER>
" next buffer
map ,2 :bn<ENTER>
" close buffer
map ,w :bd<ENTER>
" return to last buffer
nmap <tab> :b#<cr>
" fuzzy search
nmap <C-P> :FZF<cr>
" commenting
map <leader>/ <plug>NERDCommenterToggle<cr>
" turn off highlighting temporarily
map ,h :noh<cr>

" PLUGINS =====

call plug#begin('~/.config/nvim/plugged')

function! DoRemote(arg)
  UpdateRemotePlugins
endfunction

Plug 'airblade/vim-gitgutter'
Plug 'bling/vim-bufferline'
Plug 'Shougo/deoplete.nvim', { 'do': function('DoRemote') }
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'editorconfig/editorconfig-vim'
Plug 'nvie/vim-flake8'
Plug 'scrooloose/nerdcommenter'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'kylef/apiblueprint.vim'

call plug#end()

" autocompletion
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_ignore_case = 1
set completeopt+=noinsert