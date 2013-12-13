class Koemei.View.Notes extends Koemei.View.Paginator

  initialize: ->
    @views = {}


  fetchData: ->
    video: @options.widget.media_item.id


  render: ->
    Koemei.log 'Koemei.View.Notes#render'
    @$list = @$ 'ul.notes'
    @collection.fetch
      reset: true
      data: @fetchData()
      success: => @renderCollection()
    @delegateEvents()
    this


  remove: ->
    Koemei.log 'Koemei.View.Notes#remove'
    @$list.empty()
    @undelegateEvents()


  renderCollection: ->
    Koemei.log 'Koemei.View.Notes#renderCollection'
    if @$list and @collection.length
      @collection.each (model) =>
        @renderModel model
    else
      @$list.html "No notes yet on that video, be the first to create one!"


  appendCollection: ->
    Koemei.log 'Koemei.View.Notes#appendCollection'
    _.each @collection.last(@collection.count), (model) =>
      @renderModel model


  renderModel: (model, search_string = false) ->
    Koemei.log 'Koemei.View.Notes#renderModel'
    unless @views[model.cid]?
      @views[model.cid] = new Koemei.View.Note
        widget: @options.widget
        model: model
        $wrapper: @$list
    @$list.append @views[model.cid].el
    @views[model.cid].render search_string
