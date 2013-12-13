# A panel is a widget view with the search capabilities
# you need to declare
# - the panel_name of the panel
# - a renderModel method which accepts the model and search string
# - the events for the search to fire on
class Koemei.View.Panel extends Backbone.View

  renderModel: (model, search_string=false) ->
    Koemei.log "Koemei.View.#{@panel_name}#renderModel"
    Koemei.error "Implement me!"

  search: (e) ->
    Koemei.log "Koemei.View.#{@panel_name}#search"
    if e?
      e.preventDefault()
      form_data = $(e.currentTarget).serializeFormJSON()
      @search_string = form_data.search_string.trim()

    if @search_string !='' and not $(".#{@panel_name}_search_button").hasClass('has_text')
      #if no search currently active, search
      @results = @collection.search(@search_string, @search_success_callback)
    else
      # a search is active, the "x" button was clicked
      $(".#{@panel_name}_search_button").removeClass('has_text')
      @render()

  search_success_callback: (results) =>
    Koemei.log "Koemei.View.#{@panel_name}#search_success_callback"
    if results?
      @search_display_results(results)
    else
      @search_display_no_result()

  search_display_no_result: () ->
    Koemei.log "Koemei.View.#{@panel_name}#search_display_no_result"

    el = new Object
    $(".#{@panel_name}_search_results").hide()
    el.preventDefault = ->
      true

    $(".#{@panel_name}_search_wrap").attr "data-tooltip-text", "No results for #{@search_string}"
    el.currentTarget = $(".#{@panel_name}_search_wrap")
    @widget.sumon_tooltip el
    setTimeout (->
      $(".tip").fadeOut 400
      $("##{@panel_name}_search input").val('')
    ), 1000
    @render()


  search_display_results: (results) ->
    Koemei.log "Koemei.View.#{@panel_name}#search_display_results"
    @$list.empty()
    # if from ajax
    $(".#{@panel_name}_search_button").removeClass('kw_icon_search')
    $(".#{@panel_name}_search_button").addClass('has_text')

    if results.models?
      results = results.models
    for model in results
      @renderModel(model, @search_string)

    $(".#{@panel_name}_search_results").html("#{results.length} matches")
    $(".#{@panel_name}_search_results").show()
    @render_search_result_heatmap(results)


  render_search_result_heatmap: (results)->
    Koemei.log "Koemei.View.#{@panel_name}#render_search_result_heatmap"
    # TODO: do some nice things here
    #@widget.player.notes_heatmap.toggle()
    # TODO : restore this by moving it into the heatmap view:

  search_on_focus:(e) ->
    Koemei.log "Koemei.View.#{@panel_name}#search_on_focus"
    Koemei.error "Implement me!"