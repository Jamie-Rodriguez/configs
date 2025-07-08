-- Syntax highlighting
vim.cmd('syntax on')

-- Display 'hybrid' linenumbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Display current line and column in the bottom-right
vim.opt.ruler = true

-- Disable code-folding
vim.opt.foldenable = false

-- Enable searching down into sub-folders
vim.opt.path:append("**")

-- Highlight the search results
vim.opt.hlsearch = true

-- Incrementally search while typing
vim.opt.incsearch = true

-- Display all matches when using tab-completion
vim.opt.wildmenu = true

-- Make autocomplete work like Bash
vim.opt.wildmode = 'list:longest,list:full'

-- Set so that we don't have to save current buffer before switching to another buffer
vim.opt.hidden = true

-- Split windows to the right and below by default
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Auto-reload files when changed outside of NeoVim
vim.opt.autoread = true
vim.api.nvim_create_autocmd({"FocusGained", "BufEnter"}, {
    pattern = "*",
    command = "checktime"
})

-- Clear the jumplist each time you start NeoVim
vim.api.nvim_create_autocmd("VimEnter", {
    pattern = "*",
    command = "clearjumps"
})

-- Clear any previous usages of <SPACE>
vim.keymap.set('n', '<SPACE>', '<Nop>', { noremap = true })
-- Set leader key to <SPACE>
vim.g.mapleader = " "


----------------------------------- Plugins ------------------------------------

local Plug = vim.fn['plug#']

vim.call('plug#begin', vim.fn.has('nvim') and vim.fn.stdpath('data') .. '/plugged' or '~/.vim/plugged')

-- Git
Plug 'tpope/vim-fugitive'

-- Delete/change/add parentheses/quotes/XML-tags/much more with ease
Plug 'tpope/vim-surround'

-- For fast-switching between buffers
Plug 'tpope/vim-unimpaired'

-- Multicursors support
Plug('mg979/vim-visual-multi', { branch = 'master' })

-- Make marks visible in 'sign column'
Plug 'kshenoy/vim-signature'

-- fzf
Plug('nvim-telescope/telescope-fzf-native.nvim', { ['do'] = 'make' })
Plug 'junegunn/fzf.vim'

-- Treesitter
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })

-- Telescope
Plug 'nvim-lua/plenary.nvim'
Plug('nvim-telescope/telescope.nvim', { tag = '0.1.8' })

-- Syntax support
Plug 'kien/rainbow_parentheses.vim'
Plug 'NLKNguyen/c-syntax.vim'
Plug 'pangloss/vim-javascript'
Plug 'MaxMEllon/vim-jsx-pretty'
Plug 'preservim/vim-markdown'
Plug 'vim-python/python-syntax'

-- Colourschemes
Plug 'NLKNguyen/papercolor-theme'
Plug('sonph/onehalf', { rtp = 'vim' })
Plug 'sainnhe/everforest'
Plug 'sainnhe/gruvbox-material'
Plug 'sainnhe/sonokai'

-- LSPs
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

vim.call('plug#end')

------------------------------------- LSP --------------------------------------

-- nvim-cmp
local cmp = require 'cmp'

cmp.setup({
    snippet = {
        -- REQUIRED - you must specify a snippet engine
        expand = function(args)
            vim.fn['vsnip#anonymous'](args.body)
        end,
    },
    window = {
        -- completion = cmp.config.window.bordered(),
        -- documentation = cmp.config.window.bordered(),
    },
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true })
    }),
    sources = cmp.config.sources({
        { name = 'nvim_lsp' }
    }, {
        { name = 'buffer' }
    })
})

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't workanymore).
cmp.setup.cmdline({ '/', '?' }, {
    mapping = cmp.mapping.preset.cmdline(),
    sources = {
        { name = 'buffer' }
    }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't workanymore).
cmp.setup.cmdline(':', {
    mapping = cmp.mapping.preset.cmdline(),
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    }),
    matching = { disallow_symbol_nonprefix_matching = false }
})

-- lspconfig
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local nvim_lsp = require('lspconfig')

local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

    -- Enable semantic tokens if the server supports it (similar to vim-lsp semantic highlighting)
    if client.server_capabilities.semanticTokensProvider then
        vim.lsp.semantic_tokens.start(bufnr, client.id)
    end

    -- Enable code lens if supported
    if client.server_capabilities.codeLensProvider then
        vim.lsp.codelens.refresh()
        -- Auto refresh code lens
        vim.api.nvim_create_autocmd({"BufEnter", "CursorHold", "InsertLeave"}, {
            buffer = bufnr,
            callback = vim.lsp.codelens.refresh,
        })
    end

    local opts = { noremap = true, silent = true, buffer = bufnr }

    -- Go to definition of symbol under cursor
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)

    -- Go to declaration of symbol under cursor
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)

    -- Go to type definition of symbol under cursor
    vim.keymap.set('n', 'gy', vim.lsp.buf.type_definition, opts)

    -- Go to implementation of symbol under cursor
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)

    -- Peek definition without jumping (using Telescope)
    vim.keymap.set('n', '<leader>pd', function()
        require('telescope.builtin').lsp_definitions({ jump_type = "never" })
    end, opts)

    -- Peek declaration without jumping
    vim.keymap.set('n', '<leader>pD', function()
        -- NeoVim doesn't have built-in peek for declaration, use Telescope
        require('telescope.builtin').lsp_declarations({ jump_type = "never" })
    end, opts)

    -- Peek type definition without jumping
    vim.keymap.set('n', '<leader>py', function()
        require('telescope.builtin').lsp_type_definitions({ jump_type = "never" })
    end, opts)

    -- Peek implementation without jumping
    vim.keymap.set('n', '<leader>pi', function()
        require('telescope.builtin').lsp_implementations({ jump_type = "never" })
    end, opts)

    -- Find references of symbol under cursor
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

    -- Show the places where the current function is being called
    vim.keymap.set('n', '<leader>ci', vim.lsp.buf.incoming_calls, opts)

    -- Show functions that are called within the body of the current function
    vim.keymap.set('n', '<leader>co', vim.lsp.buf.outgoing_calls, opts)

    -- Show hover information of symbol under cursor
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)

    -- Show signature help (parameter information) for current function call
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)

    -- Rename symbol under cursor
    vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)

    -- Show available code actions
    vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, opts)

    -- Show diagnostic (error, warning, etc.) in a floating window
    vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)

    -- Go to next diagnostic
    vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)

    -- Go to previous diagnostic
    vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)

    -- Show document symbol list
    vim.keymap.set('n', '<leader>ds', function()
        require('telescope.builtin').lsp_document_symbols()
    end, opts)

    -- Show workspace symbol list
    vim.keymap.set('n', '<leader>ws', function()
        require('telescope.builtin').lsp_workspace_symbols()
    end, opts)

    -- Open document outline
    vim.keymap.set('n', '<leader>do', vim.lsp.buf.document_symbol, opts)

    -- Format current document
    vim.keymap.set('n', '<leader>lf', function()
        vim.lsp.buf.format { async = true }
    end, opts)

    -- Run code lens action
    vim.keymap.set('n', '<leader>cl', vim.lsp.codelens.run, opts)
end

-- WARNING: If you want to use clangd as the LSP server in your project, you
-- NEED to set up a JSON Compilation Database (compile_commands.json)
nvim_lsp.clangd.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    cmd = { 'clangd' },
    filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
    root_dir = nvim_lsp.util.root_pattern(
        '.clangd',
        '.clang-tidy',
        '.clang-format',
        'compile_commands.json',
        'compile_flags.txt',
        '.git'
    )
}

nvim_lsp.clojure_lsp.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "clojure", "clojurescript", "edn" },
    root_dir = nvim_lsp.util.root_pattern(
        ".clj-kondo",
        "project.clj",
        "deps.edn",
        "build.boot",
        "shadow-cljs.edn",
        ".git"
    )
}

nvim_lsp.pylsp.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "python" },
    root_dir = nvim_lsp.util.root_pattern(
        "pyproject.toml",
        "setup.py",
        "setup.cfg",
        "requirements.txt",
        "Pipfile",
        ".git"
    ),
    settings = {
        pylsp = {
            plugins = {
                pycodestyle = { enabled = false },
                mccabe = { enabled = false },
                pyflakes = { enabled = false },
                flake8 = { enabled = true }
            },
            configurationSources = {'flake8'}
        }
    }
}

nvim_lsp.rust_analyzer.setup({
    on_attach = on_attach,
    capabilities = capabilities,
    settings = {
        ["rust-analyzer"] = {
            imports = {
                granularity = {
                    group = "module",
                },
                prefix = "self",
            },
            cargo = {
                buildScripts = {
                    enable = true,
                },
            },
            procMacro = {
                enable = true
            },
        }
    }
})

nvim_lsp.tsserver.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = {
        'javascript',
        'javascriptreact',
        'javascript.jsx',
        'typescript',
        'typescriptreact',
        'typescript.tsx'
    },
    root_dir = nvim_lsp.util.root_pattern(
        'package.json',
        'tsconfig.json',
        'jsconfig.json',
        '.git'
    )
}


---------------------------- Plugins Custom Configs ----------------------------

require('telescope').setup {
    defaults = {
        layout_strategy = 'vertical',
        preview = {
            treesitter = true,
            wrap_lines = true,
        },
        path_display = { 'smart', shorten = { len = 3 } },
        dynamic_preview_title = true,
        wrap_results = true
    },
}

require('telescope').load_extension('fzf')


--------------------------------- Keybindings ----------------------------------

-- Telescope
local builtin = require('telescope.builtin')

-- Search through marks
vim.keymap.set('n', '<leader>m', builtin.marks, {})

-- List open buffers
vim.keymap.set('n', '<leader>b', builtin.buffers, {})

-- Search through all lines of all open buffers
vim.keymap.set('n', '<leader>l', function()
    builtin.live_grep({
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Buffers',
    })
end, {})

-- Find file
vim.keymap.set('n', '<C-p>', builtin.find_files, {})

-- Search across entire project for string (Ripgrep)
vim.keymap.set('n', '<leader>f', builtin.live_grep, {})

-- Search for word under cursor
vim.keymap.set('n', '<leader>*', function()
    builtin.grep_string({ search = vim.fn.expand("<cword>") })
end, {})

--------------------------------- Colourscheme ---------------------------------

-- Use 'dark' themes on colourschemes when available
vim.opt.background = 'dark'
-- Specify 'soft' contrast for Everforest theme
vim.g.everforest_background = 'soft'
vim.cmd.colorscheme('everforest')


------------------------------------ Other -------------------------------------
-- Highlight trailing spaces
-- Put this at the bottom as some plugins may override this setting
vim.cmd [[highlight TrailingSpaces ctermbg=red guibg=red]]
vim.cmd [[match TrailingSpaces /\s\+$/]]
