/datum/design/aimodule
	build_type = IMPRINTER
	materials = list(MAT_GLASS = 2000, MAT_GOLD = 100)

/datum/design/aimodule/AssembleDesignName()
	name = "AI module design ([name])"

/datum/design/aimodule/AssembleDesignDesc()
	desc = "Allows for the construction of \a '[name]' AI module."

/datum/design/aimodule/safeguard
	name = "Safeguard"
	id = "safeguard"
	req_tech = list(TECH_DATA = 3, TECH_MATERIAL = 4)
	build_path = /obj/item/aiModule/safeguard
	sort_string = "XABAA"

/datum/design/aimodule/onehuman
	name = "OneCrewMember"
	id = "onehuman"
	req_tech = list(TECH_DATA = 4, TECH_MATERIAL = 6)
	build_path = /obj/item/aiModule/oneHuman
	sort_string = "XABAB"

/datum/design/aimodule/protectstation
	name = "ProtectStation"
	id = "protectstation"
	req_tech = list(TECH_DATA = 3, TECH_MATERIAL = 6)
	build_path = /obj/item/aiModule/protectStation
	sort_string = "XABAC"

/datum/design/aimodule/notele
	name = "TeleporterOffline"
	id = "notele"
	req_tech = list(TECH_DATA = 3)
	build_path = /obj/item/aiModule/teleporterOffline
	sort_string = "XABAD"

/datum/design/aimodule/quarantine
	name = "Quarantine"
	id = "quarantine"
	req_tech = list(TECH_DATA = 3, TECH_BIO = 2, TECH_MATERIAL = 4)
	build_path = /obj/item/aiModule/quarantine
	sort_string = "XABAE"

/datum/design/aimodule/oxygen
	name = "OxygenIsToxicToHumans"
	id = "oxygen"
	req_tech = list(TECH_DATA = 3, TECH_BIO = 2, TECH_MATERIAL = 4)
	build_path = /obj/item/aiModule/oxygen
	sort_string = "XABAF"

/datum/design/aimodule/freeform
	name = "Freeform"
	id = "freeform"
	req_tech = list(TECH_DATA = 4, TECH_MATERIAL = 4)
	build_path = /obj/item/aiModule/freeform
	sort_string = "XABAG"

/datum/design/aimodule/reset
	name = "Reset"
	id = "reset"
	req_tech = list(TECH_DATA = 3, TECH_MATERIAL = 6)
	build_path = /obj/item/aiModule/reset
	sort_string = "XAAAZ"	// Duplicate string, really need to redo this whole thing

/datum/design/aimodule/purge
	name = "Purge"
	id = "purge"
	req_tech = list(TECH_DATA = 4, TECH_MATERIAL = 6)
	build_path = /obj/item/aiModule/purge
	sort_string = "XAAAB"

// Core modules
/datum/design/aimodule/core
	req_tech = list(TECH_DATA = 4, TECH_MATERIAL = 6)

/datum/design/aimodule/core/AssembleDesignName()
	name = "AI core module design ([name])"

/datum/design/aimodule/core/AssembleDesignDesc()
	desc = "Allows for the construction of \a '[name]' AI core module."

/datum/design/aimodule/core/asimov
	name = "Asimov"
	id = "asimov"
	build_path = /obj/item/aiModule/asimov
	sort_string = "XACAB"

