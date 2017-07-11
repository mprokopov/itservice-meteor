Router.configure
  layoutTemplate: 'ApplicationLayout'

Router.route '/', ->
  if Meteor.user().profile.employee?
    Router.redirect '/mytickets'
  @render 'Dashboard'
  name: 'Dashboard'

Router.map ->
  @route 'mytickets',
    path: '/mytickets'
    template: 'indexEmployeeTickets'

  @route 'availableEmployeeSLAs',
    path: '/mytickets/slas'
    template: 'availableEmployeeSLAs'

  @route  'problems.index',
    path: '/problems'
    template: 'Problems'

  @route 'show.problem',
    path: '/problems/:_id'
    template: 'showProblem'
    data: ->
      Problems.findOne
        _id: @params._id
  
  @route 'rfcs.index',
    path: '/rfcs'
    template: 'rfcs.index'

  @route 'changes.index',
    path: '/changes'
    template: 'changesIndex'

  @route 'changes.new',
    path: '/changes/new'
    template: 'newChange'
    data: ->
      Tickets.findOne
        _id: @params.query.ticket

  @route 'changes.show',
    path: '/changes/:_id'
    template: 'showChange'
    data: ->
      Changes.findOne _id: @params._id

  @route 'tickets.index',
    path: '/tickets'
    template: 'tickets'

  @route 'tickets.new',
    path: '/tickets/new'
    template: 'newTicket'
  
  @route 'incidents.index',
    path: '/incidents'
    template: 'incidents.index'
  
  @route 'ticket.show',
    path: '/tickets/:_id'
    template: 'showTicket'
    data: ->
      Tickets.findOne _id: @params._id
  
  @route 'clients.index',
    path: '/clients'
    template: 'clients'

  @route 'client.edit',
    path: '/clients/:_id/edit'
    template: 'editClient'
    data: ->
      Clients.findOne _id: @params._id

  @route 'client.employees.index',
    path: '/clients/:_id/employees'
    template: 'clientEmployees'
    data: ->
      Clients.findOne _id: @params._id
  
  @route 'client.employees.new',
    path: '/clients/:_id/employees/new'
    template: 'newClientEmployee'
    data: ->
      Clients.findOne
        _id: @params._id

  @route 'client.employee',
    path: '/clients/:_id/employees/:employeeId'
    template: 'clientEmployee'
    data: ->
      Employees.findOne
        _id: @params.employeeId
  
  @route 'knowledges.index',
    path: '/knowledges'
    template: 'knowledgesIndex'

  @route 'knowledge.show',
    path: '/knowledges/:_id'
    template: 'showKnowledge'
    data: ->
      Knowledges.findOne
        _id: @params._id
  @route 'cmdb.index',
    path: '/cmdb'
    template: 'cmdbIndex'


Router.route '/mytickets/new', ->
  @render 'newEmployeeTicket'

Router.route '/mytickets/:_id', ->
  @render 'showEmployeeTicket',
    data: Tickets.findOne
      _id: @params._id



Router.route '/clients/new', ->
  @render 'newClient'

Router.route '/clients/:_id/employees/:employeeId/edit', ->
  @render 'editClientEmployee',
    data: Employees.findOne
      _id: @params.employeeId



Router.route '/clients/:_id/slas', ->
  @render 'editClientSLAs',
    data: Clients.findOne
      _id: @params._id


Router.route '/agents', ->
  @render 'Agents'

Router.route '/agents/new', ->
  @render 'newAgent'

Router.route '/agents/:_id', ->
  @render 'editAgent',
    data: Agents.findOne
      _id: @params._id

Router.route '/service_requests', ->
  @render 'serviceRequestsIndex'

Router.route '/slas', ->
  @render 'slas'

Router.route '/slas/new', ->
  @render 'newSla'