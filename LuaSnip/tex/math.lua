local ls = require 'luasnip'
local s = ls.snippet
local sn = ls.snippet_node
local isn = ls.indent_snippet_node
local t = ls.text_node
local i = ls.insert_node
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
local r = ls.restore_node
local events = require 'luasnip.util.events'
local ai = require 'luasnip.nodes.absolute_indexer'
local extras = require 'luasnip.extras'
local l = extras.lambda
local rep = extras.rep
local p = extras.partial
local m = extras.match
local n = extras.nonempty
local dl = extras.dynamic_lambda
local fmt = require('luasnip.extras.fmt').fmt
local fmta = require('luasnip.extras.fmt').fmta
local conds = require 'luasnip.extras.expand_conditions'
local postfix = require('luasnip.extras.postfix').postfix
local types = require 'luasnip.util.types'
local parse = require('luasnip.util.parser').parse_snippet
local ms = ls.multi_snippet
local autosnippet = ls.extend_decorator.apply(s, { snippetType = 'autosnippet' })

-- [
-- personal imports
-- ]
local function add_require_path(dir)
  dir = dir:gsub('\\', '/') -- Normalize
  if not package.path:find(dir, 1, true) then
    package.path = dir .. '/?.lua;' .. package.path
  end
end

add_require_path(tostring(os.getenv 'HOME') .. '/.config/nvim/LuaSnip/tex/utils') -- Linux form
add_require_path(tostring(os.getenv 'UserProfile') .. '\\.config\\nvim\\LuaSnip\\tex\\utils') -- Windows form (normalized automatically)

-- local my_module = require("my_module")  -- Will look for my_module.lua in that dir
local tex = require 'conditions'
local line_begin = require('luasnip.extras.conditions.expand').line_begin

local generate_matrix = function(args, snip)
  local rows = tonumber(snip.captures[2])
  local cols = tonumber(snip.captures[3])
  local nodes = {}
  local ins_indx = 1
  for j = 1, rows do
    table.insert(nodes, r(ins_indx, tostring(j) .. 'x1', i(1)))
    ins_indx = ins_indx + 1
    for k = 2, cols do
      table.insert(nodes, t ' & ')
      table.insert(nodes, r(ins_indx, tostring(j) .. 'x' .. tostring(k), i(1)))
      ins_indx = ins_indx + 1
    end
    table.insert(nodes, t { '\\\\', '' })
  end
  -- fix last node.
  nodes[#nodes] = t '\\\\'
  return sn(nil, nodes)
end

-- update for cases
local generate_cases = function(args, snip)
  local rows = tonumber(snip.captures[1]) or 2 -- default option 2 for cases
  local cols = 2 -- fix to 2 cols
  local nodes = {}
  local ins_indx = 1
  for j = 1, rows do
    table.insert(nodes, r(ins_indx, tostring(j) .. 'x1', i(1)))
    ins_indx = ins_indx + 1
    for k = 2, cols do
      table.insert(nodes, t ' & ')
      table.insert(nodes, r(ins_indx, tostring(j) .. 'x' .. tostring(k), i(1)))
      ins_indx = ins_indx + 1
    end
    table.insert(nodes, t { '\\\\', '' })
  end
  -- fix last node.
  table.remove(nodes, #nodes)
  return sn(nil, nodes)
end

M = {
  -- Math modes
  autosnippet(
    { trig = 'lm', name = '$..$', dscr = 'inline math' },
    fmta(
      [[
    \(<>\)<>
    ]],
      { i(1), i(0) }
    )
  ),
  --note: the following have the first group ahead by 1 char as autopairs brings you back 1 char.
  autosnippet(
    { trig = 'lr()', name = '\\left(\\right)', dscr = 'inline math' },
    fmta(
      [[
    \left(\<>right)<>
    ]],
      { i(1), i(0) }
    ),
    { condition = tex.in_math, show_condition = tex.in_math }
  ),
  autosnippet(
    { trig = 'lr[]', name = '\\left[\\right]', dscr = 'left right square brackets' },
    fmta(
      [[
    \left[\<>right]<>
    ]],
      { i(1), i(0) }
    ),
    { condition = tex.in_math, show_condition = tex.in_math }
  ),
  autosnippet(
    { trig = 'lr{}', name = '\\left\\{\\right\\}', dscr = 'left right braces' },
    fmta(
      [[
    \left\{\<>right\}<>
    ]],
      { i(1), i(0) }
    ),
    { condition = tex.in_math, show_condition = tex.in_math }
  ),
  autosnippet(
    { trig = 'lr|', name = '\\left|\\right|', dscr = 'left right abs val' },
    fmta(
      [[
    \left|<>\right|<>
    ]],
      { i(1), i(0) }
    ),
    { condition = tex.in_math, show_condition = tex.in_math }
  ),
  autosnippet(
    { trig = 'lr\\|', name = '\\left\\|\\right\\|', dscr = 'left right norm' },
    fmta(
      [[
    \left\|<>\right\|<>
    ]],
      { i(1), i(0) }
    ),
    { condition = tex.in_math, show_condition = tex.in_math }
  ),
  autosnippet(
    { trig = 'lr<', name = '< >', dscr = 'left right angle brackes' },
    fmta(
      [[
    \langle<>\rangle<>
    ]],
      { i(1), i(0) }
    ),
    { condition = tex.in_math, show_condition = tex.in_math }
  ),
  autosnippet(
    { trig = 'dm', name = '\\[...\\]', dscr = 'display math' },
    fmta(
      [[ 
    \[ 
    <>
    \]
    <>]],
      { i(1), i(0) }
    ),
    { condition = line_begin, show_condition = tex.show_line_begin }
  ),
  -- autosnippet({ trig = 'sqrt' }, t '\\sqrt', { condition = tex.in_math }),
  autosnippet(
    { trig = 'ali', name = 'align(|*|ed)', dscr = 'align math' },
    fmta(
      [[ 
    \begin{align<>}
    <>
    \end{align<>}
    ]],
      { c(1, { t '*', t '', t 'ed' }), i(2), rep(1) }
    ), -- in order of least-most used
    { condition = line_begin, show_condition = tex.show_line_begin }
  ),

  autosnippet(
    { trig = '==', name = '&= align', dscr = '&= align' },
    fmta(
      [[
    &<> <> \\
    ]],
      { c(1, { t '=', t '\\leq', t '\\geq', i(1) }), i(2) }
    ),
    { condition = tex.in_align, show_condition = tex.in_align }
  ),

  autosnippet(
    { trig = 'gat', name = 'gather(|*|ed)', dscr = 'gather math' },
    fmta(
      [[ 
    \begin{gather<>}
    <>
    \end{gather<>}
    ]],
      { c(1, { t '*', t '', t 'ed' }), i(2), rep(1) }
    ),
    { condition = line_begin, show_condition = tex.show_line_begin }
  ),

  autosnippet(
    { trig = 'eqn', name = 'equation(|*)', dscr = 'equation math' },
    fmta(
      [[
    \begin{equation<>}
    <>
    \end{equation<>}
    ]],
      { c(1, { t '*', t '' }), i(2), rep(1) }
    ),
    { condition = line_begin, show_condition = tex.show_line_begin }
  ),

  -- Matrices and Cases
  s(
    { trig = '([bBpvV])mat(%d+)x(%d+)([ar])', name = '[bBpvV]matrix', dscr = 'matrices', regTrig = true, hidden = true },
    fmta(
      [[
    \begin{<>}<>
    <>
    \end{<>}]],
      {
        f(function(_, snip)
          return snip.captures[1] .. 'matrix'
        end),
        f(function(_, snip)
          if snip.captures[4] == 'a' then
            out = string.rep('c', tonumber(snip.captures[3]) - 1)
            return '[' .. out .. '|c]'
          end
          return ''
        end),
        d(1, generate_matrix),
        f(function(_, snip)
          return snip.captures[1] .. 'matrix'
        end),
      }
    ),
    { condition = tex.in_math, show_condition = tex.in_math }
  ),
  autosnippet(
    { trig = '([ZN])(%S+)([ZN])', name = 'Z mod n', descr = 'residue classes set', regTrig = true },
    fmta(
      [[
	\mathbb{<>} / <>\mathbb{<>}
	]],
      {
        f(function(_, snip)
          return snip.captures[1]
        end),
        f(function(_, snip)
          return snip.captures[2]
        end),
        f(function(_, snip)
          return snip.captures[3]
        end),
      }
    ),
    { condition = tex.in_math, show_condition = tex.in_math }
  ),

  autosnippet(
    { trig = '(%d?)cases', name = 'cases', dscr = 'cases', regTrig = true, hidden = true },
    fmta(
      [[
    \begin{cases}
    <>
    \end{cases}
    ]],
      { d(1, generate_cases) }
    ),
    { condition = tex.in_math, show_condition = tex.in_math }
  ),
}

return M
