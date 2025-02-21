/datum/event/meteor_strike
	announceWhen = 1
	var/turf/strike_target

/datum/event/meteor_strike/setup()
	startWhen = rand(8,15)
	if(LAZYLEN((LEGACY_MAP_DATUM).meteor_strike_areas))
		strike_target = pick(get_area_turfs(pick((LEGACY_MAP_DATUM).meteor_strike_areas)))

	if(!strike_target)
		kill()

/datum/event/meteor_strike/announce()
	command_announcement.Announce("A meteoroid has been detected entering the atmosphere on a trajectory that will terminate near the surface facilty. Brace for impact.", "NanoTrasen Orbital Monitoring", new_sound = 'sound/effects/meteor_strike.ogg')

/datum/event/meteor_strike/start()
	new /obj/effect/meteor_falling(strike_target)

/obj/effect/meteor_falling
	name = "meteor"
	desc = "The sky is falling!"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "large"
	anchored = 1

/obj/effect/meteor_falling/Initialize(mapload)
	. = ..()
	SpinAnimation()
	INVOKE_ASYNC(src, .proc/meteor_fall)

/obj/effect/meteor_falling/proc/meteor_fall()
	var/turf/current = get_turf(src)
	if(istype(current, /turf/simulated/open) || istype(current, /turf/space))
		var/turf/below = GetBelow(src)
		if(below.density)
			meteor_impact()
			return
		for(var/atom/movable/A in current)
			LEGACY_EX_ACT(A, 3, null) //Let's have it be heavy, but not devistation in case it hits walls or something.
		forceMove(below)
		meteor_fall()
		return
	meteor_impact()

/obj/effect/meteor_falling/proc/meteor_impact()
	var/turf/current = get_turf(src)
	spawn()
		explosion(current, 1, 2, 4, 8, 0) //Was previously 2,4,6,10. Way too big.
	anim(get_step(current,SOUTHWEST),, 'icons/effects/96x96.dmi',, "explosion")
	new /obj/structure/meteorite(current)

	var/datum/planet/impacted
	for(var/datum/planet/P in SSplanets.planets)
		if(current.z in P.expected_z_levels)
			impacted = P
			break
	if(impacted)
		for(var/mob/living/L in GLOB.mob_list)
			if(!istype(L))
				continue
			var/turf/mob_turf = get_turf(L)
			if(!mob_turf || !(mob_turf.z in impacted.expected_z_levels))
				continue
			if(!L.buckled && !issilicon(L))
				if(!L.Check_Shoegrip())
					L.throw_at_old(get_step_rand(L),1,5)
				L.afflict_paralyze(20 * 5)
			if(L.client)
				to_chat(L, "<span class='danger'>The ground lurches beneath you!</span>")
				shake_camera(L, 6, 1)
				if(!L.ear_deaf)
					SEND_SOUND(L, sound('sound/soundbytes/effects/explosion/explosionfar.ogg'))
	qdel(src)

/obj/structure/meteorite
	name = "meteorite"
	desc = "A big hunk of star-stuff."
	icon = 'icons/obj/meteor.dmi'
	icon_state = "large"
	density = 1
	climbable = 1

/obj/structure/meteorite/Initialize(mapload)
	. = ..()
	icon = turn(icon, 90)
	switch(rand(1,100))
		if(1 to 30)
			for(var/i=1 to rand(12,36))
				new /obj/item/ore/iron(src)
		if(31 to 90)
			for(var/i=1 to rand(8,24))
				new /obj/item/ore/silver(src)
				new /obj/item/ore/gold(src)
				new /obj/item/ore/osmium(src)
				new /obj/item/ore/diamond(src)
		if(91 to 100)
			new /obj/machinery/artifact(src)

/obj/structure/meteorite/legacy_ex_act()
	return

/obj/structure/meteorite/attackby(var/obj/item/I, var/mob/M)
	if(istype(I, /obj/item/pickaxe))
		var/obj/item/pickaxe/P = I
		M.visible_message("<span class='warning'>[M] starts [P.drill_verb] \the [src].</span>", "<span class='warning'>You start [P.drill_verb] \the [src].</span>")

		if(!do_after(M, P.digspeed*3))
			return

		M.visible_message("<span cleass='warning'>[M] breaks apart \the [src].</span>", "<span cleass='warning'>You break apart \the [src].</span>")
		for(var/obj/O in src)
			O.forceMove(get_turf(src))
		qdel(src)
		return
