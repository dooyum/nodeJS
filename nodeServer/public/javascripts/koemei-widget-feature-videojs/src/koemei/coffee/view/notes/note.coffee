class Koemei.View.Note extends Backbone.View

  tagName: 'li'

  id: -> @cid

  events:
    'click .note_delete_button':'delete'
    'submit .reply_note':'create_reply'
    'click .note_reply_button': 'reply_focus'
    'click .note_share_button': 'share'

  template: JST.Note_row

  initialize: ->
    Koemei.log "Koemei.View.Note#initialize"
    @$wrapper = @options.$wrapper
    @replies = new Koemei.Collection.Notes
    @widget = @options.widget
    @listenTo @model, 'change', @onChange
    @listenTo @model, 'destroy', @remove


  onChange: -> @render()


  render: (search_string=false)->
    # display a note line in a notes list
    Koemei.log "Koemei.View.Note#render - search string: #{search_string}"
    note = @model.toJSON()
    note.id = @model.id
    @$el.html @template
      user: @widget.user?.toJSON()
      note: note
      user_is_note_author: @widget.user?.uuid == note.author.uuid
      search_string: search_string
    # append the element, unless it is already in the DOM
    unless @$el.parent().has(@$el).length
      @$wrapper.append @$el
    this

  delete: (e) ->
    Koemei.log 'Koemei.View.Note#delete'

    tooltip = Koemei.View.NoteDeleteConfirmTooltip.toggle
      $wrapper: @$el.parent()
      $button: @$ e.target
      model: @model
    tooltip?.render()


  reply_focus: (e)->
    # positions the cursor in the reply input
    e.preventDefault()
    element = $(e.currentTarget).parent().parent().find('.note_reply_input')
    $(element).focus()


  create_reply: (e)->
    # post the reply to the server
    e.preventDefault()
    $input = $(e.target).find('input')
    attrs =
      parent_uuid: @model.id
      video_uuid: @model.attributes.video.uuid
      content: $input.val()
    @model.replies.create attrs,
      wait: yes
    $input.val ''


  share: (e)->
    Koemei.log "Koemei.View.Note#share"
    # open share note popup

    # TODO: share note mechanism
    tooltip = Koemei.View.ShareNotePopup.toggle
      $wrapper: @$el
      $button: @$ e.target
      widget: @widget
      data:
        share_url: @widget.options.koemei_host+'/media/'+@widget.media_item.get('uuid')
        embed_code: '<script src="'+@widget.options.static_cdn_path+'/widget/latest/javascript/koemei-widget.min.js"></script><script> new KoemeiWidget({media_uuid: "'+@widget.media_item.get('uuid')+'"});</script>'
    tooltip?.render()

