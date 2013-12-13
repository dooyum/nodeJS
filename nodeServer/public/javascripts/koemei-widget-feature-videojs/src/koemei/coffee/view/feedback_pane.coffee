class Koemei.View.Feedback extends Backbone.View

  initialize: ->
    Koemei.log 'Koemei.View.Feedback#initialize'
    height = @options.widget.options.widget_height - 206
    if @options.widget.options.toolbar
      height = height - 39
    @template = JST.Feedback_pane

  render: ->
    Koemei.log 'Koemei.View.Feedback#render'
    # TODO : prefill the email address and make it readonly if user logged in
    feedback_pane = @template(
      height:@height
    )
    # TODO : use the el passed in the constructor
    @$el.children('.kw_koemei_widget').children('#panel_container').html feedback_pane
