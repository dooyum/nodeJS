class Koemei.View.EditPlaylistPopup extends Koemei.View.Tooltip

  events:
    'click .btn_cancel':'remove'
    'click .btn_save':'edit'


  template: JST.Media_playlist_edit


  edit: (event) ->
    Koemei.log "Koemei.View.EditPlaylistPopup#edit"
    event.preventDefault()
    element = event.currentTarget
    form_data = $(element).serializeFormJSON()
    @options.model.set
      name:form_data.new_name
    @remove()
