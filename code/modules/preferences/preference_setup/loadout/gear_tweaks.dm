/datum/gear_tweak/proc/get_contents(var/metadata)
	return

/datum/gear_tweak/proc/get_metadata(var/user, var/metadata)
	return

/datum/gear_tweak/proc/get_default()
	return

/datum/gear_tweak/proc/tweak_gear_data(var/metadata, var/datum/gear_data)
	return

/datum/gear_tweak/proc/tweak_item(var/obj/item/I, var/metadata)
	return

/*
* Color adjustment
*/

/datum/gear_tweak/color
	var/list/valid_colors

/datum/gear_tweak/color/New(var/list/valid_colors)
	src.valid_colors = valid_colors
	..()

/datum/gear_tweak/color/get_contents(var/metadata)
	return "Color: <font color='[metadata]'>&#9899;</font>"

/datum/gear_tweak/color/get_default()
	return valid_colors ? valid_colors[1] : COLOR_GRAY

/datum/gear_tweak/color/get_metadata(var/user, var/metadata, var/title = "Character Preference")
	if(valid_colors)
		return input(user, "Choose a color.", title, metadata) as null|anything in valid_colors
	return input(user, "Choose a color.", title, metadata) as color|null

/datum/gear_tweak/color/tweak_item(var/obj/item/I, var/metadata)
	if(valid_colors && !(metadata in valid_colors))
		return
	if(!metadata || (metadata == "#ffffff"))
		return
	if(istype(I))
		I.add_atom_colour(metadata, FIXED_COLOUR_PRIORITY)
	else
		I.color = metadata		// fuck off underwear

GLOBAL_DATUM_INIT(gear_tweak_free_matrix_recolor, /datum/gear_tweak/matrix_recolor, new)

/datum/gear_tweak/matrix_recolor

/datum/gear_tweak/matrix_recolor/get_contents(var/metadata)
	if(islist(metadata) && length(metadata))
		return "Matrix Recolor: [english_list(metadata)]"
	return "Matrix Recolor"

/datum/gear_tweak/matrix_recolor/get_default()
	return null

/datum/gear_tweak/matrix_recolor/get_metadata(user, metadata)
	var/list/returned = color_matrix_picker(user, "Pick a color matrix for this item", "Matrix Recolor", "Ok", "Erase", "Cancel", TRUE, 10 MINUTES, islist(metadata) && metadata)
	var/list/L = returned["matrix"]
	if(returned["button"] == 3)
		return metadata
	if((returned["button"] == 2) || !islist(L) || !ISINRANGE(L.len, 9, 20))
		return list()
	var/identity = TRUE
	var/static/list/ones = list(1, 5, 9)
	for(var/i in 1 to L.len)
		if(L[i] != ((i in ones)? 1 : 0))
			identity = FALSE
			break
	return identity? list() : L

/datum/gear_tweak/matrix_recolor/tweak_item(obj/item/I, metadata)
	. = ..()
	if(!islist(metadata) || (length(metadata) < 12))
		return
	if(istype(I))
		I.add_atom_colour(metadata, FIXED_COLOUR_PRIORITY)
	else
		I.color = metadata		// fuck off underwear

/*
* Path adjustment
*/

/datum/gear_tweak/path
	var/list/valid_paths

/datum/gear_tweak/path/New(var/list/valid_paths)
	src.valid_paths = valid_paths
	..()

/datum/gear_tweak/path/get_contents(var/metadata)
	return "Type: [metadata]"

/datum/gear_tweak/path/get_default()
	return valid_paths[1]

/datum/gear_tweak/path/get_metadata(var/user, var/metadata)
	return input(user, "Choose a type.", "Character Preference", metadata) as null|anything in valid_paths

/datum/gear_tweak/path/tweak_gear_data(var/metadata, var/datum/gear_data/gear_data)
	if(!(metadata in valid_paths))
		return
	gear_data.path = valid_paths[metadata]

/*
* Content adjustment
*/

/datum/gear_tweak/contents
	var/list/valid_contents

/datum/gear_tweak/contents/New()
	valid_contents = args.Copy()
	..()

/datum/gear_tweak/contents/get_contents(var/metadata)
	return "Contents: [english_list(metadata, and_text = ", ")]"

/datum/gear_tweak/contents/get_default()
	. = list()
	for(var/i = 1 to valid_contents.len)
		. += "Random"

/datum/gear_tweak/contents/get_metadata(var/user, var/list/metadata)
	. = list()
	for(var/i = metadata.len to valid_contents.len)
		metadata += "Random"
	for(var/i = 1 to valid_contents.len)
		var/entry = input(user, "Choose an entry.", "Character Preference", metadata[i]) as null|anything in (valid_contents[i] + list("Random", "None"))
		if(entry)
			. += entry
		else
			return metadata

/datum/gear_tweak/contents/tweak_item(var/obj/item/I, var/list/metadata)
	if(metadata.len != valid_contents.len)
		return
	for(var/i = 1 to valid_contents.len)
		var/path
		var/list/contents = valid_contents[i]
		if(metadata[i] == "Random")
			path = pick(contents)
			path = contents[path]
		else if(metadata[i] == "None")
			continue
		else
			path = 	contents[metadata[i]]
		new path(I)

/*
* Ragent adjustment
*/

/datum/gear_tweak/reagents
	var/list/valid_reagents

/datum/gear_tweak/reagents/New(var/list/reagents)
	valid_reagents = reagents.Copy()
	..()

/datum/gear_tweak/reagents/get_contents(var/metadata)
	return "Reagents: [metadata]"

/datum/gear_tweak/reagents/get_default()
	return "Random"

/datum/gear_tweak/reagents/get_metadata(var/user, var/list/metadata)
	. = input(user, "Choose an entry.", "Character Preference", metadata) as null|anything in (valid_reagents + list("Random", "None"))
	if(!.)
		return metadata

/datum/gear_tweak/reagents/tweak_item(var/obj/item/I, var/list/metadata)
	if(metadata == "None")
		return
	if(metadata == "Random")
		. = valid_reagents[pick(valid_reagents)]
	else
		. = valid_reagents[metadata]
	I.reagents.add_reagent(., I.reagents.available_volume())

//Custom name and desciption code
//note to devs downstream: where 'gear_tweaks = list(gear_tweak_free_color_choice)' was used before for color selection
//in the loadout, now 'gear_tweaks += gear_tweak_free_color_choice' will need to be used, otherwise the item will not
// be able to be given a custom name or description
/*
Custom Name
*/

var/datum/gear_tweak/custom_name/gear_tweak_free_name = new()

/datum/gear_tweak/custom_name
	var/list/valid_custom_names

/datum/gear_tweak/custom_name/New(var/list/valid_custom_names)
	src.valid_custom_names = valid_custom_names
	..()

/datum/gear_tweak/custom_name/get_contents(var/metadata)
	return "Name: [metadata]"

/datum/gear_tweak/custom_name/get_default()
	return ""

/datum/gear_tweak/custom_name/get_metadata(var/user, var/metadata)
	if(jobban_isbanned(user, "Custom loadout"))
		to_chat(user, WARNING("You are banned from using custom loadout names/descriptions."))
		return
	if(valid_custom_names)
		return input(user, "Choose an item name.", "Character Preference", metadata) as null|anything in valid_custom_names
	return sanitize(input(user, "Choose the item's name. Leave it blank to use the default name.", "Item Name", metadata) as text|null, MAX_LNAME_LEN, extra = 0)

/datum/gear_tweak/custom_name/tweak_item(var/obj/item/I, var/metadata)
	if(!metadata)
		return I.name
	I.name = metadata

/*
Custom Description
*/
var/datum/gear_tweak/custom_desc/gear_tweak_free_desc = new()

/datum/gear_tweak/custom_desc
	var/list/valid_custom_desc

/datum/gear_tweak/custom_desc/New(var/list/valid_custom_desc)
	src.valid_custom_desc = valid_custom_desc
	..()

/datum/gear_tweak/custom_desc/get_contents(var/metadata)
	return "Description: [metadata]"

/datum/gear_tweak/custom_desc/get_default()
	return ""

/datum/gear_tweak/custom_desc/get_metadata(var/user, var/metadata)
	if(jobban_isbanned(user, "Custom loadout"))
		to_chat(user, WARNING("You are banned from using custom loadout names/descriptions."))
		return
	if(valid_custom_desc)
		return input(user, "Choose an item description.", "Character Preference", metadata) as null|anything in valid_custom_desc
	return sanitize(input(user, "Choose the item's description. Leave it blank to use the default description.", "Item Description", metadata) as message|null, extra = 0)

/datum/gear_tweak/custom_desc/tweak_item(var/obj/item/I, var/metadata)
	if(!metadata)
		return I.desc
	I.desc = metadata

//end of custom description


/datum/gear_tweak/tablet
	var/list/ValidProcessors = list(/obj/item/computer_hardware/processor_unit/small)
	var/list/ValidBatteries = list(/obj/item/computer_hardware/battery_module/nano, /obj/item/computer_hardware/battery_module/micro, /obj/item/computer_hardware/battery_module)
	var/list/ValidHardDrives = list(/obj/item/computer_hardware/hard_drive/micro, /obj/item/computer_hardware/hard_drive/small, /obj/item/computer_hardware/hard_drive)
	var/list/ValidNetworkCards = list(/obj/item/computer_hardware/network_card, /obj/item/computer_hardware/network_card/advanced)
	var/list/ValidNanoPrinters = list(null, /obj/item/computer_hardware/nano_printer)
	var/list/ValidCardSlots = list(null, /obj/item/computer_hardware/card_slot)
	var/list/ValidTeslaLinks = list(null, /obj/item/computer_hardware/tesla_link)

/datum/gear_tweak/tablet/get_contents(var/list/metadata)
	var/list/names = list()
	var/obj/O = ValidProcessors[metadata[1]]
	if(O)
		names += initial(O.name)
	O = ValidBatteries[metadata[2]]
	if(O)
		names += initial(O.name)
	O = ValidHardDrives[metadata[3]]
	if(O)
		names += initial(O.name)
	O = ValidNetworkCards[metadata[4]]
	if(O)
		names += initial(O.name)
	O = ValidNanoPrinters[metadata[5]]
	if(O)
		names += initial(O.name)
	O = ValidCardSlots[metadata[6]]
	if(O)
		names += initial(O.name)
	O = ValidTeslaLinks[metadata[7]]
	if(O)
		names += initial(O.name)
	return "[english_list(names, and_text = ", ")]"

/datum/gear_tweak/tablet/get_metadata(var/user, var/metadata)
	. = list()

	var/list/names = list()
	var/counter = 1
	for(var/i in ValidProcessors)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	var/entry = input(user, "Choose a processor.", "Character Preference") in names
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidBatteries)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	entry = input(user, "Choose a battery.", "Character Preference") in names
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidHardDrives)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	entry = input(user, "Choose a hard drive.", "Character Preference") in names
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidNetworkCards)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	entry = input(user, "Choose a network card.", "Character Preference") in names
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidNanoPrinters)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	entry = input(user, "Choose a nanoprinter.", "Character Preference") in names
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidCardSlots)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	entry = input(user, "Choose a card slot.", "Character Preference") in names
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidTeslaLinks)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	entry = input(user, "Choose a tesla link.", "Character Preference") in names
	. += names[entry]

/datum/gear_tweak/tablet/get_default()
	return list(1, 1, 1, 1, 1, 1, 1)

/datum/gear_tweak/tablet/tweak_item(var/obj/item/modular_computer/tablet/I, var/list/metadata)
	if(ValidProcessors[metadata[1]])
		var/t = ValidProcessors[metadata[1]]
		I.processor_unit = new t(I)
	if(ValidBatteries[metadata[2]])
		var/t = ValidBatteries[metadata[2]]
		I.battery_module = new t(I)
		I.battery_module.charge_to_full()
	if(ValidHardDrives[metadata[3]])
		var/t = ValidHardDrives[metadata[3]]
		I.hard_drive = new t(I)
	if(ValidNetworkCards[metadata[4]])
		var/t = ValidNetworkCards[metadata[4]]
		I.network_card = new t(I)
	if(ValidNanoPrinters[metadata[5]])
		var/t = ValidNanoPrinters[metadata[5]]
		I.nano_printer = new t(I)
	if(ValidCardSlots[metadata[6]])
		var/t = ValidCardSlots[metadata[6]]
		I.card_slot = new t(I)
	if(ValidTeslaLinks[metadata[7]])
		var/t = ValidTeslaLinks[metadata[7]]
		I.tesla_link = new t(I)
	I.update_verbs()

/datum/gear_tweak/laptop
	var/list/ValidProcessors = list(/obj/item/computer_hardware/processor_unit/small, /obj/item/computer_hardware/processor_unit)
	var/list/ValidBatteries = list(/obj/item/computer_hardware/battery_module, /obj/item/computer_hardware/battery_module/advanced, /obj/item/computer_hardware/battery_module/super)
	var/list/ValidHardDrives = list(/obj/item/computer_hardware/hard_drive, /obj/item/computer_hardware/hard_drive/advanced, /obj/item/computer_hardware/hard_drive/super)
	var/list/ValidNetworkCards = list(/obj/item/computer_hardware/network_card, /obj/item/computer_hardware/network_card/advanced)
	var/list/ValidNanoPrinters = list(null, /obj/item/computer_hardware/nano_printer)
	var/list/ValidCardSlots = list(null, /obj/item/computer_hardware/card_slot)
	var/list/ValidTeslaLinks = list(null, /obj/item/computer_hardware/tesla_link)

/datum/gear_tweak/laptop/get_contents(var/list/metadata)
	var/list/names = list()
	var/obj/O = ValidProcessors[metadata[1]]
	if(O)
		names += initial(O.name)
	O = ValidBatteries[metadata[2]]
	if(O)
		names += initial(O.name)
	O = ValidHardDrives[metadata[3]]
	if(O)
		names += initial(O.name)
	O = ValidNetworkCards[metadata[4]]
	if(O)
		names += initial(O.name)
	O = ValidNanoPrinters[metadata[5]]
	if(O)
		names += initial(O.name)
	O = ValidCardSlots[metadata[6]]
	if(O)
		names += initial(O.name)
	O = ValidTeslaLinks[metadata[7]]
	if(O)
		names += initial(O.name)
	return "[english_list(names, and_text = ", ")]"

/datum/gear_tweak/laptop/get_metadata(var/user, var/metadata)
	. = list()

	var/list/names = list()
	var/counter = 1
	for(var/i in ValidProcessors)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	var/entry = input(user, "Choose a processor.", "Character Preference") in names
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidBatteries)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	entry = input(user, "Choose a battery.", "Character Preference") in names
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidHardDrives)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	entry = input(user, "Choose a hard drive.", "Character Preference") in names
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidNetworkCards)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	entry = input(user, "Choose a network card.", "Character Preference") in names
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidNanoPrinters)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	entry = input(user, "Choose a nanoprinter.", "Character Preference") in names
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidCardSlots)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	entry = input(user, "Choose a card slot.", "Character Preference") in names
	. += names[entry]

	names = list()
	counter = 1
	for(var/i in ValidTeslaLinks)
		if(i)
			var/obj/O = i
			names[initial(O.name)] = counter++
		else
			names["None"] = counter++

	entry = input(user, "Choose a tesla link.", "Character Preference") in names
	. += names[entry]

/datum/gear_tweak/laptop/get_default()
	return list(1, 1, 1, 1, 1, 1, 1)

/datum/gear_tweak/laptop/tweak_item(var/obj/item/modular_computer/laptop/preset/I, var/list/metadata)
	if(ValidProcessors[metadata[1]])
		var/t = ValidProcessors[metadata[1]]
		I.processor_unit = new t(I)
	if(ValidBatteries[metadata[2]])
		var/t = ValidBatteries[metadata[2]]
		I.battery_module = new t(I)
		I.battery_module.charge_to_full()
	if(ValidHardDrives[metadata[3]])
		var/t = ValidHardDrives[metadata[3]]
		I.hard_drive = new t(I)
	if(ValidNetworkCards[metadata[4]])
		var/t = ValidNetworkCards[metadata[4]]
		I.network_card = new t(I)
	if(ValidNanoPrinters[metadata[5]])
		var/t = ValidNanoPrinters[metadata[5]]
		I.nano_printer = new t(I)
	if(ValidCardSlots[metadata[6]])
		var/t = ValidCardSlots[metadata[6]]
		I.card_slot = new t(I)
	if(ValidTeslaLinks[metadata[7]])
		var/t = ValidTeslaLinks[metadata[7]]
		I.tesla_link = new t(I)
	I.update_verbs()

/datum/gear_tweak/collar_tag/get_contents(var/metadata)
	return "Tag: [metadata]"

/datum/gear_tweak/collar_tag/get_default()
	return ""

/datum/gear_tweak/collar_tag/get_metadata(var/user, var/metadata)
	return sanitize( input(user, "Choose the tag text", "Character Preference", metadata) as text , MAX_NAME_LEN )

/datum/gear_tweak/collar_tag/tweak_item(var/obj/item/clothing/accessory/collar/C, var/metadata)
	if(metadata == "")
		return ..()
	else
		C.initialize_tag(metadata)
