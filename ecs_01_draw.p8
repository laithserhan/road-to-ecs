pico-8 cartridge // http://www.pico-8.com
version 29
__lua__
-- ecs_01_draw v. 1.1
-- by @apa64
-- with tinyecs 1.1 by @katrinakitten https://www.lexaloffle.com/bbs/?tid=39021
-- draw entities

--[[ MIT License

copyright (c) 2020 antti ollilainen

permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "software"), to deal
in the software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the software, and to permit persons to whom the software is
furnished to do so, subject to the following conditions:

the above copyright notice and this permission notice shall be included in all
copies or substantial portions of the software.

the software is provided "as is", without warranty of any kind, express or
implied, including but not limited to the warranties of merchantability,
fitness for a particular purpose and noninfringement. in no event shall the
authors or copyright holders be liable for any claim, damages or other
liability, whether in an action of contract, tort or otherwise, arising from,
out of or in connection with the software or the use or other dealings in the
software.
--]]

-- master container of entities
entities = {}

function _init()
  sfx(0)
  -- create factories
  load_components()
  load_systems()
  -- create entities
  local e_player = mk_player(59, 119)
  local e_thing = mk_thing(30, 30)
  -- store ents in master table
  add(entities, e_player)
  add(entities, e_thing)
end

function _update()
  -- run systems
  s_randpos(entities)
end

function _draw()
  cls(5)
  -- run draw system
  s_draw(entities)
end

-->8
-- #################### entities

-- creates player entity.
function mk_player(x, y)
  local e_player = ent()
  e_player += c_pos(59, 119)
  e_player += c_draw(1)
  return e_player
end

-- creates a funny thing entity.
function mk_thing(x, y)
  local e_thing = ent()
  e_thing += c_pos(30, 30)
  e_thing += c_draw(2)
  e_thing += c_randpos(4, 4)
  return e_thing
end

-->8
-- ################## components

-- creates component factories.
-- factories are wrapped in this to work around scope/visibility (otherwise ecs framework has to be first in file)
function load_components()
  -- x,y position
  c_pos = function(x, y)
    return cmp("pos", { x = x, y = y })
  end

  -- has drawable
  c_draw = function(sprite)
    return cmp("draw", { sprite = sprite })
  end

  -- moves randomly
  c_randpos = function(dxmax, dymax)
    return cmp("randpos", { dxmax = dxmax, dymax = dymax })
  end
end

-->8
-- ##################### systems

-- creates system functions.
function load_systems()
  -- drawing system
  s_draw = sys({"pos", "draw"},
  function(e)
    spr(e.draw.sprite, e.pos.x, e.pos.y)
  end)

  -- move every tick
  s_randpos = sys({"pos", "randpos"},
  function(e)
    e.pos.x = (e.pos.x + rnd(e.randpos.dxmax) - e.randpos.dxmax + 2) % 128
    e.pos.y = (e.pos.y + rnd(e.randpos.dymax) - e.randpos.dymax + 2) % 128
  end)
end

-->8
-- ############### tiny ecs v1.1

-- by katrinakitten
-- entity component system framework

-- entity factory.
-- the created entity table has + and - overridden for adding and removing components, eg. e += c_pos(x,y)
-- t    - table, entity parameters
-- returns an entity as table
function ent(t)
  local cmpt = {}
  t = t or {}
  -- override entity's + and - operators
  setmetatable(t, {
    __index = cmpt,
    __add = function(self, cmp)
      assert(cmp._cn)
      self[cmp._cn] = cmp
      return self
    end,
    __sub = function(self, cn)
      self[cn] = nil
      return self
    end
  })
  return t
end

-- component factory.
-- creates component tables with name and parameter table.
-- cn   - string, the component name, eg. "pos"
-- t    - table, component parameters, eg. {x=x,y=y}
-- returns a component as table
function cmp(cn, t)
  t = t or {}
  t._cn = cn
  return t
end

-- system factory.
-- creates a system function that runs for entity which has specified components.
-- cns  - table, component names for this system, eg. {"pos","phys"}
-- f    - function(e), the system function with param for entity that has the systems, eg. function(e) e.pos.x+=e.phys.xv end
-- returns a system function
function sys(cns, f)
  return function(ents,...)
    for e in all(ents) do
      for cn in all(cns) do
        -- break to label _ if entity does not have component
        if (not e[cn]) goto _
      end
      -- run system function f for entity e
      f(e,...)
      -- for loop breaks to this label
      ::_::
    end
  end
end

__gfx__
00000000000000008a68860000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000aa0008aaa680000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000aa0009999a60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000a88a009779a80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0007700000a88a009798a60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000a22a009779a80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000a8228a09999a60000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000a8228a09bbbb80000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000b0000130500c0500c050090500205003050050500605000000050500505002050080500a0500b0500c0500d0500e0500e0500d0500c0500a05008050080500605006050050500605000000000000000000000
