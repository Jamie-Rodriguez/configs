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

" fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" LSP
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'

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

" Set colorscheme now that plugins are loaded
colorscheme sonokai

" ------------------------------------ LSP -------------------------------------

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" -------------------------------- Keybindings ---------------------------------

" LSP keybindings
function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
    nmap <buffer> gd <plug>(lsp-definition)
    nmap <buffer> gs <plug>(lsp-document-symbol-search)
    nmap <buffer> gS <plug>(lsp-workspace-symbol-search)
    nmap <buffer> gr <plug>(lsp-references)
    nmap <buffer> gi <plug>(lsp-implementation)
    nmap <buffer> gt <plug>(lsp-type-definition)
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    nmap <buffer> ]g <plug>(lsp-next-diagnostic)
    nmap <buffer> [g <plug>(lsp-previous-diagnostic)
    nmap <buffer> K <plug>(lsp-hover)
    nnoremap <buffer> <expr><c-f> lsp#scroll(+4)
    nnoremap <buffer> <expr><c-d> lsp#scroll(-4)

    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
endfunction
