local S = minetest.get_translator(minetest.get_current_modname())

-- variable global pour choisir le temp d'un tick
local tick = 1
-- Code pour créer un bloc avec une texture (image imageface.png)
minetest.register_node("mcl2_clocks:redstone_clock_block", {
    description = S("Horloge Redstone"),
    drawtype = "nodebox",
    paramtype = "light",
    paramtype2 = "facedir",
    tiles = {
        "default_stone.png^mcl2_clocks_redstone_clock_block.png"
    },
    stack_max = 64,
    groups = {cracky = 3},
    is_ground_content = false,
    _mcl_blast_resistance = 6,
    _mcl_hardness = 5,
	--ajout de la valeur du bloc
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("number", 5)
		meta:set_int("timer", 1)
		meta:set_int("bloucle", "on")
		meta:set_string("redstone_state", "off")
	end,
	on_rightclick = function(pos, node, player, itemstack, pointed_thing) -- Fonction pour ouvrir le formulaire lors d'un clic droit et ajout la valeur actuelle du bloc
		--recuperer la valeur actuelle du bloc
		local meta = minetest.get_meta(pos)
		local number = meta:get_int("number")
		--ouvrir le formulaire et ajoute les cordonner du bloc dans le formulaire
		minetest.show_formspec(player:get_player_name(), "redstone_clocks:form",
			"size[6,3.476]" ..
			"field[0.375,1.25;5.25,0.8;number;" .. minetest.formspec_escape(S("Nombre :")) .. ";" .. number .. "]" ..
			--cordonner du bloc
			"field[0.375,20.25;5.25,0.8;pos;" .. minetest.formspec_escape(S("Position :")) .. ";" .. minetest.pos_to_string(pos) .. "]" ..
			"button[1.5,2.3;3,0.8;submit;" .. minetest.formspec_escape(S("Soumettre")) .. "]"
		)
	end,
	--ajoute une clock pour en fonction du nombre du bloc et regarde la valeur du bloc change et envoie un message dans le chat 1 unité de temps de temp dans le bloc = 1 tick de temp
	--je veut que ca ce lance au demarage du serveur
	on_timer = function(pos, elapsed)
		local meta = minetest.get_meta(pos)
		local number = meta:get_int("number")
		--ajoute 1 au timer
		meta:set_int("timer", meta:get_int("timer") + 1)
		if meta:get_string("redstone_state") == "on" then
			mesecon.receptor_off(pos, mesecon.rules.alldirs)
			meta:set_string("redstone_state", "off")
		end
		--envoie un message dans le chat pour dire que le timer a ete mis a jour
		--si le timer est egale ou superieur a la valeur du bloc alors se remet a 0 et envoie un message dans le chat
		if meta:get_int("timer") >= number then
			meta:set_int("timer", 0)
			meta:set_string("redstone_state", "on")
			mesecon.receptor_on(pos, mesecon.rules.alldirs)
		end
		
		--met a jour le timer en fonction de la valeur du bloc
		
		
		--envoie un signal redstone pour allumer la redstone
		--si la restone est allumer alors elle envoie un signal pour allumer la redstone ou l'eteindre

		return true
	end,
	--ajoute un pour le temp d'un tick
	on_construct = function(pos)
		minetest.get_node_timer(pos):start(tick)
	end


})

--ajout du formulaire apelle la fonction pour modifier le meta du bloc
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "redstone_clocks:form" then
		if fields.quit then
			return
		end
		--recuperer la position du bloc qui est dans le formulaire
		local pos = minetest.string_to_pos(fields.pos)
		local node = minetest.get_node(pos)
		if node.name == "redstone_clocks:redstone_clock_block" then
			local meta = minetest.get_meta(pos)
			local number = tonumber(fields.number)
			if number then
				meta:set_int("number", number)
				minetest.chat_send_player(player:get_player_name(), "changements effectués pour le nombre : " .. number)
			end
		end
	end
end)

minetest.register_craft({
	type = "shaped",
	output = "mcl2_clocks:redstone_clock_block 6",
	recipe = {
		{"mcl_core:stone", "mcl_core:stone", "mcl_core:stone"},
		{"mesecons_delayer:delayer_off_1", "mesecons_torch:redstoneblock", "mesecons_delayer:delayer_off_1"},
		{"mcl_core:stone", "mcl_core:stone", "mcl_core:stone"}
	}
})



--ajout un item pour desactiver le timer et reactivé le timer
minetest.register_craftitem("mcl2_clocks:redstone_clock_item", {
	description = S("Horloge Redstone"),
	inventory_image = "mcl2_clocks_item.png",
	stack_max = 1,
	on_use = function(itemstack, user, pointed_thing)
		local pos = pointed_thing.under
		local node = minetest.get_node(pos)
		if node.name == "redstone_clocks:redstone_clock_block" then
			local meta = minetest.get_meta(pos)
			local number = meta:get_int("number")
			--savoir si le timer est activer ou desactiver minetest.get_node_timer(pos):start(0.01)
			if meta:get_string("bloucle") == "on" then
				meta:set_string("bloucle", "off")
				minetest.get_node_timer(pos):stop()
				--areter la redstone
				mesecon.receptor_off(pos, mesecon.rules.alldirs)
				minetest.chat_send_all("Timer desactiver")
			else
				meta:set_string("bloucle", "on")
				minetest.get_node_timer(pos):start(tick)
				minetest.chat_send_all("Timer activer")
			end

		end
	end
})

minetest.register_craft({
	output = "mcl2_clocks:redstone_clock_item 1",
	recipe = {
		{"mesecons:redstone", "mesecons:redstone", "mesecons:redstone"},
		{"mesecons:redstone", "mcl_core:gold_ingot", "mesecons:redstone"},
		{"mesecons:redstone", "mesecons:redstone", "mesecons:redstone"}
	}
})
