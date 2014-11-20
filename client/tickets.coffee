Template.newTicket.events
	'change select': (event) ->
		Session.set('employee_id', event.currentTarget.value)
	'submit': (event) ->
		event.preventDefault()
		# console.log event.target.employee_id.value
		employee = Employees.findOne({_id: event.target.employee_id.value})
		
		Meteor.call 'counter', (err, result) =>
			@_id = Tickets.insert
				employee: Employees.findOne({_id: event.target.employee_id.value})
				description: event.target.description.value
				createdAt: new Date()
				doc_id: result
				status: 'open'

			Router.go("/tickets/#{@_id}")

Template.newTicket.rendered = ->
	$('textarea').autosize()
	$('select').select2()

Template.tickets.helpers
	'tickets': ->
		Tickets.find {},
			{
				sort:
					createdAt: -1
			}

UI.registerHelper 'ticket_icon', ->
	switch @type
		when 'Incident' then  'icon-bug'
		when 'ServiceRequest' then 'icon-basket'
		when 'Rfc' then 'icon-cog'
		when 'Feedback' then 'icon-comments'

UI.registerHelper 'status_class', ->
	switch @status
		when 'open'
			'bg-blue'
		when 'classified'
			'bg-green'
		when 'assigned'
			'bg-red'
		when 'in_progress'
			'bg-yellow'

UI.registerHelper 'type_locale', ->
	switch @type
			when 'Incident' then  'Инцидент'
			when 'ServiceRequest' then 'Запрос на обслуживание'
			when 'Rfc' then 'Запрос на изменение'
			when 'Feedback' then 'Обратная связь'
			when undefined then 'Обращение'

UI.registerHelper 'status_locale', ->  
	switch @status
		when 'open'
			'открыт'
		when 'classified'
			'классифицирован'
		when 'assigned'
			'назначен'
		when 'in_progress'
			'в работе'

@pad = (num) ->
	if num < 10
		"0" + num
	else
		num
UI.registerHelper 'to_duration', (duration) ->
	hours = parseInt(duration / 3600)
	mins = parseInt (duration - hours * 3600)/60
	"#{pad hours}:#{pad mins}"


Template.newTicket.helpers
	'employees': ->
		Employees.find()
	'employee': ->
		Employees.findOne
			_id: Session.get('employee_id')
	'tickets': ->
		Tickets.find
			'employee._id': Session.get('employee_id')

Template.showTicket.events
	'click a.remove': ->
		Tickets.remove(@_id)
		Router.go('/tickets')

Template.showTicket.helpers
	'isClassified': ->
		@status is 'classified'
	'isAssigned': ->
		@status is 'assigned'
	'isInProgress': ->
		@status is 'in_progress'
	
	# 'response_percent': ->
	# 	minutes_left = (@responseAt - new Date()) / 1000
	# 	parseInt minutes_left / @sla.response * 100
	
	# 'resolve_percent': ->
	# 	@resolveAt - new Date()

Template.processTicket.events
	'click button.process': ->
		Tickets.update _id: @_id,
			$set:
				status: 'in_progress'
				respondedAt: new Date()
				response_breached: new Date() < @responseAt

Template.assignTicket.events
	'click button.reclassify': (event) ->
		event.preventDefault()
		Tickets.update _id: @_id,
			$set:
				status: 'open'
				updatedAt: new Date()
				reclassified: true
			$unset:
				sla: ''
				type: ''

	'submit': (event) ->
		event.preventDefault()
		Tickets.update _id: @_id,
			$set:
				status: 'assigned'
				assigned_to: Agents.findOne(_id: event.target.agent_id.value)
				assignedAt: new Date()
		Agents.update _id: event.target.agent_id.value,
			$inc:
				tickets_count: 1
			$push:
				tickets: Tickets.findOne(_id: @_id)

Template.showTicket.rendered = ->
	$.Metro.initAll()

Template.unclassifiedTickets.helpers
	'tickets': ->
		Tickets.find
			type: undefined

Template.Incidents.helpers
	'tickets': ->
		Tickets.find 
			type: 'Incident'
			{
				sort:
					createdAt: -1
			}
Template.ServiceRequests.helpers
	'tickets': ->
		Tickets.find
			type: 'ServiceRequest'
			{
				sort:
					createdAt: -1
			}

Template.Rfcs.helpers
	'tickets': ->
		Tickets.find
			type: 'Rfc'
			{
				sort:
					createdAt: -1
			}

Template.classifyTicket.helpers
	'slas': ->
		console.log Tickets.findOne(_id: @_id)
		Clients.findOne
			'employees.name': Tickets.findOne(_id: @_id).employee.name
		.slas

Template.classifyTicket.events
	'submit': (event) ->
		event.preventDefault()
		sla = SLAs.findOne(_id: event.target.sla_id.value)

		responseAt = new Date(@createdAt.getTime() + sla.response * 1000)
		resolveAt = new Date(@createdAt.getTime() + sla.resolve * 1000)

		Tickets.update _id: @_id,
			$set:
				type: $('input[name=ticketType]:checked').val()
				sla: sla
				status: 'classified'
				classifiedAt: new Date()
				responseAt:  responseAt
				resolveAt: resolveAt

		console.log "Ticket id #{@_id}, type: #{$('input[name=ticketType]:checked').val()}"

Template.assignTicket.helpers
	'agents': ->
		Agents.find
			active: true