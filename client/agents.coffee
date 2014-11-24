Template.Agents.helpers
	'agents': ->
		Agents.find {},
			sort:
				createdAt: -1
Template.agentForm.helpers
	'isAgent': ->
		('agent' in @roles)
	'isSupervisor': ->
		('supervisor' in @roles)

Template.newAgent.events
	'submit': (event) ->
		event.preventDefault()
		agent = event.target
		
		Agents.insert
			name: agent.name.value
			cost_per_hour: agent.cost_per_hour.value
			active: agent.active.checked
			email: agent.email.value
			phone: agent.phone.value
			roles: (role.value for role in $(agent).find('input[type=checkbox][name=roles]:checked'))
			createdAt: new Date()

		Router.go '/agents'

Template.editAgent.events
	'submit': (event) ->
		event.preventDefault()
		agent = event.target

		Agents.update _id: @_id,
			$set:	
				name: agent.name.value
				cost_per_hour: agent.cost_per_hour.value
				active: agent.active.checked
				# active: $(agent).find('input[name=active]:checked').first().val()
				email: agent.email.value
				phone: agent.phone.value
				roles: (role.value for role in $(agent).find('input[type=checkbox][name=roles]:checked'))
				updatedAt: new Date()
		
		Router.go '/agents'

# Template.agentForm.rendered = ->
#   $.Metro.initAll()
