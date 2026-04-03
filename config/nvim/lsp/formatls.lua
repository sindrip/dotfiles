return {
  init_options = {
    formatters_by_ft = {
      javascript = {
        { "biome" },
        { "source.addMissingImports", "source.organizeImports", "prettier" },
      },
      javascriptreact = {
        { "biome" },
        { "source.addMissingImports", "source.organizeImports", "prettier" },
      },
      typescript = {
        { "biome" },
        { "source.addMissingImports", "source.organizeImports", "prettier" },
      },
      typescriptreact = {
        { "biome" },
        { "source.addMissingImports", "source.organizeImports", "prettier" },
      },
      json = {
        { "biome" },
        { "prettier" },
      },
      css = {
        { "biome" },
        { "prettier" },
      },
      lua = {
        { "stylua" },
      },
      go = {
        { "source.organizeImports", "source.format" },
      },
    },
  },
}
