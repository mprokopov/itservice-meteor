@countPercent = (current, finish) ->
	minutes_left = (current - new Date()) / 1000
	parseInt minutes_left / finish * 100

@percentDurationLeft = (duration, total_duration) ->
	if duration > 0
		parseInt duration / total_duration * 100
	else
		0

Meteor.methods
	'counter': ->
		incrementCounter('Tickets')
	'addMeToAdmins': ->
		Roles.addUsersToRoles(Meteor.user(), 'supervisor')
	'addMeToAgents': ->
		Roles.addUsersToRoles(Meteor.user(), 'agent')		
	'clearTickets': ->
		Agents.update {},
			$unset:
				tickets: ''
			multi: true
	# 'addActivityToTicket': (activity, ticket) ->
	# 	activity_id = Activities.insert activity
	# 	activity._id = activity_id

	# 	Tickets.update _id: @_id,
	# 		$set:
	# 			ticket
	# 		$push:
	# 			activities:
	# 				activity
	'migrateSlas': ->
		for sla in SLAs.find(incidents: {$exists: false}).fetch()
			SLAs.update _id: sla._id,
				$set:
					incidents:
						resolve: sla.resolve
						response: sla.response
					service_requests:
						resolve: sla.resolve
						response: sla.response
	'resetEmployees': ->
		Employees.remove()
		
		for client in Clients.find(employees:{$exists: true}).fetch()
			for employee in client.employees
				console.log employee.name
				employee.client =
					_id: client._id
					name: client.name
				Employees.insert employee

	'processTickets': ->
		tickets = Tickets.find({status:{$in: ['classified','assigned']}}).fetch()
		now = moment()
		if isWorkday(now) and isWorkhours(now)
			for ticket in tickets 
				do (ticket) ->
					# minutes_left = (ticket.responseAt - new Date()) / 1000
					# response_percent = parseInt minutes_left / ticket.sla.response * 100
					# console.log "for ticket #{ticket._id} : #{minutes_left} : #{response_percent}"
					duration_left = workingHoursBetweenDates(new Date(), ticket.responseAt) * 60 # переводим в секунды
					Tickets.update _id: ticket._id,
						$set:
							response_percent: percentDurationLeft(duration_left, ticket.sla.response)
							# response_duration_left: (ticket.responseAt - new Date())/1000
							response_duration_left: duration_left
							response_breached: ticket.responseAt < new Date()
					console.log "response tick #{ticket._id} #{ticket.response_percent}"

			tickets = Tickets.find({status:{$in: ['classified','assigned','in_progress']}}).fetch()
			for ticket in tickets
				do (ticket) ->
					duration_left = workingHoursBetweenDates(new Date(), ticket.resolveAt) * 60 # переводим в секунды
					Tickets.update _id: ticket._id,
						$set:
							resolve_percent: percentDurationLeft(duration_left, ticket.sla.resolve)
							resolve_duration_left: duration_left
							# resolve_duration_left: (ticket.resolveAt - new Date())/1000
							resolve_breached: ticket.resolveAt < new Date()

					console.log "resolve tick #{ticket._id} #{ticket.resolve_percent}"

cron = new Cron()
## каждую минуту запуск процессинга тикетов
cron.addJob 1, ->
	Meteor.call('processTickets')

# Accounts.onCreateUser (options, user) ->
# 	console.log options
# 	# Rolser.addUserToRoles(user, 'agent') if  /@it-premium.com.ua/.test(options.services.google.email)
# 	console.log 'oncreateuser'
# 	user

# Tickets._ensureIndex({ "status": 1})
# Tickets._ensureIndex({ "type": 1})