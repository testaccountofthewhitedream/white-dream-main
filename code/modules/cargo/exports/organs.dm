/datum/export/organ
	include_subtypes = FALSE	//CentCom doesn't need organs from non-humans.
	export_category = EXPORT_CONTRABAND

/datum/export/organ/heart
	cost = 10 //For the man who has everything and nothing.
	unit_name = "гуманоидное сердце"
	export_types = list(/obj/item/organ/heart)

/datum/export/organ/eyes
	cost = 5
	unit_name = "гуманоидные глаза"
	export_types = list(/obj/item/organ/eyes)

/datum/export/organ/ears
	cost = 5
	unit_name = "гуманоидные уши"
	export_types = list(/obj/item/organ/ears)

/datum/export/organ/liver
	cost = 5
	unit_name = "гуманоидные печень"
	export_types = list(/obj/item/organ/liver)

/datum/export/organ/lungs
	cost = 5
	unit_name = "гуманоидные легкие"
	export_types = list(/obj/item/organ/lungs)

/datum/export/organ/stomach
	cost = 5
	unit_name = "гуманоидный желудок"
	export_types = list(/obj/item/organ/stomach)

/datum/export/organ/tongue
	cost = 5
	unit_name = "гуманоидный язык"
	export_types = list(/obj/item/organ/tongue)

/datum/export/organ/tail/lizard
	cost = 250
	unit_name = "lizard tail"
	export_types = list(/obj/item/organ/tail/lizard)


/datum/export/organ/tail/cat
	cost = 300
	unit_name = "cat tail"
	export_types = list(/obj/item/organ/tail/cat)

/datum/export/organ/ears/cat
	cost = 200
	unit_name = "cat ears"
	export_types = list(/obj/item/organ/ears/cat)

