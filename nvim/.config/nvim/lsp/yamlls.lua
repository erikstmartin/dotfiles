local schemas = require("schemastore").yaml.schemas()
-- Kubernetes manifests aren't in SchemaStore. Apply yamlls' built-in
-- Kubernetes schema (plus its CRD catalogue for custom resources) to the usual
-- manifest locations. Elsewhere, opt a file in with a first-line comment (the
-- `kubernetes` shorthand only works here, not in the comment):
--   # yaml-language-server: $schema=https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/v1.34.1-standalone-strict/all.json
-- kustomization.yaml keeps its own SchemaStore schema.
schemas.kubernetes = {
  "**/k8s/**/!(kustomization).{yaml,yml}",
  "**/kubernetes/**/!(kustomization).{yaml,yml}",
  "**/manifests/**/!(kustomization).{yaml,yml}",
  "**/deploy/**/!(kustomization).{yaml,yml}",
  "**/*.k8s.{yaml,yml}",
}

return {
  cmd = { "yaml-language-server", "--stdio" },
  filetypes = { "yaml", "yaml.docker-compose" },
  root_markers = { ".git" },
  settings = {
    yaml = {
      -- Schemas come from SchemaStore.nvim; stop yamlls downloading its own
      -- copy of the catalogue as well
      schemaStore = { enable = false, url = "" },
      schemas = schemas,
      validate = true,
    },
  },
}
