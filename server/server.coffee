@countPercent = (current, finish) ->
	minutes_left = (current - new Date()) / 1000
	parseInt minutes_left / finish * 100

Meteor.methods
	'counter': ->
		incrementCounter('Tickets')
	'clearTickets': ->
		Agents.update {},
			$unset:
				tickets: ''
			multi: true
	'processTickets': ->
		tickets = Tickets.find({status:{$in: ['classified','assigned']}}).fetch()
		
		for ticket in tickets 
			do (ticket) ->
				# minutes_left = (ticket.responseAt - new Date()) / 1000
				# response_percent = parseInt minutes_left / ticket.sla.response * 100
				# console.log "for ticket #{ticket._id} : #{minutes_left} : #{response_percent}"

				Tickets.update _id: ticket._id,
					$set:
						response_percent: countPercent(ticket.responseAt, ticket.sla.response)
				console.log "response tick #{ticket._id} #{ticket.response_percent}"

		tickets = Tickets.find({status:{$in: ['classified','assigned','in_progress']}}).fetch()
		for ticket in tickets
			do (ticket) ->
				Tickets.update _id: ticket._id,
					$set:
						resolve_percent: countPercent(ticket.resolveAt, ticket.sla.resolve)
				console.log "resolve tick #{ticket._id} #{ticket.resolve_percent}"

cron = new Cron()
cron.addJob 1, ->
	Meteor.call('processTickets')

# Tickets._ensureIndex({ "status": 1})
# Tickets._ensureIndex({ "type": 1})