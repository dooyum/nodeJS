class Koemei.Collection.Connections extends Backbone.Collection

  model: Koemei.Model.Connection

  url: '../REST/connections/'

  parse: (resp) ->
    resp.connections
