return {
  {
    "templ",
    for_cat = "go",
    lsp = {
      filetypes = { "templ" },
    },
  },
  {
    "tailwindcss",
    for_cat = "web",
    lsp = {
      filetypes = { "aspnetcorerazor", "astro", "astro-markdown", "blade", "clojure", "django-html", "htmldjango", "edge", "eelixir", "elixir", "ejs", "erb", "eruby", "gohtml", "gohtmltmpl", "haml", "handlebars", "hbs", "html", "htmlangular", "html-eex", "heex", "jade", "leaf", "liquid", "markdown", "mdx", "mustache", "njk", "nunjucks", "php", "razor", "slim", "twig", "css", "less", "postcss", "sass", "scss", "stylus", "sugarss", "javascript", "javascriptreact", "reason", "rescript", "typescript", "typescriptreact", "vue", "svelte", "templ" },
    },
  },
  {
    "ts_ls",
    for_cat = "web",
    lsp = {
      filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
      },
    },
  },
  {
    "htmx",
    for_cat = "web",
    lsp = {
      filetypes = { "aspnetcorerazor", "astro", "astro-markdown", "blade", "clojure", "django-html", "htmldjango", "edge", "eelixir", "elixir", "ejs", "erb", "eruby", "gohtml", "gohtmltmpl", "haml", "handlebars", "hbs", "html", "htmlangular", "html-eex", "heex", "jade", "leaf", "liquid", "mdx", "mustache", "njk", "nunjucks", "php", "razor", "slim", "twig", "javascript", "javascriptreact", "reason", "rescript", "typescript", "typescriptreact", "vue", "svelte", "templ" },
    },
  },
  {
    "cssls",
    for_cat = "web",
    lsp = {
      filetypes = { "css", "scss", "less" },
    },
  },
  {
    "eslint",
    for_cat = "web",
    lsp = {
      filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx", "vue", "svelte", "astro" },
    },
  },
  {
    "jsonls",
    for_cat = "web",
    lsp = {
      filetypes = { "json", "jsonc" },
    },
  },
  {
    "html",
    for_cat = "web",
    lsp = {
      filetypes = { 'html', 'twig', 'hbs', 'templ' },
      settings = {
        html = {
          format = {
            templating = true,
            wrapLineLength = 120,
            wrapAttributes = 'auto',
          },
          hover = {
            documentation = true,
            references = true,
          },
        },
      },
    },
  },
}
