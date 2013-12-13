class Koemei.Model.Connection extends Backbone.Model

  idAttribute: 'uuid'


  urlRoot: '../REST/connections/'


  defaults:
    user: null
    source_media: null
    target_media: null
    media_time: 0


  initialize: ->
    Koemei.log 'Koemei.Model.Connection#initialize'
    @source_media = new Koemei.Model.Media @get('source_media')
    @target_media = new Koemei.Model.Media @get('target_media')


  @connected: (source_media, target_media, options) ->
    args =
      url: "#{this::urlRoot}connected/#{source_media.id}/#{target_media.id}"
      type: 'GET'
      dataType: 'json'
    options = _.extend args, options
    Backbone.ajax options


  parse: (resp) ->
    # if we are parsing a single connection, it will come inside `connection`
    if resp.connection?
      resp = resp.connection
    resp
