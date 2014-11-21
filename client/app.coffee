Router.configure
  layoutTemplate: 'ApplicationLayout'

Router.route '/', ->
  @render 'Dashboard'

Router.route '/tickets', ->
  @render 'tickets'


Router.route '/tickets/new', 
 ->
  @render 'newTicket'
name: 'tickets.new'

Router.route '/tickets/:_id',
  ->
    @render 'showTicket',
      data: Tickets.findOne
        _id: @params._id
  name: 'ticket.show'

Router.route '/clients/new', ->
  @render 'newClient'

Router.route '/clients', ->
  @render 'clients'

Router.route '/clients/:_id', ->
  @render 'editClient',
    data: Clients.findOne
      _id: @params._id

Router.route '/clients/:_id/employees', ->
  @render 'clientEmployees',
    data: Clients.findOne
      _id: @params._id

Router.route '/clients/:_id/employees/new', ->
  @render 'newClientEmployee',
    data: Clients.findOne
      _id: @params._id

Router.route '/problems', ->
  @render 'Problems'

Router.route '/agents', ->
  @render 'Agents'

Router.route '/agents/new', ->
  @render 'newAgent'

Router.route '/agents/:_id', ->
  @render 'editAgent',
    data: Agents.findOne
      _id: @params._id

Router.route '/incidents', ->
  @render 'incidents.index'

Router.route '/slas', ->
  @render 'slas'

Router.route '/slas/new', ->
  @render 'newSla'