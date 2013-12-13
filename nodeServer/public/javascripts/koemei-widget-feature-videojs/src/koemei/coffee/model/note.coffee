class Koemei.Model.Note extends Backbone.Model

  idAttribute: 'uuid'

  urlRoot: '../REST/notes/'

  defaults:
    author: null
    created: null
    content: ''
    # which video this note is attached to
    video: null
    # a note refers to a certain time in the video
    start_time: 0
    end_time: 0
    replies: null

  initialize: ->
    #Koemei.log "Koemei.Model.Note#initialize #{@get('uuid')}"
    # initialize the replies collection
    @replies = new Koemei.Collection.Notes @get('replies')

    if @get('author')?
      @author = new Koemei.Model.User
        uuid: @get('author').uuid
        email: @get('author').email
        client_uuid: @get('author').client_uuid
        firstname: @get('author').firstname
        lastname: @get('author').lastname

    # update attributes
    @listenTo @replies, 'add', @refreshReplies


  refreshReplies: ->
    Koemei.log 'Koemei.Model.Note#refreshReplies'
    @set 'replies', @replies.toJSON()


  parse: (resp) ->
    #Koemei.log 'Koemei.Model.Note#parse'
    # if we are parsing a single note, it will come inside `note` attribute
    if resp.note?
      resp = resp.note

    if resp.media_item?
      resp.video = resp.media_item
      delete resp.media_item

    #TODO: maybe this shouldn't be here, we have @video which will do the same
    if resp.video? and resp.video.created?
      resp.video.human_created = Koemei.dateToFuzzy resp.video.created

    if resp.created?
      resp.human_created = Koemei.dateToFuzzy resp.created

    if resp.start_time?
      resp.human_start_time = Koemei.secsToString resp.start_time

    resp