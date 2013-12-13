class Koemei.View.Binder extends Backbone.View

  tagName: 'li'


  id: -> @cid


  events:
    'click .title_link':            'list'
    'click .binder_share_button':   'share'
    'click .binder_edit_button':    'edit'
    'click .binder_delete_button':  'delete'


  initialize: ->
    @$wrapper = @options.$wrapper
    @template = JST.Binder_row
    @listenModel()


  listenModel: ->
    @listenTo @model, 'change:title', @render
    @listenTo @model, 'destroy', @remove


  render: ->
    #TODO: ??? we should have a better way of delegate and undelegate events
    #TODO:addyosmani.github.io/backbone-fundamentals/#listento-and-stoplistening
    @delegateEvents()
    @listenModel()
    @$el.html @template
      count: @model.get('snippets').length
      title: @model.escape('title')

    @popup_share = new Koemei.View.BinderSharePopup
      el: @$wrapper.find '.binder_share_popup'
      $wrapper: @$wrapper
      $button: @$ '.binder_share_button'
      model: @model

    @popup_edit = new Koemei.View.BinderEditPopup
      el: @$wrapper.find '.binder_popup'
      $wrapper: @$wrapper
      $button: @$ '.binder_edit_button'
      model: @model

    @popup_delete = new Koemei.View.BinderDeletePopup
      el: @$wrapper.find '.binder_delete_popup'
      $wrapper: @$wrapper
      $button: @$ '.binder_delete_button'
      model: @model

    this


  list: (e) ->
    e.preventDefault()
    @remove()
    Backbone.trigger 'remove:binder_list'
    Backbone.trigger 'reset_binder', @model


  share: (e) ->
    e.preventDefault()
    @popup_share.render()


  edit: (e) ->
    e.preventDefault()
    @popup_edit.render()


  delete: (e) ->
    e.preventDefault()
    @popup_delete.render()


class Koemei.View.BinderSharePopup extends Koemei.View.Popup

  template: -> binder_share_popup

  attrs: {}


class Koemei.View.BinderEditPopup extends Koemei.View.Popup

  template: -> binder_popup

  attrs: ->
    cid: @cid
    title: 'EDIT BINDER'
    binder_title: @model.escape 'title'

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

    @model.set 'title', title
    @toggle()


class Koemei.View.BinderDeletePopup extends Koemei.View.Popup

  template: -> binder_delete_popup

  attrs: ->
    cid: @cid

  events: ->
    e = {}
    e["click ##{@cid} .button.neutral"] = 'toggle'
    e["click ##{@cid} .button.positive"] = 'delete'
    e

  delete: ->
    @model.destroy()
    @toggle()
