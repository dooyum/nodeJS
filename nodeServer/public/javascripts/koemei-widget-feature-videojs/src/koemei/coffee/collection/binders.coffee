class Koemei.Collection.Binders extends Backbone.Collection

  model: Koemei.Model.Binder

  url: '/REST/binders'

  parse: (resp) ->
    resp.binders