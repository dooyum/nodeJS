class Koemei.View.Playlist extends Backbone.View

  events:
    'click .playlist_delete_option': 'delete'
    'click .playlist_share_option': 'share'
    'click .playlist_edit_option': 'edit'

  tagName: 'li'

  id: -> @cid

  initialize: ->
    Koemei.log "Koemei.View.Playlist#initialize"
    @$wrapper = @options.$wrapper
    @template = JST.Media_playlist
    @widget = @options.widget

    @listenTo @model, 'change', @render
    @listenTo @model, 'destroy', @remove


  render: ->
    Koemei.log "Koemei.View.Playlist#render"
    @$wrapper.append @$el.html @template(
      playlist: @model.toJSON()
    )

  share: (e) ->
    e.preventDefault()
    tooltip = Koemei.View.SharePlaylistPopup.toggle
      $wrapper: @$el
      $button: @$ e.target
      widget: @widget
      data:
        # TODO: share the playlist, not the media
        share_url: @widget.options.koemei_host+'/media/'+@widget.media_item.get('uuid')
        embed_code: '<script src="'+@widget.options.static_cdn_path+'/widget/latest/javascript/koemei-widget.min.js"></script><script> new KoemeiWidget({media_uuid: "'+@widget.media_item.get('uuid')+'"});</script>'
    tooltip?.render()

  delete: (e) ->
    e.preventDefault()
    tooltip = Koemei.View.DeletePlaylistPopup.toggle
      $wrapper: @$el
      $button: @$ e.target
      widget: @widget
      data:
        model: @model.toJSON()
    tooltip?.render()

  edit: (e) ->
    e.preventDefault()
    tooltip = Koemei.View.EditPlaylistPopup.toggle
      $wrapper: @$el
      $button: @$ e.target
      widget: @widget
      data:
        model: @model.toJSON()
    tooltip?.render()