syntax enable
filetype plugin indent on

set ruler " show position of cursor
set number " show line numbers
set hidden " buffers hide instead of close when opening new ones without saving changes
set noswapfile " no backup files
set clipboard+=unnamedplus " send every yank to the OS's clipboard
set expandtab " use spaces
set inccommand=nosplit " real time changes when replacing text
set mouse=a "  mouse enabled

let $NVIM_TUI_ENABLE_TRUE_COLOR=1 " true color
set termguicolors " true color
let g:netrw_dirhistmax = 0 " stop polluting the clipboard
let g:jsx_ext_required = 0 " highlight jsx on al js files

" python config for plugins
let g:python_host_prog = '/Users/pablasso/.pyenv/versions/neovim2/bin/python'
let g:python3_host_prog = '/Users/pablasso/.pyenv/versions/neovim3/bin/python'
let g:black_virtualenv = '/Users/pablasso/.pyenv/versions/neovim3'
" nerdtree
let NERDTreeMinimalUI=1
let g:NERDTreeMouseMode=3

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
" commenting
map <leader>/ <plug>NERDCommenterToggle<cr>
" turn off highlighting temporarily
map ,h :noh<cr>
" Dash.app
map ,d :Dash<cr>
" File explorer
nmap ,n :NERDTreeFind<cr>
nmap ,m :NERDTreeToggle<cr>
" fuzzy file search
nmap ,f :FZF<cr>
" search
nmap ,s :CtrlSF
" splits movement
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" resize windows faster: http://vim.wikia.com/wiki/Resize_splits_more_quickly
nnoremap <silent> <Leader>] :exe "vertical resize " . (winwidth(0) * 10/9)<CR>
nnoremap <silent> <Leader>[ :exe "vertical resize " . (winwidth(0) * 9/10)<CR>
nnoremap <silent> <Leader>= :exe "resize " . (winheight(0) * 10/9)<CR>
nnoremap <silent> <Leader>- :exe "resize " . (winheight(0) * 9/10)<CR>

" PLUGINS =====

call plug#begin('~/.config/nvim/plugged')

Plug 'connorholyday/vim-snazzy'
Plug 'airblade/vim-gitgutter'
Plug 'bling/vim-bufferline'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'ervandew/supertab'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'editorconfig/editorconfig-vim'
Plug 'scrooloose/nerdcommenter'
Plug 'pangloss/vim-javascript'
Plug 'mxw/vim-jsx'
Plug 'rizzatti/dash.vim'
Plug 'tpope/vim-fugitive'
Plug 'metakirby5/codi.vim'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'octref/RootIgnore'
Plug 'sheerun/vim-polyglot'
Plug 'itchyny/lightline.vim'
Plug 'edkolev/tmuxline.vim'
Plug 'itspriddle/vim-marked'
Plug 'junegunn/goyo.vim'
Plug 'sbdchd/neoformat'
Plug 'reasonml-editor/vim-reason'
Plug 'ambv/black'
Plug 'tpope/vim-vinegar'
Plug 'dyng/ctrlsf.vim'

call plug#end()

" theme
colorscheme snazzy

" file explorer
let loaded_netrwPlugin=1
let NERDTreeRespectWildIgnore=1
let NERDTreeShowHidden=1

" autocompletion
let g:deoplete#enable_at_startup = 1
let g:deoplete#enable_ignore_case = 1
let g:SuperTabDefaultCompletionType = "<c-n>"

" lightline
let g:lightline = {
  \ 'colorscheme': 'wombat',
\ }

" tmuxline
let g:tmuxline_powerline_separators = 0

" vim-polyglot don't hide quotes automatically
" this is the worst default feature ever
let g:vim_json_syntax_conceal = 0
