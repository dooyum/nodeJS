class Koemei.Collection.Segments extends Backbone.Collection

  model: Koemei.Model.Segment

  initialize: (segments)->
    Koemei.log "Koemei.Collection.Segments#initialize"
    # TODO : is this necessary or can we just use @models?
    @segments = segments

  ###
  Get the segment corresponding to the a given time
  * @param {number} time in centiseconds
  * @return {Koemei.Segment} segment corresponding to time, or the first segment if none found
  ###
  get_segment: (time) ->
    try
      for segment in @models
        if segment.start <= time and segment.end > time
          return segment
        if segment.start > time
          return false
    catch ex
      Koemei.error "Exception getting segment for time #{time}0ms : #{ex}"
    return false

  search: (search_string, search_success_callback) ->
    # search inside the segments
    # TODO: use https://github.com/fortnightlabs/snowball-js (nb: score does not work well here :()
    # TODO: also search inside the changes
    Koemei.log "Koemei.Collection.Segments#search for #{search_string}"
    matches = []
    search_terms = search_string.split(" ")
    for segment in @models
      match = false
      for search_term in search_terms
        for label in segment.labels when label.value.toLowerCase().indexOf(search_term.toLowerCase()) != -1 and not match
          matches.push(segment)
          match = true

    search_success_callback(matches)