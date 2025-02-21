//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:32

/obj/item/implantcase
	name = "glass case"
	desc = "A case containing an implant."
	icon = 'icons/obj/items.dmi'
	icon_state = "implantcase-0"
	item_state = "implantcase"
	throw_speed = 1
	throw_range = 5
	w_class = ITEMSIZE_TINY
	var/obj/item/implant/imp = null

/obj/item/implantcase/proc/update()
	if (imp)
		icon_state = "implantcase-[imp.implant_color]"
	else
		icon_state = "implantcase-0"
	return

/obj/item/implantcase/attackby(obj/item/I as obj, mob/user as mob)
	..()
	if (istype(I, /obj/item/pen))
		var/t = input(user, "What would you like the label to be?", name, null) as text
		if (user.get_active_held_item() != I)
			return
		if((!in_range(src, usr) && loc != user))
			return
		t = sanitizeSafe(t, MAX_NAME_LEN)
		if(t)
			name = "Glass Case - '[t]'"
		else
			name = "Glass Case"
	else if(istype(I, /obj/item/reagent_containers/syringe))
		if(!src.imp)	return
		if(!src.imp.allow_reagents)	return
		if(src.imp.reagents.total_volume >= src.imp.reagents.maximum_volume)
			to_chat(user, "<span class='warning'>\The [src] is full.</span>")
		else
			spawn(5)
				I.reagents.trans_to_obj(src.imp, 5)
				to_chat(user, "<span class='notice'>You inject 5 units of the solution. The syringe now contains [I.reagents.total_volume] units.</span>")
	else if (istype(I, /obj/item/implanter))
		var/obj/item/implanter/M = I
		if (M.imp)
			if ((src.imp || M.imp.implanted))
				return
			M.imp.loc = src
			src.imp = M.imp
			M.imp = null
			src.update()
			M.update()
		else
			if (src.imp)
				if (M.imp)
					return
				src.imp.loc = M
				M.imp = src.imp
				src.imp = null
				update()
			M.update()
	return


/obj/item/implantcase/tracking
	name = "glass case - 'tracking'"
	desc = "A case containing a tracking implant."
	icon_state = "implantcase-b"

/obj/item/implantcase/tracking/Initialize(mapload)
	. = ..()
	imp = new /obj/item/implant/tracking( src )

/obj/item/implantcase/explosive
	name = "glass case - 'explosive'"
	desc = "A case containing an explosive implant."
	icon_state = "implantcase-r"

/obj/item/implantcase/explosive/Initialize(mapload)
	imp = new /obj/item/implant/explosive( src )
	return ..()

/obj/item/implantcase/chem
	name = "glass case - 'chem'"
	desc = "A case containing a chemical implant."
	icon_state = "implantcase-b"

/obj/item/implantcase/chem/Initialize(mapload)
	imp = new /obj/item/implant/chem( src )
	return ..()

/obj/item/implantcase/loyalty
	name = "glass case - 'loyalty'"
	desc = "A case containing a loyalty implant."
	icon_state = "implantcase-r"

/obj/item/implantcase/death_alarm
	name = "glass case - 'death alarm'"
	desc = "A case containing a death alarm implant."
	icon_state = "implantcase-b"

/obj/item/implantcase/death_alarm/Initialize(mapload)
	imp = new /obj/item/implant/death_alarm( src )
	return ..()

/obj/item/implantcase/freedom
	name = "glass case - 'freedom'"
	desc = "A case containing a freedom implant."
	icon_state = "implantcase-r"

/obj/item/implantcase/freedom/Initialize(mapload)
	imp = new /obj/item/implant/freedom( src )
	return ..()

/obj/item/implantcase/adrenalin
	name = "glass case - 'adrenalin'"
	desc = "A case containing an adrenalin implant."
	icon_state = "implantcase-b"

/obj/item/implantcase/adrenalin/Initialize(mapload)
	src.imp = new /obj/item/implant/adrenalin( src )
	return ..()

/obj/item/implantcase/dexplosive
	name = "glass case - 'explosive'"
	desc = "A case containing an explosive."
	icon_state = "implantcase-r"

/obj/item/implantcase/dexplosive/Initialize(mapload)
	imp = new /obj/item/implant/dexplosive( src )
	return ..()

/obj/item/implantcase/health
	name = "glass case - 'health'"
	desc = "A case containing a health tracking implant."
	icon_state = "implantcase-b"

/obj/item/implantcase/health/Initialize(mapload)
	imp = new /obj/item/implant/health( src )
	return ..()

/obj/item/implantcase/language
	name = "glass case - 'GalCom'"
	desc = "A case containing a GalCom language implant."
	icon_state = "implantcase-b"

/obj/item/implantcase/language/Initialize(mapload)
	src.imp = new /obj/item/implant/language( src )
	return ..()

/obj/item/implantcase/language/eal
	name = "glass case - 'EAL'"
	desc = "A case containing an Encoded Audio Language implant."
	icon_state = "implantcase-b"

/obj/item/implantcase/language/eal/Initialize(mapload)
	src.imp = new /obj/item/implant/language/eal( src )
	return ..()

/obj/item/implantcase/shades
	name = "glass case - 'Integrated Shades'"
	desc = "A case containing a nanite fabricator implant."
	icon_state = "implantcase-b"

/obj/item/implantcase/shades/Initialize(mapload)
	src.imp = new /obj/item/implant/organ( src )
	return ..()

/obj/item/implantcase/taser
	name = "glass case - 'Taser'"
	desc = "A case containing a nanite fabricator implant."
	icon_state = "implantcase-b"

/obj/item/implantcase/taser/Initialize(mapload)
	src.imp = new /obj/item/implant/organ/limbaugment( src )
	return ..()

/obj/item/implantcase/laser
	name = "glass case - 'Laser'"
	desc = "A case containing a nanite fabricator implant."
	icon_state = "implantcase-b"

/obj/item/implantcase/laser/Initialize(mapload)
	src.imp = new /obj/item/implant/organ/limbaugment/laser( src )
	return ..()

/obj/item/implantcase/dart
	name = "glass case - 'Dart'"
	desc = "A case containing a nanite fabricator implant."
	icon_state = "implantcase-b"

/obj/item/implantcase/dart/Initialize(mapload)
	src.imp = new /obj/item/implant/organ/limbaugment/dart( src )
	return ..()

/obj/item/implantcase/toolkit
	name = "glass case - 'Toolkit'"
	desc = "A case containing a nanite fabricator implant."
	icon_state = "implantcase-b"

/obj/item/implantcase/toolkit/Initialize(mapload)
	src.imp = new /obj/item/implant/organ/limbaugment/upperarm( src )
	return ..()

/obj/item/implantcase/medkit
	name = "glass case - 'Medikit'"
	desc = "A case containing a nanite fabricator implant."
	icon_state = "implantcase-b"

/obj/item/implantcase/medkit/Initialize(mapload)
	src.imp = new /obj/item/implant/organ/limbaugment/upperarm/medkit( src )
	return ..()

/obj/item/implantcase/surge
	name = "glass case - 'Muscle Overclocker'"
	desc = "A case containing a nanite fabricator implant."
	icon_state = "implantcase-b"

/obj/item/implantcase/surge/Initialize(mapload)
	src.imp = new /obj/item/implant/organ/limbaugment/upperarm/surge( src )
	return ..()

/obj/item/implantcase/analyzer
	name = "glass case - 'Scanner'"
	desc = "A case containing a nanite fabricator implant."
	icon_state = "implantcase-b"

/obj/item/implantcase/analyzer/Initialize(mapload)
	src.imp = new /obj/item/implant/organ/limbaugment/wrist( src )
	return ..()

/obj/item/implantcase/sword
	name = "glass case - 'Sword'"
	desc = "A case containing a nanite fabricator implant."
	icon_state = "implantcase-b"

/obj/item/implantcase/sword/Initialize(mapload)
	src.imp = new /obj/item/implant/organ/limbaugment/wrist/sword( src )
	return ..()

/obj/item/implantcase/sprinter
	name = "glass case - 'Sprinter'"
	desc = "A case containing a nanite fabricator implant."
	icon_state = "implantcase-b"

/obj/item/implantcase/sprinter/Initialize(mapload)
	src.imp = new /obj/item/implant/organ/pelvic( src )
	return ..()

/obj/item/implantcase/vrlanguage
	name = "glass case - 'language'"
	desc = "A case containing a language implant."
	icon_state = "implantcase-r"

/obj/item/implantcase/vrlanguage/Initialize(mapload)
	imp = new /obj/item/implant/uni_translator( src )
	return ..()

/obj/item/implantcase/restrainingbolt
	name = "glass case - 'Restraining Bolt'"
	desc = "A case containing a restraining bolt."
	icon_state = "implantcase-b"

/obj/item/implantcase/restrainingbolt/New()
	src.imp = new /obj/item/implant/restrainingbolt( src )
	..()
	return
