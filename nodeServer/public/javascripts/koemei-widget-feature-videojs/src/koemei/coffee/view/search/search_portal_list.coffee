class Koemei.View.SearchPortalList extends Koemei.View.Paginator

  #events:
  #  'click .video_info_button': 'toggle_info'

  events:
    'click .kw_sort_mode li.kw_sp_sort_name': 'sort_name'
    'click .kw_sort_mode li.kw_sp_sort_date': 'sort_date'
    "submit #kw_search_form":"search"

  defaults:
    search_query:
      page_size: 12
      order_way: 'ASC'
      order_by: 'upload_date'
      status_filter: 'all'
      deleted: '0'
      start: 0


  # The element that triggers the scroll handler.
  scrollAreaElement: window


  fetchData: ->
    if @search_string
      search_query: @search_string
    else
      {}


  initialize: ->
    Koemei.log 'Koemei.View.SearchPortalList#initialize'
    @widget = @options.widget
    @template = JST.Search_list
    @views = {}
    @collection = new Koemei.Collection.Media() unless @collection
    @search_string = @options.search_string
    @mode = @options.mode


  render: ->
    Koemei.log 'Koemei.View.SearchPortalList#render'
    @$('.sp_wrapp').html @template
      search_string:@search_string
    @$list = @$('.search_results_list')

    data = {}

    if @search_string != '' and @search_string?
      @collection.search_string = @search_string
      data.search_query = @search_string
      @$(".kw_sp_search_button").addClass('has_text')
    else
      @search_string = null
      @$(".kw_sp_search_button").removeClass('has_text')

    if @order_by?
      data.order_by = @order_by
      if @order_by == 'title'
        $('.kw_sort_mode li.kw_sp_sort_name').addClass('active')
        $('.kw_sort_mode li.kw_sp_sort_date').removeClass('active')
      if @order_by == 'created'
        $('.kw_sort_mode li.kw_sp_sort_date').addClass('active')
        $('.kw_sort_mode li.kw_sp_sort_name').removeClass('active')

    # fetch the collection if not in prompt mode (recent videos or search string provided)
    if (@mode == 'prompt' and @search_string? and @search_string != '') or @mode != 'prompt'
      @$list.addClass 'load_sp'
      @collection.fetch
        reset: yes
        data: data
        success: => @renderCollection()

    this


  # override View.remove so we don't remove the whole $el from the DOM
  remove: ->
    Koemei.log 'Koemei.View.SearchPortalList#remove'
    @$list.empty()
    @stopListening()


  loadingCallback: ->
    #TODO: show the loading image in the bottom of the list


  successCallback: ->
    #TODO: hide the loading image


  errorCallback: ->
    #TODO: hide the loading image and show error to the user


  renderCollection: ->
    Koemei.log 'Koemei.View.SearchPortalList#renderCollection'
    # $('#kw_remaining').empty()
    @$list.removeClass("load_sp")
    @$list.html("")
    if @$list and @collection.length
      @collection.each (media_item) =>
        @sortTranscriptMatches media_item
        @renderModel media_item, @search_string
    else
      @$list.html "No media found"

    #update the sp header
    if @collection.search_string?
      @$('.search_portal_header').html("#{@collection.length} results for <b>#{@collection.search_string}</b>")
    #else if mode != 'prompt'
    #  @$('.search_portal_header').html("Please enter your search keywords")
    else
      @$('.search_portal_header').html("Recent videos")

  appendCollection: ->
    Koemei.log 'Koemei.View.SearchPortalList#appendCollection'
    _.each @collection.last(@collection.count), (model) =>
      @sortTranscriptMatches model
      @renderModel model, @search_string

  search: (e) ->
    Koemei.log 'Koemei.View.SearchPortalList#search'
    if e?
      e.preventDefault()
    form_data = $(e.currentTarget).serializeFormJSON()
    @search_string = form_data.search_string.trim()
    @render()

  sort_name: (e)->
    Koemei.log 'Koemei.View.SearchPortalList#sort_name'
    e.preventDefault()
    @order_by = 'title'
    @render()

  sort_date: (e)->
    Koemei.log 'Koemei.View.SearchPortalList#sort_date'
    e.preventDefault()
    @order_by = 'created'
    @render()



  sortTranscriptMatches: (model) ->
    transcript = model.get 'current_transcript'
    if transcript? and transcript.matches?
      transcript.matches = _(transcript.matches).sortBy 'start'


  renderModel: (media_item) ->
    #Koemei.log 'Koemei.View.SearchPortalList#renderModel'
    unless @views[media_item.cid]?
      @views[media_item.cid] = new Koemei.View.SearchMediaItemRow
        widget: @widget
        model: media_item
        $wrapper: @$list
    #TODO: if media_item is already present don't append, just replace it
    @$list.append @views[media_item.cid].el
    @views[media_item.cid].render(@search_string)
