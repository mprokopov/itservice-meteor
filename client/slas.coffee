@durationFromString = (str) ->
	[hours, minutes] = str.split(':')
	hours = parseInt(hours) * 3600
	minutes = parseInt(minutes) * 60
	hours + minutes

Template.slas.helpers
	'slas':  ->
		SLAs.find()

Template.slas.events
	'click .remove': (event) ->
		SLAs.remove @_id

Template.newSla.events
	'submit': (event) ->
		event.preventDefault()
		
		SLAs.insert
			name: event.target.name.value
			incidents:
				response: durationFromString(event.target.incident_response.value)
				resolve: durationFromString(event.target.incident_resolve.value)
			service_requests:
				response: durationFromString(event.target.sr_response.value)
				resolve: durationFromString(event.target.sr_resolve.value)
			# response: durationFromString(event.target.response.value)
			# resolve: durationFromString(event.target.resolve.value)
			createdAt: new Date()
		
		Router.go '/slas'
				