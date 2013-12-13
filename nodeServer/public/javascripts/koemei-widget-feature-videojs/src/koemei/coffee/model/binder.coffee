class Koemei.Model.Binder extends Backbone.Model

  idAttribute: 'uuid'

  defaults:
    title:        ''
    author:       {}
    created:      null
    location:     null
    note_count:   0
    video_count:  0

  parse: (resp) ->
    if resp.created?
      resp.human_created = koemei.dateToFuzzy resp.created

    resp

  save: ->
    Koemei.log "Save the binder"
