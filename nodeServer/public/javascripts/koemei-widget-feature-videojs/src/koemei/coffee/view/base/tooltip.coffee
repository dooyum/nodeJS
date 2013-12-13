# A tooltip is just a Backbone View. To setup you need to call the method
# `toggle` with the options bellow.
#
# - `$button`: the element that launches the tooltip;
#
# If you want to use a tooltip template, you should provide:
#
# - `template` (DOM id of the template);
# - `data` (data object to populate the template - defaults to `{}`);
# - `$wrapper` (element in which the template will be appended).
#
# Otherwise, if you want to pass an existing element to be toggled:
#
# - `el`: the element which will be shown.
#
# #### Example:
#
# ```
# tooltip = Koemei.View.Tooltip
#   $button: $ e.target
#   el: $ 'my-tooltip'
# tooltip?.render()
#
# tooltip = Koemei.View.Tooltip
#   $button: $ e.target
#   $wrapper: $ document.body
#   template: 'my-tooltip-template'
#   data: {user: userModel.toJSON()}
# tooltip?.render()
# ```
class Koemei.View.Tooltip extends Backbone.View

  # Remove the tooltip when the overlay is clicked.
  _events:
    'click .overlay': 'remove'


  # Only allow one instance of a tooltip at a time. If the given element is
  # the same as the rendered one, it will return `null`, otherwise returns a
  # new instance.
  @toggle: (options) ->
    # Get element from options.
    optionsElem = options.$wrapper or options.el
    optionsElem = optionsElem[0] if optionsElem instanceof Backbone.$

    if Tooltip.singleton?
      tooltipElem = Tooltip.singleton.$wrapper or Tooltip.singleton.el
      tooltipElem = tooltipElem[0] if tooltipElem instanceof Backbone.$
      isSameInstance = Tooltip.singleton instanceof this
      isSameElement = tooltipElem is optionsElem
      Tooltip.singleton.remove()
    if !isSameElement or !isSameInstance
      Tooltip.singleton = new this::constructor options


  # Override the `delegateEvents` method so we can merge the `scroll` event
  # with the child's events.
  delegateEvents: ->
    events = _.result this, 'events'
    _.extend @_events, @events
    super @_events


  initialize: ->
    @$button = @options.$button
    @template = @options.template if @options.template
    @data = @options.data or {}
    @$wrapper = @options.$wrapper

  # Remove the tooltip, if this has a template it removes the element from the
  # DOM, otherwise just hides it.
  remove: ->
    if @template?
      super()
    else
      @$el.hide()
      @stopListening()
      @undelegateEvents()
    Tooltip.singleton = null


  # Renders the tooltip, with a template or just turning the `el` visible.
  render: ->
    @renderTemplate() if @template?
    @$tooltip = @$wrapper.find '.popup'
    @renderStatic()


  # Shows the provided `el`.
  renderStatic: ->
    # Render the element in the DOM so we can calculate the position.
    @$tooltip.css
      visibility: 'hidden'
      position:   'absolute'
    @$tooltip.show()
    position = @$button.offset()
    # Center the tooltip according to the button position.
    position.top += @$button.outerHeight(true) + @$('.arrow').outerHeight true
    position.left += (@$button.outerWidth(true)/2) - @$tooltip.outerWidth()/2

    @$tooltip.offset position
    @$tooltip.css 'visibility', 'visible'

    this


  # Renders the template inside the `el`.
  renderTemplate: ->
    if @template? and @$wrapper
      @$el.html @template @data
      @$wrapper.append @$el
    else
      Koemei.error 'No template provided for the tooltip.'