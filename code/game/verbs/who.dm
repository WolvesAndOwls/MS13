/client/verb/who()
	set name = "Who"
	set category = "OOC"

	var/msg = "<b>Current Players:</b>\n"

	var/list/Lines = list()

	if(holder && (R_ADMIN & holder.rights || R_MOD & holder.rights))
		for(var/client/C in GLOB.clients)
			var/entry = "\t[C.key]"
			if(C.holder && C.holder.fakekey)
				entry += " <i>(as [C.holder.fakekey])</i>"
			if(!C.initialized)
				entry += " - [SPAN_BOLDANNOUNCE("UNINITIALIZED!")]"
				continue
			if(isnull(C.mob))
				entry += " - [SPAN_BOLDANNOUNCE("NULL MOB!")]"
				continue
			entry += " - Playing as [C.mob.real_name]"
			switch(C.mob.stat)
				if(UNCONSCIOUS)
					entry += " - <font color='darkgray'><b>Unconscious</b></font>"
				if(DEAD)
					if(isobserver(C.mob))
						var/mob/observer/dead/O = C.mob
						if(O.started_as_observer)
							entry += " - <font color='gray'>Observing</font>"
						else
							entry += " - <font color='black'><b>DEAD</b></font>"
					else
						entry += " - <font color='black'><b>DEAD</b></font>"

			var/age
			if(isnum(C.player.player_age))
				age = C.player.player_age
			else
				age = 0

			if(age <= 1)
				age = "<font color='#ff0000'><b>[age]</b></font>"
			else if(age < 10)
				age = "<font color='#ff8c00'><b>[age]</b></font>"

			entry += " - [age]"

			if(C.is_afk())
				var/seconds = C.last_activity_seconds()
				entry += " (AFK - "
				entry += "[round(seconds / 60)] minutes, "
				entry += "[seconds % 60] seconds)"

			entry += " (<A HREF='?_src_=holder;adminmoreinfo=\ref[C.mob]'>?</A>)"
			Lines += entry
	else
		for(var/client/C in GLOB.clients)
			if(C.holder && C.holder.fakekey)
				Lines += C.holder.fakekey
			else
				Lines += C.key

	for(var/line in sortList(Lines))
		msg += "[line]\n"

	msg += "<b>Total Players: [length(Lines)]</b>"
	to_chat(src, msg)

/client/verb/staffwho()
	set category = "Admin"
	set name = "Staffwho"

	var/msg = ""
	var/num_admins_online = 0
	if(holder)
		for(var/client/C in GLOB.admins)
			if(C.holder.fakekey && !((R_ADMIN|R_MOD) & holder.rights))
				continue

			msg += "\t[C] is a [C.holder.rank]"

			if(C.holder.fakekey)
				msg += " <i>(as [C.holder.fakekey])</i>"

			if(isobserver(C.mob))
				msg += " - Observing"
			else if(istype(C.mob,/mob/new_player))
				msg += " - Lobby"
			else
				msg += " - Playing"

			if(C.is_afk())
				var/seconds = C.last_activity_seconds()
				msg += " (AFK - "
				msg += "[round(seconds / 60)] minutes, "
				msg += "[seconds % 60] seconds)"
			msg += "\n"
			num_admins_online++

	else
		for(var/client/C in GLOB.admins)
			if(C.holder.fakekey)
				continue	// hidden
			msg += "\t[C] is a [C.holder.rank]"
			num_admins_online++
			if(C.is_afk(10 MINUTES))
				if(C.is_afk(30 MINUTES))
					msg += " (AFK \[30m+\])"
				else
					msg += " (Inactive \[10m+\])"
			msg += "\n"


	if(config_legacy.admin_irc)
		to_chat(src, "<span class='info'>Adminhelps are also sent to IRC. If no admins are available in game try anyway and an admin on IRC may see it and respond.</span>")
	msg = "<b>Current Admins ([num_admins_online]):</b>\n" + msg

	to_chat(src, msg)
