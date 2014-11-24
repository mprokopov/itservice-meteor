@Tickets = new Mongo.Collection('Tickets')
@Clients = new Mongo.Collection('Clients')
@Employees = new Mongo.Collection('Employees')
@Problems = new Mongo.Collection('Problems')
@Agents = new Mongo.Collection('Agents')
# @Agents = Meteor.users
@Activities = new Mongo.Collection('Activities')
@SLAs = new Mongo.Collection('SLAs')

# Accounts.config
# 	restrictCreationByEmailDomain: 'it-premium.com.ua'
	# здесь можно искать в домене клиентов
# Agents.allow
# 	update: (userId, doc, fields, modifier) ->
# 		Roles.userIsInRole(Agents.findOne(_id: userId), 'supervisor')
	
	
if Meteor.isClient
	 moment.locale(window.navigator.userLanguage or window.navigator.language)