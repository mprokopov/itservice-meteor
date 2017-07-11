Template.newTicket.events
	'change select': (event) ->
		Session.set('employee_id', event.currentTarget.value)
	
	'submit': (event) ->
		event.preventDefault()
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
	$('select').select2
		width: 'element'
	Session.set 'employee_id', $('select').val()

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

UI.registerHelper 'created_at_calendar', ->
	moment(@createdAt).calendar()

UI.registerHelper 'as_calendar', (date) ->
	moment(date).calendar()

UI.registerHelper 'as_duration', (seconds) ->
	moment.duration(seconds,'s').humanize()

@pad = (num) ->
	if num < 10
		"0" + num
	else
		num


Template.newTicket.helpers
	'employees': ->
		Employees.find()
	
	'selected_employee': ->
		Employees.findOne
			_id: Session.get('employee_id')
	
	'tickets': ->
		Tickets.find
			'employee._id': Session.get('employee_id')
			'createdAt': 
			 	$gt: new Date(new Date().getTime() - 1000 * 3600 * 48) # предыдущие 48 часов
	
	'client_tickets': ->
		Tickets.find
			'employee.client._id': Employees.findOne(_id: Session.get('employee_id')).client._id
			'employee._id': 
				$ne: Session.get 'employee_id'
			'createdAt': 
			 	$gt: new Date(new Date().getTime() - 1000 * 3600 * 48) # предыдущие 48 часов

Template.showTicket.events
	'click button#new-knowledge': (event) ->
		event.preventDefault()
		
		Knowledges.insert
			sla: @sla
			client: @employee.client
			description: $('#knowledge-description').val()
			createdAt: new Date()
			author: Meteor.user().profile.agent
			tickets: [ @_id ]
		$('#knowledge-description').val('')

	'click a.new-problem': (event) ->
		event.preventDefault()
		Problems.insert
			tickets: [ this ]
			sla: @sla
			client: @employee.client
			description: $('#problem-description').val()
			author: Meteor.user().profile.agent
			status: 'open'
			createdAt: new Date()
		$('#problem-description').val('')

	'click a.remove': ->
		if confirm("Точно хотите удалить этот тикет?")
			for activity in Tickets.findOne({_id: @_id}).activities
				Activities.remove _id: activity._id

			Tickets.remove _id: @_id
			Router.go 'tickets.index'

	'mouseenter .panel.problem': (event) ->
		$(event.currentTarget).find('a.add-incident').toggleClass('hide')

	'mouseleave .panel.problem': (event) ->
		$(event.currentTarget).find('a.add-incident').toggleClass('hide')

	'click a.add-incident': (event) ->
		event.preventDefault()
		Problems.update _id: @_id,
			$push:
				tickets:
					Tickets.findOne _id: $(event.currentTarget).data('ticket-id')

	'click #is_major': (event) ->
		console.log event.currentTarget.checked
		Tickets.update _id: @_id,
			$set:
				is_major: event.currentTarget.checked

	'click #is_outdoor': (event) ->
		console.log event.currentTarget.checked
		Tickets.update _id: @_id,
			$set:
				is_outdoor: event.currentTarget.checked

Template.showTicket.helpers
	'change': ->
		if @type is 'Rfc' and @change?
			Changes.findOne _id: @change
		else
			null
	'problems': ->
		if @sla
			Problems.find
				'sla._id': @sla._id
				'client._id': @employee.client._id
	'changes_count': ->
		if @change
			Changes.find
				'ticket._id': @_id
			.count()
		else
			0
	'problems_count': ->
		if @sla
			Problems.find
				'sla._id': @sla._id
				'client._id': @employee.client._id
			.count()
	'knowledges': ->
		if @sla
			Knowledges.find
				'sla._id': @sla._id
				'client._id': @employee.client._id
	'knowledges_count': ->
		if @sla
			Knowledges.find
				'sla._id': @sla._id
				'client._id': @employee.client._id
			.count()

	'isIncident': ->
		@type is 'Incident'
	'isRfc': ->
		@type is 'Rfc'	
	'isClassified': ->
		@status is 'classified'
	'isAssigned': ->
		@status is 'assigned'
	'isInProgress': ->
		@status is 'in_progress'
	'notResponded': ->
		@status is 'assigned' or @status is 'classified'
	'notResolved': ->
		@status is 'assigned' or @status is 'classified' or @status is 'in_progress'
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
	# $.Metro.initCalendars("#changes")
	# $('.calendar').calendar()

Template.outdoorTickets.helpers
	'tickets': ->
		Tickets.find
			is_outdoor: true
			status:
				$in: ['classified', 'assigned', 'in_progress']

Template.unclassifiedTickets.helpers
	'tickets': ->
		Tickets.find
			status: 'open'
			# type: undefined
Template.majorTickets.helpers
	tickets: ->
		Tickets.find
			is_major: true
			status:
				$in: ['classified', 'assigned', 'in_progress']

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
		if client.slas
			client.slas

Template.classifyTicket.events
	'submit': (event) ->
		event.preventDefault()
		sla = SLAs.findOne(_id: event.target.sla_id.value)
		ticket_type = $('input[name=ticketType]:checked').val()
		# sla = Clients.findOne('slas._id': event.target.sla_id.value)
		switch ticket_type
			when 'Incident'
				sla.resolve = sla.incidents.resolve
				sla.response = sla.incidents.response
				responseAt = dateFromDuration(sla.response)
				resolveAt = dateFromDuration(sla.resolve)
				console.log 'incident classified'
			when 'ServiceRequest'
				sla.resolve = sla.service_requests.resolve
				sla.response = sla.service_requests.response
				responseAt = dateFromDuration(sla.response)
				resolveAt = dateFromDuration(sla.resolve)
				console.log 'sr classified'
			else
				responseAt = dateFromDuration(sla.response)
				resolveAt = dateFromDuration(sla.resolve)
		# responseAt = new Date(@createdAt.getTime() + sla.response * 1000)
		# resolveAt = new Date(@createdAt.getTime() + sla.resolve * 1000)
		
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
		Meteor.call 'sendClassificationNotification', Tickets.findOne _id: @_id


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