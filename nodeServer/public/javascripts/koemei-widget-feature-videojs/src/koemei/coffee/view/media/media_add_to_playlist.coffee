class Koemei.View.AddVideoToPlaylistPopup extends Koemei.View.Tooltip

  template: JST.Media_add_to_playlist_popup


  events:
    'click .button.positive': 'add'
    'submit form':            'add'


  initialize: (options) ->
    # `Koemei.View.Tooltip` uses `data` to populate the template.
    options.data = {playlists: @collection.toJSON()}
    super options


  add: (e) ->
    Koemei.log 'Koemei.View.AddVideoToPlaylistPopup#add'
    e.preventDefault()
    playlistUuid = @$('select option:selected').val()
    title = @$('input').val()
    if title.length > 0
      @addToNewPlaylist title
    else
      @addToExistingPlaylist playlistUuid


  addToExistingPlaylist: (playlistUuid) ->
    Koemei.log 'Koemei.View.AddVideoToPlaylistPopup#addToExistingPlaylist'
    if playlistUuid
      @model.addToPlaylist playlistUuid,
        success: =>
          Koemei.log 'TODO: video added successfully'
          @remove()
        error: (model, xhr) ->
          Koemei.error xhr.responseText


  addToNewPlaylist: (title) ->
    Koemei.log 'Koemei.View.AddVideoToPlaylistPopup#addToNewPlaylist'
    @collection.create {title: title},
      wait: yes
      success: (model) =>
        Koemei.log 'TODO: playlist created successfully'
        @addToExistingPlaylist model.id
      error: (model, xhr) -> Koemei.error xhr.responseText
