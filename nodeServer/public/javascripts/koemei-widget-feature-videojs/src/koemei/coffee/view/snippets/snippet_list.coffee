class Koemei.View.SnippetList extends Backbone.View

  events: ->
    e = {}
    e["click ##{@cid} .binder_list_button"] = 'backToBinders'
    e["click ##{@cid} .new_snippet_button"] = 'create'
    e["click ##{@cid} .binder_edit_button"] = 'edit'
    e


  initialize: ->
    @height = @options.height
    Backbone.on 'reset_binder', @resetBinder, this


  listenModel: ->
    @listenTo @model, 'change', @render


  resetBinder: (binder) ->
    @model = binder
    @listenModel()
    @render()


  render: ->
    @$el.html JST.Snippets_panel
      cid: @cid
      height: @height
      binder_title: @model.escape 'title'
    @renderCollection()

    @popup_create = new Koemei.View.SnippetCreatePopup
      el: @$ '.snippet_create_popup'
      $wrapper: @$el
      $button: @$ '.new_snippet_button'

    @popup_edit = new Koemei.View.BinderEditPopup
      el: @$ '.binder_edit_popup'
      $wrapper: @$el
      $button: @$ '.binder_edit_button'
      model: @model


  renderCollection: ->
    $list = @$ '#snippet-list'
    $list.empty()
    @model.get('snippets').each (snippet) =>
      view = new Koemei.View.Snippet
        model: snippet
        $wrapper: @$el
      $list.append view.render().el


  #TODO
  create: (e) ->
    e.preventDefault()
    Koemei.log 'create snippet'
    @popup_create.render()


  edit: (e) ->
    e.preventDefault()
    @popup_edit.render()


  backToBinders: (e) ->
    e.preventDefault()
    Koemei.log 'SnippetListView backToBinders'
    Backbone.trigger 'render:binder_list'


#TODO: popup is missing snippets listing
class Koemei.View.SnippetCreatePopup extends Koemei.View.Popup

  template: -> snippet_create_popup

  attrs: {}

