Template.activities.events
	'click #hide_automated': (event) ->
		event.preventDefault()
		@hideAutomated = !@hideAutomated

		console.log @
			
Template.formActivity.events
	'submit': (event) ->
		event.preventDefault()
		
		valid = true
		
		if event.target.duration.value is ''
			valid = false
			$(event.target.duration).parent().addClass('warning-state')
		else
			$(event.target.duration).parent().removeClass('warning-state')

		if event.target.description.value is ''
			valid = false
			$(event.target.description).parent().addClass('warning-state')
		else
			$(event.target.description).parent().removeClass('warning-state')
		
		if valid

			activity_id = Activities.insert
				agent: Meteor.user().profile.agent
				duration: fromDuration(event.target.duration.value)
				description: event.target.description.value
				# ticket: Tickets.findOne(_id: @_id)
				ticket:
					_id: @_id
				createdAt: new Date()

			Tickets.update _id: @_id,
				$inc: 
					duration: fromDuration(event.target.duration.value)
				$push:
					activities:
						_id: activity_id
						agent: Meteor.user().profile.agent
						duration: fromDuration(event.target.duration.value)
						description: event.target.description.value
						createdAt: new Date()
			

			event.target.duration.value='00:05'
			event.target.description.value=''