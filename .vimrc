" (gVim) Font
" Note: Different operating systems have different syntax for specifying fonts
" e.g.
"     OSX/Windows: SF\ Mono\ Medium:h12
"     Linux:       SF\ Mono\ Medium\ 12
" See :help guifont inside gVim for more details
set guifont=SF\ Mono\ Medium\ 12

" Syntax highlighting
syntax on

" Display 'hybrid' linenumbers
set number relativenumber

" Highlight the search results
set hlsearch

" Set so that we don't have to save current buffer before switching to another buffer
set hidden

" Display current line and column in the bottom-right
set ruler

" Use 'light' themes on colourschemes when available
" set background=light

" ---------------------------------- Plugins ----------------------------------- 

" NOTE: using vim-plug

" Plugins will be downloaded under the specified directory.
call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')

" Colourschemes
Plug 'habamax/vim-habaurora'
Plug 'NLKNguyen/papercolor-theme'
"Plug 'sainnhe/everforest'
"Plug 'nordtheme/vim'
Plug 'sainnhe/sonokai'

" Syntax support
Plug 'kien/rainbow_parentheses.vim'
Plug 'NLKNguyen/c-syntax.vim'
Plug 'pangloss/vim-javascript'
Plug 'MaxMEllon/vim-jsx-pretty'
Plug 'preservim/vim-markdown'
Plug 'vim-python/python-syntax'
Plug 'elixir-editors/vim-elixir'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()

