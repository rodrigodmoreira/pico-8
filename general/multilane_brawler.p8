pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- init

function _init()
	game_init()
	_update
	=game_update
	_draw=game_draw
end

-- game init
function game_init()
	plist={
		player:new(),
		player:new(1)
	}
end

-->8
-- update

function game_update()
	sort_by_depth()
	for _,p in ipairs(plist) do
		p:update()
	end
end

-->8
-- draw

function game_draw()
	cls()
	
	map(0,0, 0,0, 16,16)
	
	for _,p in ipairs(plist) do
		p:draw()
	end
	local p1=plist[1]
	print("pos="..p1.pos.x.." "..p1.pos.y.." "..p1.pos.z.." vspd="..p1.vspd, 1,1, 7)
	local axis=get_player_gnd_axis()
	print(axis.x.." "..axis.y, 1,8, 7)
	print("hitpower="..p1.hitpower, 1,16, 7)
	print(p1.hitting, 105,16, 7)
	print(ticks(), 105,32, 7)
end

-->8
-- util

scene_manager = {
	goto_menu=function()
	end
}

player={
	new=function(self, id)
		local o={
			id=id or 0,
			state=0,
			pos=vec2:new(64,64),
			spd=vec2:new(),
			vspd=0,
			hflip=false,
			hitpower=0,
			hitting=false,
			hit_start=0,
			anim={
				{0, 2, 4}, -- idle
				{6, 8, 10, 12}, -- run
				{8} -- jump
			},

			update=function(self)
				local axis=get_player_gnd_axis(self.id)
				local grounded=self.pos.z==0

				-- set state
				if abs(axis.x)+abs(axis.y) > 0 and grounded then
					self.state=1
				elseif not grounded then
					self.state=2
				else
					self.state=0
				end

				-- jump
				if btnp(❎, id) and grounded then
					self.vspd = 8
					sfx(0)
				end
				
				-- hit
				-- on hit start
				if self.hitpower==0 and btn(🅾️, id) then
					self.hit_start=ticks()
					sfx(3)
				end
				-- on hit release
				if self.hitpower~=0 and not btn(🅾️, id) then
					self.hitting=true
					sfx(2)
				end
				if self.hitting and (ticks()-self.hit_start)>=100 then
					self.hitting=false
				end
				self.hitpower=_t(
					btn(🅾️, id),
					min(self.hitpower+1,10),
					0
				)
				
				-- set sprite orientation
				if (axis.x < 0) self.hflip=true
				if (axis.x > 0) self.hflip=false
				
				-- state machine
				if self.state==3 then
					
				end

				-- update position
				self.pos.x=clamp(
					self.pos.x+2*axis.x,
					0,127
				)
				self.pos.y=clamp(
					self.pos.y+2*axis.y,
					56,127
				)
				
				-- update fake vertical spd and pos
				if not grounded then
					self.vspd = self.vspd-1
				end
				self.pos.z = clamp(
					self.pos.z+self.vspd,
					0,100)
			end,

			draw=function(self)
				local p=self.pos
				
				-- shadow
				local z_hoff=min(7,p.z/5)
				local z_voff=min(2,p.z/10)
				ovalfill(
					p.x-8+z_hoff,p.y-2+z_voff,
					p.x+8-z_hoff,p.y+2-z_voff, 1)
				
				-- player sprite
				local frame_list=self.anim[self.state+1]
				local frame=frame_list[get_frame_id(#frame_list, 0.1)+1]
				spr(frame,
					p.x-8,p.y-16-p.z,
					2,2, self.hflip)
				if (self.id==0) print("st="..frame,105,1,7)

				-- bat sprite
				if self.hitting then
					spr(34+2*get_frame_id(5, 0.1, self.hit_start), --get_frame_id(6, 10, self.hit_start)
						p.x-8,p.y-16-p.z,
						2,2, self.hflip)
				else
					spr(32,
						p.x-8,p.y-16-p.z,
						2,2, self.hflip)
				end

				-- power meter
				if (self.hitpower~=0) rectfill(p.x+8,p.y-p.z, p.x+10,p.y-p.z-2*self.hitpower, 8)
			end
		}
		return o
	end
}

function get_player_gnd_axis(id)
	id=id or 0
	local axis=vec2:new()
	axis.x = _t(btn(⬅️, id),-1,0) + _t(btn(➡️,id), 1,0)
	axis.y = _t(btn(⬆️, id),-1,0) + _t(btn(⬇️,id), 1,0)
	return axis
end

vec2={
	new=function(self,x,y,z)
		local o={
			x=x or 0,
			y=y or 0,
			z=z or 0}
		return o
	end
}

function ticks()
	return flr(time()*100)
end

-- ternary
function _t(exp, a,b)
	return exp and a or b
end

function clamp(v, mi, ma)
	return max(min(v, ma), mi)
end

function get_frame_id(_max, spd, offset)
	return flr((ticks()-(offset or 0))*spd)%_max
end

--[[
function get_frame_id(_max, spd, width, height)
	local lid=width*(flr(time()*spd)%_max)
	return height*flr(lid/128)+lid%128
end
]]

function sort_by_depth()
	local res={}
	-- bubblesort cause im lazy right now
	for i=1,#plist-1 do
		for j=1, #plist-1 do
			local current=plist[j]
			local next=plist[j+1]
			if current.pos.y>next.pos.y then
				plist[j]=next
				plist[j+1]=current
			end
		end
	end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000071111000000000000000000000000000711110000000000000000000000
00000711110000000000071111000000000000000000000000000711110000000007771111000000000007111100000000077711110000000000000000000000
000777111100000000077711110000000000071111000000000777111100000000000ff5f5000000000777111100000000000ff5f50000000000000000000000
00000ff5f500000000000dd5d5000000000777111100000000000dd5d500000000000fffff00000000000dd5d500000000000fffff0000000000000000000000
00000fffff00000000000ff5f500000000000ff5f500000000000ff5f5000000000008888800000000000ff5f500000000000888880000000000000000000000
000008888800000000000fffff00000000000fffff00000000000fffff000000000008888800000000000fffff00000000000888880000000000000000000000
00000888880000000000088888000000000008888800000000000888880000000000088888000000000008888800000000000888880000000000000000000000
00000888880000000000088888000000000008888800000000000888880000000000088888000000000008888800000000000888880000000000000000000000
00000888880000000000088888000000000008888800000000000888880000000000088888000000000008888800000000000888880000000000000000000000
00000888880000000000088888000000000008888800000000000888880000000000088888000000000008888800000000000888880000000000000000000000
00000888880000000000088888000000000008888800000000000888880000000000088811100000000008888800000000000111180000000000000000000000
00000111110000000000011188000000000008888800000000000111110000000001f11111100000000001888100000000001f11110000000000000000000000
00000111110000000000011111000000000001111100000000000111110000000001f1100ff00000000001111100000000001f1ff00000000000000000000000
00000110110000000000011011000000000001101100000000000110110000000001000001110000000001101100000000001001110000000000000000000000
00000ff0ff00000000000ff0ff00000000000ff0ff00000000000ff0ff000000000000000000000000000ff0ff00000000000000000000000000000000000000
00000111111000000000011111100000000001111110000000000111111000000000000000000000000001111110000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000550000000000000050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000555000000000000500000000000000000000000000000000000000000000055000000000000005500000000000000550000000000000000
00000000000000000055500000000000500000000000000000000000000000000000000000005555000000000000555500000000000055550000000000000000
00000000000000000005550000000000500000000000000000000000000000000000000000555555000000000055555500000000005555000000000000000000
00000000000000000000557000000000550000000000000000000000000000000000000055555555000000005555005500000000555500000000000000000000
00000000000000000000077500000000055000550000000000000057700000000000005755005555000000575500005500000057550000000000000000000000
00000000000000000000005500000000055550770000000000000057555000000000005750055555000000577000005000000057700000000000000000000000
00000000000000000000000000000000005555550000000000050000555550000000000000555550000000000000050000000000000000000000000000000000
00000550000000000000000000000000000555550000000000005555555555500000500055555500000000000000000000000000000000000000000000000000
00007750000000000000000000000000000005550000000000000055555555500000055555550000000000000000000000000000000000000000000000000000
00055700000000000000000000000000000000000000000000000000055555000000000000000000000000000000000000000000000000000000000000000000
00555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
05550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002222222222222222ddd2dddddddddddd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002222222222222222ddd2dddddddddddd
000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000222222221222222222222222dddddddd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002222222222222222dddd222ddddddddd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002222222212222222dddddddddddddddd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002222222212222222dddddddddddddddd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002222222211222222dddddddddddddddd
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000002222222211111111dddddddddddddddd
__map__
fcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fcfcfcfcfcfcfcfcfcfcfcfcfcfcfcfc00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fdfdfdfdfdfdfdfdfdfdfdfdfdfdfdfd00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
fefefefefefefefefefefefefefefefe00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
ffffffffffffffffffffffffffffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000c0500e050100501105013050180001c000180001c000180001c000180001c000180001c000180001c000180001c000180001c000180001c000180001c000180001c000180001c000180001c00018000
910f00040c77300000117730000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
011400002f5522f555180001800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
490b00000074402741047410274500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000