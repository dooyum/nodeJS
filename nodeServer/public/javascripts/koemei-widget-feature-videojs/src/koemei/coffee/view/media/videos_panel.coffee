class Koemei.View.VideosPanel extends Koemei.View.Panel

  template: JST.Media_videos_panel


  events:
    'click .all_videos_button':       'renderMedia'
    'click .connections_button':      'renderConnections'
    'click .video_playlists_button':  'renderPlaylists'
    'click .show_playlist':           'renderPlaylist'
    'submit #video_search':           'search'


  initialize: ->
    Koemei.log 'Koemei.View.VideosPanel#initialize'
    @panel_name = 'videos'

    @widget = @options.widget
    if @widget.user?
      @playlists = new Koemei.View.Playlists widget: @widget
    @mediaView = new Koemei.View.Media widget: @widget
    @connectionsView = new Koemei.View.Connections widget: @widget
    this


  cleanViews: ->
    @mediaView.remove()
    @connectionsView.remove()
    @playlists.remove() if @playlists
    @playlistMedia.remove() if @playlistMedia


  render: ->
    Koemei.log 'Koemei.View.VideosPanel#render'
    @$el.html @template
      height: @options.height
      playlists: @widget.user?
    @$container = @$ '.videos_list'
    # Render the default view.
    @renderMedia()


  renderMedia: (e) ->
    Koemei.log 'Koemei.View.VideosPanel#renderMedia'
    e?.preventDefault()
    @cleanViews()
    @$('.playlist_options').hide()
    @$('.video_options').show()
    @$('.video_options a').removeClass 'active'
    @$('.all_videos_button').addClass 'active'
    @$container.html @mediaView.render().el
    @collection = @mediaView.collection
    @$list = @mediaView.$list


  renderConnections: (e) ->
    Koemei.log 'Koemei.View.VideosPanel#renderConnections'
    e?.preventDefault()
    @cleanViews()
    @$('.playlist_options').hide()
    @$('.video_options').show()
    @$('.video_options a').removeClass 'active'
    @$('.connections_button').addClass 'active'
    @$container.html @connectionsView.render().el


  renderPlaylists: (e) ->
    Koemei.log 'Koemei.View.VideosPanel#renderPlaylists'
    e?.preventDefault()
    @cleanViews()
    @$('.video_options').show()
    @$('.playlist_options').hide()
    @$('.video_options a').removeClass 'active'
    @$('.video_playlists_button').addClass 'active'
    @$container.html @playlists.render().el


  renderPlaylist: (e) ->
    Koemei.log 'Koemei.View.VideosPanel#renderPlaylist'
    e.preventDefault()
    playlist = @playlists.collection.get(@$(e.currentTarget).data('id'))
    @cleanViews()
    @$('.kw_playlist_name').text playlist.get('title')
    @$('.playlist_edit_top_wrap').show()
    @$('.playlist_edit_top_button').data('id', playlist.id)
    @$('.videos_search_wrap').hide()

    @playlistMedia = new Koemei.View.PlaylistMedia
      playlist: playlist
      widget: @widget

    @$('.video_options').hide()
    @$('.playlist_options').show()
    @$container.html @playlistMedia.render().el


  renderModel: (media_item, search_string=false) ->
    #TODO: where does `@media` come from??? and where does it should render?
    @mediaView.renderModel media_item, search_string
