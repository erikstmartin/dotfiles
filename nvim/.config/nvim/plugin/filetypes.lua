-- Filetypes Neovim doesn't detect on its own, needed by language servers:
-- docker_compose_language_service (yaml.docker-compose), helm_ls (helm),
-- gopls templates (gotmpl)
vim.filetype.add {
  extension = {
    gotmpl = "gotmpl",
  },
  filename = {
    ["docker-compose.yml"] = "yaml.docker-compose",
    ["docker-compose.yaml"] = "yaml.docker-compose",
    ["compose.yml"] = "yaml.docker-compose",
    ["compose.yaml"] = "yaml.docker-compose",
  },
  pattern = {
    ["docker%-compose%..+%.ya?ml"] = "yaml.docker-compose",
    -- Helm templates: yaml/tpl under templates/ in a chart (has Chart.yaml)
    [".*/templates/.+%.ya?ml"] = function(path)
      return vim.fs.root(path, "Chart.yaml") and "helm" or nil
    end,
    [".*/templates/.+%.tpl"] = "helm",
  },
}
