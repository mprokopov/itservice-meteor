@fromDuration = (str) ->
	[hours, minutes] = str.split(":")
	parseInt(hours) * 3600 + parseInt(minutes) * 60

UI.registerHelper 'to_duration', (duration) ->
	
	if duration < 0 
		direction="-"
		duration = -duration
	else
		direction=""
	

	hours = parseInt(duration / 3600)
	mins = parseInt (duration - hours * 3600)/60
	"#{direction}#{pad hours}:#{pad mins}"


UI.registerHelper 'ticket_icon', ->
	switch @type
		when 'Incident' then  'icon-bug'
		when 'ServiceRequest' then 'icon-basket'
		when 'Rfc' then 'icon-cog'
		when 'Feedback' then 'icon-comments'