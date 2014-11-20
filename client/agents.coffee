Template.Agents.helpers
	'agents': ->
		Agents.find {},
			sort:
				createdAt: -1

Template.newAgent.events
	'submit': (event) ->
		event.preventDefault()
		agent = event.target
		
		Agents.insert
			name: agent.name.value
			cost_per_hour: agent.cost_per_hour.value
			active: agent.active.value
			createdAt: new Date()

		Router.go '/agents'

Template.editAgent.events
	'submit': (event) ->
		event.preventDefault()
		agent = event.target
		console.log 'updated'
		Agents.update _id: @_id,
			$set:
				name: agent.name.value
				cost_per_hour: agent.cost_per_hour.value
				active: agent.active.value
				updatedAt: new Date()

		Router.go '/agents'

# Template.agentForm.rendered = ->
#   $.Metro.initAll()
