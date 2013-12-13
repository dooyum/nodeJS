class Koemei.View.ConnectMediaPopup extends Koemei.View.Tooltip

  events:
    'click .button.neutral':  'remove'
    'click .btn_connect':     'connect'
    'click .btn_disconnect':  'disconnect'


  template: JST.Media_connect_popup


  initialize: (options) ->
    # The model can be either a media_item or a connection.
    if @model instanceof Koemei.Model.Connection
      result = true
    else
      result = @hasConnection()
    options.data = {connect: !result}
    super options


  connect: (e) ->
    Koemei.log 'Koemei.View.ConnectMediaPopup#connect'
    attrs =
      source_uuid: @options.widget.media_item.id
      target_uuid: @model.id
    @options.widget.connections.create attrs,
      wait: yes
      success: => @model.setConnected true
      error: (model, xhr) -> Koemei.error xhr.responseText
    @remove()


  disconnect: (e) ->
    Koemei.log 'Koemei.View.ConnectMediaPopup#disconnect'
    # The model can be either a media_item or a connection.
    if @model instanceof Koemei.Model.Connection
      @model.destroy {wait: yes}
    else
      @options.widget.connections.each (c) =>
        if c.get('source_media').uuid is @model.id or c.get('target_media').uuid is @model.id
          c.destroy
            wait: yes
            success: => @model.setConnected false
    @remove()


  # Check if this model is connected to the widget's media item.
  hasConnection: ->
    !! @options.widget.connections.find (c) =>
      c.get('source_media').uuid is @model.id or c.get('target_media').uuid is @model.id
