class Koemei.View.BinderList extends Backbone.View

  el: '.widget_hold_panel'

  template: JST.Binder_panel

  events:
    'click .new_binder_button':   'create'

  initialize: ->
    Koemei.log 'Koemei.View.Binders#initialize'
    @collection = new Koemei.Collection.Binders() unless @collection
    # pre-fetches all binders
    #TODO: pagination!
    @collection.fetch {reset: true}
    @listenTo @collection, 'reset', @renderCollection
    @height = @options.height

    Backbone.on 'render:binder_list', @render, this
    Backbone.on 'remove:binder_list', @remove, this
    @listenModel()


  listenModel: ->
    # listen for changes on the collection
    @listenTo @collection, 'add', @renderCollection
    @listenTo @collection, 'remove', @renderCollection


  render: ->
    Koemei.log 'Koemei.View.Binders#render'
    @$el.html @template()
    @$list = @$ 'ul.binders'
    @renderCollection()

    @popup_create = new Koemei.View.BinderCreatePopup
      el: @$ '#binder-list'
      $wrapper: @$el
      $button: @$ '.new_binder_button'
      collection: @collection

    this


  # override View.remove so we don't remove the whole $el from the DOM
  remove: ->
    @$el.empty()
    @stopListening()


  renderCollection: ->
    Koemei.log 'Koemei.View.Binders#renderCollection'
    if @$list and @collection.length
      @collection.each (binder) =>
        @renderBinder binder
    else
      #TODO: something saying the user has no binders?

  renderBinder: (binder) ->
    Koemei.log 'Koemei.View.Binders#renderBinder'
    unless @views[binder.cid]?
      @views[binder.cid] = new Koemei.View.Binder {model: binder}
    #TODO: if binder is already present don't append, just replace it
    @$list.append @views[binder.cid].render().el

    # get a new view for every binder entry and append it to the list
    @collection.each (binder) =>
      view = new Koemei.View.Binder
        model: binder
        $wrapper: @$el
      $list.append view.render().el


  create: (e) ->
    e.preventDefault()
    @popup_create.render()


class Koemei.View.BinderCreatePopup extends Koemei.View.Popup

  template: -> binder_popup

  attrs: ->
    cid: @cid
    title: 'NEW BINDER'
    binder_title: ''

  events: ->
    e = {}
    e["submit #form-#{@cid}"] = 'save'
    e["click ##{@cid} .button.neutral"] = 'toggle'
    e["click ##{@cid} .button.positive"] = 'save'
    e

  save: (e) ->
    e.preventDefault()
    $input = @$ 'input'
    title = $input.val()
    return unless title.length > 0

    @collection.add new Koemei.Model.Binder
      title: title

    $input.val ''
    @toggle()
