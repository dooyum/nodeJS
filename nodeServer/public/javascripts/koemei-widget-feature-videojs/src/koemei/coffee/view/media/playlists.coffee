class Koemei.View.Playlists extends Koemei.View.Paginator

  tagName: 'ul'


  className: 'playlists_list'


  initialize: ->
    Koemei.log 'Koemei.View.Playlists#initialize'
    @panel_name = 'playlists'

    @widget = @options.widget
    @views = {}
    @collection = @widget.user.playlists unless @collection?

  render: ->
    Koemei.log 'Koemei.View.Playlists#render'
    @$el.empty()
    @collection.fetch
      reset: yes
      success: => @renderCollection()
    @delegateEvents()
    this


  renderCollection: ->
    Koemei.log 'Koemei.View.Playlists#renderCollection'
    if @collection.length
      @collection.each (playlist) =>
        @renderModel playlist
    else
      @$el.html "You have not created any playlist yet"


  appendCollection: ->
    Koemei.log 'Koemei.View.Playlists#appendCollection'
    _.each @collection.last(@collection.count), (model) =>
      @renderModel model


  renderModel: (playlist) ->
    Koemei.log 'Koemei.View.Playlists#renderModel'
    unless @views[playlist.cid]?
      @views[playlist.cid] = new Koemei.View.Playlist
        model: playlist
        $wrapper: @$el
        widget: @widget
    #TODO: if media_item is already present don't append, just replace it
    @$el.append @views[playlist.cid].el
    @views[playlist.cid].render()
