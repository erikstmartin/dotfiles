-- require("luasnip.session.snippet_collection").clear_snippets "go"

local ls = require "luasnip"

local s = ls.snippet

local fmt = require("luasnip.extras.fmt").fmt
local i = ls.insert_node

ls.add_snippets("go", {
  s("ifer", fmt("if err != nil {{\n\t{}\n}}", { i(1, "") })),
})
