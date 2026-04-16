vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.profile = vim.env.CONFIG_PROFILE
vim.g.have_nerd_font = true
vim.o.number = true
vim.o.mouse = 'a'
vim.o.showmode = false
vim.schedule(function() vim.o.clipboard = 'unnamedplus' end)
vim.o.breakindent = true
vim.o.undofile = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.signcolumn = 'yes'
vim.o.updatetime = 400
vim.o.timeoutlen = 300
vim.o.splitright = true
vim.o.splitbelow = true
vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }
vim.o.inccommand = 'split'
vim.o.cursorline = true
vim.o.scrolloff = 25
vim.o.confirm = true
vim.o.title = true
vim.o.titlestring = '%{fnamemodify(getcwd(), ":t")}'
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Hover: K to show, K again to enter (for scrolling), q to close
vim.keymap.set('n', 'K', function()
  local wins = vim.api.nvim_list_wins()
  for _, win in ipairs(wins) do
    local config = vim.api.nvim_win_get_config(win)
    if config.relative ~= '' and config.focusable then
      vim.api.nvim_set_current_win(win)
      vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = vim.api.nvim_win_get_buf(win) })
      return
    end
  end
  vim.lsp.buf.hover()
end, { desc = 'Hover / enter hover window' })

vim.diagnostic.config {
  update_in_insert = false,
  severity_sort = true,
  float = {
    border = 'rounded',
    source = 'if_many',
    max_width = 80,
    wrap = true,
  },
  underline = { severity = { min = vim.diagnostic.severity.WARN } },
  virtual_text = {
    spacing = 4,
    prefix = '●',
    format = function(diagnostic)
      local max_width = 50
      local message = diagnostic.message:gsub('\n', ' ')
      if #message > max_width then return string.sub(message, 1, max_width) .. '...' end
      return message
    end,
  },
  virtual_lines = false,
  jump = { float = true },
}

vim.api.nvim_create_autocmd('CursorHold', {
  callback = function()
    vim.diagnostic.open_float(nil, { focus = false, scope = 'cursor' })
  end,
})
vim.keymap.set('n', '<leader>Q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })
vim.keymap.set('n', '<leader>q', vim.cmd.q, { desc = '[q]uit current window' })
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })

vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
  if vim.v.shell_error ~= 0 then error('Error cloning lazy.nvim:\n' .. out) end
end

---@type vim.Option
local rtp = vim.opt.rtp
rtp:prepend(lazypath)
require('lazy').setup({
  { 'NMAC427/guess-indent.nvim', opts = {} },
  {
    'lewis6991/gitsigns.nvim',
    ---@module 'gitsigns'
    ---@type Gitsigns.Config
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      signs = {
        add = { text = '+' }, ---@diagnostic disable-line: missing-fields
        change = { text = '~' }, ---@diagnostic disable-line: missing-fields
        delete = { text = '_' }, ---@diagnostic disable-line: missing-fields
        topdelete = { text = '‾' }, ---@diagnostic disable-line: missing-fields
        changedelete = { text = '~' }, ---@diagnostic disable-line: missing-fields
      },
    },
  },

  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    ---@module 'which-key'
    ---@type wk.Opts
    ---@diagnostic disable-next-line: missing-fields
    opts = {
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },

      spec = {
        { '<leader>s', group = '[s]earch', mode = { 'n', 'v' } },
        { '<leader>t', group = '[t]oggle' },
        { '<leader>h', group = 'Git [h]unk', mode = { 'n', 'v' } },
        { 'gr', group = 'LSP Actions', mode = { 'n' } },
      },
    },
  },

  {
    'hat0uma/csvview.nvim',
    config = function()
      vim.keymap.set('n', '<leader>tc', function() vim.cmd 'CsvViewToggle' end, { desc = '[t]oggle [c]svview' })
    end,
  },

  {
    'sindrets/diffview.nvim',
    config = function()
      vim.keymap.set('n', '<leader>tf', function()
        if next(require('diffview.lib').views) == nil then
          vim.cmd 'DiffviewOpen'
        else
          vim.cmd 'DiffviewClose'
        end
      end, { desc = '[t]oggle Dif[f]view' })
    end,
  },

  {
    'NeogitOrg/neogit',
    config = function()
      vim.keymap.set('n', '<leader>tg', function() vim.cmd 'Neogit' end, { desc = '[t]oggle Neo[g]it ' })
    end,
  },

  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      require('toggleterm').setup {
        shell = '/bin/zsh',
        direction = 'float',
        float_opts = {
          border = 'rounded',
          winblend = 25,
        },
        shade_terminals = true,
        shading_factor = '50',
        winbar = {
          enabled = false,
          name_formatter = function(term) return term.name end,
        },
        highlights = {
          NormalFloat = {
            link = 'Normal',
          },
          FloatBorder = {
            link = 'FloatBorder',
          },
        },
        size = 20,
      }
      vim.api.nvim_set_hl(0, 'NormalFloat', {})
      vim.api.nvim_set_hl(0, 'FloatBorder', {})
      vim.keymap.set({ 'n', 't' }, ';;', '<cmd>ToggleTerm direction=float<cr>')
    end,
  },

  { -- Fuzzy Finder (files, lsp, etc)
    'nvim-telescope/telescope.nvim',
    enabled = true,
    event = 'VimEnter',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',

        build = 'make',

        cond = function() return vim.fn.executable 'make' == 1 end,
      },
      { 'nvim-telescope/telescope-ui-select.nvim' },

      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    config = function()
      require('telescope').setup {
        defaults = {
          file_ignore_patterns = {
            'node_modules/',
            '.venv/',
            '*.js',
            '.DS_Store',
            '*.log',
            '*.pid',
            '*.tmp',
            '__pycache__/',
            '*.pyc',
            '*.pyo',
            '*.pyd',
            '.pytest_cache/',
            '.coverage',
            'htmlcov/',
            'build/',
            '.pyright/',
            'npm-debug.log*',
            '.next/',
            '.cache/',
            'dist/',
          },
        },
        extensions = {
          ['ui-select'] = { require('telescope.themes').get_dropdown() },
        },
      }

      pcall(require('telescope').load_extension, 'fzf')
      pcall(require('telescope').load_extension, 'ui-select')

      local builtin = require 'telescope.builtin'
      vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[s]earch [h]elp' })
      vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[s]earch [k]eymaps' })
      vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[s]earch [f]iles' })
      vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[s]earch [s]elect Telescope' })
      vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[s]earch current [w]ord' })
      vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[s]earch by [g]rep' })
      vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[s]earch [s]iagnostics' })
      vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[s]earch [r]esume' })
      vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[s]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[s]earch [c]ommands' })
      vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
        callback = function(event)
          local buf = event.buf

          vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[g]oto [r]eferences' })

          vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[g]oto [i]mplementation' })

          vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[g]oto [d]efinition' })

          vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })

          vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })

          vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[g]oto [t]ype Definition' })
        end,
      })

      vim.keymap.set(
        'n',
        '<leader>/',
        function()
          builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
            winblend = 10,
            previewer = false,
          })
        end,
        { desc = '[/] Fuzzily search in current buffer' }
      )

      vim.keymap.set(
        'n',
        '<leader>s/',
        function()
          builtin.live_grep {
            grep_open_files = true,
            prompt_title = 'Live Grep in Open Files',
          }
        end,
        { desc = '[s]earch [/] in Open Files' }
      )

      vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config' } end, { desc = '[s]earch [n]eovim files' })
    end,
  },

  -- LSP Plugins
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {
        'mason-org/mason.nvim',
        ---@module 'mason.settings'
        ---@type MasonSettings
        ---@diagnostic disable-next-line: missing-fields
        opts = {},
      },
      'mason-org/mason-lspconfig.nvim',
      'WhoIsSethDaniel/mason-tool-installer.nvim',

      { 'j-hui/fidget.nvim', opts = {} },

      'saghen/blink.cmp',
    },
    config = function()
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or 'n'
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
          end

          map('grn', vim.lsp.buf.rename, '[r]e[n]ame')

          map('gra', vim.lsp.buf.code_action, '[g]oto code [a]ction', { 'n', 'x' })

          map('grD', vim.lsp.buf.declaration, '[g]oto [D]eclaration')

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method('textDocument/documentHighlight', event.buf) then
            local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
            vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
              buffer = event.buf,
              group = highlight_augroup,
              callback = vim.lsp.buf.clear_references,
            })

            vim.api.nvim_create_autocmd('LspDetach', {
              group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
              callback = function(event2)
                vim.lsp.buf.clear_references()
                vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
              end,
            })
          end

          if client and client:supports_method('textDocument/inlayHint', event.buf) then
            map('<leader>th', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = event.buf }) end, '[t]oggle Inlay [h]ints')
          end
        end,
      })
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('python_lsp_disable_ruff_hover', { clear = true }),
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if not client then return end

          if client.name == 'ruff' then client.server_capabilities.hoverProvider = false end
        end,
      })

      ---@type table<string, vim.lsp.Config>
      local servers = {
        ruff = {
          settings = {
            configuration = vim.g.profile == 'kensho'
                and vim.fn.expand '~/code/zentreefish/klib/pkgs/kensho_lint/kensho_lint/pyproject.toml'
              or nil,
          },
        },
        basedpyright = {
          handlers = {
            -- Suppress basedpyright diagnostics, mypy handles type checking
            ['textDocument/publishDiagnostics'] = function() end,
          },
          settings = {
            basedpyright = {
              disableOrganizeImports = true, -- ruff handles this
              analysis = {
                typeCheckingMode = 'basic', -- needed for hover/completions
              },
            },
          },
        },
        rust_analyzer = {
          settings = {
            ['rust-analyzer'] = {
              cargo = {
                allFeatures = true,
                loadOutDirsFromCheck = true,
                buildScripts = { enable = true },
              },
              checkOnSave = true,
              check = {
                command = 'clippy',
              },
              procMacro = { enable = true },
              diagnostics = {
                enable = true,
              },
            },
          },
        },
        ts_ls = {},
        stylua = {},
        lua_ls = {
          on_init = function(client)
            if client.workspace_folders then
              local path = client.workspace_folders[1].name
              if path ~= vim.fn.stdpath 'config' and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc')) then return end
            end

            client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
              runtime = {
                version = 'LuaJIT',
                path = { 'lua/?.lua', 'lua/?/init.lua' },
              },
              workspace = {
                checkThirdParty = false,
                library = vim.tbl_extend('force', vim.api.nvim_get_runtime_file('', true), {
                  '${3rd}/luv/library',
                  '${3rd}/busted/library',
                }),
              },
            })
          end,
          settings = {
            Lua = {},
          },
        },
      }
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {})

      require('mason-tool-installer').setup { ensure_installed = ensure_installed }

      for name, server in pairs(servers) do
        vim.lsp.config(name, server)
        vim.lsp.enable(name)
      end
    end,
  },

  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function() require('conform').format { async = true, lsp_format = 'fallback' } end,
        mode = '',
        desc = '[f]ormat buffer',
      },
    },
    ---@module 'conform'
    ---@type conform.setupOpts
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        if disable_filetypes[vim.bo[bufnr].filetype] then
          return nil
        else
          return {
            timeout_ms = 500,
            lsp_format = 'fallback',
          }
        end
      end,
      formatters_by_ft = {
        lua = { 'stylua' },
        markdown = { 'prettier' },
        python = { 'ruff_organize_imports', 'ruff_format' },
        rust = { 'rustfmt' },
        typescript = { 'prettierd' },
        typescriptreact = { 'prettierd' },
        javascript = { 'prettierd' },
        javascriptreact = { 'prettierd' },
      },
      formatters = vim.g.profile == 'kensho' and {
        ruff_format = {
          prepend_args = { '--config', vim.fn.expand '~/code/zentreefish/klib/pkgs/kensho_lint/kensho_lint/pyproject.toml' },
        },
        ruff_organize_imports = {
          prepend_args = { '--config', vim.fn.expand '~/code/zentreefish/klib/pkgs/kensho_lint/kensho_lint/pyproject.toml' },
        },
      } or {},
    },
  },

  {
    'nvim-neo-tree/neo-tree.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    keys = {
      { '<leader>e', '<cmd>Neotree toggle<cr>', desc = 'Toggle N[e]otree' },
    },
  },

  {
    'goolord/alpha-nvim',
    dependencies = {
      'nvim-tree/nvim-web-devicons',
    },
    config = function()
      local dashboard = require 'alpha.themes.dashboard'
      local function get_welcome()
        local user = vim.env.USER or 'jason'
        return 'Welcome back, ' .. user .. ' :D'
      end
      local header = vim.split(
        [[
⣿⣿⣿⣿⣿⣿⣿⣿⠿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⠏⠀⠀⠀⠀⠙⠿⠿⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣿⡀⠀⣠⣴⣶⣿⣿⣿⣿⣶⣮⣝⠻⢿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⡟⣡⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⡀⠀⠀⠙⢿
⣿⠿⣿⣿⡿⢰⣿⡿⠋⠉⠉⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⡄⠀⠀⣸
⠁⠀⠀⠙⠃⢿⣿⡅⠀⠀⢀⣼⣿⣿⣿⣿⠟⠛⠻⣿⣿⣷⢀⣴⣿
⡀⠀⠀⠀⠀⠸⣿⣛⣳⣾⣿⢿⡍⢉⣻⡇⠰⠀⠀⣿⣿⣿⢸⣿⣿
⣷⡀⠀⠀⠀⠀⠈⠻⢿⣿⣿⣷⣶⣬⣽⣿⣦⣤⣤⣟⣿⢇⣾⣿⣿
⣿⣿⣄⠀⠀⠀⠀⠀⠀⠈⠙⠻⠿⣿⣿⣿⣿⣮⣿⠟⣡⣾⣿⣿⣿
⣿⣿⣿⡇⢰⣶⣤⣤⣤⣀⣀⠀⠀⠀⠀⠀⠀⠀⠀⢻⣿⣿⣿⣿⣿
⣿⣿⣿⣇⣿⣿⣿⣿⣿⣿⣿⣿⣷⣶⣤⡀⠀⠀⠀⠀⢻⣿⣿⣿⣿
⣿⣿⣿⡈⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡄⠀⠀⠀⠀⢿⣿⣿⣿
⣿⣿⣿⡇⠹⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⢸⣿⣿⣿
⣿⣿⣿⡇⠀⠙⠿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠃⢠⣄⣀⣠⣿⣿⣿⣿
⣿⣿⣿⣿⠀⠀⠀⠀⠉⣉⣛⣛⡛⠉⠁⠀⠀⢸⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣆⠀⠀⠀⣰⣿⣿⣿⣷⡀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣿⣿
⣿⣿⣿⣿⣿⣷⣶⣶⣿⣿⣿⣿⣿⣿⣶⣶⣿⣿⣿⣿⣿⣿⣿⣿⣿⠀⠀⠀⠀⠀
     
    ]],
        '\n',
        { trimempty = true }
      )
      table.insert(header, get_welcome())
      dashboard.section.header.val = header

      local function button(sc, txt, keybind)
        local b = dashboard.button(sc, txt, keybind)
        b.opts.hl = 'AlphaButtons'
        b.opts.hl_shortcut = 'AlphaShortcut'
        return b
      end

      local function get_git_branch()
        local handle = io.popen 'git branch --show-current 2>/dev/null'
        if not handle then return '' end
        local branch = handle:read('*a'):gsub('%s+', '')
        handle:close()
        if branch == '' then return '  not in a git repository' end
        return '  ' .. branch
      end

      dashboard.section.header.opts = {
        position = 'center',
        hl = 'AlphaHeader',
      }
      local projects = {
        kensho = {
          { key = 'p1', name = 'text2sql', path = '/Users/jasonyang/code/zentreefish/projects/text2sql' },
          { key = 'p2', name = 'kce', path = '/Users/jasonyang/code/zentreefish/klib/pkgs/kensho_code_eval' },
          { key = 'p3', name = 'kensho-text2sql', path = '/Users/jasonyang/code/zentreefish/klib/pkgs/kensho_text2sql' },
          { key = 'p4', name = 'aquila', path = '/Users/jasonyang/code/aquila' },
        },
        personal = {
          { key = 'p1', name = 'code', path = '/home/jason/code' },
          { key = 'p2', name = 'rustbook', path = '/home/jason/code/projects/rustbook' },
        },
      }
      local buttons = {
        button('d', '󰱼  Current directory', '<cmd>Neotree dir=. position=current<CR>'),
        button('r', '  Recent files', ':Telescope oldfiles<CR>'),
        button('g', '󰈬  Live grep', ':Telescope live_grep<CR>'),
        button('c', '  Chezmoi', '<cmd>Neotree dir=~/.local/share/chezmoi position=current<CR>'),
      }
      for _, p in ipairs(projects[vim.g.profile] or {}) do
        table.insert(buttons, button(p.key, '  ' .. p.name, '<cmd>Neotree dir=' .. p.path .. ' position=current<CR>'))
      end
      table.insert(buttons, button('q', '  Quit', ':qa<CR>'))
      dashboard.section.buttons.val = buttons
      dashboard.section.buttons.opts = {
        position = 'center',
      }
      dashboard.section.footer.val = function()
        local stats = require('lazy').stats()
        return {
          '',
          '󰉋  ' .. vim.fn.fnamemodify(vim.fn.getcwd(), ':~'),
          get_git_branch(),
          '⚡  Neovim loaded ' .. stats.count .. ' plugins in ' .. math.floor(stats.startuptime) .. 'ms',
        }
      end
      dashboard.section.footer.opts = {
        position = 'center',
        hl = 'AlphaFooter',
      }

      dashboard.config.layout = {
        { type = 'padding', val = 4 },
        dashboard.section.header,
        { type = 'padding', val = 2 },
        dashboard.section.buttons,
        { type = 'padding', val = 2 },
        dashboard.section.footer,
      }

      vim.api.nvim_set_hl(0, 'AlphaHeader', { link = 'Type' })
      vim.api.nvim_set_hl(0, 'AlphaButtons', { link = 'Keyword' })
      vim.api.nvim_set_hl(0, 'AlphaShortcut', { link = 'Number' })
      vim.api.nvim_set_hl(0, 'AlphaFooter', { link = 'Comment' })
      require('alpha').setup(dashboard.config)
    end,
  },

  { -- Autocompletion
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        version = '2.*',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then return end
          return 'make install_jsregexp'
        end)(),
        dependencies = {},
        opts = {},
      },
    },
    ---@module 'blink.cmp'
    ---@type blink.cmp.Config
    opts = {
      keymap = {
        preset = 'default',
      },

      appearance = {
        nerd_font_variant = 'mono',
      },

      completion = {
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },

      sources = {
        default = { 'lsp', 'path', 'snippets' },
      },

      snippets = { preset = 'luasnip' },
      fuzzy = { implementation = 'lua' },
      signature = { enabled = true },
    },
  },

  {
    'nyoom-engineering/oxocarbon.nvim',
    priority = 1000,
    config = function()
      vim.opt.background = 'dark'
      -- vim.cmd.colorscheme 'oxocarbon'
    end,
  },

  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      vim.opt.background = 'dark'
      vim.cmd.colorscheme 'tokyonight-night'
      -- Dim virtual text to be less distracting
      vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextError', { fg = '#8a5555' })
      vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextWarn', { fg = '#7a6b50' })
      vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextInfo', { fg = '#506880' })
      vim.api.nvim_set_hl(0, 'DiagnosticVirtualTextHint', { fg = '#507a60' })
    end,
  },

  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    ---@module 'todo-comments'
    ---@type TodoOptions
    ---@diagnostic disable-next-line: missing-fields
    opts = { signs = false },
  },

  {
    'nvim-mini/mini.nvim',
    config = function()
      require('mini.ai').setup { n_lines = 500 }
      require('mini.surround').setup()
      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function() return '%2l:%-2v' end
    end,
  },

  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    branch = 'main',
    config = function()
      local parsers = {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'rust',
        'vim',
        'vimdoc',
        'python',
        'regex',
        'toml',
        'typescript',
        'yaml',
        'json',
        'xml',
        'javascript',
      }
      require('nvim-treesitter').install(parsers)
      vim.api.nvim_create_autocmd('FileType', {
        callback = function(args)
          local buf, filetype = args.buf, args.match

          local language = vim.treesitter.language.get_lang(filetype)
          if not language then return end

          if not vim.treesitter.language.add(language) then return end
          vim.treesitter.start(buf, language)
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
      })
    end,
  },

  -- require 'kickstart.plugins.debug',
  require 'kickstart.plugins.indent_line',
  require 'kickstart.plugins.lint',
  require 'kickstart.plugins.autopairs',
  require 'kickstart.plugins.neo-tree',
  require 'kickstart.plugins.gitsigns', -- adds gitsigns recommend keymaps
}, { ---@diagnostic disable-line: missing-fields
  ui = {
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

if vim.g.profile then pcall(require, 'profiles.' .. vim.g.profile) end
