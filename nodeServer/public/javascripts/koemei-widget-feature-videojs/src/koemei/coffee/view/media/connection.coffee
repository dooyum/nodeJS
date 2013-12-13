class Koemei.View.Connection extends Backbone.View

  tagName: 'li'


  template: JST.Connection


  events:
    'click .video_disconnect_option': 'disconnect'
    'click .show_video':              'load_media'


  initialize: ->
    Koemei.log 'Koemei.View.Connection#initialize'
    @$wrapper = @options.$wrapper
    @widget = @options.widget
    # The 'remove' event will be handled in the collection view.
    @listenTo @model, 'change', @render


  render: ->
    Koemei.log 'Koemei.View.Connection#render'
    # Choose which media item is different from the widget's media item.
    if @model.source_media.id is @widget.media_item.id
      media_item = @model.target_media
    else
      media_item = @model.source_media

    #TODO: if easyXDM could add '..' before the model urls, we could handle this better
    thumbnail_path = media_item.get('thumbnail_path') or
      @widget.options.koemei_host + '/REST/media/' + media_item.id + '/thumbnails'

    @$el.html @template
      media_item: media_item.toJSON()
      thumbnail_path: thumbnail_path
    this


  load_media: (e)->
    @widget.reinit(e)


  disconnect: (e) ->
    tooltip = Koemei.View.ConnectMediaPopup.toggle
      $wrapper: @$el
      $button: @$ e.target
      widget: @widget
      model: @model
    tooltip?.render()
