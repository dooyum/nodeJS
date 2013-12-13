class Koemei.View.NoteDeleteConfirmTooltip extends Koemei.View.Tooltip

  template: JST.Note_delete_confirm_popup


  events:
    'click .delete_action': 'delete_note'
    'click .close_popup':   'remove'


  delete_note: ->
    Koemei.log 'Koemei.View.NoteDeleteConfirmTooltip#delete_note'
    @model.collection.remove @model
    @model.destroy()

    @remove()
