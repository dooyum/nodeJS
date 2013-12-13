class Koemei.View.NotesPanel extends Koemei.View.Panel
# It's more of a panel search interface actually

  events:
    'click .new_note_button': 'create'
    'click .new_note_cancel_button': 'render'
    'click .note_edit_button': 'render_edit_note_form'
    'click .note_permission_option .toggle_option': 'toggle_note_permission'
    'click .new_note_post_button':'create_edit_note'
    'submit #notes_search':'search'

  """events:
    'click .note_delete_popup .neutral': 'delete_note'
    'click .note_delete_popup .positive': 'delete_note_yes'
    'click .note_link_icon':'toogle_time_link'
    'click .note_timeskip_button': 'jump_to_time'
  """

  template: JST.Note_panel


  initialize: ->
    Koemei.log 'Koemei.View.NotesPanel#initialize'
    @panel_name = 'notes'
    @widget = @options.widget
    @media_item = @widget.media_item
    #@views = {}
    @collection = @media_item.notes
    #@listenTo @collection, 'reset', @renderCollection

  render: ->
    Koemei.log 'Koemei.View.NotesPanel#render'
    @$el.html @template(
      height: @options.height
    )
    @$list = @$ 'ul.notes'
    @notesView = new Koemei.View.Notes
      widget: @widget
      el: @$ '.note_list'
      collection: @collection
    @notesView.render()
    this

  renderModel: (model, search_string=false) ->
    @notesView.renderModel(model, search_string)

  # override View.remove so we don't remove the whole $el from the DOM
  remove: ->
    Koemei.log 'Koemei.View.NotesPanel#remove'
    @$el.empty()
    @stopListening()

  # create a note
  create: (e)->
    Koemei.log 'Koemei.View.NotesPanel#create'
    e.preventDefault()
    if @widget.user?
      @render_new_note_form(e)
    else
      @widget.toolbar.toggle_login_overlay(e)
      # TODO: open the new note form once the user is logged/subscribed

  render_new_note_form: (e) ->
    # Display the form for adding a note
    Koemei.log 'Koemei.View.NotesPanel#render_new_note_form'
    e.preventDefault()
    @timestamp = Math.ceil(@widget.transcript_panel.current_label.start / 100)
    @$el.html JST.Note_new_form
      mode: 'add'
      id:''
      content: ''
      title: 'New note'
      #TODO: This should be more straightforward to get.
      time: @timestamp
      # TODO: restore this
      #time: @widget.player.player.getPosition()

    this.editor = new wysihtml5.Editor("kw_notes_editor",
      toolbar: "kw_notes_toolbar"
      parserRules: wysihtml5ParserRules
    )

  render_edit_note_form: (event)->
    # Display the form for editing a note
    Koemei.log 'Koemei.View.NotesPanel#render_edit_note_form'
    event.preventDefault()
    note = @collection.get($(event.currentTarget).attr('data-id'))

    @$el.html JST.Note_new_form
      mode: 'edit'
      id: note.id
      content: note.attributes.content
      title: 'Edit note'
      time: note.attributes.start_time
      height: @options.height # TODO: is this necessary? why is it not on the new note form?

    editor = new wysihtml5.Editor("kw_notes_editor",
      toolbar: "kw_notes_toolbar"
      parserRules: wysihtml5ParserRules
    )


  toggle_note_permission: (e)->
    # toggle the permission setting of a note when editing or creating it
    $toggle = $(e.currentTarget)
    $toggle.toggleClass('active')
    $toggle.closest('li').siblings().find('.toggle_option').toggleClass('active')


  create_edit_note:(e) ->
    Koemei.log 'Koemei.View.NotesPanel#create_edit_note'
    # Create or edit a note
    e.preventDefault()
    $element = @$ e.currentTarget
    mode = $element.attr('data-mode')

    if mode is "add"
      attrs =
        content: @$('#kw_notes_editor').val()
        video_uuid: @widget.media_item.attributes.uuid
        start_time: @timestamp
      @collection.create attrs,
        wait: yes
        success: =>
          #TODO: render without fetching!
          @render()
        error: ->
          #TODO
          alert('Error while creating note, please try again later.')

    else if mode is "edit"
      note = @collection.get($element.attr('data-id'))
      note.set(
        content: @$('#kw_notes_editor').val()
      )
      note.save
        success: =>
          #TODO: render without fetching!
          @render()
        error: ->
          #TODO
          alert('Error while editing note, please try again later.')