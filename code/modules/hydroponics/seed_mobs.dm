// The following procs are used to grab players for mobs produced by a seed (mostly for dionaea).
/datum/seed/proc/handle_living_product(var/mob/living/host)

	if(!host || !istype(host)) return

	if(apply_color_to_mob)
		host.color = traits[TRAIT_PRODUCT_COLOUR]

	spawn(75)
		if(!host.ckey && !host.client)
			host.death()  // This seems redundant, but a lot of mobs don't
			host.set_stat(DEAD) // handle death() properly. Better safe than etc.
			host.visible_message("<span class='danger'>[host] is malformed and unable to survive. It expires pitifully, leaving behind some seeds.</span>")

			var/total_yield = rand(1,3)
			for(var/j = 0;j<=total_yield;j++)
				var/obj/item/seeds/S = new(get_turf(host))
				S.seed_type = name
				S.update_seed()
