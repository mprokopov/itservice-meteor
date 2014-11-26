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
				duration: 0
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


UI.registerHelper 'status_class', ->
	switch @status
		when 'open'
			'bg-pink'
		when 'classified'
			'bg-teal'
		when 'assigned'
			'bg-cyan'
		when 'in_progress'
			'bg-green'
		when 'finished'
			'bg-indigo'

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
		when 'finished'
			'завершен'
		when 'closed'
			'закрыт'

@pad = (num) ->
	if num < 10
		"0" + num
	else
		num


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
	'response_class': ->
		switch 
			when 75 < @response_percent
				'bg-green'
			when 25 < @response_percent < 75
				'bg-yellow'
			when 0 < @response_percent < 25
				'bg-red'
			else
				'bg-crimson'
	'resolve_class': ->
		switch 
			when 75 < @resolve_percent
				'bg-green'
			when 25 < @resolve_percent < 75
				'bg-yellow'
			when 0 < @resolve_percent < 25
				'bg-red'
			else
				'bg-crimson'

	
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
		# Agents.update _id: event.target.agent_id.value,
		# 	$inc:
		# 		tickets_count: 1
		# 	$push:
		# 		tickets: Tickets.findOne(_id: @_id)

Template.showTicket.rendered = ->
	$.Metro.initAll()

Template.unclassifiedTickets.helpers
	'tickets': ->
		Tickets.find
			status: 'open'
			# type: undefined

Template.myTickets.helpers
	'tickets': ->
		Tickets.find
			status:
				$in: ['assigned', 'in_progress']
			'assigned_to._id': Meteor.user().profile.agent._id


Template.Incidents.helpers
	'tickets': ->
		Tickets.find 
			type: 'Incident'
			status: 
				$in: ['classified', 'assigned', 'in_progress']
			{
				sort:
					createdAt: -1
			}
Template.ServiceRequests.helpers
	'tickets': ->
		Tickets.find
			type: 'ServiceRequest'
			status: 
				$in: ['classified', 'assigned', 'in_progress']
			{
				sort:
					createdAt: -1
			}

Template.Rfcs.helpers
	'tickets': ->
		Tickets.find
			type: 'Rfc'
			status: 
				$in: ['classified', 'assigned', 'in_progress']
			{
				sort:
					createdAt: -1
			}

Template.classifyTicket.helpers
	'slas': ->
		
		client = Clients.findOne
			'employees._id': Tickets.findOne(_id: @_id).employee._id
		
		client.slas

Template.classifyTicket.events
	'submit': (event) ->
		event.preventDefault()
		sla = SLAs.findOne(_id: event.target.sla_id.value)

		responseAt = new Date(@createdAt.getTime() + sla.response * 1000)
		resolveAt = new Date(@createdAt.getTime() + sla.resolve * 1000)
		
		# activity=
		# 	description: "Классифицировал как #{$('input[name=ticketType]:checked').val()}"
		# 	is_automated: true
		# 	duration: 2*60 # две минуты
		# 	agent: Meteor.user().profile.agent
		# 	createdAt: new Date()
		# ticket=
		# 	type: $('input[name=ticketType]:checked').val()
		# 	sla: sla
		# 	status: 'classified'
		# 	classifiedAt: new Date()
		# 	responseAt:  responseAt
		# 	resolveAt: resolveAt			

		# Meteor.call 'addActivityToTicket', activity, ticket
		description = "Классифицировал как #{$('input[name=ticketType]:checked').val()}"

		activity_id = Activities.insert
			description: description
			is_automated: true
			duration: 2*60 # две минуты
			agent: Meteor.user().profile.agent
			createdAt: new Date()

		Tickets.update _id: @_id,
			$set:
				type: $('input[name=ticketType]:checked').val()
				sla: sla
				status: 'classified'
				classifiedAt: new Date()
				responseAt:  responseAt
				resolveAt: resolveAt
			$push:
				activities:
					_id: activity_id
					description: description
					is_automated: true
					duration: 2*60 # две минуты
					agent: Meteor.user().profile.agent
					createdAt: new Date()


		Meteor.call('processTickets')

Template.assignTicket.helpers
	'agents': ->
		Agents.find
			active: true

Template.finishTicket.events
	'click .finish': (event) ->
		event.preventDefault()
		Tickets.update _id: @_id,
			$set:
				status: 'finished'
				resolvedAt: new Date()
		Router.go '/'