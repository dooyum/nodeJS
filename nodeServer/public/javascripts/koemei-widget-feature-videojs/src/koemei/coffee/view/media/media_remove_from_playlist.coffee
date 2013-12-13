class Koemei.View.RemoveMediaFromPlaylistPopup extends Koemei.View.Tooltip

  template: JST.Media_remove_from_playlist_popup


  events:
    'click .btn_cancel':  'remove'
    'click .delete_action':  'remove_from_playlist'


  remove_from_playlist: (e) ->
    Koemei.log 'Koemei.View.RemoveMediaFromPlaylistPopup#remove_from_playlist'
    Koemei.error 'TODO'
    #@options.data.playlist_collection.remove(@options.model)