/obj/structure/grille
	desc = "Хрупкий каркас из металлических стержней."
	name = "решетка"
	icon = 'icons/obj/structures.dmi'
	icon_state = "grille"
	density = TRUE
	anchored = TRUE
	flags_1 = CONDUCT_1 | RAD_PROTECT_CONTENTS_1 | RAD_NO_CONTAMINATE_1
	pressure_resistance = 5*ONE_ATMOSPHERE
	armor = list("melee" = 50, "bullet" = 70, "laser" = 70, "energy" = 100, "bomb" = 10, "bio" = 100, "rad" = 100, "fire" = 0, "acid" = 0)
	max_integrity = 50
	integrity_failure = 0.4
	var/rods_type = /obj/item/stack/rods
	var/rods_amount = 2
	var/rods_broken = TRUE
	var/grille_type = null
	var/broken_type = /obj/structure/grille/broken
	var/shock_cooldown

/obj/structure/grille/Destroy()
	update_cable_icons_on_turf(get_turf(src))
	return ..()

/obj/structure/grille/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	update_icon()

/obj/structure/grille/update_icon()
	if(QDELETED(src) || broken)
		return

	var/ratio = obj_integrity / max_integrity
	ratio = CEILING(ratio*4, 1) * 25

	if(smooth)
		QUEUE_SMOOTH(src)

	if(ratio > 50)
		return
	icon_state = "grille50_[rand(0,3)]"

/obj/structure/grille/examine(mob/user)
	. = ..()
	if(anchored)
		. += "<span class='notice'>Это прикручено на месте <b>винтами</b>. Стержни выглядят так, как будто они могут быть <b>прокушены</b>.</span>"
	if(!anchored)
		. += "<span class='notice'>Это выглядит <i>открученым</i>. Стержни выглядят так, как будто они могут быть <b>прокушены</b>.</span>"

/obj/structure/grille/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 20, "cost" = 5)
		if(RCD_WINDOWGRILLE)
			if(the_rcd.window_type == /obj/structure/window/reinforced/fulltile)
				return list("mode" = RCD_WINDOWGRILLE, "delay" = 40, "cost" = 12)
			else
				return list("mode" = RCD_WINDOWGRILLE, "delay" = 20, "cost" = 8)
	return FALSE

/obj/structure/grille/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_DECONSTRUCT)
			to_chat(user, "<span class='notice'>Разбираю решетку.</span>")
			qdel(src)
			return TRUE
		if(RCD_WINDOWGRILLE)
			if(locate(/obj/structure/window) in loc)
				return FALSE
			to_chat(user, "<span class='notice'>Собираю окно.</span>")
			var/obj/structure/window/WD = new the_rcd.window_type(drop_location()[1])
			WD.set_anchored(TRUE)
			return TRUE
	return FALSE

/obj/structure/grille/Bumped(atom/movable/AM)
	if(!ismob(AM))
		return
	var/thingdir = get_dir(src, AM)
	for(var/obj/structure/window/window in OBOUNDS_EDGE(src, thingdir))
		if(window.anchored)
			return
	shock(AM, 70)

/obj/structure/grille/attack_animal(mob/user)
	. = ..()
	if(!.)
		return
	if(!shock(user, 70) && !QDELETED(src)) //Last hit still shocks but shouldn't deal damage to the grille
		take_damage(rand(5,10), BRUTE, "melee", 1)

/obj/structure/grille/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/grille/hulk_damage()
	return 60

/obj/structure/grille/attack_hulk(mob/living/carbon/human/user)
	if(shock(user, 70))
		return
	. = ..()

/obj/structure/grille/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src, ATTACK_EFFECT_KICK)
	user.visible_message("<span class='warning'>[user] бьёт [src].</span>", null, null, COMBAT_MESSAGE_RANGE)
	log_combat(user, src, "hit")
	if(!shock(user, 70))
		take_damage(rand(5,10), BRUTE, "melee", 1)

/obj/structure/grille/attack_alien(mob/living/user)
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message("<span class='warning'>[user] разрывает [src].</span>", null, null, COMBAT_MESSAGE_RANGE)
	if(!shock(user, 70))
		take_damage(20, BRUTE, "melee", 1)

/obj/structure/grille/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	if(mover.pass_flags & PASSGRILLE)
		return TRUE
	else if(!. && istype(mover, /obj/projectile))
		return prob(30)

/obj/structure/grille/CanAStarPass(ID, dir, caller)
	. = !density
	if(ismovable(caller))
		var/atom/movable/mover = caller
		. = . || (mover.pass_flags & PASSGRILLE)

/obj/structure/grille/attackby(obj/item/W, mob/user, params)
	user.changeNext_move(CLICK_CD_MELEE)
	add_fingerprint(user)
	if(W.tool_behaviour == TOOL_WIRECUTTER)
		if(!shock(user, 100))
			W.play_tool_sound(src, 100)
			deconstruct()
	else if((W.tool_behaviour == TOOL_SCREWDRIVER) && (isturf(loc) || anchored))
		if(!shock(user, 90))
			W.play_tool_sound(src, 100)
			set_anchored(!anchored)
			user.visible_message("<span class='notice'>[user] [anchored ? "прикручивает" : "откручивает"] [src.name].</span>", \
								 "<span class='notice'>Я [anchored ? "прикручиваю [src.name] к полу" : "откручиваю [src.name] от пола"].</span>")
			return
	else if(istype(W, /obj/item/stack/rods) && broken)
		var/obj/item/stack/rods/R = W
		if(!shock(user, 90))
			user.visible_message("<span class='notice'>[user] чинит решетку.</span>", \
								 "<span class='notice'>Чиню решетку.</span>")
			new grille_type(src.loc)
			R.use(1)
			qdel(src)
			return

//window placing begin
	else if(is_glass_sheet(W))
		if (!broken)
			var/obj/item/stack/ST = W
			if (ST.get_amount() < 2)
				to_chat(user, "<span class='warning'>Надо бы хотя бы парочку листов стекла!</span>")
				return
			var/dir_to_set = SOUTHWEST
			if(!anchored)
				to_chat(user, "<span class='warning'>Надо бы прикрутить [src] к полу!</span>")
				return
			for(var/obj/structure/window/WINDOW in loc)
				to_chat(user, "<span class='warning'>Здесь уже есть окно!</span>")
				return
			to_chat(user, "<span class='notice'>Начинаю ставить окно...</span>")
			if(do_after(user,20, target = src))
				if(!src.loc || !anchored) //Grille broken or unanchored while waiting
					return
				for(var/obj/structure/window/WINDOW in loc) //Another window already installed on grille
					return
				var/obj/structure/window/WD
				if(istype(W, /obj/item/stack/sheet/plasmarglass))
					WD = new/obj/structure/window/plasma/reinforced/fulltile(drop_location()[1]) //reinforced plasma window
				else if(istype(W, /obj/item/stack/sheet/plasmaglass))
					WD = new/obj/structure/window/plasma/fulltile(drop_location()[1]) //plasma window
				else if(istype(W, /obj/item/stack/sheet/rglass))
					WD = new/obj/structure/window/reinforced/fulltile(drop_location()[1]) //reinforced window
				else if(istype(W, /obj/item/stack/sheet/titaniumglass))
					WD = new/obj/structure/window/shuttle(drop_location()[1])
				else if(istype(W, /obj/item/stack/sheet/plastitaniumglass))
					WD = new/obj/structure/window/plasma/reinforced/plastitanium(drop_location()[1])
				else
					WD = new/obj/structure/window/fulltile(drop_location()[1]) //normal window
				WD.setDir(dir_to_set)
				WD.ini_dir = dir_to_set
				WD.set_anchored(FALSE)
				WD.state = 0
				ST.use(2)
				to_chat(user, "<span class='notice'>Ставлю [WD] на [src].</span>")
			return
//window placing end

	else if(istype(W, /obj/item/shard) || !shock(user, 70))
		return ..()

/obj/structure/grille/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/effects/grillehit.ogg', 80, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 80, TRUE)


/obj/structure/grille/deconstruct(disassembled = TRUE)
	if(!loc) //if already qdel'd somehow, we do nothing
		return
	if(!(flags_1&NODECONSTRUCT_1))
		var/obj/R = new rods_type(drop_location()[1], rods_amount)
		transfer_fingerprints_to(R)
		qdel(src)
	..()

/obj/structure/grille/obj_break()
	if(!broken && !(flags_1 & NODECONSTRUCT_1))
		new broken_type(src.loc)
		var/obj/R = new rods_type(drop_location()[1], rods_broken)
		transfer_fingerprints_to(R)
		qdel(src)


// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise

/obj/structure/grille/proc/shock(mob/user, prb)
	if(!anchored || broken)		// anchored/broken grilles are never connected
		return FALSE
	if(!prob(prb))
		return FALSE
	if(!in_range(src, user))//To prevent TK and mech users from getting shocked
		return FALSE
	if(shock_cooldown > world.time)
		return FALSE
	var/turf/T = get_turf(src)
	var/obj/structure/cable/C = T.get_cable_node()
	if(C)
		if(electrocute_mob(user, C, src, 1, TRUE))
			var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			shock_cooldown = world.time + 0.5 SECONDS
			return TRUE
		else
			return FALSE
	return FALSE

/obj/structure/grille/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(!broken)
		if(exposed_temperature > T0C + 1500)
			take_damage(1, BURN, 0, 0)
	..()

/obj/structure/grille/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isobj(AM))
		if(prob(50) && anchored && !broken)
			var/obj/O = AM
			if(O.throwforce != 0)//don't want to let people spam tesla bolts, this way it will break after time
				var/turf/T = get_turf(src)
				var/obj/structure/cable/C = T.get_cable_node()
				if(C)
					playsound(src, 'sound/magic/lightningshock.ogg', 100, TRUE, extrarange = 5)
					tesla_zap(src, 3, C.newavail() * 0.01, ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_MOB_STUN | ZAP_ALLOW_DUPLICATES) //Zap for 1/100 of the amount of power. At a million watts in the grid, it will be as powerful as a tesla revolver shot.
					C.add_delayedload(C.newavail() * 0.0375) // you can gain up to 3.5 via the 4x upgrades power is halved by the pole so thats 2x then 1X then .5X for 3.5x the 3 bounces shock.
	return ..()

/obj/structure/grille/get_dumping_location(datum/component/storage/source,mob/user)
	return null

/obj/structure/grille/broken // Pre-broken grilles for map placement
	icon_state = "brokengrille"
	density = FALSE
	obj_integrity = 20
	broken = TRUE
	rods_amount = 1
	rods_broken = FALSE
	grille_type = /obj/structure/grille
	broken_type = null
