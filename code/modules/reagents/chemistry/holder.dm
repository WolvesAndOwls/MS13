/datum/reagents
	//? core
	/// reagent holder flags - see [code/__DEFINES/reagents/flags.dm]
	var/reagent_holder_flags = NONE

	///? legacy / unsorted
	var/list/datum/reagent/reagent_list = list()
	var/total_volume = 0
	var/maximum_volume = 100

	var/atom/my_atom = null
	// todo: remove / refactor this var into reagent_holder_flags with proper defines, this was never ported properly.
	var/reagents_holder_flags

/datum/reagents/New(max = 100, atom/A = null, new_flags = NONE)
	..()
	maximum_volume = max
	my_atom = A

	//I dislike having these here but map-objects are initialised before world/New() is called. >_>
	if(!SSchemistry.reagent_lookup)
		//Chemical Reagents - Initialises all /datum/reagent into a list indexed by reagent id
		var/paths = typesof(/datum/reagent) - /datum/reagent
		SSchemistry.reagent_lookup = list()
		for(var/path in paths)
			var/datum/reagent/D = new path()
			if(!D.name)
				continue
			SSchemistry.reagent_lookup[D.id] = D

	reagents_holder_flags = new_flags

/datum/reagents/Destroy()
	STOP_PROCESSING(SSchemistry, src)
	for(var/datum/reagent/R in reagent_list)
		qdel(R)
	reagent_list = null
	if(my_atom && my_atom.reagents == src)
		my_atom.reagents = null
	return ..()

// Used in attack logs for reagents in pills and such
/datum/reagents/proc/log_list()
	if(!length(reagent_list))
		return "no reagents"

	var/list/data = list()
	for(var/r in reagent_list) //no reagents will be left behind
		var/datum/reagent/R = r
		data += "[R.type] [R.volume]u)"
		//Using IDs because SOME chemicals (I'm looking at you, chlorhydrate-beer) have the same names as other chemicals.
	return english_list(data)

/* Internal procs */

/datum/reagents/proc/get_master_reagent() // Returns reference to the reagent with the biggest volume.
	var/the_reagent = null
	var/the_volume = 0

	for(var/datum/reagent/A in reagent_list)
		if(A.volume > the_volume)
			the_volume = A.volume
			the_reagent = A

	return the_reagent

/datum/reagents/proc/get_master_reagent_name() // Returns the name of the reagent with the biggest volume.
	var/the_name = null
	var/the_volume = 0
	for(var/datum/reagent/A in reagent_list)
		if(A.volume > the_volume)
			the_volume = A.volume
			the_name = A.name

	return the_name

/datum/reagents/proc/get_master_reagent_id() // Returns the id of the reagent with the biggest volume.
	var/the_id = null
	var/the_volume = 0
	for(var/datum/reagent/A in reagent_list)
		if(A.volume > the_volume)
			the_volume = A.volume
			the_id = A.id

	return the_id

/datum/reagents/proc/update_total() // Updates volume.
	total_volume = 0
	for(var/datum/reagent/R in reagent_list)
		if(R.volume < MINIMUM_CHEMICAL_VOLUME)
			del_reagent(R.id)
		else
			total_volume += R.volume
	return

/datum/reagents/proc/handle_reactions()
	set waitfor = FALSE		// shitcode. reagents shouldn't ever sleep but hey :^)
	if(QDELETED(my_atom))
		return FALSE
	if(my_atom.atom_flags & NOREACT)
		return FALSE
	var/reaction_occurred
	var/list/eligible_reactions = list()
	var/list/effect_reactions = list()
	do
		reaction_occurred = FALSE
		for(var/i in reagent_list)
			var/datum/reagent/R = i
			if(SSchemistry.chemical_reactions_by_reagent[R.id])
				eligible_reactions |= SSchemistry.chemical_reactions_by_reagent[R.id]

		for(var/i in eligible_reactions)
			var/datum/chemical_reaction/C = i
			if(C.can_happen(src) && C.process(src))
				effect_reactions |= C
				reaction_occurred = TRUE
		eligible_reactions.len = 0
	while(reaction_occurred)
	for(var/i in effect_reactions)
		var/datum/chemical_reaction/C = i
		C.post_reaction(src)
	update_total()

/datum/reagents/proc/holder_full()
	if(total_volume >= maximum_volume)
		return TRUE
	return FALSE

/* Holder-to-chemical */

/datum/reagents/proc/add_reagent(id, amount, data = null, safety = 0)
	if(ispath(id))
		var/datum/reagent/accessing = id
		id = initial(accessing.id)

	if(!isnum(amount) || amount <= 0)
		return 0

	update_total()
	amount = min(amount, available_volume())

	for(var/datum/reagent/current in reagent_list)
		if(current.id == id)
			if(current.id == "blood")
				if(data && !isnull(data["species"]) && !isnull(current.data["species"]) && data["species"] != current.data["species"])	// Species bloodtypes are already incompatible, this just stops it from mixing into the one already in a container.
					continue

			current.volume += amount
			if(!isnull(data)) // For all we know, it could be zero or empty string and meaningful
				current.mix_data(src, current.data, current.volume, data, amount)
			update_total()
			if(!safety)
				handle_reactions()
			if(my_atom)
				my_atom.on_reagent_change()
			return 1
	var/datum/reagent/D = SSchemistry.reagent_lookup[id]
	if(D)
		var/datum/reagent/R = new D.type()
		reagent_list += R
		R.holder = src
		R.volume = amount
		R.initialize_data(data)
		update_total()
		if(!safety)
			handle_reactions()
		if(my_atom)
			my_atom.on_reagent_change()
		return 1
	else
		stack_trace("[my_atom] attempted to add a reagent called '[id]' which doesn't exist. ([usr])")
	return 0

/datum/reagents/proc/isolate_reagent(reagent)
	for(var/A in reagent_list)
		var/datum/reagent/R = A
		if(R.id != reagent)
			del_reagent(R.id)
			update_total()

/datum/reagents/proc/remove_reagent(id, amount, safety = 0)
	if(!isnum(amount))
		return 0
	for(var/datum/reagent/current in reagent_list)
		if(current.id == id)
			current.volume -= amount // It can go negative, but it doesn't matter
			update_total() // Because this proc will delete it then
			if(!safety)
				handle_reactions()
			if(my_atom)
				my_atom.on_reagent_change()
			return 1
	return 0

/datum/reagents/proc/del_reagent(id)
	for(var/datum/reagent/current in reagent_list)
		if (current.id == id)
			reagent_list -= current
			qdel(current)
			update_total()
			if(my_atom)
				my_atom.on_reagent_change()
			return 0

/datum/reagents/proc/has_reagent(id, amount = 0)
	for(var/datum/reagent/current in reagent_list)
		if(current.id == id)
			if(current.volume >= amount)
				return 1
			else
				return 0
	return 0

/datum/reagents/proc/has_any_reagent(list/check_reagents)
	for(var/datum/reagent/current in reagent_list)
		if(current.id in check_reagents)
			if(current.volume >= check_reagents[current.id])
				return 1
			else
				return 0
	return 0

/datum/reagents/proc/has_all_reagents(list/check_reagents)
	//this only works if check_reagents has no duplicate entries... hopefully okay since it expects an associative list
	var/missing = check_reagents.len
	for(var/datum/reagent/current in reagent_list)
		if(current.id in check_reagents)
			if(current.volume >= check_reagents[current.id])
				missing--
	return !missing

/datum/reagents/proc/clear_reagents()
	for(var/datum/reagent/current in reagent_list)
		del_reagent(current.id)
	return

/datum/reagents/proc/get_reagent(id)
	for(var/datum/reagent/current in reagent_list)
		if(current.id == id)
			return current

/datum/reagents/proc/get_reagent_amount(id)
	for(var/datum/reagent/current in reagent_list)
		if(current.id == id)
			return current.volume
	return 0

/datum/reagents/proc/get_data(id)
	for(var/datum/reagent/current in reagent_list)
		if(current.id == id)
			return current.get_data()
	return 0

/datum/reagents/proc/get_reagents()
	. = list()
	for(var/datum/reagent/current in reagent_list)
		. += "[current.id] ([current.volume])"
	return english_list(., "EMPTY", "", ", ", ", ")

/* Holder-to-holder and similar procs */

/datum/reagents/proc/remove_any(amount = 1) // Removes up to [amount] of reagents from [src]. Returns actual amount removed.
	amount = min(amount, total_volume)

	if(!amount)
		return

	var/part = amount / total_volume

	for(var/datum/reagent/current in reagent_list)
		var/amount_to_remove = current.volume * part
		remove_reagent(current.id, amount_to_remove, 1)

	update_total()
	handle_reactions()
	return amount

/datum/reagents/proc/trans_to_holder(datum/reagents/target, amount = 1, multiplier = 1, copy = 0) // Transfers [amount] reagents from [src] to [target], multiplying them by [multiplier]. Returns actual amount removed from [src] (not amount transferred to [target]).
	if(!target || !istype(target))
		return

	amount = max(0, min(amount, total_volume, target.available_volume() / multiplier))

	if(!amount)
		return

	var/part = amount / total_volume

	for(var/datum/reagent/current in reagent_list)
		var/amount_to_transfer = current.volume * part
		target.add_reagent(current.id, amount_to_transfer * multiplier, current.get_data(), safety = 1) // We don't react until everything is in place
		if(!copy)
			remove_reagent(current.id, amount_to_transfer, 1)

	if(!copy)
		handle_reactions()
	target.handle_reactions()
	return amount

/* Holder-to-atom and similar procs */

/**
 * The general proc for applying reagents to things. This proc assumes the reagents are being applied externally,
 * not directly injected into the contents. It first calls touch, then the appropriate trans_to_*() or splash_mob().
 * If for some reason touch effects are bypassed (e.g. injecting stuff directly into a reagent container or person),
 * call the appropriate trans_to_*() proc.
 */
/datum/reagents/proc/trans_to(atom/target, amount = 1, multiplier = 1, copy = 0)
	touch(target) //First, handle mere touch effects

	if(ismob(target))
		return splash_mob(target, amount, copy)
	if(isturf(target))
		return trans_to_turf(target, amount, multiplier, copy)
	if(isobj(target) && target.is_open_container())
		return trans_to_obj(target, amount, multiplier, copy)
	return 0

//Splashing reagents is messier than trans_to, the target's loc gets some of the reagents as well.
/datum/reagents/proc/splash(atom/target, amount = 1, multiplier = 1, copy = 0, min_spill = 0, max_spill = 60)
	var/spill = 0
	if(!isturf(target) && target.loc)
		spill = amount*(rand(min_spill, max_spill)/100)
		amount -= spill
	if(spill)
		splash(target.loc, spill, multiplier, copy, min_spill, max_spill)

	trans_to(target, amount, multiplier, copy)

/datum/reagents/proc/trans_id_to(atom/target, id, amount = 1)
	if (!target || !target.reagents)
		return

	amount = min(amount, get_reagent_amount(id))

	if(!amount)
		return

	var/datum/reagents/F = new /datum/reagents(amount)
	var/tmpdata = get_data(id)
	F.add_reagent(id, amount, tmpdata)
	remove_reagent(id, amount)

	return F.trans_to(target, amount) // Let this proc check the atom's type

// When applying reagents to an atom externally, touch() is called to trigger any on-touch effects of the reagent.
// This does not handle transferring reagents to things.
// For example, splashing someone with water will get them wet and extinguish them if they are on fire,
// even if they are wearing an impermeable suit that prevents the reagents from contacting the skin.
/datum/reagents/proc/touch(atom/target, amount)
	if(ismob(target))
		touch_mob(target, amount)
	if(isturf(target))
		touch_turf(target, amount)
	if(isobj(target))
		touch_obj(target, amount)
	return

/datum/reagents/proc/touch_mob(mob/target)
	if(!target || !istype(target))
		return

	for(var/datum/reagent/current in reagent_list)
		current.touch_mob(target, current.volume)

	update_total()

/datum/reagents/proc/touch_turf(turf/target, amount)
	if(!target || !istype(target))
		return

	for(var/datum/reagent/current in reagent_list)
		current.touch_turf(target, amount)

	update_total()

/datum/reagents/proc/touch_obj(obj/target, amount)
	if(!target || !istype(target))
		return

	for(var/datum/reagent/current in reagent_list)
		current.touch_obj(target, amount)

	update_total()

// Attempts to place a reagent on the mob's skin.
// Reagents are not guaranteed to transfer to the target.
// Do not call this directly, call trans_to() instead.
/datum/reagents/proc/splash_mob(mob/target, amount = 1, copy = 0)
	var/perm = 1
	if(isliving(target)) //will we ever even need to tranfer reagents to non-living mobs?
		var/mob/living/L = target
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(H.check_shields(0, null, null, null, "the spray") == 1)		//If they block the spray, it does nothing.
				amount = 0
		perm = L.reagent_permeability()
	return trans_to_mob(target, amount, CHEM_TOUCH, perm, copy)

/datum/reagents/proc/trans_to_mob(mob/target, amount = 1, type = CHEM_INJECT, multiplier = 1, copy = 0) // Transfer after checking into which holder...
	if(!target || !istype(target))
		return
	if(iscarbon(target))
		var/mob/living/carbon/C = target
		if(type == CHEM_INJECT)
			var/datum/reagents/R = C.reagents
			return trans_to_holder(R, amount, multiplier, copy)
		if(type == CHEM_INGEST)
			var/datum/reagents/R = C.ingested
			return C.ingest(src, R, amount, multiplier, copy)
		if(type == CHEM_TOUCH)
			var/datum/reagents/R = C.touching
			return trans_to_holder(R, amount, multiplier, copy)
	else
		var/datum/reagents/R = new /datum/reagents(amount)
		. = trans_to_holder(R, amount, multiplier, copy)
		R.touch_mob(target)

/datum/reagents/proc/trans_to_turf(turf/target, amount = 1, multiplier = 1, copy = 0) // Turfs don't have any reagents (at least, for now). Just touch it.
	if(!target)
		return

	var/datum/reagents/R = new /datum/reagents(amount * multiplier)
	. = trans_to_holder(R, amount, multiplier, copy)
	R.touch_turf(target, amount)
	return

/// Objects may or may not; if they do, it's probably a beaker or something and we need to transfer properly; otherwise, just touch.
/datum/reagents/proc/trans_to_obj(obj/target, amount = 1, multiplier = 1, copy = 0)
	if(!target)
		return

	if(!target.reagents)
		var/datum/reagents/R = new /datum/reagents(amount * multiplier)
		. = trans_to_holder(R, amount, multiplier, copy)
		R.touch_obj(target, amount)
		return

	return trans_to_holder(target.reagents, amount, multiplier, copy)

/* Atom reagent creation - use it all the time */

/atom/proc/create_reagents(max_vol)
	reagents = new /datum/reagents(max_vol, src)
	return reagents

//Spreads the contents of this reagent holder all over the vicinity of the target turf.
/datum/reagents/proc/splash_area(turf/epicentre, range = 3, portion = 1.0, multiplier = 1, copy = 0)
	var/list/things = dview(range, epicentre, INVISIBILITY_LIGHTING)
	var/list/turfs = list()
	for (var/turf/T in things)
		turfs += T
	if (!turfs.len)
		return//Nowhere to splash to, somehow
	//Create a temporary holder to hold all the amount that will be spread
	var/datum/reagents/R = new /datum/reagents(total_volume * portion * multiplier)
	trans_to_holder(R, total_volume * portion, multiplier, copy)
	//The exact amount that will be given to each turf
	var/turfportion = R.total_volume / turfs.len
	for (var/turf/T in turfs)
		var/datum/reagents/TR = new /datum/reagents(turfportion)
		R.trans_to_holder(TR, turfportion, 1, 0)
		TR.splash_turf(T)
	qdel(R)

//Spreads the contents of this reagent holder all over the target turf, dividing among things in it.
//50% is divided between mobs, 20% between objects, and whatever is left on the turf itself
/datum/reagents/proc/splash_turf(turf/T, amount = null, multiplier = 1, copy = 0)
	if (isnull(amount))
		amount = total_volume
	else
		amount = min(amount, total_volume)
	if (amount <= 0)
		return
	var/list/mobs = list()
	for (var/mob/M in T)
		mobs += M
	var/list/objs = list()
	for (var/obj/O in T)
		objs += O
	if (objs.len)
		var/objportion = (amount * 0.2) / objs.len
		for (var/o in objs)
			var/obj/O = o
			trans_to(O, objportion, multiplier, copy)
	amount = min(amount, total_volume)
	if (mobs.len)
		var/mobportion = (amount * 0.5) / mobs.len
		for (var/m in mobs)
			var/mob/M = m
			trans_to(M, mobportion, multiplier, copy)
	trans_to(T, total_volume, multiplier, copy)
	if (total_volume <= 0)
		qdel(src)

/datum/reagents/proc/conditional_update_move(atom/A, Running = 0)
	var/list/cached_reagents = reagent_list
	for(var/datum/reagent/R in cached_reagents)
		R.on_move (A, Running)
	update_total()

/datum/reagents/proc/conditional_update(atom/A)
	var/list/cached_reagents = reagent_list
	for(var/datum/reagent/R in cached_reagents)
		R.on_update (A)
	update_total()

// I wrote this while :headempty: and I'm not sure if it's correct. @Zandario
/datum/reagents/proc/can_reactions_happen()
	var/do_happen = FALSE
	var/list/eligible_reactions = list()
	for(var/i in reagent_list)
		var/datum/reagent/R = i
		if(SSchemistry.chemical_reactions_by_reagent[R.id])
			eligible_reactions |= SSchemistry.chemical_reactions_by_reagent[R.id]

	for(var/i in eligible_reactions)
		var/datum/chemical_reaction/C = i
		if(C.can_happen(src))
			do_happen = TRUE
	return do_happen

//? Queries - Whole

/**
 * returns volume remaining
 */
/datum/reagents/proc/available_volume()
	return maximum_volume - total_volume

//? UI

/**
 * data list for ReagentContents in /tgui/interfaces/common/Reagents.tsx
 */
/datum/reagents/proc/tgui_reagent_contents()
	var/list/built = list()
	for(var/datum/reagent/R as anything in reagent_list)
		built[++built.len] = list(
			"name" = R.name,
			"amount" = R.volume,
			"id" = R.id,
		)
	return built
