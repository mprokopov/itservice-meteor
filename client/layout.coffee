Template.sidebar.rendered = ->
	$.Metro.initDropdowns('.navigation-bar')
	$(".sidebar a[href='#{Router.current().url}']").parent().addClass('active')
	console.log Router.current().url