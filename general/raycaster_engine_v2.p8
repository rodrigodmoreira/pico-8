pico-8 cartridge // http://www.pico-8.com
version 27
__lua__
-- init

function _init()
  gridmap = {
    cellw=8, cellh=8,
    map={
      {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
      {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
      {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
      {1,0,0,0,0,1,1,0,0,1,1,0,0,0,0,1},
      {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
      {1,0,0,1,0,0,0,0,0,0,0,0,1,0,0,1},
      {1,0,0,1,0,0,0,0,0,0,0,0,1,0,0,1},
      {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
      {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
      {1,0,0,1,0,0,0,0,0,0,0,0,1,0,0,1},
      {1,0,0,1,0,0,0,0,0,0,0,0,1,0,0,1},
      {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
      {1,0,0,0,0,1,1,0,0,1,1,0,0,0,0,1},
      {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
      {1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1},
      {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
    }
  }

  player = {
    pos=vec2:new(63,63),
    angle=0,
    turn_spd=2,
    max_ray=200,
    spd=10
  }

  cam = {
    topdown=true
  }

  ray_hits = {}
  for i=0, 128 do
    add(ray_hits, vec2:new())
  end
end

-->8
-- update

function _update60()
  -- turn
  if (btn(0)) player.angle = player.angle + player.turn_spd
  if (btn(1)) player.angle = player.angle - player.turn_spd
  -- walk
  if (btn(2)) player.pos = player.pos:add(vec2:new(cam.topdown and 1 or player.spd,0):rotate(player.angle))
  if (btn(3)) player.pos = player.pos:sub(vec2:new(cam.topdown and 1 or player.spd,0):rotate(player.angle))

  if (btnp(4)) cam.topdown = not cam.topdown

  cast_rays()
end

function cast_rays()
  -- for each vertical strip
  for i=0, 128, 4 do
    local px = player.pos.x
    local py = player.pos.y
    local ray = vec2:new(1, 0):rotate(player.angle)
    local phi = player.angle

    -- retrieve increment for dda algorithm
    -- https://lodev.org/cgtutor/images/raycastdelta.gif
    -- local dv = gridmap.cellw / cos(phi) -- increment for vertical lines (vector lengths)
    -- local dh = gridmap.cellh / sin(phi) -- increment for horizontal lines (vector lengths)

    -- find first hit along VERTICAL lines -----------------------------------------------------------------------------------------------------------
    local tan_phi = sin(phi)/cos(phi)
    local dv_x = gridmap.cellw
    local dv_y = dv_x * tan_phi

    -- latest point checked on loop
    local vx_point = px -- player pos x
    local vy_point = py -- player pos y
  
    -- flag if latest point is a wall hit
    local vhit = false
    while not vhit and length(vx_point-px, vy_point-py) <= player.max_ray do
      local i_x = dv_x
      local i_y = dv_y
      -- correct increment for first cell (correct player somewhere inside the cell)
      if vx_point == px and vy_point == py then
        i_x = (gridmap.cellw - px%gridmap.cellw)
        i_y = i_x * tan_phi
      end

      vx_point = vx_point + i_x
      vy_point = vy_point + i_y

      local tile_coord_x = flr(vx_point/gridmap.cellw)
      local tile_coord_y = flr(vy_point/gridmap.cellh)
      -- check if next cell after vertical line is wall
      if gridmap.map[tile_coord_x+1+sgn(i_x)] then
        if gridmap.map[tile_coord_x+1+sgn(i_x)][tile_coord_y+1] ~= 0 then
          vhit = true
        end
      end
    end

    -- find first hit along HORIZONTAL lines -----------------------------------------------------------------------------------------------------------
    local dh_y = gridmap.cellh
    local dh_x = dh_y / tan_phi

    local hx_point = px -- player pos x
    local hy_point = py -- player pos y

    -- flag if latest point is a wall hit
    local hhit = false
    while not hhit and length(hx_point-px, hy_point-py) <= player.max_ray do
      local i_x = dh_x
      local i_y = dh_y
      -- correct increment for first cell (correct player somewhere inside the cell)
      if hx_point == px and hy_point == py then
        i_x = (gridmap.cellw - px%gridmap.cellw)
        i_y = i_x * tan_phi
      end

      hx_point = hx_point + i_x
      hy_point = hy_point + i_y

      local tile_coord_x = flr(hx_point/gridmap.cellw)
      local tile_coord_y = flr(hy_point/gridmap.cellh)
      -- check if next cell after vertical line is wall
      if gridmap.map[tile_coord_x+1+sgn(i_x)] then
        if gridmap.map[tile_coord_x+1+sgn(i_x)][tile_coord_y+1] ~= 0 then
          hhit = true
        end
      end
    end

    -- find closest point between the two --------------------------------------------------------------------------------------------------------------
    local vp_length = length(vx_point-px, vy_point-py)
    local hp_length = length(hx_point-px, hy_point-py)
    local v_is_closer = vp_length > hp_length
    
    ray_hits[i+1].x = v_is_closer and vx_point or hx_point
    ray_hits[i+1].y = v_is_closer and vy_point or hy_point
  end 
end

function print_cls(str, x,y, clr)
  rectfill(x,y, x+6*#str, y+6, 1)
  print(str, x,y, clr)
end

-->8
-- draw

function _draw()
  cls(1)
  if cam.topdown then
    draw_topdown()

    print(player.pos.x.." "..player.pos.y,1,1, 10)
    print(player.angle,7,7, 10)
  else
    draw_raycast()
  end
end

function draw_topdown()
  for i=1, 16 do
    for j=1, 16 do
      if (gridmap.map[i][j] ~= 0) rectfill((i-1)*8, (j-1)*8, i*8, j*8, 6)
    end
  end

  local px = player.pos.x
  local py = player.pos.y

  for i=0, 128 do
    line(px, py, px + ray_hits[i+1].x, py + ray_hits[i+1].y, 8)
  end
  pset(px, py, 10)
end

function draw_raycast()
  for _, ray in pairs(ray_hits) do
    local height = ray:length()
    line(i, 63-height*0.5, i, 63+height*0.5, xcloser and 6 or 5)
  end
end

function length(x,y)
  return sqrt(x*x + y*y)
end

-->8
-- utils

vec2 = {
  new=function(self, x,y)
    local o = {x=x or 0, y=y or 0}
    setmetatable(o, { __index=self })
    return o
  end,
  rotate=function(self, deg)
    local rot = deg/360
    return vec2:new(
      self.x*cos(rot) - self.y*sin(rot),
      self.x*sin(rot) + self.y*cos(rot)
    )
  end,
  length=function(self)
    return sqrt(self.x*self.x + self.y*self.y)
  end,
  add=function(self, vec)
    return vec2:new(self.x + vec.x, self.y + vec.y)
  end,
  sub=function(self, vec)
    return vec2:new(self.x - vec.x, self.y - vec.y)
  end,
  flr=function(self)
    return vec2:new(flr(self.x), flr(self.y))
  end
}

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
