Template.Problems.helpers
	'problems': ->
		Problems.find()
	'status_locale': ->
		switch @status
			when 'open'
				'открыта'
			when 'workaround'
				'есть обходное решение'
			when 'solved'
				'решена'
		
Template.showProblem.helpers
	isOpen: ->
		@status is 'open'
	isWorkaround: ->
		@status is 'workaround'
	isSolved: ->
		@status is 'solved'

Template.Problems.events
	'click a.remove': (event) ->
		Problems.remove @_id
	'click button': (event) ->
		Meteor.call 'addRecord', 
		(err,result) ->
			console.log result

Template.showProblem.events
	'submit': (event) ->
		event.preventDefault()
		Problems.update _id: @_id,
			$set:
				status: $('input[name=status]:checked').val()
				description: event.target.description.value
				workaround: event.target.workaround.value
				solution: event.target.solution.value
		Router.go '/problems'
