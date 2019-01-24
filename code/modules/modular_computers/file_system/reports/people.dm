// TODO: REMOVE CALLBACKS AND USE WHATEVER AFTERTHOUGHT SAID
/*
[11:56 PM] afterthought: if I were you I'd make a datum that does two things: manages data for the nanoui interface and provides the template, and then fields any Topic callsrouted to it (and stores relevant internal state, etc)
[11:56 PM] afterthought: then in program.ui_interact, you call this thing's data proc and use it's template when in delegate-to-handler state
[11:57 PM] afterthought: and in program.Topic() you do the usual checks, intercept any flag for the delegate, and send the Topic call there
[11:58 PM] afterthought: problem with just raw nano_modules for IC stuff is that you need to check interaction handling somewhere (which is potentially pretty hard)
[11:58 PM] afterthought: and computers do all the work for you
*/
//Field with people in it; has some communications procs available to it.
/datum/report_field/people/proc/send_email(mob/user, datum/nanoui/master_ui, datum/callback/cb)
	// master_ui is the UI who started this, thus it'll handle visibility.
	if(!get_value())
		cb.Invoke(user, src.owner)
		return //No one to send to anyway.
	var/datum/nano_module/send_report_prompt/send_prompt = new(src, cb = cb)
	send_prompt.ui_interact(user, master_ui = master_ui)

// Prompting a bunch of alert boxes is probably not fun. So a nano ui filled with the questions should make it better and pretty.
// Also what is over engineering
/datum/nano_module/send_report_prompt
	name = "Send Report"
	var/datum/report_field/people/field = null
	var/datum/callback/cb = null
	var/subject = null
	var/body = null
	var/attach_report = TRUE

/datum/nano_module/send_report_prompt/New(datum/host, topic_manager, datum/callback/cb)
	field = host
	src.cb = cb
	..()
	reset()

/datum/nano_module/send_report_prompt/proc/reset()
	// Resets everything to defaults.
	subject = "Report Submission: [field.owner.display_name()]"
	body = "Please see the attached document."
	attach_report = initial(attach_report)

/datum/nano_module/send_report_prompt/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1, master_ui = null, datum/topic_state/state = GLOB.interactive_state)
	var/list/data = initial_data()
	data["recipients"] = field.get_value()
	data["subject"] = subject
	data["body"] = pencode2html(body)
	data["attach_report"] = attach_report
	ui = SSnano.try_update_ui(user, src, ui_key, ui, data, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "send_report_prompt.tmpl", "Sending Report: [field.owner.display_name()]", 800, 700, master_ui = master_ui, state = state)
		ui.set_initial_data(data)
		ui.open()

/datum/nano_module/send_report_prompt/Topic(ref, href_list, var/datum/topic_state/state = GLOB.interactive_state)
	var/user = usr
	if(href_list["edit_subject"])
		// Edit subject and respect max length.
		var/new_subject = sanitize(replacetext(input(user, "Email Subject:", "Enter title for your message:", subject) as null|text, "\n", "\[br\]"), MAX_EMAIL_SUBJECT_LEN)
		if(new_subject)
			subject = new_subject

		return TOPIC_REFRESH

	if(href_list["edit_body"])
		// Edit body and respect max length.
		var/old_body = replacetext(html_decode(body), "\[br\]", "\n")
		var/new_body = sanitize(replacetext(input(user, "Email Body:", "Enter your message. You may use most tags from paper formatting", old_body) as null|message, "\n", "\[br\]"), MAX_EMAIL_BODY_LEN)
		if(new_body)
			body = new_body

		return TOPIC_REFRESH

	if(href_list["toggle_attach_report"])
		// Toggles if the report is attached.
		attach_report = !attach_report
		return TOPIC_REFRESH
	
	if(href_list["append_report"])
		// Appends the report to the subject while respecting the max email body length.
		var/new_body = sanitize(html_decode(body + field.owner.generate_pencode(get_access(user), no_html = TRUE)), MAX_EMAIL_BODY_LEN)
		if(new_body)
			body = new_body

		return TOPIC_REFRESH
	
	if(href_list["template_reset"])
		// Resets the template to defaults.
		reset()
		return TOPIC_REFRESH
	
	if(href_list["template_report_body_only"])
		// Template for attaching the report as part of the body.
		var/new_body = sanitize(html_decode(field.owner.generate_pencode(get_access(user), no_html = TRUE)), MAX_EMAIL_BODY_LEN)
		if(new_body)
			body = new_body
		
		attach_report = FALSE
		return TOPIC_REFRESH
	
	if(href_list["template_report_body_and_attached"])
		// Template for attaching the report as part of the body and as a .RPT.
		var/new_body = sanitize(html_decode(field.owner.generate_pencode(get_access(user), no_html = TRUE)), MAX_EMAIL_BODY_LEN)
		if(new_body)
			body = new_body
		
		attach_report = TRUE
		return TOPIC_REFRESH
	
	if(href_list["template_report_attached_only"])
		// Similar to reset(), but avoids the subject.
		body = "Please see the attached document."
		attach_report = TRUE
		return TOPIC_REFRESH
	
	if(href_list["send_report"])
		// Email the report.
		if(field.perform_send(subject, body, attach_report))
			to_chat(user, SPAN_NOTICE("The email has been sent."))
			if(cb)
				cb.Invoke(user, field.owner)
			SSnano.get_open_ui(user, src, "main").close() // Close the nano ui since it's no longer needed.

/datum/nano_module/send_report_prompt/Destroy()
	field = null
	cb = null
	. = ..()

//Helper procs.
/datum/report_field/people/proc/perform_send(subject, body, attach_report)
	return

/datum/report_field/people/proc/send_to_recipient(subject, body, attach_report, recipient)
	var/datum/computer_file/data/email_account/server = ntnet_global.find_email_by_name(EMAIL_DOCUMENTS)
	var/datum/computer_file/data/email_message/message = new()
	message.title = subject
	message.stored_data = body
	message.source = server.login
	if(attach_report)
		message.attachment = owner.clone()
	server.send_mail(recipient, message)

/datum/report_field/people/proc/format_output(name, rank, milrank)
	. = list()
	if(milrank)
		. += milrank
	. += name
	if(rank)
		. += "([rank])"
	return jointext(., " ")

//Lets you select one person on the manifest.
/datum/report_field/people/from_manifest
	value = list()

/datum/report_field/people/from_manifest/get_value()
	return format_output(value["name"], value["rank"], value["milrank"])

/datum/report_field/people/from_manifest/set_value(given_value)
	if(!given_value)
		value = list()
	if(!in_as_list(given_value, flat_nano_crew_manifest()))
		return //Check for inclusion, but have to be careful when checking list equivalence.
	value = given_value

/datum/report_field/people/from_manifest/ask_value(mob/user)
	var/list/full_manifest = flat_nano_crew_manifest()
	var/list/formatted_manifest = list()
	for(var/entry in full_manifest)
		formatted_manifest[format_output(entry["name"], entry["rank"], entry["milrank"])] = entry
	var/input = input(user, "[display_name()]:", "Form Input", get_value()) as null|anything in formatted_manifest
	set_value(formatted_manifest[input])

/datum/report_field/people/from_manifest/perform_send(subject, body, attach_report)
	var/login = find_email(value["name"])
	send_to_recipient(subject, body, attach_report, login)
	return 1

//Lets you select multiple people.
/datum/report_field/people/list_from_manifest
	value = list()
	needs_big_box = 1

/datum/report_field/people/list_from_manifest/get_value(in_line = 0)
	var/dat = list()
	for(var/entry in value)
		var/milrank = entry["milrank"]
		if(in_line && (GLOB.using_map.flags & MAP_HAS_RANK))
			var/datum/computer_file/report/crew_record/CR = get_crewmember_record(entry["name"])
			if(CR)
				var/datum/mil_rank/rank_obj = mil_branches.get_rank(CR.get_branch(), CR.get_rank())
				milrank = (rank_obj ? rank_obj.name_short : "")
		dat += format_output(entry["name"], in_line ? null : entry["rank"], milrank)
	return jointext(dat, in_line ? ", " : "<br>")

/datum/report_field/people/list_from_manifest/set_value(given_value)
	var/list/full_manifest = flat_nano_crew_manifest()
	var/list/new_value = list()
	if(!islist(given_value))
		return
	for(var/entry in given_value)
		if(!in_as_list(entry, full_manifest))
			return
		if(in_as_list(entry, new_value))
			continue //ignore repeats
		new_value += list(entry)
	value = new_value	

/datum/report_field/people/list_from_manifest/ask_value(mob/user)
	var/alert = alert(user, "Would you like to add or remove a name?", "Form Input", "Add", "Remove")
	var/list/formatted_manifest = list()
	switch(alert)
		if("Add")
			var/list/full_manifest = flat_nano_crew_manifest()
			for(var/entry in full_manifest)
				if(!in_as_list(entry, value)) //Only look at those not already selected.
					formatted_manifest[format_output(entry["name"], entry["rank"], entry["milrank"])] = entry
			var/input = input(user, "Add to [display_name()]:", "Form Input", null) as null|anything in formatted_manifest
			set_value(value + list(formatted_manifest[input]))
		if("Remove")
			for(var/entry in value)
				formatted_manifest[format_output(entry["name"], entry["rank"], entry["milrank"])] = entry
			var/input = input(user, "Remove from [display_name()]:", "Form Input", null) as null|anything in formatted_manifest
			set_value(value - list(formatted_manifest[input]))

//Batch-emails the list.
/datum/report_field/people/list_from_manifest/perform_send(subject, body, attach_report)
	for(var/entry in value)
		var/login = find_email(entry["name"])
		send_to_recipient(subject, body, attach_report, login)
	return 1