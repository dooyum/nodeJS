# This class should be inherited by views that have a `collection` and want to
# implement infinite-scroll to render it.
# Note that the collections inside these views should extend
#`Collection.Paginator`.  
# See: [http://backbonetutorials.com/infinite-scrolling/]().
class Koemei.View.Paginator extends Backbone.View

  _events: ->
    key = 'scroll '
    key += @scrollAreaSelector if @scrollAreaSelector
    events = {}
    events[key] = '_onScroll'
    events


  _eventName: 'scroll.koemeiPaginator'


  # A flag to make sure we request a page at a time.
  _isLoading: false


  # At what distance (pixels) from the bottom the `fetch` should be triggered.
  scrollTrigger: 50


  # The DOM element which is scrollable area and will trigger the pagination.
  # This can return either a DOM element or a jQuery object.
  # If none is set, the scrollable area will be the `el` itself.
  # Finally, this can be a value or a function (so it can be evaluated only
  # after running `initialize`).
  scrollAreaElement: null


  # Name of the attribute that holds the collection.
  collectionName: 'collection'


  # The data to send in every fetch. This can either be a value or a function.
  fetchData: {}


  # Name of the function that renders the collection for the first time.
  renderHandler: 'renderCollection'


  # Name of the function that appends the collection the remaining times.
  appendHandler: 'appendCollection'


  # Function called when the fetch is requested.
  loadingCallback: null


  # Function called when the fetch succeeds. The collection, the response and
  # the request options are passed as arguments.
  successCallback: null


  # Function called when the fetch fails. The collection, the response and
  # the request options are passed as arguments.
  errorCallback: null


  # Override the `delegateEvents` method so we can setup a listener on a
  # scrollable element other than the `el` itself (in case the
  # `scrollAreaElement` is set).  
  # Note: we can't add an event to the view `events` because the
  # `scrollAreaElement` might be outside of the view's scope.
  delegateEvents: ->
    events = @events

    if @scrollAreaElement
      super events
      element = Backbone.$ _.result(this, 'scrollAreaElement')
      # Listen for the custom event on the element.
      element.on "scroll.#{Koemei.getClassName(@constructor)}", @_onScroll
    else
      # Add custom event to the view events.
      custom = 'scroll': @_onScroll
      events = _.extend custom, events
      super events

    this


  undelegateEvents: ->
    if @scrollAreaElement
      element = Backbone.$ _.result(this, 'scrollAreaElement')
      # Remove listener for the custom event.
      element.off "scroll.#{Koemei.getClassName(@constructor)}"
    super


  # Handler for the `scroll` event.
  _onScroll: =>
    return if @_isLoading

    # Get the DOM element: `el` or `scrollAreaElement`.
    if @scrollAreaElement
      $element = Backbone.$ _.result(this, 'scrollAreaElement')
    else
      $element = @$el

    # The `window` doesn't have any of these properties, so we have to pick
    # the `body` element to check the heights.  
    # And set the `visibleHeight` to the window visible height.
    # This gets the height of the visible area.
    if $element[0] is window
      $element = $(window.document.body)
      visibleHeight = $(window).height()
    else
      visibleHeight = $element.height()

    triggerHeight = $element.scrollTop() + visibleHeight + @scrollTrigger
    return if triggerHeight <= $element[0].scrollHeight

    @loadMore()


  loadMore: ->
    Koemei.log 'Koemei.View.Paginator#loadMore'
    # Load next page. The first time the collection is fetched we render,
    # otherwise we append it.
    @._isLoading = true
    @loadingCallback() if _.isFunction @loadingCallback
    collection = this[@collectionName]
    data = _.result this, 'fetchData'
    collection.fetch
      data: data
      success: (collection, response, options) =>
        if _.isFunction @successCallback
          @successCallback collection, response, options

        response = collection.parse response
        # If the response length is the same as the collection length, it
        # means we just got the first page. If it is smaller we use the append
        # method.
        if response.length is collection.length
          this[@renderHandler]()
        else if response.length < collection.length
          this[@appendHandler]()
        @._isLoading = false
      error: (collection, response, options) =>
        if _.isFunction @errorCallback
          @errorCallback collection, response, options
