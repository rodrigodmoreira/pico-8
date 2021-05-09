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

  local ray = vec2:new(200,0):rotate(player.angle)
  local px = player.pos.x
  local py = player.pos.y
  line(px, py, px + ray.x, py + ray.y, 8)
  pset(px, py, 10)
end

function draw_raycast()
  -- for each vertical strip
  for i=0, 128, 4 do
    rectfill(0,0, 30,10, 1)
    print(player.angle, 1,1, 10)
    local px = player.pos.x
    local py = player.pos.y
    local ray = vec2:new(1, 0):rotate(player.angle)
    local phi = player.angle

    -- retrieve increment for dda algorithm
    -- https://lodev.org/cgtutor/images/raycastdelta.gif
    local tan_phi = sin(phi)/cos(phi)
    local dx = vec2:new(gridmap.cellw, tan_phi * gridmap.cellw)
    local dy = vec2:new(gridmap.cellh, gridmap.cellh / tan_phi)

    local firstdx = vec2:new((flr(px)+1-px), tan_phi * (flr(px)+1-px))
    local firstdy = vec2:new((flr(py)+1-py), (flr(py)+1-py) / tan_phi)

    -- find first hit along VERTICAL lines -----------------------------------------------------------------------------------------------------------
    local xstart_point = player.pos
    local xhit = false
    if firstdx:length() > 0 and firstdx:length() < dx:length() then
      local check_point = xstart_point:add(firstdx)
      xstart_point = check_point
      local tile_coord = check_point:flr():add(vec2:new(1,1))
      if gridmap.map[tile_coord.x-1] then
        if gridmap.map[tile_coord.x-1][tile_coord.y-1] ~= 0 then
          xhit = true
        end
      end
    end
    -- if not next tile, keep searching foward
    while not xhit and not (xstart_point:sub(player.pos):length() > player.max_ray) do
      local check_point = xstart_point:add(dx)
      xstart_point = check_point
      local tile_coord = check_point:flr():add(vec2:new(1,1))
      if gridmap.map[tile_coord.x-1] then
        if gridmap.map[tile_coord.x-1][tile_coord.y-1] ~= 0 then
          xhit = true
        end
      end
    end

    -- find first hit along HORIZONTAL lines -----------------------------------------------------------------------------------------------------------
    local ystart_point = player.pos
    local yhit = false
    if firstdy:length() > 0 and firstdy:length() < dy:length() then
      local check_point = ystart_point:add(firstdy)
      ystart_point = check_point
      local tile_coord = check_point:flr():add(vec2:new(1,1))
      if gridmap.map[tile_coord.x-1] then
        if gridmap.map[tile_coord.x-1][tile_coord.y-1] ~= 0 then
          yhit = true
        end
      end
    end
    -- if not next tile, keep searching foward
    while not yhit and not (ystart_point:sub(player.pos):length() > player.max_ray) do
      local check_point = ystart_point:add(dy)
      ystart_point = check_point
      local tile_coord = check_point:flr():add(vec2:new(1,1))
      if gridmap.map[tile_coord.x-1] then
        if gridmap.map[tile_coord.x-1][tile_coord.y-1] ~= 0 then
          yhit = true
        end
      end
    end

    -- find closest point between the two --------------------------------------------------------------------------------------------------------------
    local xcloser = xstart_point:sub(player.pos):length() > ystart_point:sub(player.pos):length()
    local hit_point = xcloser and xstart_point or ystart_point
    
    -- draw vertical line proportional to the distance between player and point ------------------------------------------------------------------------
    local height = hit_point:sub(player.pos):length()
    line(i, 63-height/2, i, 63+height/2, xcloser and 6 or 5)
  end
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
