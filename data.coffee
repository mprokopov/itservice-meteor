@Tickets = new Mongo.Collection('Tickets')
@Clients = new Mongo.Collection('Clients')
@Employees = new Mongo.Collection('Employees')
@Problems = new Mongo.Collection('Problems')
@Agents = new Mongo.Collection('Agents')
@Activities = new Mongo.Collection('Activities')
@SLAs = new Mongo.Collection('SLAs')

if Meteor.isClient
	 moment.locale(window.navigator.userLanguage or window.navigator.language)