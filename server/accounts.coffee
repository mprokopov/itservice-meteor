Accounts.onLogin (options) ->
	currentUser = Meteor.users.findOne(_id: options.user._id) if options.user
	console.log options
	if currentUser?
		email = currentUser.services.google.email
		console.log email
		agent = Agents.findOne
			email: email
		# if logged user is agent
		if agent?
			Roles.setUserRoles(currentUser, agent.roles)
			Meteor.users.update _id: currentUser._id,
				$set:
					'profile.agent':
						_id: agent._id
						name: agent.name
			unless agent.picture
				Agents.update _id: agent._id,
					$set:
						picture: currentUser.services.google.picture
	
		employee = Employees.findOne
			email: email
		
		if employee?
			Roles.setUserRoles(currentUser, 'employee')
			Meteor.users.update _id: currentUser._id,
				$set:
					'profile.employee':
						_id: employee._id
						name: employee.name
						client: employee.client
				
			unless employee.picture
				Employees.update _id: employee._id,
					$set:
						picture: currentUser.services.google.picture
				client_finder=
					_id: employee.client._id
					'employees.email': email
				
				client_update=
					$set:
						'employees.$.picture': currentUser.services.google.picture
				
				Clients.update client_finder,
					client_update
					
					
