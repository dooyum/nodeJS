class Koemei.Collection.Media extends Koemei.Collection.Paginator

  model: Koemei.Model.Media

  url: '../REST/media/'

  parse: (resp) ->
    resp.media.remaining = resp.remaining
    @remaining = resp.remaining
    resp.media

  search: (search_string, search_success_callback) ->
    Koemei.log "Koemei.Collection.Media#search - #{search_string}"
    @fetch
      reset: true
      data:
        search_query: search_string
      error: ->
        Koemei.error "Error searching"
      success: search_success_callback