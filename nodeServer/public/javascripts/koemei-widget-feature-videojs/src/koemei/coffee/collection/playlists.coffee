class Koemei.Collection.Playlists extends Koemei.Collection.Paginator

  model: Koemei.Model.Playlist

  url: '../REST/playlists/'


  parse: (resp) ->
    resp.playlists
