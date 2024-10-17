-- Syntax highlighting
vim.cmd('syntax on')

-- Display 'hybrid' linenumbers
vim.opt.number = true
vim.opt.relativenumber = true

-- Display current line and column in the bottom-right
vim.opt.ruler = true

-- Use 'light' themes on colourschemes when available
vim.opt.background = 'dark'

-- Highlight the search results
vim.opt.hlsearch = true

-- Incrementally search while typing
vim.opt.incsearch = true

-- Make autocomplete work like Bash
vim.opt.wildmode = 'list:longest,list:full'

-- Set so that we don't have to save current buffer before switching to another buffer
vim.opt.hidden = true

-- Clear the jumplist each time you start NeoVim
vim.api.nvim_create_autocmd("UIEnter", {
    pattern = "*",
    command = "clearjumps"
})

----------------------------------- Plugins ------------------------------------

local Plug = vim.fn['plug#']

vim.call('plug#begin', vim.fn.has('nvim') and vim.fn.stdpath('data') .. '/plugged' or '~/.vim/plugged')

-- Git
Plug 'tpope/vim-fugitive'

-- fzf
Plug('junegunn/fzf', {
    ['do'] = function()
        vim.fn['fzf#install']()
    end
})
Plug 'junegunn/fzf.vim'

-- Treesitter
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })

-- Telescope
Plug 'nvim-lua/plenary.nvim'
Plug('nvim-telescope/telescope.nvim', { tag = '0.1.8' })

-- LSPs
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'hrsh7th/nvim-cmp'

-- Make marks visible in 'sign column'
Plug 'kshenoy/vim-signature'

-- Colourschemes
Plug 'NLKNguyen/papercolor-theme'
Plug('sonph/onehalf', { rtp = 'vim' })
Plug 'sainnhe/everforest'
Plug 'sainnhe/gruvbox-material'
Plug 'sainnhe/sonokai'

-- Syntax support
Plug 'kien/rainbow_parentheses.vim'
Plug 'NLKNguyen/c-syntax.vim'
Plug 'pangloss/vim-javascript'
Plug 'MaxMEllon/vim-jsx-pretty'
Plug 'preservim/vim-markdown'
Plug 'vim-python/python-syntax'
Plug 'elixir-editors/vim-elixir'

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

    local opts = { noremap = true, silent = true, buffer = bufnr }

    -- Go to definition of symbol under cursor
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)

    -- Go to implementation of symbol under cursor
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)

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
    vim.keymap.set('n', '<space>o', vim.lsp.buf.document_symbol, opts)

    -- Show workspace symbol list
    vim.keymap.set('n', '<space>ws', vim.lsp.buf.workspace_symbol, opts)
end

-- clangd
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
        'configure.ac',
        '.git'
    )
}

-- tsserver
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

-- clojure-lsp
nvim_lsp.clojure_lsp.setup {
    on_attach = on_attach,
    capabilities = capabilities,
    filetypes = { "clojure", "clojurescript", "edn" },
    root_dir = nvim_lsp.util.root_pattern(
        "project.clj",
        "deps.edn",
        "build.boot",
        "shadow-cljs.edn",
        ".git"
    )
}

-- python-lsp-server
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
    pickers = {
        live_grep = {
            theme = 'dropdown',
            previewer = true,
        },
    },
}

--------------------------------- Keybindings ----------------------------------

-- Telescope
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})


-- Set colorscheme
vim.cmd('colorscheme everforest')
