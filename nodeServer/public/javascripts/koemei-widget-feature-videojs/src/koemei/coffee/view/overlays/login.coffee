class Koemei.View.Login extends Backbone.View

  events:
    'submit #kw_login_form': 'login'
    'click .account_retry': 'hide_error_message'
    'click .login_error': 'hide_error_message'
    'click .account_signup': 'signup'

  initialize: () ->
    @$el = $(".widget_player")
    @template = JST.Login_overlay()
    @widget = @options.widget

  render: ->
    # display the login overlay
    @$el.prepend @template
    $('.koemei_shaded_overlay').show()

  remove: ->
    # remove the login overlay
    @$el.find('.kw_login_overlay').remove()
    $('.koemei_shaded_overlay').hide()

  toggle: (xhr, login_success_callback)->
    @xhr=xhr
    @login_success_callback = login_success_callback
    # Toggle the login overlay
    $('.koemei_video_info').remove()
    if $('.kw_login_overlay').length == 0
      @render()
    else
      @remove()

  login: (e)=>
    # log the user in
    e.preventDefault()
    form_data = $(e.currentTarget).serializeFormJSON()
    Koemei.Model.User.login(
      @xhr,
      form_data.email,
      form_data.password,
      @login_success_handler,
      @login_error_handler
    )

  login_success_handler: (user) =>
    @login_success_callback(user)
    @remove()

  login_error_handler: (error) ->
    @render_error(error)

  hide_error_message: (e) ->
    if e is not null
      e.preventDefault()
    $('.login_error_wrap').hide()
    $('.login_fields_wrap').show()

  render_error: (error_message)->
    $('.login_error div').html(error_message)
    $('.login_error_wrap').show()
    $('.login_fields_wrap').hide()
    setTimeout (=>
      @hide_error_message(null)
    ), 2000

  signup_success_handler: (user_data) =>
    # on signup success, login the user
    form_data = $("#kw_login_form").serializeFormJSON()
    Koemei.Model.User.login(
      @xhr,
      form_data.email,
      form_data.password,
      @login_success_handler,
      @login_error_handler
    )
    @remove()

  signup_error_handler: (error) =>
    # TODO: handle 500 and 409 errors!
    @render_error(error)

  signup: (e) =>
    Koemei.log "Koemei.View.Login#signup"
    e.preventDefault()
    location.replace "#{@widget.options.koemei_host}/signup"

    # TODO: restore this
    #form_data = $(e.currentTarget).closest("form").serializeFormJSON()
    #Koemei.Model.User.register(
    #  @xhr,
    #  form_data.email,
    #  form_data.password,
    #  @signup_success_handler,
    #  @signup_error_handler
    #)