/datum/gm_action/ionstorm
	name = "ion storm"
	departments = list(DEPARTMENT_SYNTHETIC)
	var/botEmagChance = 0.5
	var/list/players = list()
	var/active = FALSE
	length = 1 MINUTE

/datum/gm_action/ionstorm/set_up()
	length = rand(length, length * 10)
//		command_alert("The station has entered an ion storm.  Monitor all electronic equipment for malfunctions", "Anomaly Alert")
	for (var/mob/living/carbon/human/player in GLOB.player_list)
		if(	!player.mind || player.client.inactivity > MinutesToTicks(10))
			continue
		players += player.real_name

	for (var/mob/living/silicon/ai/target in silicon_mob_list)
		var/law = target.generate_ion_law()
		to_chat(target, "<font color='red'><b>You have detected a change in your laws information:</b></font>")
		to_chat(target, law)
		target.add_ion_law(law)
		target.show_laws()

/datum/gm_action/ionstorm/announce()
	if(message_servers)
		for (var/obj/machinery/message_server/MS in message_servers)
			MS.spamfilter.Cut()
			var/i
			for (i = 1, i <= MS.spamfilter_limit, i++)
				MS.spamfilter += pick("kitty","HONK","rev","malf","liberty","freedom","drugs", "[(LEGACY_MAP_DATUM).station_short]", \
					"admin","ponies","heresy","meow","Pun Pun","monkey","Ian","moron","pizza","message","spam",\
					"director", "Hello", "Hi!"," ","nuke","crate","dwarf","xeno")

/datum/gm_action/ionstorm/start()
	while(active)
		sleep(1)
		if(botEmagChance)
			for(var/mob/living/bot/bot in GLOB.mob_list)
				if(prob(botEmagChance))
					bot.emag_act(1)

/datum/gm_action/ionstorm/end()
	spawn(rand(5000,8000))
		if(prob(50))
			ion_storm_announcement()

/datum/gm_action/ionstorm/get_weight()
	var/bots = metric.count_people_in_department(DEPARTMENT_SYNTHETIC)
	var/weight = 5 + (bots * 20)
	return weight
