/mob/living/carbon/human/say(var/message,var/whispering=0)
	var/alt_name = ""
	if(name != GetVoice())
		alt_name = "(as [get_id_name("Unknown")])"

	message = sanitize_or_reflect(message,src) // Reflect too-long messages, within reason
	..(message, alt_name = alt_name, whispering = whispering)

/mob/living/carbon/human/proc/forcesay(list/append)
	if(stat == CONSCIOUS)
		if(client)
			var/virgin = 1	//has the text been modified yet?
			var/temp = winget(client, "input", "text")
			if(findtextEx(temp, "Say \"", 1, 7) && length(temp) > 5)	//case sensitive means

				temp = replacetext_char(temp, ";", "")	//general radio

				if(findtext_char(trim_left(temp), ":", 6, 7))	//dept radio
					temp = copytext_char(trim_left(temp), 8)
					virgin = 0

				if(virgin)
					temp = copytext_char(trim_left(temp), 6)	//normal speech
					virgin = 0

				while(findtext_char(trim_left(temp), ":", 1, 2))	//dept radio again (necessary)
					temp = copytext_char(trim_left(temp), 3)

				if(findtext_char(temp, "*", 1, 2))	//emotes
					return
				temp = copytext_char(trim_left(temp), 1, rand(5,8))

				var/trimmed = trim_left(temp)
				if(length(trimmed))
					if(append)
						temp += pick(append)

					say(temp)
				winset(client, "input", "text=[null]")

/mob/living/carbon/human/speech_bubble_appearance()
	if(isSynthetic())
		var/datum/robolimb/robo = isSynthetic()
		return robo.speech_bubble_appearance
	else
		if(species)
			return species.speech_bubble_appearance
	return "normal"

/mob/living/carbon/human/say_understands(var/mob/other,var/datum/language/speaking = null)

	if(species.can_understand(other))
		return 1

	//These only pertain to common. Languages are handled by mob/say_understands()
	if (!speaking)
		if (istype(other, /mob/living/carbon/alien/diona))
			if(other.languages.len >= 2) //They've sucked down some blood and can speak common now.
				return 1
		if (istype(other, /mob/living/silicon))
			return 1
		if (istype(other, /mob/living/carbon/brain))
			return 1
		if (istype(other, /mob/living/simple_mob/slime))
			return 1

	//This is already covered by mob/say_understands()
	//if (istype(other, /mob/living/simple_mob))
	//	if((other.universal_speak && !speaking) || src.universal_speak || src.universal_understand)
	//		return 1
	//	return 0

	return ..()

/mob/living/carbon/human/GetVoice()

	var/voice_sub
	if(istype(back,/obj/item/hardsuit))
		var/obj/item/hardsuit/hardsuit = back
		// todo: fix this shit
		if(hardsuit.speech && hardsuit.speech.voice_holder && hardsuit.speech.voice_holder.active && hardsuit.speech.voice_holder.voice)
			voice_sub = hardsuit.speech.voice_holder.voice
	if(!voice_sub)	// If the hardsuit has a voice changer, then we use that. Otherwise, use this
		for(var/obj/item/gear in list(wear_mask,wear_suit,head))
			if(!gear)
				continue
			var/obj/item/voice_changer/changer = locate() in gear
			if(changer && changer.active)
				if(changer.voice)
					voice_sub = changer.voice
				else
					voice_sub = get_id_name()
	if(voice_sub)
		return voice_sub
	if(GetSpecialVoice())
		return GetSpecialVoice()
	return real_name

/mob/living/carbon/human/proc/SetSpecialVoice(var/new_voice)
	if(new_voice)
		special_voice = new_voice
	return

/mob/living/carbon/human/proc/UnsetSpecialVoice()
	special_voice = ""
	return

/mob/living/carbon/human/proc/GetSpecialVoice()
	return special_voice


/*
   ***Deprecated***
   let this be handled at the hear_say or hear_radio proc
   This is left in for robot speaking when humans gain binary channel access until I get around to rewriting
   robot_talk() proc.
   There is no language handling build into it however there is at the /mob level so we accept the call
   for it but just ignore it.
*/

/mob/living/carbon/human/say_quote(var/message, var/datum/language/speaking = null)
	var/verb = "says"
	var/ending = copytext_char(message, length(message))

	if(speaking)
		verb = speaking.get_spoken_verb(ending)
	else
		if(ending == "!")
			verb=pick("exclaims","shouts","yells")
		else if(ending == "?")
			verb="asks"

	return verb

/mob/living/carbon/human/handle_speech_problems(var/list/message_data)
	if(sdisabilities & SDISABILITY_MUTE)
		message_data[1] = ""
		. = 1

	else if(istype(wear_mask, /obj/item/clothing/mask))
		var/obj/item/clothing/mask/M = wear_mask
		if(M.voicechange)
			message_data[1] = pick(M.say_messages)
			message_data[2] = pick(M.say_verbs)
			. = 1

	else
		. = ..(message_data)

/mob/living/carbon/human/handle_message_mode(message_mode, message, verb, speaking, used_radios, alt_name)
	switch(message_mode)
		if("intercom")
			if(!src.restrained())
				for(var/obj/item/radio/intercom/I in view(1))
					I.talk_into(src, message, null, verb, speaking)
					I.add_fingerprint(src)
					used_radios += I
		if("headset")
			if(l_ear && istype(l_ear,/obj/item/radio))
				var/obj/item/radio/R = l_ear
				R.talk_into(src,message,null,verb,speaking)
				used_radios += l_ear
			else if(r_ear && istype(r_ear,/obj/item/radio))
				var/obj/item/radio/R = r_ear
				R.talk_into(src,message,null,verb,speaking)
				used_radios += r_ear
		if("right ear")
			var/obj/item/radio/R
			var/has_radio = 0
			if(r_ear && istype(r_ear,/obj/item/radio))
				R = r_ear
				has_radio = 1
			if(r_hand && istype(r_hand, /obj/item/radio))
				R = r_hand
				has_radio = 1
			if(has_radio)
				R.talk_into(src,message,null,verb,speaking)
				used_radios += R
		if("left ear")
			var/obj/item/radio/R
			var/has_radio = 0
			if(l_ear && istype(l_ear,/obj/item/radio))
				R = l_ear
				has_radio = 1
			if(l_hand && istype(l_hand,/obj/item/radio))
				R = l_hand
				has_radio = 1
			if(has_radio)
				R.talk_into(src,message,null,verb,speaking)
				used_radios += R
		else
			if(message_mode)
				if(l_ear && istype(l_ear,/obj/item/radio))
					l_ear.talk_into(src,message, message_mode, verb, speaking)
					used_radios += l_ear
				else if(r_ear && istype(r_ear,/obj/item/radio))
					r_ear.talk_into(src,message, message_mode, verb, speaking)
					used_radios += r_ear

/mob/living/carbon/human/handle_speech_sound()
	if(species.speech_sounds && prob(species.speech_chance))
		var/list/returns[2]
		returns[1] = sound(pick(species.speech_sounds))
		returns[2] = 50
	return ..()
