class Koemei.View.Walkthrough extends Backbone.View

  initialize: () ->
    Koemei.log "Koemei.View.Walkthrough#initialize"
    @template = JST.Walkthrough
    @$el.append @template()

  render: ->
    Koemei.log "Koemei.View.Walkthrough#render"
    $('#kw_help_ol').joyride
      preStepCallback: (index, $next_tip) ->
        #there are some steps that need to do some stuff (eg: switch tabs)
        $li = $('#kw_help_ol li:nth-child('+(index+1)+')')
        kw_id = $li.data('id')
        kw_class = $li.data('class')
        if kw_class == 'transcript_edit'
          $('.'+kw_class).click()