Template.indexEmployeeTickets.helpers
	'tickets': ->
		Tickets.find
			'employee._id': Meteor.user().profile.employee._id
Template.newEmployeeTicket.events
	'submit': (event) ->
		event.preventDefault()

		Meteor.call 'counter', (err, result) =>
			@_id = Tickets.insert
				employee: Employees.findOne _id: Meteor.user().profile.employee._id
				description: event.target.description.value
				createdAt: new Date()
				doc_id: result
				status: 'open'
		
			Router.go("/mytickets/#{@_id}")

Template.formNewEmployeeActivity.events
	'submit': (event) ->
		event.preventDefault()

		Tickets.update _id: @_id,
			$push:
				activities:
					employee: Meteor.user().profile.employee
					description: event.target.description.value
					createdAt: new Date()

		event.target.description.value = ''