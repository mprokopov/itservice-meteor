Template.clients.helpers
  'clients': ->
    Clients.find()
  'selected_client': ->
    Clients.findOne
      _id: Session.get 'client_id'

Template.client.events
  'click .tile': (event) ->
    # console.log @_id
    Session.set 'client_id', @_id
    $('.tile').removeClass('selected')
    $(event.currentTarget).addClass('selected')
    
Template.newClient.events
  'submit': (event) ->
    event.preventDefault()

    Clients.insert
      name: event.target.name.value
      createdAt: new Date()
      employees: []

    Router.go('/clients')

Template.clientEmployees.helpers
  'employees': ->
    this.employees

Template.newClientEmployee.events
  'submit': (event) ->
    event.preventDefault()

    employee_id = Employees.insert
      name: event.target.name.value
      position: event.target.position.value
      createdAt: new Date()
      email: event.target.email.value
      phone: event.target.phone.value
      client:
        _id: @_id
        name: Clients.findOne({_id: @_id}).name
    
    Clients.update _id: @_id,
      $push:
        employees:
          _id: employee_id
          name: event.target.name.value
          position: event.target.position.value
          email: event.target.email.value
          phone: event.target.phone.value
          createdAt: new Date()

    Router.go "/clients/#{@_id}/employees"

Template.editClient.helpers
  'available_slas': ->
    # if @slas
    clients_sla_ids = if @slas then (sla._id for sla in @slas) else []
    SLAs.find
      _id:
        $nin: clients_sla_ids

Template.editClient.events
  'click .removeSla': (event) ->
    Clients.update _id: $(event.currentTarget).data('client-id'),
      $pop:
        slas: this
  'click a.addThisSla': (event) ->
    sla = SLAs.findOne(_id: @_id)
    Clients.update _id: $(event.currentTarget).data('client-id'),
      $push:
        slas: sla
    # console.log $(event.currentTarget).data('id')
    # console.log sla
    # console.log @_id
    # console.log $(event.currentTarget).data('client-id')

  # 'click a.addSla': -> 
  #   clients_sla_ids = (sla._id for sla in @slas)
  #   Blaze.renderWithData Template.selectSLA, {slas: SLAs.find({_id:{$nin:clients_sla_ids}})}, $('table.slas')[0]
    