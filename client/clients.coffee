Template.clients.helpers
  'clients': ->
    Clients.find()
  'selected_client': ->
    Clients.findOne
      _id: Session.get 'client_id'

Template.client.events
  'click .tile-content': (event) ->
    # console.log @_id
    Session.set 'client_id', @_id
    
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
        id: @_id
        name: Clients.findOne({_id: @_id}).name
    
    Clients.update _id: @_id,
      $push:
        employees:
          id: employee_id
          name: event.target.name.value
          position: event.target.position.value
          email: event.target.email.value
          phone: event.target.phone.value
          createdAt: new Date()

    Router.go("/clients/#{@_id}/employees")