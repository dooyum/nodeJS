class Koemei.View.Snippet extends Backbone.View

  tagName: 'li'


  id: -> @cid


  events:
    #'click .entry_preview': 'preview'
    #'click .binder_share_button': 'share'
    #'click .binder_edit_button': 'edit'
    'click .snippet_delete_button': 'delete'


  initialize: ->
    @$wrapper = @options.$wrapper
    @template = JST.Snippet_row

    @listenTo @model, 'change', @render
    @listenTo @model, 'destroy', @remove


  render: ->
    @$el.html @template
      timestamp: @model.get 'timestamp'
      content: @model.escape 'content'
      video_title: @model.escape 'video_title'

    @popup_delete = new Koemei.View.SnippetDeletePopup
      el: @$wrapper.find '.snippet_delete_popup'
      $wrapper: @$wrapper
      $button: @$ '.snippet_delete_button'
      model: @model

    this


  ###
  preview: ->
    Koemei.log 'preview snippet'


  share: ->
    Koemei.log 'share snippet'


  edit: ->
    Koemei.log 'edit snippet'
  ###


  delete: ->
    @popup_delete.render()


class Koemei.View.SnippetDeletePopup extends Koemei.View.Popup

  template: -> snippet_delete_popup

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
