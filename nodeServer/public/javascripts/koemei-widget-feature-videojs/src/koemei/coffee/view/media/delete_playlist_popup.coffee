class Koemei.View.DeletePlaylistPopup extends Koemei.View.Tooltip

  template: JST.Media_delete_playlist_popup


  events:
    'click .btn_cancel': 'remove'
    'click .delete_action': 'delete'


  delete: (e) ->
    Koemei.log 'Koemei.View.DeletePlaylistPopup#delete'
    @model.destroy()
