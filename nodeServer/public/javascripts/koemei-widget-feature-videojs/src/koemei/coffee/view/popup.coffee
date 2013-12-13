class Koemei.View.Popup extends Backbone.View

  initialize: ->
    @$button = @options.$button
    @$wrapper = @options.$wrapper


  render: ->
    template = if _.isFunction @template then @template() else @template
    attrs = if _.isFunction @attrs then @attrs() else @attrs
    @$el.html template(attrs)
    @toggle()
    this


  remove: ->
    @$el.empty()
    @stopListening()


  toggle: ->
    $source = @$el.data 'source_element'
    if typeof($source) == 'undefined'
      $source = @$button
    if $source.hasClass 'active'
      Koemei.hide_single_popup @$wrapper, @$el
      $source.removeClass 'active'
      @remove()
    else
      Koemei.hide_popups @$wrapper
      Koemei.display_popup @$button, @$el, 'bottom'
      @$button.addClass 'active'
      @$el.data 'source_element', @$button
      @$('input').focus()
