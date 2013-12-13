class Koemei.View.Toolbar extends Backbone.View

  events:
    'click .login_button': 'toggle_login_overlay'
    'click .profile_button': 'profile'
    #'click .like_button': 'like_video'
    'click .share_button': 'share_media'
    'click .playlist_button': 'add_to_playlist'
    'click .kw_toolbar a': 'display_panel'
    # TODO : restore walkthrough and feedback pane
    #'click #kw_help':'show_walkthrough',

  initialize: ->
    Koemei.log 'Koemei.View.Toolbar#initialize'
    @widget = @options.widget
    @media_item = @widget.media_item

    @render()

  render: ->
    Koemei.log 'Koemei.View.Toolbar#render'
    @$el.html JST.Toolbar(
      features: @widget.options.features
    )
    @delegateEvents()

    if @widget.user?
      @login_success_callback(@widget.user)

    this

  toggle_login_overlay: (e) =>
    # display or hide the login overlay
    e.preventDefault()
    login_overlay = new Koemei.View.Login
      widget: @widget
    login_overlay.toggle(@widget.xhr, @login_success_callback)

  login_success_callback:(user)=>
    @widget.user = user
    @widget.user.playlists = new Koemei.Collection.Playlists()
    @widget.user.playlists.fetch()

    # add the playlists panel
    if @widget.videos_panel?
      unless @widget.videos_panel.playlists?
        @widget.videos_panel.playlists = new Koemei.View.Playlists widget: @widget
        @widget.videos_panel.playlists.collection = @widget.user.playlists

    $('.login_button').hide()
    $('.logged_in_toolbar').show()

  display_panel: (e)->
    e.preventDefault()
    button = e.currentTarget
    target = $(button).attr('data-target')
    $('.kw_toolbar a').removeClass('active')
    $(button).addClass('active')
    # TODO: do not render again if already rendered
    @widget[target + "_panel"].render()

    # TODO: necessary? if yes: comment, if no: remove
    #if this.options.modal
    #  this.centerVertically()


  """  like_video: (e) ->
    e.preventDefault()
    $(e.currentTarget).toggleClass('liked')

    if $(e.currentTarget).hasClass('liked')
      do_like = true
    else
      do_like = false

    @media_item.like @widget.xhr, @media_item, do_like, @widget.options.auth, null, null
  """

  profile: (e) ->
    Koemei.log "Koemei.View.Toolbar#profile"
    e.preventDefault()

    tooltip = Koemei.View.ProfilePopup.toggle
      $wrapper: @$el
      $button: @$ e.target
      widget: @widget
      data:
        user: @widget.user.toJSON()
    tooltip?.render()

  share_media: (e) ->
    Koemei.log "Koemei.View.Toolbar#share_media"
    e.preventDefault()

    tooltip = Koemei.View.ShareMediaPopup.toggle
      $wrapper: @$el
      $button: @$ e.target
      widget: @widget
      data:
        share_url: @widget.options.koemei_host+'/media/'+@widget.media_item.get('uuid')
        embed_code: '<script src="'+@widget.options.static_cdn_path+'/widget/latest/javascript/koemei-widget.min.js"></script><script> new KoemeiWidget({media_uuid: "'+@widget.media_item.get('uuid')+'"});</script>'
    tooltip?.render()

  add_to_playlist: (e) ->
    Koemei.log "Koemei.View.Toolbar#add_to_playlist"
    e.preventDefault()
    tooltip = Koemei.View.AddVideoToPlaylistPopup.toggle
      $wrapper: @$el
      $button: @$ e.target
      widget: @widget
      model: @widget.media_item
      collection: @widget.user.playlists
    tooltip?.render()