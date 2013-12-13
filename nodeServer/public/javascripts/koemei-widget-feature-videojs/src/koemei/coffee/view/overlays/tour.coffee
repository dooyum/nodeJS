class Koemei.View.Tour extends Backbone.View

  initialize: () ->
    Koemei.log "Koemei.View.Tour#initialize"
    @$el = $(".widget_player")

    @template = JST.Tour_overlay

  render: ->
    Koemei.log "Koemei.View.Tour#render"
    # display the login overlay
    @$el.prepend @template()
    $('.koemei_shaded_overlay').show()

  remove: ->
    Koemei.log "Koemei.View.Tour#remove"
    # remove the login overlay
    @$el.find('.koemei_tour_overlay').remove()
    $('.koemei_shaded_overlay').hide()

  toggle: ()->
    Koemei.log "Koemei.View.Tour#toggle"
    # Toggle the tour overlay
    if @$el.find('.koemei_tour_overlay').length == 0
      @render()
    else
      @remove()