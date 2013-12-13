class Koemei.View.Segment extends Backbone.View

  initialize: ->
    #Koemei.log 'Koemei.View.Segment#initialize'
    @template = JST.Segment
    @$wrapper = @options.$wrapper

  render: (search_string=false)->
    #Koemei.log 'Koemei.View.Segment#render'

    @$el.html @template
      segment: @model
      # TODO: do not compute those 3 each time
      content_editable: if @options.readonly then 'false' else 'true'
      readonly_class: if @options.readonly then 'kw_readonly_segment' else ''
      display_speakers: false
      search_string: search_string

    @$wrapper.append @$el
    this