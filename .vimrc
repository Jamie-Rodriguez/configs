" Load Vim's own defaults first (a ~/.vimrc stops Vim loading them by itself):
" sensible backspace, no lag after <Esc>, scrolloff, showcmd, reopening a file
" at the last cursor position, etc. Anything below can override them.
unlet! skip_defaults_vim
source $VIMRUNTIME/defaults.vim

" Regex engine: automatic selection
set re=0

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

" Case-insensitive search, unless the pattern contains a capital letter
" (matches ripgrep's --smart-case)
set ignorecase smartcase

" Display all matches when using tab-completion
set wildmenu

" Set so that we don't have to save current buffer before switching to another buffer
set hidden

" Split windows to the right and below by default
set splitright
set splitbelow

" Auto-reload files when changed outside of Vim
" the augroup stops it being added twice when this file is re-sourced)
set autoread
augroup auto_reload
    autocmd!
    autocmd FocusGained,BufEnter * if getcmdwintype() ==# '' | checktime | endif
augroup END

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
Plug 'luochen1990/rainbow'
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

" List ends here. Plugins become visible to Vim after this call.
call plug#end()

" ------------------------------ Plugin settings -------------------------------

" Rainbow parentheses: turn on everywhere
let g:rainbow_active = 1
" Its default colours for 256-colour terminals are pale and hard to read on a
" light background, so use darker ones (with 'termguicolors' on, its own darker
" GUI colours are used instead)
let g:rainbow_conf = {
    \ 'ctermfgs': [26, 166, 29, 124, 92],
    \ }

" Turn on all of python-syntax's extra highlighting (built-in functions and
" types, string formatting, etc.), which is off by default (why??)
let g:python_highlight_all = 1


" ==============================================================================
" =                                    LSP                                     =
" ==============================================================================

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

" Use Vim's built-in LSP channel support, which is faster than vim-lsp's own
if has('patch-8.2.4780')
    let g:lsp_use_native_client = 1
endif

" Highlight references under cursor automatically
let g:lsp_document_highlight_enabled = 1

" Show diagnostics in virtual text
let g:lsp_diagnostics_virtual_text_enabled = 1
let g:lsp_diagnostics_virtual_text_align = 'after'

" Semantic highlighting
let g:lsp_semantic_enabled = 1

if executable('clangd')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'clangd',
        \ 'cmd': {server_info->['clangd']},
        \ 'allowlist': ['c', 'cpp', 'objc', 'objcpp'],
        \ 'root_uri': {server_info->lsp#utils#path_to_uri(
        \     lsp#utils#find_nearest_parent_file_directory(
        \         lsp#utils#get_buffer_path(),
        \         ['.clangd',
        \          '.clang-tidy',
        \          '.clang-format',
        \          'compile_commands.json',
        \          'compile_flags.txt',
        \          '.git']
        \     ))},
        \ })
endif

if executable('clojure-lsp')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'clojure-lsp',
        \ 'cmd': {server_info->['clojure-lsp']},
        \ 'allowlist': ['clojure', 'clojurescript'],
        \ 'root_uri': {server_info->lsp#utils#path_to_uri(
        \     lsp#utils#find_nearest_parent_file_directory(
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
        \   'allowlist': ['rust'],
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

if executable('typescript-language-server')
    au User lsp_setup call lsp#register_server({
        \ 'name': 'typescript-language-server',
        \ 'cmd': {server_info->['typescript-language-server', '--stdio']},
        \ 'root_uri':{server_info->lsp#utils#path_to_uri(
        \     lsp#utils#find_nearest_parent_file_directory(
        \         lsp#utils#get_buffer_path(),
        \         ['package.json',
        \          'tsconfig.json',
        \          'jsconfig.json',
        \          '.git']))},
        \ 'allowlist': ['javascript',
        \               'javascriptreact',
        \               'javascript.jsx',
        \               'typescript',
        \               'typescriptreact',
        \               'typescript.tsx'],
        \ })
endif

" ==============================================================================
" =                                Keybindings                                 =
" ==============================================================================

" ----------------------------- FuZzy Finder (fzf) -----------------------------

let g:fzf_vim = {}

let g:fzf_layout = { 'window': { 'width': 1.0, 'height': 0.9, 'border': 'horizontal' } }

" Display preview on the right if there are > 70 columns,
" else stack it above the list
" `Ctrl /` toggles this setting
let g:fzf_vim.preview_window = [ 'right,50%,wrap,<70(up,50%,border-bottom)', 'ctrl-/' ]

" Cut long paths from the left so that the filenames stay intact
let g:fzf_vim.files_options = ['--keep-right']
let g:fzf_vim.buffers_options = ['--keep-right']

" Search results: 'path:line:col:' on one line, the code on the next,
" and wrap anything too long rather than cutting it off
let g:fzf_vim.grep_multi_line = 1
let g:fzf_vim.rg_options = ['--wrap']

" Search through marks
nnoremap <leader>m :Marks<CR>

" List open buffers
nnoremap <leader>b :Buffers<CR>

" Search through all lines of all open buffers
nnoremap <leader>l :Lines<CR>

" Find file
nnoremap <C-p> :Files<CR>

" ---------------------------------- Ripgrep -----------------------------------

let g:rg_command = 'rg --column --line-number --no-heading --color=always --smart-case'
  \ . ' --trim --max-columns=150 --max-columns-preview -- '

" :Rg {pattern}    Search once, then fuzzy-filter the results
command! -bang -nargs=* Rg
  \ call fzf#vim#grep(g:rg_command . fzf#shellescape(<q-args>),
  \   fzf#vim#with_preview(), <bang>0)

" :RG    Live search that re-runs as you type. CTRL-F switches to
"        fuzzy-filtering the current results
command! -bang -nargs=* RG
  \ call fzf#vim#grep2(g:rg_command, <q-args>, fzf#vim#with_preview({ 'options': [
  \   '--bind', 'ctrl-f:unbind(change,ctrl-f)+change-prompt(Filter> )+enable-search+clear-query'
  \ ]}), <bang>0)

nnoremap <leader>f :RG<CR>
" Whole-word search for the word under the cursor, like *
nnoremap <leader>* :Rg \b<C-R><C-W>\b<CR>

" ------------------------------ LSP keybindings -------------------------------
function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    setlocal signcolumn=yes
    if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif

    " Go to definition of symbol under cursor
    nmap <buffer> gd <plug>(lsp-definition)
    " Go to declaration of symbol under cursor
    nmap <buffer> gD <plug>(lsp-declaration)
    " Go to type definition of symbol under cursor
    nmap <buffer> gy <plug>(lsp-type-definition)
    " Go to implementation of symbol under cursor
    nmap <buffer> <leader>gi <plug>(lsp-implementation)
    " Peek definition without jumping
    nmap <buffer> <leader>pd <plug>(lsp-peek-definition)
    " Peek declaration without jumping
    nmap <buffer> <leader>pD <plug>(lsp-peek-declaration)
    " Peek type definition without jumping
    nmap <buffer> <leader>py <plug>(lsp-peek-type-definition)
    " Peek implementation without jumping
    nmap <buffer> <leader>pi <plug>(lsp-peek-implementation)
    " Find references of symbol under cursor
    nmap <buffer> <leader>gr <plug>(lsp-references)
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
    " List the file's diagnostics (errors, warnings, etc.) in the location list
    " (the diagnostic for each line is also shown inline as virtual text)
    nmap <buffer> <leader>e <plug>(lsp-document-diagnostics)
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
    nmap <buffer> <leader>cf <plug>(lsp-document-format)
    " Run code lens action
    nmap <buffer> <leader>cl <plug>(lsp-code-lens)

    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.rs call execute('LspDocumentFormatSync')
endfunction


" ==============================================================================
" =                                   Other                                    =
" ==============================================================================
" Highlight trailing spaces in red
" NOTE: must come before `colorscheme` below, so the ColorScheme autocmd
" creates the highlight group when the colourscheme loads

function! s:MatchTrailingSpaces(in_insert_mode) abort
    if &buftype !=# ''
        match none
    elseif a:in_insert_mode
        " Don't flag the space just typed at the cursor
        match TrailingSpaces /\s\+\%#\@<!$/
    else
        match TrailingSpaces /\s\+$/
    endif
endfunction

augroup trailing_spaces
    autocmd!
    " :colorscheme clears custom highlight groups, so re-create it every time
    autocmd ColorScheme * highlight TrailingSpaces ctermbg=red guibg=red
    autocmd BufWinEnter,WinEnter,InsertLeave * call s:MatchTrailingSpaces(0)
    autocmd InsertEnter * call s:MatchTrailingSpaces(1)
augroup END

" Also define it now, in case no colourscheme gets loaded
highlight TrailingSpaces ctermbg=red guibg=red


" ==============================================================================
" =                               Colourschemes                                =
" ==============================================================================
" Use 24-bit 'true' colour when the terminal supports it
" ($COLORTERM is the standard way terminals advertise this)
if has('termguicolors') && ($COLORTERM ==# 'truecolor' || $COLORTERM ==# '24bit')
    set termguicolors
endif

" Use 'light' themes on colourschemes when available
set background=light
" Set colorscheme now that plugins are loaded
colorscheme PaperColor
