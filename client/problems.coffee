Template.Problems.helpers
	'problems': ->
		Problems.find()

Template.Problems.events
	'click a.remove': (event) ->
		Problems.remove @_id
	'click button': (event) ->
		Meteor.call 'addRecord', 
		(err,result) ->
			console.log result

Template.newProblem.events
	'submit': (event) ->
		event.preventDefault()
		Problems.insert
			name: event.target.description.value