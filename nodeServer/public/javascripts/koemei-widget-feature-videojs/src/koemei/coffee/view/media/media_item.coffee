class Koemei.View.MediaItem extends Backbone.View

  events:
    'click .show_video':                    'load_media'
    'click .video_share_option':            'share'
    'click .video_connect_option':          'connect'
    'click .video_disconnect_option':       'connect'
    'click .playlist_edit_option':          'add_to_playlist'
    'click .playlist_delete_video_option':  'remove_from_playlist'

  tagName: 'li'

  id: -> @cid

  initialize: ->
    Koemei.log "Koemei.View.MediaItem#initialize"
    @$wrapper = @options.$wrapper
    @template = JST.Media_item
    @widget = @options.widget

    @listenTo @model, 'change', @render
    @listenTo @model, 'destroy', @remove


  render: (search_string='')->
    Koemei.log "Koemei.View.MediaItem#render"
    # if displaying the "all media" pane, playlist is empty
    playlist =  if @options.playlist? then @options.playlist.toJSON() else {id:""}
    @$el.html @template(
      media_item: @model.toJSON()
      connected: @model.isConnected()
      playlist: playlist
      search_string: search_string
      user: @widget.user
    )
    this

  load_media: (e)->
    @widget.reinit(e)


  share: (e) ->
    e.preventDefault()
    tooltip = Koemei.View.ShareMediaPopup.toggle
      $wrapper: @$el
      $button: @$ e.target
      widget: @widget
      data:
        share_url: @widget.options.koemei_host+'/media/'+@model.get('uuid')
        embed_code: '<script src="'+@widget.options.static_cdn_path+'/widget/latest/javascript/koemei-widget.min.js"></script><script> new KoemeiWidget({media_uuid: "'+@model.get('uuid')+'"});</script>'
    tooltip?.render()

  connect: (e) ->
    e.preventDefault()
    tooltip = Koemei.View.ConnectMediaPopup.toggle
      $wrapper: @$el
      $button: @$ e.target
      widget: @widget
      model: @model
    tooltip?.render()

  add_to_playlist: (e) ->
    tooltip = Koemei.View.AddVideoToPlaylistPopup.toggle
      $wrapper: @$el
      $button: @$ e.target
      widget: @widget
      model: @model
      collection: @widget.user.playlists
    tooltip?.render()

  remove_from_playlist: (e) ->
    tooltip = Koemei.View.RemoveMediaFromPlaylistPopup.toggle
      $wrapper: @$el
      $button: @$ e.target
      widget: @widget
      data:
        playlist: @model.get('playlist')
        model: @model.toJSON()
    tooltip?.render()
