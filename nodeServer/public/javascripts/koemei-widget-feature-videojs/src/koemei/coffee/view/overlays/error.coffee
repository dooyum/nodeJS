class Koemei.View.Error extends Backbone.View

  initialize: () ->
    @$el = $(".widget_player")
    @template = _.template error_panel

  render: (error_message) ->
    @$el.prepend @template
      error_message: error_message
