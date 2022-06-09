pico-8 cartridge // http://www.pico-8.com
version 35
__lua__
-- init

function _init()
	init_game()	
	_draw = draw_game
	_update = update_game
end

function init_game()
	p = {
		x = 24, y = 63,
		vy = 0
	}
	
	points = 0
	
	tbs = {
		new_tb(128),
		new_tb(128+64)
	}
end

function new_tb(x)
	return {
		x=x,y=64+rnd(50)-25,
		gap=30,counted=false
	}
end
-->8
-- draw

function draw_game()
	cls(12)
	
	-- player
	spr(1 + 6*time()%2, p.x,p.y)
	
	-- tubes
	for tb in all(tbs) do
		draw_tb(tb)
	end
	
	-- points
	print(
		"◆"..points,
		2,2, 1)
end

function draw_tb(tb)
	-- upside
		uy = tb.y-4 -tb.gap/2
		spr(3,
						tb.x,uy,
						1,1, -- width/height
						false,true) -- flip x/y
		for i=1,12 do
			spr(4,
							tb.x,uy-8*i)
		end

		-- downside
		dy = tb.y+4 +tb.gap/2
		spr(3,
						tb.x,dy)
		for i=1,12 do
			spr(4,
							tb.x,dy+8*i)
		end
end

-->8
-- update

function update_game()
	p_update()
	
	for tb in all(tbs) do
			tb_update(tb)
			
			if tb_close2player(tb, 2) then
				if not tb_player_in_gap(tb,2) then
					init_game()
				elseif not tb.counted then
					points += 1
					tb.counted = true
				end
			end
	end
end

function p_update()
	-- jump
	if btnp(❎)
				or btnp(🅾️)
				or btnp(⬆️) then
		p.vy = -2.5
		sfx(1)
	end
	
	-- gravity
	p.vy += 0.15

	-- update vertical pos
	p.y += p.vy

	-- limit height
	p.y = min(max(0,p.y),127-8)
end

function tb_update(tb)
	tb.x -= 2
	
	if tb.x <= 0 - 8 then
		tb.x = 128
		tb.y = 64 + rnd(50) -25
		tb.counted = false
	end
end

function tb_close2player(tb, tolerance)
	local p_lside = p.x
	local p_rside = p.x+8
	
	return p_lside <= tb.x+8 -tolerance
				and p_rside >= tb.x +tolerance
end

function tb_player_in_gap(tb, tolerance)
	local p_uside = p.y
	local p_dside = p.y+8
	
	return p_uside >= tb.y-tb.gap/2 -tolerance
				and p_dside <= tb.y+tb.gap/2 +tolerance
end
__gfx__
000000000000000000000000aaaaaaaa0abbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000aaa000aa9aa00abbbbbbb0abbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
007007000aaa55a00aaa55a0abbbbbbb0abbbbb00077770000777700000777000000000000000000000000000000000000000000000000000000000000000000
00077000aa9a75a0a9aa75a0033333300abbbbb00777777707777770077777700000000000000000000000000000000000000000000000000000000000000000
00077000a9aa8888aa9a88880bbbbbb00abbbbb07776677007667770766777770000000000000000000000000000000000000000000000000000000000000000
007007000aaaaa000aaaaa000abbbbb00abbbbb00006660076666677007766000000000000000000000000000000000000000000000000000000000000000000
000000000aaa0000000000000abbbbb00abbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000abbbbb00abbbbb00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
48010000194301c4301d4301f4301f430204301f4301d4301b43019430174301443013430104300e4300d4300a4300943009450084500845009450094500a4500b4500d4500e4500f4500f450114501245013450
