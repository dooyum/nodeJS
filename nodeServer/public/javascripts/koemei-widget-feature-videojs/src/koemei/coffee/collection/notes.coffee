class Koemei.Collection.Notes extends Koemei.Collection.Paginator

  model: Koemei.Model.Note

  url: '../REST/notes/'

  parse: (resp) ->
    resp.notes

  search: (search_string, search_success_callback) ->
    # search inside the notes
    # TODO: search in replies
    # TODO: use https://github.com/fortnightlabs/snowball-js (nb: score does not work well here :()
    Koemei.log "Koemei.Collection.Notes#search for #{search_string}"
    matches = []
    search_terms = search_string.split(" ")
    for note in @models
      for search_term in search_terms
        if note.attributes.content.toLowerCase().indexOf(search_term.toLowerCase()) != -1
          matches.push(note)
        else
          match = false
          for reply in note.get 'replies'
            if reply.content.toLowerCase().indexOf(search_term.toLowerCase()) != -1
              matches.push(note)

    search_success_callback(matches)