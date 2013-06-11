#= require ./api_interface/api_interface

alert(777)

window.app =
  root: "/"
  websql_db: openDatabase('cache', '1.0', 'lazy loading caching db', 2 * 1024 * 1024)
  api_interface: new APIInterface()
  models: {}
  collections: {}
  validators: {}
  views:
    layouts: {}
    agent: {}
    bill: {}
    claim: {}
    login: {}
    logout: {}
    user: {}
    about: {}
    vehicle: {}
    policy: {}
    photo: {}
    photos: {}
  photos: undefined
  error_messages: {
    login_expired: "Your session has expired. Please login again"
  }

  initialize: ->
    window.app.errors = []
    window.app.bindEvents()

  bindEvents: ->
    if (navigator.userAgent.match(/(iPhone|iPod|iPad|Android|BlackBerry)/))
      document.addEventListener "deviceready", window.app.onDeviceReady, false
    else
      $(document).on "ready", window.app.onDeviceReady

    $(document).on "click", "a[target=_blank]", ->
      url = $(this).attr("href").trim()
      ref = window.open(url, '_system', 'location=no')
      false
    
    if ( navigator.userAgent.match(/Android/) )
      $(document).on("render_finished", ->
        if( $("#wrapper").length > 0 )
          $("#wrapper").getNiceScroll().resize()
        false
      )
    window.onresize = window.app.setContentSize

  onDeviceReady: ->
    console.log "the device is ready!"
    app.router = new router()
    if ( navigator.userAgent.match(/Android/) )
      register_android_native_datapicker()
      app.router.bind "all", ->
        if( $("#wrapper").length > 0 )
          $("#wrapper").niceScroll(
            smoothscroll: false
            scrollSpeed: 100
          )
    $(document).on "focus", "input, select, textarea", ->
      if app.current_layout && $(this).attr("type") != "date" && $(this).attr("type") != "time" && $(this).attr("type") != "month" && $(this).attr("type") != "datetime"
        app.current_layout.hideNavBar()

    $("input, select, textarea").live "blur", ->
      if app.current_layout && Backbone.history.fragment != "login"
        app.current_layout.showNavBar()

    Backbone.history.start()
    app.router.navigate("startup", true)

    app.registerBackButtonListener()

  registerBackButtonListener: ->
    $(document).on "backbutton", ->
      if Backbone.history.fragment == "propert_claim_start"
        history.go(-2)
      else if Backbone.history.fragment == "vehicle_claim_start"
        history.go(-2)
      else if Backbone.history.fragment == "login"
        history.go(-2)
      else if Backbone.history.fragment == "propert_claim_attach_photo"
        app.router.navigate("property_claim_contacts", true)
      else if Backbone.history.fragment == "vehicle_claim_attach_photo"
        app.router.navigate("vehicle_claim_other_vehicles", true)
      else if Backbone.history.fragment == "photos_new"
        history.go(-2)
      else if Backbone.history.fragment == "photos"
        if app.property_claim
          app.router.navigate("propert_claim_attach_photo", true)
        else if app.vehicle_claim
          app.router.navigate("vehicle_claim_attach_photo", true)
      else
        history.back()

  setContentSize: ->
    if($("#wrapper").length != 0)
      windowHeight = $(window).height()
      headerHeight = $("#header").height()
      footerHeight = $("#footer").height()
      paddingTop = $("#wrapper").css("padding-top").slice(0, -2)
      paddingBottom = $("#wrapper").css("padding-bottom").slice(0, -2)
      $("#wrapper").height( windowHeight - footerHeight - paddingTop - paddingBottom)
      niceScroll = $("#wrapper").getNiceScroll()[0]
      if(niceScroll)
        niceScroll.resize()
        focused = $("input:focus")
        if( focused )
          top = focused.position().top || 0
          niceScroll = $("#wrapper").getNiceScroll()[0]
          diff = top - niceScroll.view.h
          if diff > 0
            diff = (if (diff > 150) then 0 else 150)
            $("#wrapper").scrollTop(top + diff)

  
  showSpinner: ->
    container = "<div class=\"spinner-container grey\"> <div class=\"spinner\">"
    i = 1
    while i < 13
      container += "<div class=\"bar" + i + "\"></div>"
      i++
    container += "</div></div>"
    overlay = "<div class=\"modal-overlay\"></div>"
    $("body").prepend(overlay, container)

  removeSpinner: ->
    $(".spinner-container, .modal-overlay").remove()

  check_error: (error) ->
    if error && $.inArray(error, app.errors) != -1 && app.error_messages[error]
      app.error_messages[error]
    else
      undefined

  take_error: (error) ->
    if error && $.inArray(error, app.errors) == -1 && app.error_messages[error]
      app.errors.push(error)
    else
      undefined    

  take_off_error: (error) ->
    if error && $.inArray(error, app.errors) != -1 && app.error_messages[error]
      app.errors.pop(error)
    else
      undefined

window.app.initialize()
