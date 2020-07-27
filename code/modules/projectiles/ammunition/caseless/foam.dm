/obj/item/ammo_casing/caseless/foam_dart
	name = "пенчик"
	desc = "It's nerf or nothing! Детям от восьми лет и выше."
	projectile_type = /obj/projectile/bullet/reusable/foam_dart
	caliber = "foam_force"
	icon = 'icons/obj/guns/toy.dmi'
	icon_state = "foamdart"
	custom_materials = list(/datum/material/iron = 11.25)
	harmful = FALSE
	var/modified = FALSE

/obj/item/ammo_casing/caseless/foam_dart/update_icon()
	..()
	if (modified)
		icon_state = "foamdart_empty"
		desc = "It's nerf or nothing... Хотя, этот не выглядит слишком безопасным."
		if(BB)
			BB.icon_state = "foamdart_empty"
	else
		icon_state = initial(icon_state)
		desc = "It's nerf or nothing! Детям от восьми лет и выше."
		if(BB)
			BB.icon_state = initial(BB.icon_state)


/obj/item/ammo_casing/caseless/foam_dart/attackby(obj/item/A, mob/user, params)
	var/obj/projectile/bullet/reusable/foam_dart/FD = BB
	if (A.tool_behaviour == TOOL_SCREWDRIVER && !modified)
		modified = TRUE
		FD.modified = TRUE
		FD.damage_type = BRUTE
		to_chat(user, "<span class='notice'>Снимаю защитный колпачок с <b>[src.name]</b>.</span>")
		update_icon()
	else if (istype(A, /obj/item/pen))
		if(modified)
			if(!FD.pen)
				harmful = TRUE
				if(!user.transferItemToLoc(A, FD))
					return
				FD.pen = A
				FD.damage = 5
				FD.nodamage = FALSE
				to_chat(user, "<span class='notice'>Вставляю <b>[A.name]</b> в <b>[src.name]</b>.</span>")
			else
				to_chat(user, "<span class='warning'>Здесь уже что-то есть в <b>[src.name]</b>.</span>")
		else
			to_chat(user, "<span class='warning'>Защитная крышка не позволяет вставить <b>[A.name]</b> в <b>[src.name]</b>.</span>")
	else
		return ..()

/obj/item/ammo_casing/caseless/foam_dart/attack_self(mob/living/user)
	var/obj/projectile/bullet/reusable/foam_dart/FD = BB
	if(FD.pen)
		FD.damage = initial(FD.damage)
		FD.nodamage = initial(FD.nodamage)
		user.put_in_hands(FD.pen)
		to_chat(user, "<span class='notice'>Вытаскиваю <b>[FD.pen]</b> из <b>[src.name]</b>.</span>")
		FD.pen = null

/obj/item/ammo_casing/caseless/foam_dart/riot
	name = "резиновый пенчик"
	desc = "Чья это была умная идея использовать игрушки для контроля толпы? Для детей от восемнадцати и старше."
	projectile_type = /obj/projectile/bullet/reusable/foam_dart/riot
	icon_state = "foamdart_riot"
	custom_materials = list(/datum/material/iron = 1125)
