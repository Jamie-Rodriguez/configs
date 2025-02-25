" Syntax highlighting
syntax on

" Display 'hybrid' linenumbers
set number relativenumber

" Display current line and column in the bottom-right
set ruler

" Disable code-folding
set nofoldenable

" Enable searching down into sub-folders
set path+=**

" Highlight the search results
set hlsearch

" Incrementally search while typing
set incsearch

" Display all matches when using tab-completion
set wildmenu

" Set so that we don't have to save current buffer before switching to another buffer
set hidden

" Split windows to the right and below by default
set splitright
set splitbelow

" Auto-reload files when changed outside of Vim
set autoread
au FocusGained,BufEnter * checktime

" Clear the jumplist each time you start Vim
autocmd VimEnter * :clearjumps

" Clear any previous usages of <SPACE>
nnoremap <SPACE> <Nop>
" Set leader key to <SPACE>
let mapleader = " "


" ==============================================================================
" =                                  Plugins                                   =
" ==============================================================================

" NOTE: using vim-plug

" Plugins will be downloaded under the specified directory.
call plug#begin(has('nvim') ? stdpath('data') . '/plugged' : '~/.vim/plugged')

" Git
Plug 'tpope/vim-fugitive'

" Delete/change/add parentheses/quotes/XML-tags/much more with ease
Plug 'tpope/vim-surround'

" For fast-switching between buffers
Plug 'tpope/vim-unimpaired'

" Multicursors support
Plug 'mg979/vim-visual-multi', {'branch': 'master'}

" Make marks visible in 'sign column'
Plug 'kshenoy/vim-signature'

" fzf
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Syntax support
Plug 'kien/rainbow_parentheses.vim'
Plug 'NLKNguyen/c-syntax.vim'
Plug 'pangloss/vim-javascript'
Plug 'MaxMEllon/vim-jsx-pretty'
Plug 'preservim/vim-markdown'
Plug 'vim-python/python-syntax'

" Colourschemes
Plug 'NLKNguyen/papercolor-theme'
Plug 'sonph/onehalf', { 'rtp': 'vim' }
Plug 'sainnhe/everforest'
Plug 'sainnhe/gruvbox-material'
Plug 'sainnhe/sonokai'

" LSP
Plug 'prabirshrestha/vim-lsp'
Plug 'mattn/vim-lsp-settings'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()


" ==============================================================================
" =                                    LSP                                     =
" ==============================================================================

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

if executable('typescript-language-server')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'tsserver',
        \ 'cmd': {server_info->['typescript-language-server', '--stdio']},
        \ 'root_uri':{server_info->lsp#utils#path_to_uri(
        \     lsp#utils#find_nearest_parent_file_directory(
        \         lsp#utils#get_buffer_path(),
        \         ['package.json',
        \          'tsconfig.json',
        \          'jsconfig.json',
        \          '.git']))},
        \ 'whitelist': ['javascript',
        \               'javascriptreact',
        \               'javascript.jsx',
        \               'typescript',
        \               'typescriptreact',
        \               'typescript.tsx'],
        \ })
endif

if executable('clojure-lsp')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'clojure-lsp',
        \ 'cmd': {server_info->['clojure-lsp']},
        \ 'allowlist': ['clojure', 'clojurescript'],
        \ 'root_uri': {server_info->lsp#utils#path_to_uri(
        \     lsp#utils#find_nearest_parent_directory(
        \         lsp#utils#get_buffer_path(),
        \         ['.clj-kondo',
        \          'project.clj',
        \          'deps.edn',
        \          'build.boot',
        \          'shadow-cljs.edn']
        \     ))},
        \ })
endif

if executable('pylsp')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'pylsp',
        \ 'cmd': {server_info->['pylsp']},
        \ 'allowlist': ['python'],
        \ 'config': {
        \   'pylsp': {
        \     'plugins': {
        \       'pycodestyle': {'enabled': v:false},
        \       'mccabe': {'enabled': v:false},
        \       'pyflakes': {'enabled': v:false},
        \       'flake8': {'enabled': v:true}
        \     },
        \     'configurationSources': ['flake8']
        \   }
        \ }
        \ })
endif

if executable('rust-analyzer')
    au User lsp_setup call lsp#register_server({
        \   'name': 'Rust Language Server',
        \   'cmd': {server_info->['rust-analyzer']},
        \   'whitelist': ['rust'],
        \   'initialization_options': {
        \     'cargo': {
        \       'buildScripts': {
        \         'enable': v:true,
        \       },
        \     },
        \     'procMacro': {
        \       'enable': v:true,
        \     },
        \   },
        \ })
endif


" ==============================================================================
" =                                Keybindings                                 =
" ==============================================================================

" ----------------------------- FuZzy Finder (fzf) -----------------------------

" Search through marks
nnoremap <leader>m :Marks<CR>

" List open buffers
nnoremap <leader>b :Buffers<CR>

" Search through all lines of all open buffers
nnoremap <leader>l :Lines<CR>

" Find file
nnoremap <C-p> :Files<CR>

" ---------------------------------- Ripgrep -----------------------------------

" This command produces more advanced Rg with preview
command! -bang -nargs=* RgPreview
  \ call fzf#vim#grep(
  \   'rg --column --line-number --no-heading --color=always --smart-case -- '.shellescape(<q-args>), 1,
  \   fzf#vim#with_preview(), <bang>0)
" Search across entire project for string
nnoremap <leader>f :RgPreview<space>

" Search for word under cursor
nnoremap <leader>* :Rg <C-R><C-W><CR>

" ------------------------------ LSP keybindings -------------------------------
function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif

    " Go to definition of symbol under cursor
    nmap <buffer> gd <plug>(lsp-definition)
    " Go to implementation of symbol under cursor
    nmap <buffer> gi <plug>(lsp-implementation)
    " Find references of symbol under cursor
    nmap <buffer> gr <plug>(lsp-references)
    " Show the places where the current function is being called
    nmap <buffer> <leader>ci <plug>(lsp-call-hierarchy-incoming)
    " Show functions that are called within the body of the current function
    nmap <buffer> <leader>co <plug>(lsp-call-hierarchy-outgoing)
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
    nmap <buffer> <leader>ds <plug>(lsp-document-symbol-search)
    " Show workspace symbol list
    nmap <buffer> <leader>ws <plug>(lsp-workspace-symbol-search)
    " Open document outline
    nmap <buffer> <leader>do <plug>(lsp-document-symbol)
    " Format current document
    nmap <buffer> <leader>lf <plug>(lsp-document-format)

    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
endfunction


" ==============================================================================
" =                               Colourschemes                                =
" ==============================================================================
" Use 'light' themes on colourschemes when available
set background=light
" Set colorscheme now that plugins are loaded
colorscheme PaperColor


" ==============================================================================
" =                                   Other                                    =
" ==============================================================================
" Highlight trailing spaces
" Put this at the bottom as some plugins may override this setting
highlight TrailingSpaces ctermbg=red guibg=red
match TrailingSpaces /\s\+$/
