require("nvchad.configs.lspconfig").defaults()

-- read :h vim.lsp.config for changing options of lsp servers

-- ##my rust configuration
vim.lsp.config("rust_analyzer", {
  cmd = { "rust-analyzer" },
  filetypes = { "rust" },
  root_dir = vim.fs.root(0, { "Cargo.toml", "rust-project.json" }), -- project root finding
  settings = {
    ["rust-analyzer"] = {
      cargo = {
        allFeatures = true,
      },
      check = {
        command = "clippy",
      },
    },
  },
})

-- ## c/c++ configuration
vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--clang-tidy",
    "--background-index",
    "--completion-style=detailed",
    "--header-insertion=never",
    "--all-scopes-completion",
    "--cross-file-rename",
    "--pch-storage=memory",
    "--j=4",
    "--fallback-style=llvm",
  },
  filetypes = { "c", "cpp" },
  root_dir = function(bufnr, on_dir)
    local root = vim.fs.root(bufnr, { "compile_commands.json", ".git" })
    on_dir(root)
  end,
  capabilities = {
    textDocument = {
      completion = {
        editsNearCursor = true,
      },
    },
    offsetEncoding = { "utf-8", "utf-16" },
  },
  on_init = function(client, init_result)
    if init_result.offsetEncoding then
      client.offset_encoding = init_result.offsetEncoding
    end
  end,
})

-- qml [for quickshelling]
vim.lsp.config("qmlls", {
  cmd = { "qmlls6" },
  filetypes = { "qml", "qmljs", "qtquick" },
  root_dir = vim.fs.root(0, { "*.qmlproject", ".git", "qmldir" }),
  handlers = {
    ["textDocument/publishDiagnostics"] = function(e, r, c)
      r.diagnostics = vim
        .iter(r.diagnostics)
        :filter(function(d)
          return not d.message:find("not declared as singleton", 1, true)
        end)
        :totable()
      return vim.lsp.diagnostic.on_publish_diagnostics(e, r, c)
    end,
  },
})

vim.lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go" },
  root_dir = vim.fs.root(0, { "go.mod", ".git" }),
})
vim.lsp.enable "gopls"
vim.lsp.enable "rust_analyzer"
vim.lsp.enable "clangd"
-- vim.lsp.enable "jdtls"
vim.lsp.enable "qmlls"
