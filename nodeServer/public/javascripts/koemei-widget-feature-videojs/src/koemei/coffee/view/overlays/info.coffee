class Koemei.View.Info extends Backbone.View

  events:
    'click .close_overlay_panel': 'remove'
    'click #kw_info_title': 'toggle_title'


  initialize: () ->
    Koemei.log "Koemei.View.Info#initialize"
    @$el = $(".widget_player")
    @media_item = @options.media_item

    template_variables =
      media_item: @media_item.toJSON()
      show_close: not @options.detach_info
    if @options.show_confidence
      confidence = @media_item.get('current_transcript').confidence
      template_variables.confidence = parseInt(confidence * 100)
    @template = JST.Info_overlay(template_variables)

    if @options.detach_info
      @$el.after @template
    

  render: ->
    Koemei.log "Koemei.View.Info#render"
    # display the login overlay
    @$el.prepend @template
    $('.koemei_shaded_overlay').show()

  remove: ->
    Koemei.log "Koemei.View.Info#remove"
    # remove the login overlay
    @$el.find('.koemei_video_info').remove()
    $('.koemei_shaded_overlay').hide()

  toggle: ()->
    Koemei.log "Koemei.View.Info#toggle"
    # Toggle the info overlay
    $('.kw_login_overlay').remove()
    if @$el.find('.koemei_video_info').length == 0
      @render()
    else
      @remove()

  toggle_title: (event)->
    event.preventDefault()
    $(event.currentTarget).toggleClass('titl_open')