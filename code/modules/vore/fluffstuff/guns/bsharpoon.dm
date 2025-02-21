//RD 'gun'
/obj/item/bluespace_harpoon
	name = "bluespace harpoon"
	desc = "For climbing on bluespace mountains!"

	icon = 'icons/obj/gun/energy.dmi'
	icon_state = "harpoon-2"

	w_class = ITEMSIZE_NORMAL

	throw_speed = 4
	throw_range = 20

	origin_tech = list(TECH_BLUESPACE = 5)

	var/mode = 1  // 1 mode - teleport you to turf  0 mode teleport turf to you
	var/last_fire = 0
	var/transforming = 0
	var/cooldown = 20 SECONDS
	var/wallhack = TRUE
	var/range = 8
	var/failchance = 5
	var/failrange = 24

/obj/item/bluespace_harpoon/afterattack(atom/target, mob/user, clickchain_flags, list/params)
	var/current_fire = world.time
	if(!user || !target)
		return
	if(transforming)
		to_chat(user,"<span class = 'warning'>You can't fire while \the [src] transforming!</span>")
		return
	if(!((wallhack && (get_dist(target, get_turf(user)) <= range)) || (target in view(get_turf(user), range))))
		to_chat(user, "<span class='warning'>The target is either out of range, or you couldn't see it clearly enough to lock on!</span>")
		return
	if((current_fire - last_fire) <= cooldown)
		to_chat(user,"<span class = 'warning'>\The [src] is recharging...</span>")
		return
	if(is_jammed(target) || is_jammed(user))
		to_chat(user,"<span class = 'warning'>\The [src] shot fizzles due to interference!</span>")
		last_fire = current_fire
		playsound(user, 'sound/weapons/wave.ogg', 60, 1)
		return
	var/turf/T = get_turf(target)
	/*
	if(!T || T.check_density(ignore_border = TRUE))
		to_chat(user,"<span class = 'warning'>That's a little too solid to harpoon into!</span>")
		return
	*///MISSING!!!
	if(get_area(target).area_flags & AREA_FLAG_BLUE_SHIELDED)
		to_chat(user, "<span class='warning'>The target area protected by bluespace shielding!</span>")
		return
	if(!do_after(user, 5 SECONDS, src))
		return

	last_fire = current_fire
	playsound(user, 'sound/weapons/wave.ogg', 60, 1)

	user.visible_message("<span class='warning'>[user] fires \the [src]!</span>","<span class='warning'>You fire \the [src]!</span>")

	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(4, 1, target)
	s.start()
	s = new /datum/effect_system/spark_spread
	s.set_up(4, 1, user)
	s.start()

	var/turf/FromTurf = mode ? get_turf(user) : get_turf(target)
	var/turf/ToTurf = mode ? get_turf(target) : get_turf(user)

	for(var/atom/movable/AM in FromTurf)
		if(!isobj(AM) && !isliving(AM))
			continue
		if(AM.anchored)
			continue
		var/turf/real_target = prob(failchance)? pick(trange(failrange, user)) : ToTurf
		AM.locationTransitForceMove(real_target, allow_pulled = FALSE, allow_grabbed = GRAB_AGGRESSIVE)

/obj/item/bluespace_harpoon/attack_self(mob/user)
	. = ..()
	if(.)
		return
	return chande_fire_mode(user)

/obj/item/bluespace_harpoon/verb/chande_fire_mode(mob/user as mob)
	set name = "Change fire mode"
	set category = "Object"
	set src in oview(1)
	if(transforming) return
	mode = !mode
	transforming = 1
	to_chat(user,"<span class = 'info'>You change \the [src]'s mode to [mode ? "transmiting" : "receiving"].</span>")
	update_icon()

/obj/item/bluespace_harpoon/update_icon()
	if(transforming)
		switch(mode)
			if(0)
				flick("harpoon-2-change", src)
				icon_state = "harpoon-1"
			if(1)
				flick("harpoon-1-change",src)
				icon_state = "harpoon-2"
		transforming = 0
