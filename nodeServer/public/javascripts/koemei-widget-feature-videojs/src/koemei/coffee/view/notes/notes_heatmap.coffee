class Koemei.View.NotesHeatmap extends Backbone.View

  events:
    'mouseenter .h_e': 'toggle_note_group_tooltip'


  initialize: ->
    Koemei.log 'Koemei.View.NotesHeatmap#initialize'
    @listenTo @options.media_item.notes, 'add', @update
    @listenTo @options.media_item.notes, 'remove', @update
    @render()


  render: ->
    Koemei.log 'Koemei.View.NotesHeatmap#render'
    template_variables =
      bar_width: @options.bar_width
      left_space: @options.left_space
      note_groups: @options.media_item.notes.groupBy 'start_time'
      # width of one second on the toolbar
      granularity: @$el.width() / @options.media_item.get('size')

    @template = JST.Note_heatmap(template_variables)

    # render the filled toolbar inside the player element
    @$heatmap_el = @$el.append @template
    this


  toggle: ->
    Koemei.log 'Koemei.View.NotesHeatmap#toggle'
    if $('.heatmap_notes').length
      @hide()
    else
      @render()


  toggle_note_group_tooltip: (e) ->
    e.preventDefault()
    element = e.currentTarget
    $('.h_e').not(element).removeClass('opened')
    $(element).toggleClass('opened')


  hide: ->
    Koemei.log 'Koemei.View.NotesHeatmap#hide'
    #@$heatmap_el.empty().hide()


  # Re-renders the heatmap if its visible, otherwise does nothing.
  update: ->
    Koemei.log 'Koemei.View.NotesHeatmap#update'
    if $('.heatmap_notes').length
      @render()
