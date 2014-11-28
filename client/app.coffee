Router.configure
  layoutTemplate: 'ApplicationLayout'

Router.map ->
  @route 'mytickets',
    path: '/mytickets'
    template: 'indexEmployeeTickets'

  @route 'availableEmployeeSLAs',
    path: '/mytickets/slas'
    template: 'availableEmployeeSLAs'

  @route 'show.problem',
    path: '/problems/:_id'
    template: 'showProblem'
    data: ->
      Problems.findOne
        _id: @params._id

Router.route '/', ->
  if Meteor.user().profile.employee?
    Router.redirect '/mytickets'
  @render 'Dashboard'

# Router.route '/mytickets', ->
#   @render 'indexEmployeeTickets'

Router.route '/mytickets/new', ->
  @render 'newEmployeeTicket'

Router.route '/mytickets/:_id', ->
  @render 'showEmployeeTicket',
    data: Tickets.findOne
      _id: @params._id

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

Router.route '/clients/:_id/employees', ->
  @render 'clientEmployees',
    data: Clients.findOne
      _id: @params._id

Router.route '/clients/:_id/employees/new', ->
  @render 'newClientEmployee',
    data: Clients.findOne
      _id: @params._id

Router.route '/clients/:_id/employees/:employeeId/edit', ->
  @render 'editClientEmployee',
    data: Employees.findOne
      _id: @params.employeeId

Router.route '/clients/:_id/employees/:employeeId', ->
  @render 'clientEmployee',
    data: Employees.findOne
      _id: @params.employeeId


Router.route '/clients/:_id/slas', ->
  @render 'editClientSLAs',
    data: Clients.findOne
      _id: @params._id

Router.route '/clients/:_id/edit', ->
  @render 'editClient',
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

Router.route '/service_requests', ->
  @render 'serviceRequestsIndex'

Router.route '/slas', ->
  @render 'slas'

Router.route '/slas/new', ->
  @render 'newSla'