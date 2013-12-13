class Koemei.View.SearchPortalDetail extends Backbone.View

  defaults:
    search_query:
      page_size: 12
      order_way: 'ASC'
      order_by: 'upload_date'
      status_filter: 'all'
      deleted: '0'
      start: 0

  initialize: ->
    Koemei.log 'Koemei.View.SearchPortalDetail#initialize'
    @widget = @options.widget
    @views = {}
    @collection = new Koemei.Collection.Media() unless @collection
    @listenTo @collection, 'reset', @renderCollection
    @template = JST.Search_detail
    @search_string = @options.search_string
    Koemei.log @search_string

  render: (media_uuid, start_time)->
    Koemei.log "Koemei.View.SearchPortalDetail#render#{media_uuid}"
    Koemei.log @search_string
    @$el.html @template
      search_string: @search_string

    @$list = @$('.search_results_detail')

    data = {}

    if @search_string != ''
      @collection.search_string = @search_string
      data.search_query = @search_string
    else
      @search_string = null

    # fetch the collection if not in prompt mode (recent videos or search string provided)
    if @mode != 'prompt'
      @$list.addClass 'load_sp'
      @collection.fetch
        reset: yes
        data: data

        success: => @renderCollection()

    # create an edit widget inside
    this.innerPlayer = new KoemeiWidget
      media_uuid: media_uuid
      el:$("#video_detail")
      width:544
      video_width: 544
      mode:"embed"
      search_string: @search_string
      #widget_height:340
      #video_height:366
      start_time: parseInt(start_time)

    @renderCollection()
    this

  renderCollection: ()->
    Koemei.log 'Koemei.View.SearchPortalDetail#renderCollection'
    # $('#kw_remaining').empty()
    @$list.removeClass("load_sp")
    @$list.html("")
    if @$list and @collection.length
      @collection.each (media_item) =>
        @renderModel media_item, @search_string
    else
      @$list.html ""

  renderModel: (media_item) ->
    #Koemei.log 'Koemei.View.SearchPortalList#renderModel'
    unless @views[media_item.cid]?
      @views[media_item.cid] = new Koemei.View.SearchMediaItemRowDetail
        widget: @widget
        model: media_item
        $wrapper: @$list
    #TODO: if media_item is already present don't append, just replace it
    @$list.append @views[media_item.cid].el
    @views[media_item.cid].render(@search_string)

  # override View.remove so we don't remove the whole $el from the DOM
  remove: ->
    Koemei.log 'Koemei.View.SearchPortalDetail#remove'
    @$list.empty()
    @stopListening()

