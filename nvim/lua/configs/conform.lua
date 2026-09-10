local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    rust = { "rustfmt" },
    c = { "clang-format" },
    cpp = { "clang-format" },
    qml = { "qmlformat" },
  },
}

return options
