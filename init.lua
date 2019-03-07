minetest.register_craftitem("animachines:leather", {
	description = "Leather",
	inventory_image = "animachines_leather.png",
})

minetest.register_craftitem("animachines:raw_beef", {
	description = "Raw Beef",
	inventory_image = "animachines_raw_beef.png",
})

minetest.register_craftitem("animachines:cooked_beef", {
	description = "Cooked Beef",
	inventory_image = "animachines_cooked_beef.png",
	on_use = minetest.item_eat(15),
})

minetest.register_craft({
	type = 'cooking',
	output = 'animachines:cooked_beef',
	recipe = 'animachines:raw_beef',
	cooktime = 20,
})

local function allow_metadata_inventory_put(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if listname == "inp" then
		return stack:get_count()
	elseif listname == "hdd" then
		return 0
	elseif listname == "outp" then
		return 0
	end
end

local function allow_metadata_inventory_move(pos, from_list, from_index, to_list, to_index, count, player)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local stack = inv:get_stack(from_list, from_index)
	return allow_metadata_inventory_put(pos, to_list, to_index, stack, player)
end

local function allow_metadata_inventory_take(pos, listname, index, stack, player)
	if minetest.is_protected(pos, player:get_player_name()) then
		return 0
	end
	return stack:get_count()
end

minetest.register_node("animachines:cow", {
	description = "Cow Machine",
	tiles = {
		"animachines_cow_top.png",       -- Top
		"animachines_cow_bottom.png",    -- Bottom
		"animachines_cow_rside.png",     -- Right Side
		"animachines_cow_lside.png",     -- Left Side
		"animachines_cow_back.png",      -- Back
		"animachines_cow_front.png"      -- Front
	},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	node_box = {
		type = "fixed",
		fixed = {
			{-0.3125, -0.5, 0.5, 0.3125, 0.125, -0.125},
			{-0.4375, -0.0625, 0.0625, -0.3125, 0.125, -0.125},
			{0.4375, -0.0625, 0.0625, 0.3125, 0.125, -0.125},
		}
	},
	groups = {dig_immediate = 3, oddly_diggable_by_hand = 3},
	stack_max = 1,

	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_string("formspec", cow_formspec(item_percent))
		local inv = meta:get_inventory()
		inv:set_size('inp', 1)
		inv:set_size('hdd', 1)
		inv:set_size('outp', 1)
	end,
	allow_metadata_inventory_put = allow_metadata_inventory_put,
	allow_metadata_inventory_move = allow_metadata_inventory_move,
	allow_metadata_inventory_take = allow_metadata_inventory_take,


	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local inplist = inv:get_list("inp")
		local hddlist = inv:get_list("hdd")
		local outplist = inv:get_list("outp")
		local xy = 10 - hddlist[1]:get_count()
		if hddlist[1]:get_count() >= 10 then
			if stack:get_name() == "farming:wheat" then
				inv:add_item("outp", {name="animachines:raw_beef", count=1, wear=0, metadata=""})
				inplist[1]:take_item()
				hddlist[1]:take_item(10)
				inv:set_stack("inp", 1, inplist[1])
				inv:set_stack("hdd", 1, hddlist[1])
			end
			if stack:get_name() == "default:junglegrass" then
				inv:add_item("outp", {name="animachines:leather", count=1, wear=0, metadata=""})
				inplist[1]:take_item()
				hddlist[1]:take_item(10)
				inv:set_stack("inp", 1, inplist[1])
				inv:set_stack("hdd", 1, hddlist[1])
			end
		else
			if stack:get_name() == "default:grass_1" then
				if (stack:get_count() + hddlist[1]:get_count()) >= 10 then
					inv:add_item("hdd", {name="default:grass_1", count=xy, wear=1, metadata=""})
					inplist[1]:take_item(xy)
					inv:set_stack("inp", 1, inplist[1])
				else
					inv:add_item("hdd", {name="default:grass_1", count=stack:get_count(), wear=1, metadata=""})
					inplist[1]:clear()
					inv:set_stack("inp", 1, inplist[1])
				end
			end
		end
	end,

})

-- Formspect

function cow_formspec(item_percent)
	return "size[8,6.5]"..
		"list[context;inp;2.00,0.5;1,1;]"..
		"image[3.50,0.5;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
		"list[context;outp;5.00,0.5;1,1;]"..
		"list[current_player;main;0,2.25;8,1;]"..
		"list[current_player;main;0,3.5;8,3;8]"..
		"listring[context;outp]"..
		"listring[current_player;main]"..
		"listring[context;inp]"..
		"listring[current_player;main]"..
		"listring[context;hdd]"..
		"listring[current_player;main]"..
		default.get_hotbar_bg(0, 2.25)
end
