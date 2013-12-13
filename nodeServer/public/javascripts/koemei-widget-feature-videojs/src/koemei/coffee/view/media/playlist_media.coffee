class Koemei.View.PlaylistMedia extends Koemei.View.Paginator

  tagName: 'ul'


  className: 'playlist_media_list'


  initialize: ->
    Koemei.log 'Koemei.View.PlaylistMedia#initialize'
    @views = {}
    @widget = @options.widget
    @playlist = @options.playlist
    @collection = new Koemei.Collection.Media()


  render: ->
    Koemei.log 'Koemei.View.PlaylistMedia#render'
    @$el.empty()
    @collection.fetch
      reset: yes
      data: {playlist: @playlist.id}
      success: => @renderCollection()
    this


  renderCollection: ->
    Koemei.log 'Koemei.View.PlaylistMedia#renderCollection'
    if @collection.length
      @collection.each (media_item) =>
        @renderModel media_item
    else
      @$el.html "You have no media inside this playlist"


  appendCollection: ->
    Koemei.log 'Koemei.View.PlaylistMedia#appendCollection'
    _.each @collection.last(@collection.count), (model) =>
      @renderModel model


  renderModel: (media_item) ->
    Koemei.log 'Koemei.View.PlaylistMedia#renderModel'
    unless @views[media_item.cid]?
      @views[media_item.cid] = new Koemei.View.MediaItem
        widget: @widget
        model: media_item
        playlist: @playlist
        $wrapper: @$el
    #TODO: if media_item is already present don't append, just replace it
    @$el.append @views[media_item.cid].el
    @views[media_item.cid].render()
