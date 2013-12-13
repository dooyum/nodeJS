class Koemei.Model.Media extends Backbone.Model

  idAttribute: 'uuid'

  urlRoot: '../REST/media/'


  defaults:
    # main
    title: ''
    description: null
    thumbnail_path: null
    created: null
    size: 0
    authors: []
    categories: []
    tags: []
    current_transcript: null

    # status
    status: null
    publish_status: null
    upload_type: null
    error_status: false
    progress: null
    access_level: null
    allowed_actions: []

    # media
    channels: null
    samplerate: null
    language: null
    streaming_url: null

    # external service
    service_name: null
    sync_date: null
    item_id: null

    # not used
    clientfilename: null
    matches: null
    kobject_uuid: null
    bits: null
    thumbnail: null

  # TODO: in case of external media, the uuid passed to this constructor may be the id in the external service

  initialize: ->
    #Koemei.log 'Koemei.Model.Media#initialize'

  # Gets the model from the response and parses some fields appropriately.
  parse: (resp) ->
    if resp.media_item?
      resp = resp.media_item


    if resp.created?
      resp.human_created = Koemei.dateToFuzzy resp.created

    if resp.size?
      resp.human_size = Koemei.secsToString resp.size

    if resp.current_transcript?
      resp.transcript = resp.current_transcript

    resp


  # Returns `true` if given action is allowed by this media.
  isAllowed: (action) ->
    Koemei.Config.mediaActions.indexOf(action) in @get 'allowed_actions'


  # Send a PUT request to add the given playlist to the media.
  addToPlaylist: (playlistUuid, options = {}) ->
    options.data = {playlist_uuid: playlistUuid}
    options.url = "#{@url()}/playlist/"
    @save {}, options

  # publish the media
  publish: (options) ->
    args =
      url: @url()+"/publish"
      type: 'PUT'
      data:
        service_name: @get 'service_name'
    options = _.extend(args, options)
    Backbone.$.ajax options


  # delete video
  delete: (options, deleteTranscript=true) ->
    uuid = @get 'kobject_uuid'
    args =
      url: "/REST/kobjects/#{uuid}?delete_transcripts=#{deleteTranscript}"
    options = _.extend(args, options)
    super options

  # Set the media as connected or disconnected
  setConnected: (which = true) ->
    @_connected = which
    @trigger 'change', this

  isConnected: ->
    !!@_connected

  ###
  Is the media transcribed
  ###
  is_transcribed: () ->
    if @status is 2 or @status is 4 or @status is 6 or (@status is 1 and @progress is not 100) then false else true

  ###
  Is the media private
  ###
  is_private: () ->
    if @access_level is 0 then true else false

  search:(search_string) ->
    # search for a seach string inside the media metadata
    if @get('title').toLowerCase().indexOf(search_string.toLowerCase()) != -1
      return true
    if @get('description').toLowerCase().indexOf(search_string.toLowerCase()) != -1
      return true
    for tag in @get('tags')
      if tag.toLowerCase().indexOf(search_string.toLowerCase()) != -1
        return true
    if @get('category').toLowerCase().indexOf(search_string.toLowerCase()) != -1
      return true
    return false