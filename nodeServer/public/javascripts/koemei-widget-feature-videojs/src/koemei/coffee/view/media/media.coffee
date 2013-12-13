class Koemei.View.Media extends Koemei.View.Paginator

  tagName: 'ul'


  className: 'media_list'


  initialize: ->
    Koemei.log 'Koemei.View.Media#initialize'
    @widget = @options.widget
    @views = {}
    @collection = new Koemei.Collection.Media()
    @$list = @$el


  render: ->
    Koemei.log 'Koemei.View.Media#render'
    @$el.empty()
    @collection.fetch
      reset: true
      success: => @renderCollection()
    @delegateEvents()
    this


  prepareCollection: ->
    return unless @collection.length
    # remove widget's media item from the video collection
    @collection.remove @collection.get(@widget.media_item.id)
    # check which items are connected to the widget's one
    @widget.connections.each (c) =>
      source = c.get('source_media').uuid
      target = c.get('target_media').uuid
      # choose which item is not the widget's item
      id = if source is @widget.media_item.id then target else source
      connectedItem = @collection.get id
      connectedItem?.setConnected true


  renderCollection: ->
    Koemei.log 'Koemei.View.Media#renderCollection'
    @prepareCollection()
    if @collection.length
      @collection.each (media_item) =>
        @renderModel media_item
    else
      @$el.html "You have no media available yet"


  appendCollection: ->
    Koemei.log 'Koemei.View.Media#appendCollection'
    #TODO: this should be called here so that the new results can be marked as connected
    #TODO: but it is breaking somewhere in the renderModel (search_string is media model??)
    #@prepareCollection()
    _.each @collection.last(@collection.count), (model) =>
      @renderModel model


  renderModel: (media_item, search_string='') ->
    Koemei.log 'Koemei.View.Media#renderModel'
    unless @views[media_item.cid]?
      @views[media_item.cid] = new Koemei.View.MediaItem
        widget: @widget
        model: media_item
        $wrapper: @$el
    #TODO: if media_item is already present don't append, just replace it
    @$el.append @views[media_item.cid].el
    @views[media_item.cid].render(search_string)
