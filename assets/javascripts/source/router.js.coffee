@router = Backbone.Router.extend(
  before: ->
    @check_login_expiration()
    
    unless Backbone.history.fragment == "photos#new"
      if app.current_view
        if app.current_view.destroy
          app.current_view.destroy()
        app.current_view.remove()
        if app.current_layout && app.current_layout.recreate_container
          app.current_layout.recreate_container()

    @fix_back_button()
    @fix_login_button()
    @current_user()
    if Backbone.history.fragment != "login"
      @current_route()
      if $.inArray(@route, @routes_without_authorization) == -1 && !@user
        this.navigate("login", true)
        return false
    if @user
      @user.trigger("activity")
    true
    
  check_login_expiration: ->
    if @user && @user.expired()
      app.take_error("login_expired")
      @user.remove_from_session_starage()
      @user = app.user = undefined

  fix_back_button:->
    @current_route()
    if $.inArray(@route, ["home", "profile", "claim_main", "agencies"]) == -1
      $('.button.left').show()
    else
      $('.button.left').hide()

  fix_login_button: ->
    $(".button.right.auth-btn").html("")
    $('.button.right.edit-btn').remove()
    if $.inArray(@route, ["home", "profile"]) == -1
      $('.button.right.auth-btn .login').hide()
    else
      $('.button.right.auth-btn .login').show()

  current_user: ->
    if app.user
      @user = app.user
    else
      @user = new app.models.User().current_user()
      app.user = @user

  current_route: ->
    path = Backbone.history.fragment.replace(/#(\d+)/,"#:id")
    @route = @routes[path]
    if( !@route )
      path = Backbone.history.fragment.replace(/(\d+)/,":id")
    @route = @routes[path]

  initialize: ->
    @routes_without_authorization = [
      "startup",
      "login",
      "home",
      "about",
      "about_contacts",
      "about_donegal",
      "about_terms",
      "about_info",
      "agencies",
      "agent",
      "agent_get_directions",
      "claim_main",
      "claim_numbers",
      "what_to_do_main",
      "auto_accident",
      "property_loss",
      "workers_compensation",
      "general_liability",

      "photo#new",
      "photo",
      "photo_edit",
      "photos#new",
      "photos"
    ]

  routes:
    startup: "startup"
    "": "index"
    login: "login"
    logout: "logout"
    user: "profile"
    home: "home"
    "my_agent": "my_agent"
    "agent_get_directions#:id": "agent_get_directions"
    "my_agent_get_directions": "my_agent_get_directions"
    search_agent: "agencies"
    "agent/:id": "agent"
    payment: "select_policy"
    "payment/:id": "payment"
    claim_main: "claim_main"
    "report_a_claim/:policy_id": "report_a_claim"
    select_claim_policy: "select_claim_policy"
    propert_claim_start: "propert_claim_start"
    property_claim_date: "property_claim_date"
    property_claim_loss_description: "property_claim_loss_description"
    property_claim_contacts: "property_claim_contacts"
    propert_claim_attach_photo: "propert_claim_attach_photo"
    propert_claim_comments: "propert_claim_comments"
    property_claim_summary: "property_claim_summary"
    property_claim_submit_results: "property_claim_submit_results"
    vehicle_claim_start: "vehicle_claim_start"
    vehicle_claim_edit_vehicle: "vehicle_claim_edit_vehicle"
    vehicle_claim_driver: "vehicle_claim_driver"
    vehicle_claim_driver_edit: "vehicle_claim_driver_edit"
    vehicle_claim_location: "vehicle_claim_location"
    vehicle_claim_date: "vehicle_claim_date"
    vehicle_claim_loss_description: "vehicle_claim_loss_description"
    vehicle_claim_injuries: "vehicle_claim_injuries"
    "vehicle_claim_injuries_edit/:id": "vehicle_claim_injuries_edit"
    vehicle_claim_injuries_edit: "vehicle_claim_injuries_edit"
    vehicle_claim_other_vehicles: "vehicle_claim_other_vehicles"
    "vehicle_claim_other_vehicles_driver_edit": "vehicle_claim_other_vehicles_driver_edit"
    "vehicle_claim_other_vehicles_driver_edit/:id": "vehicle_claim_other_vehicles_driver_edit"
    "vehicle_claim_other_vehicles_vehicle": "vehicle_claim_other_vehicles_vehicle"
    "vehicle_claim_other_vehicles_vehicle/#:id": "vehicle_claim_other_vehicles_vehicle"
    vehicle_claim_attach_photo: "vehicle_claim_attach_photo"
    vehicle_claim_comments: "vehicle_claim_comments"
    vehicle_claim_summary: "vehicle_claim_summary"
    vehicle_claim_submit_results: "vehicle_claim_submit_results"
    edit_claim_address: "edit_claim_address"
    important_claim_numbers: "claim_numbers"
    what_to_do_main: "what_to_do_main"
    claim_saved: "claim_saved"

    about: "about"
    "about/#contacts": "about_contacts"
    "about/#donegal": "about_donegal"
    "about/#terms": "about_terms"
    "about/#info": "about_info"
    
    auto_accident: "auto_accident"
    workers_compensation: "workers_compensation"
    property_loss: "property_loss"
    general_liability: "general_liability"
    vehicles: "vehicles"
    "vehicles/:policy_id/:id/:policy_label": "vehicle"

    "photo#new": "photo_new"
    "photo#:id": "photo"
    "photo/:id/edit": "photo_edit"
    "photos#new": "photos_new"
    photos: "photos"

    policy_list: "policy_list"
    "policy_coverage#:id": "policy_coverage"

  index: ->

  startup: ->
    textes = new app.models.Textes()
    textes.get_textes()
    textes.on "startup_ready", ->
      app.textes = textes.attributes
      app.current_layout = new app.views.layouts.Main()
      app.router.navigate("home", true)

  login: ->
    if @user
      this.navigate("user", true)
    else
      if app.current_layout
        app.current_layout.hideNavBar()
      app.current_view = new app.views.login.Login(model: new app.
      models.Credential(), route: @route)

  logout: ->
    app.current_view = new app.views.login.Logout(model: @user)

  profile: ->
    app.current_view = new app.views.user.Show(model: @user)

  home: ->
    app.current_view = new app.views.user.Home({user: @user})
    window.app.setContentSize()

    if (navigator.userAgent.match(/(iPhone|iPod|iPad|Android|BlackBerry)/))
      navigator.splashscreen.hide()

  my_agent: ->
    agent = new app.models.MyAgent(agent_id: @user.attributes.agencynumber)
    agent.on "load", ->
      app.current_view = new app.views.agent.MyAgent(model: agent, user: @user)

  my_agent_get_directions: ->
    id = @user.attributes.agencynumber
    agent = new app.models.MyAgent(agent_id: id)
    agent.on "load", ->
      app.current_view = new app.views.agent.GetDirections(model: agent, user: @user)

  agent_get_directions: (id) ->
    if app.agencies
      agencies = app.agencies.where({agency_id: parseInt(id)})
      if agencies && agencies.length > 0
        agency = agencies[0]
        agency.load()
        agent.on "load", ->
          app.current_view = new app.views.agent.GetDirections(model: agency)

  agencies: ->
    app.current_view = new app.views.agent.Search()

  agent: (id) ->
    app.current_view = new app.views.agent.Show(id: id)

  select_policy: ->
    policies = new app.collections.Policies(user: @user)
    policies.on "load", ->
      app.current_view = new app.views.bill.SelectPolicy(policies: policies)

  payment: (id) ->
    policies = new app.collections.Policies(user: @user)
    that = this
    policies.on "load", ->
      policy = policies.find_by_policy_id( decodeURIComponent(id) )
      if policy
        app.current_view = new app.views.bill.Payment(policy: policy, user: that.user)

  claim_main: ->
    app.current_view = new app.views.claim.Main(model: "nana", user: @user)

  claim_numbers: ->
    app.current_view = new app.views.claim.ImportantNumbers(model: "nana", user: @user)

  report_a_claim: (policy_id) ->
    app.current_view = new app.views.claim.ReportAClaim(policy_id: policy_id)

  select_claim_policy: ->
    policies = new app.collections.Policies(user: @user)
    policies.on "load", ->
      app.current_view = new app.views.claim.SelectClaimPolicy(policies: policies)

  propert_claim_start: ->
    if app.vehicle_claim
      delete app.vehicle_claim
    property_claim = new app.models.PropertyClaim()
    property_claim.attributes.policyid =  app.policy.policy_id
    property_claim.on 'claim_submission_ready', ->
      app.property_claim = property_claim
      app.current_view = new app.views.claim.PropertyClaimStart()
    property_claim.start_claim_submission(@user)

  edit_claim_address: ->
    app.current_view = new app.views.claim.EditClaimAddress()

  property_claim_date: ->
    app.current_view = new app.views.claim.PropertyClaimDate()

  property_claim_loss_description: ->
    app.current_view = new app.views.claim.PropertyClaimLoss()

  property_claim_contacts: ->
    app.current_view = new app.views.claim.PropertyClaimContacts()

  propert_claim_attach_photo: ->
    app.current_view = new app.views.claim.PropertyClaimAttachPhotos()

  propert_claim_comments: ->
    app.current_view = new app.views.claim.PropertyClaimComments()

  property_claim_summary: ->
    app.current_view = new app.views.claim.PropertyClaimSummary()

  property_claim_submit_results: ->
    app.current_view = new app.views.claim.PropertyClaimSubmitResults()

  vehicle_claim_start: ->
    if app.property_claim
      delete app.property_claim

    vehicle_claim = new app.models.VehicleClaim()
    vehicle_claim.attributes.policyid =  app.policy.policy_id
    vehicle_claim.on 'claim_submission_ready', ->
      app.vehicle_claim = vehicle_claim
      app.current_view = new app.views.claim.VehicleClaimStart()
    vehicle_claim.start_claim_submission(@user)

  vehicle_claim_edit_vehicle: ->
    app.current_view = new app.views.claim.EditClaimVehicle()

  vehicle_claim_driver: ->
    app.current_view = new app.views.claim.VehicleDriver()

  vehicle_claim_driver_edit: ->
    app.current_view = new app.views.claim.VehicleDriverEdit()

  vehicle_claim_location: ->
    app.current_view = new app.views.claim.VehicleClaimLocation()

  vehicle_claim_date: ->
    app.current_view = new app.views.claim.VehicleClaimDate()

  vehicle_claim_loss_description: ->
    app.current_view = new app.views.claim.VehicleClaimDescription()

  vehicle_claim_injuries: ->
    app.current_view = new app.views.claim.VehicleClaimInjuries()

  vehicle_claim_injuries_edit:(id) ->
    app.current_view = new app.views.claim.VehicleInjuredEdit(id: id)

  vehicle_claim_other_vehicles: ->
    app.current_view = new app.views.claim.VehicleClaimOtherVehicles()

  vehicle_claim_other_vehicles_driver_edit:(id) ->
    app.current_view = new app.views.claim.VehicleOtherVehicleDriver(id: id)

  vehicle_claim_other_vehicles_vehicle:(id) ->
    app.current_view = new app.views.claim.VehicleOtherVehicleVehicle(id: id)

  vehicle_claim_attach_photo: ->
    app.current_view = new app.views.claim.VehicleClaimAttachPhotos()

  vehicle_claim_comments: ->
    app.current_view = new app.views.claim.VehicleClaimComments()

  vehicle_claim_summary: ->
    app.current_view = new app.views.claim.VehicleClaimSummary()

  vehicle_claim_submit_results: ->
    app.current_view = new app.views.claim.VehicleClaimSubmitResults()

  what_to_do_main: ->
    app.current_view = new app.views.claim.WhatToDoMain(model: "nana", user: @user)

  about: ->
    app.current_view = new app.views.about.Main()

  about_contacts: ->
    app.current_view = new app.views.about.Contacts()

  about_donegal: ->
    app.current_view = new app.views.about.Donegal()

  about_terms: ->
    app.current_view = new app.views.about.Terms()

  about_info: ->
    app.current_view = new app.views.about.Info()  

  auto_accident: ->
    app.current_view = new app.views.claim.AutoAccident()

  workers_compensation: ->
    app.current_view = new app.views.claim.WorkersCompensation()

  property_loss: ->
    app.current_view = new app.views.claim.PropertyLoss()

  general_liability: ->
    app.current_view = new app.views.claim.GeneralLiability()

  claim_saved: ->
    app.claims = new app.collections.Claims()
    app.claims.on "load", ->
      app.current_view = new app.views.claim.SavedClaims(claims: app.claims)
    app.claims.load(@user)

  vehicles: ->
    app.vehicles = new app.collections.Vehicles()
    app.vehicles.load(@user)
    app.vehicles.on "load", ->
      app.current_view = new app.views.vehicle.List()

  vehicle: (policy_id, id, policy_label) ->
    app.current_view = new app.views.vehicle.Show(id: id, policy_id: policy_id, user: @user, policy_label: policy_label)

  photo_new: ->
    app.current_view = new app.views.photo.New(photo: new app.models.Photo())

  photo: (id) ->
    if app.property_claim
      photos = app.property_claim.attributes.photos
    else
      if app.vehicle_claim
        photos = app.vehicle_claim.attributes.photos

    app.current_view = new app.views.photo.Show(photo: photos.at(id))

  photo_edit: (id) ->
    if app.property_claim
      photos = app.property_claim.attributes.photos
    else
      if app.vehicle_claim
        photos = app.vehicle_claim.attributes.photos

    app.current_view = new app.views.photo.Edit(photo: photos.at(id))

  photos_new: ->
    if app.property_claim
      unless app.property_claim.attributes.photos
        app.property_claim.attributes.photos = new app.collections.Photos()
      app.current_view = new app.views.photos.New(photos: app.property_claim.attributes.photos)
    else
      if app.vehicle_claim
        unless app.vehicle_claim.attributes.photos
          app.vehicle_claim.attributes.photos = new app.collections.Photos()
        app.current_view = new app.views.photos.New(photos: app.vehicle_claim.attributes.photos)

  photos: ->
    if app.property_claim
      photos = app.property_claim.attributes.photos
      continue_url = "#property_claim_summary"
    else
      if app.vehicle_claim
        photos = app.vehicle_claim.attributes.photos
        continue_url = "#vehicle_claim_summary"

    app.current_view = new app.views.photos.Show(photos: photos, continue_url: continue_url)

  policy_list: ->
    policies = new app.collections.Policies(user: @user)
    policies.on "load", ->
      app.current_view = new app.views.policy.List(href: "#policy_coverage#" ,policies: policies)


  policy_coverage:(id) ->
    policy = new app.models.Policy()
    policy.on "get_coverage_ready", ->
      app.current_view = new app.views.policy.Coverage(policy: policy)
    policy.get_coverage(id, @user)
)
