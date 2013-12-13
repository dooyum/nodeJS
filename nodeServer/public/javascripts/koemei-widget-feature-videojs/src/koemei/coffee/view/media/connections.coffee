class Koemei.View.Connections extends Backbone.View

  tagName: 'ul'


  className: 'connections_list'


  template: JST.Connections

  fetchData: ->
    media_uuid: @options.widget.media_item.id


  initialize: ->
    Koemei.log 'Koemei.View.Connections#initialize'
    @widget = @options.widget
    @collection = @widget.connections
    # This is handled here because we need to update the `quantity` on the
    # template.
    @collection.on 'destroy', @render, this


  render: ->
    Koemei.log 'Koemei.View.Connections#render'
    @collection.fetch
      reset: true
      data: @fetchData()
      success: =>
        @$el.html @template({quantity: @collection.length})
        @renderCollection()
    this


  renderCollection: ->
    Koemei.log 'Koemei.View.Connections#renderCollection'
    if @collection.length
      @collection.each (model) =>
        @renderModel model
    else
      @$el.html 'No connections available for this media yet'


  renderModel: (model) ->
    Koemei.log 'Koemei.View.Connections#renderModel'
    view = new Koemei.View.Connection
      model: model
      $wrapper: @$el
      widget: @widget
    @$el.append view.render().el
