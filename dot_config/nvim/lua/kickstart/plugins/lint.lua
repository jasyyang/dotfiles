---@module 'lazy'
---@type LazySpec
return {

  { -- Linting
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'

      -- Configure dmypy (mypy daemon) for faster incremental type checking
      local function get_venv_python()
        local venv = vim.env.VIRTUAL_ENV
        if venv then return venv .. '/bin/python' end
        local cwd_venv = vim.fn.getcwd() .. '/.venv/bin/python'
        if vim.fn.filereadable(cwd_venv) == 1 then return cwd_venv end
        return nil
      end

      -- Configure mypy args
      local mypy = lint.linters.mypy
      if vim.g.profile == 'kensho' then
        table.insert(mypy.args, '--config-file')
        table.insert(mypy.args, vim.fn.expand '~/code/zentreefish/klib/pkgs/kensho_lint/kensho_lint/pyproject.toml')
        table.insert(mypy.args, '--follow-imports=normal')
      end
      local venv_python = get_venv_python()
      if venv_python then
        table.insert(mypy.args, '--python-executable')
        table.insert(mypy.args, venv_python)
      end

      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
        python = { 'mypy' },
      }

      -- To allow other plugins to add linters to require('lint').linters_by_ft,
      -- instead set linters_by_ft like this:
      -- lint.linters_by_ft = lint.linters_by_ft or {}
      -- lint.linters_by_ft['markdown'] = { 'markdownlint' }
      --
      -- However, note that this will enable a set of default linters,
      -- which will cause errors unless these tools are available:
      -- {
      --   clojure = { "clj-kondo" },
      --   dockerfile = { "hadolint" },
      --   inko = { "inko" },
      --   janet = { "janet" },
      --   json = { "jsonlint" },
      --   markdown = { "vale" },
      --   rst = { "vale" },
      --   ruby = { "ruby" },
      --   terraform = { "tflint" },
      --   text = { "vale" }
      -- }
      --
      -- You can disable the default linters by setting their filetypes to nil:
      -- lint.linters_by_ft['clojure'] = nil
      -- lint.linters_by_ft['dockerfile'] = nil
      -- lint.linters_by_ft['inko'] = nil
      -- lint.linters_by_ft['janet'] = nil
      -- lint.linters_by_ft['json'] = nil
      -- lint.linters_by_ft['markdown'] = nil
      -- lint.linters_by_ft['rst'] = nil
      -- lint.linters_by_ft['ruby'] = nil
      -- lint.linters_by_ft['terraform'] = nil
      -- lint.linters_by_ft['text'] = nil

      -- Create autocommand which carries out the actual linting
      -- on the specified events.
      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if vim.bo.modifiable then lint.try_lint() end
        end,
      })
    end,
  },
}
