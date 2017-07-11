Template.changesIndex.helpers
	changes: ->
		Changes.find()

Template.newChange.rendered = ->
	$(".calendar").calendar
		weekStart: 1
		multiSelect: false
		date: @timeslotAt
		getDates: (date) ->
			$('input[name=timeslot]').val(date)

Template.newChange.events
	'submit': (event) ->
		event.preventDefault()

		ticket = Tickets.findOne _id: event.target.ticket_id.value
		
		change_id = Changes.insert
			ticket:
				_id: ticket._id
				doc_id: ticket.doc_id
			sla: ticket.sla
			client: ticket.employee.client
			preinstall: event.target.preinstall.value
			install: event.target.install.value
			postinstall: event.target.postinstall.value
			createdAt: new Date()
			createdBy: Meteor.userId()
			timeslotAt: new Date(event.target.timeslot.value)
			duration: 0
		
		Tickets.update _id: event.target.ticket_id.value,
			$set:
				change: change_id

		Router.go 'changes.show',
			_id: change_id

Template.showChange.helpers
	'ticket': ->
		Tickets.findOne _id: @ticket._id

Template.showChange.events
	'click a.remove': (event) ->
		event.preventDefault()
		if confirm 'Удалить изменение?'
			Tickets.update _id: @ticket._id,
				$unset:
					change: 1
			Changes.remove _id: @_id
			Router.go 'changes.index'