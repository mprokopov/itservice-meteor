Template.knowledgesIndex.helpers
	knowledges: ->
		Knowledges.find {},
			sort:
				createdAt: -1

Template.knowledgesIndex.events
	'click a.remove': ->
		if confirm 'Хотите удалить знание?'
			Knowledges.remove _id: @_id