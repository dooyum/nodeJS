# WORK IN HERE

class Koemei.View.UserPortal extends Backbone.View

  initialize: ->
    Koemei.log 'Koemei.View.UserPortal#initialize'
    @template = JST.User_portal
    @widget = @options.widget
    @initWidget()

  initWidget: ->
    Koemei.log 'Koemei.View.UserPortal#initWidget'


    # render the widget in a ghost node
    @player_view = new KoemeiWidget
      media_uuid: @widget.options.media_uuid
      type: 'widget'
      #service shouldn't have to be hardcoded
      service:'videojs'
      el: $("<div></div>")
      #TODO: fix this
      static_cdn_path: @widget.options.static_cdn_path
      usermedia_cdn_path: @widget.options.usermedia_cdn_path
      koemei_css_path: @widget.options.koemei_css_path
      koemei_host: @widget.options.koemei_host
      cb_before_render: @render
      width: @widget.options.width
      video_width: @widget.options.video_width
      video_height: @widget.options.video_height
      widget_height: @widget.options.widget_height

  # user portal render before the video player show up on screen
  # it helps building the node to hold the player
  render: =>
    Koemei.log 'Koemei.View.UserPortal#render'
    # console.log('@media_item', @player_view)

    # append the user portal template first before render the video widget itself
    @$el.append @template
      media_item: @player_view.media_item.toJSON()
      title: @player_view.media_item.toJSON().title.slice(0,43)

    # now that DOM is ready append the player to the view
    @$el.find('.js_kw_widget_container').append(@player_view.$el)

    @
