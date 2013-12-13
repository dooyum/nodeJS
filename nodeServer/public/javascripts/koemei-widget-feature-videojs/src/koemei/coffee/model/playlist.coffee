class Koemei.Model.Playlist extends Backbone.Model

  idAttribute: 'uuid'

  urlRoot: '../REST/playlists/'


  """defaults: {
    name: '',
    total_duration:'',
    items:'',
    thumbnail:''
  }
  """
  # Convert creation date from seconds to a fuzzy interval and
  # videos duration from seconds to a string in the format `HH:mm:ss`.
  parse: (resp) ->
    # If we are parsing a single playlist it will be in a `playlist`
    # attribute.
    if resp.playlist?
      resp = resp.playlist

    if resp.created?
      resp.human_created = Koemei.dateToFuzzy resp.created

    if resp.videos? and resp.videos.duration?
      resp.videos.human_duration = Koemei.secsToString(
        resp.videos.duration,
        yes
      )

    resp


  """initialize: ->
    @attributes.items = @attributes.videos.length
    total_length = 0
    $.each @attributes.videos.models, (index, video) ->
      total_length = total_length + parseInt(video.attributes.duration)
    @attributes.total_duration = total_length
    @attributes.thumbnail = @attributes.videos.models[0].attributes.thumbnail
    @on "change", (model) ->
      Koemei.log "Triggered model change"
      @attributes.items = @attributes.videos.length
      total_length = 0
      $.each @attributes.videos.models, (index, video) ->
        total_length = total_length + parseInt(video.attributes.duration)
      @attributes.total_duration = total_length
    @on "destroy", (model) ->
      Koemei.log "Triggered model destroy"
  """

  """playlist_search: (string) ->
    string = string.toLowerCase()
    if string.length>=4
      returned = new Array
      $.each @attributes.videos.models, (index, video) ->
        search_in = new Object
        search_in.name = video.attributes.name
        search_in.categories = video.attributes.categories
        search_in.tags = video.attributes.tags
        result = JSON.stringify( _.values(search_in) ).toLowerCase()
        score = result.score(string)
        if score>0.7
          returned.push(video)
      returned

  save: ->
    Koemei.log "Save the playlist"
  """