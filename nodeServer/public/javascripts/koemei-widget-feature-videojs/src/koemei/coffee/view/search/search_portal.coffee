class Koemei.View.SearchPortal extends Backbone.View

  events:
    "click .kw_video_list_link":"detail"
    "click .kw_detail_list_link":"detail"
    'click .sp_back':'back'

  initialize: ->
    Koemei.log 'Koemei.View.SearchPortal#initialize'
    @template = JST.Search_portal
    @widget = @options.widget

  render: (search_string='', mode='prompt')->
    Koemei.log 'Koemei.View.SearchPortal#render'
    @search_string = search_string
    @$el.html @template
      search_string: @search_string
      recent: mode == 'recent'
    @list_view = new Koemei.View.SearchPortalList
      el: @$ '.koemei_search_portal'#'.sp_wrapp'
      widget: @widget
      mode: mode
      search_string: search_string
    @detail_view = new Koemei.View.SearchPortalDetail
      el: @$ '.sp_wrapp'
      widget: @widget
      search_string: search_string
      mode: mode

    if mode == 'detail'
      @detail_view.render()
    else
      @list_view.render()


  detail: (e) ->
    Koemei.log 'Koemei.View.SearchPortal#detail'
    e.preventDefault()
    media_uuid = $(e.currentTarget).attr('data-id')
    start_time = $(e.currentTarget).attr('data-start')

    if @list_view.search_string != ''
      @detail_view.search_string  = @list_view.search_string
    else
      @detail_view.search_string  = @search_string
    @detail_view.render(media_uuid, start_time)

  back: (e)->
    # back to the search results
    e.preventDefault()
    @$('.sp_wrapp').html ""
    @list_view.render(@search_string)

  # override View.remove so we don't remove the whole $el from the DOM
  remove: ->
    Koemei.log 'Koemei.View.SearchPortal#remove'
    @$list.empty()
    @stopListening()