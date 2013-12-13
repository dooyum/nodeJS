# This class should be inherited by collections that wish to support pagination.
# It gives your collection pagination features by overriding the `fetch` method
# and requesting new pages by passing two special parameters:
#
# - `start`: offset this number of items;
# - `count`: number of items to get on each request.
#
# The names of these parameters can be overridden be setting `startName` and
# `countName`, for instance:
#
# ```
# startName: 'offset'
# countName: 'limit'
# ```
class Koemei.Collection.Paginator extends Backbone.Collection

  start: 0


  count: 10


  startName: 'start'


  countName: 'count'


  resetStart: ->
    @start = 0


  # Override `fetch` to inject pagination attributes and call `super`.
  # If the option `reset` is passed it will also reset the `start` position.
  fetch: (options = {}) ->
    Koemei.log 'Koemei.Collection.Paginator#fetch'
    if options.reset
      @resetStart()

    data = {}
    data[@startName] = @start
    data[@countName] = @count

    # Merge `options.data` with `data`.
    if options.data?
      data = _.extend data, options.data

    # Increment the starting point so that next we fetch the next page.
    @start += @count

    # Put `data` back in the `options` with the already merged data.
    # The option `remove: no` ensures that the fetched items are appended to the
    # existing collection, instead of replacing it.
    options = _.extend options, {data: data, remove: no}
    super options