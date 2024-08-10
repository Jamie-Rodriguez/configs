" Syntax highlighting
syntax on

" Display 'hybrid' linenumbers
set number relativenumber

" Display current line and column in the bottom-right
set ruler

" Use 'light' themes on colourschemes when available
"set background=light

" Highlight the search results
set hlsearch

" Incrementally search while typing
set incsearch

" Set so that we don't have to save current buffer before switching to another buffer
set hidden

" Clear the jumplist each time you start Vim
autocmd VimEnter * :clearjumps

" ---------------------------------- Plugins -----------------------------------

" NOTE: using vim-plug

" Plugins will be downloaded under the specified directory.
call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')

" Git
Plug 'tpope/vim-fugitive'

" fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" LSP
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'

" Make marks visible in 'sign column'
Plug 'kshenoy/vim-signature'

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

if executable('clojure-lsp')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'clojure-lsp',
        \ 'cmd': {server_info->['clojure-lsp']},
        \ 'allowlist': ['clojure', 'clojurescript'],
        \ 'root_uri': {server_info->lsp#utils#path_to_uri(
        \     lsp#utils#find_nearest_parent_directory(
        \         lsp#utils#get_buffer_path(),
        \         ['.clj-kondo', 'project.clj', 'deps.edn', 'build.boot', 'shadow-cljs.edn']))},
        \ })
endif

" -------------------------------- Keybindings ---------------------------------

" fzf
" Find file
nnoremap <C-p> :Files<CR>
" Search across entire project for string
nnoremap <leader>f :Rg<space>

" LSP keybindings
function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif

    " Go to definition of symbol under cursor
    nmap <buffer> gd <plug>(lsp-definition)
    " Find references of symbol under cursor
    nmap <buffer> gr <plug>(lsp-references)
    " Go to implementation of symbol under cursor
    nmap <buffer> gi <plug>(lsp-implementation)
    " Show hover information of symbol under cursor
    nmap <buffer> K <plug>(lsp-hover)
    " Show signature help (parameter information) for current function call
    nmap <buffer> <C-k> <plug>(lsp-signature-help)
    " Rename symbol under cursor
    nmap <buffer> <leader>rn <plug>(lsp-rename)
    " Show available code actions
    nmap <buffer> <leader>ca <plug>(lsp-code-action)
    " Show diagnostic (error, warning, etc.) in a floating window
    nmap <buffer> <space>e <plug>(lsp-diagnostic-open-float)
    " Go to next diagnostic
    nmap <buffer> ]d <plug>(lsp-next-diagnostic)
    " Go to previous diagnostic
    nmap <buffer> [d <plug>(lsp-previous-diagnostic)
    " Show document symbol list
    nmap <buffer> <space>o <plug>(lsp-document-symbol-search)
    " Show workspace symbol list
    nmap <buffer> <space>ws <plug>(lsp-workspace-symbol-search)

    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
endfunction
