class Koemei.View.ProfilePopup extends Koemei.View.Tooltip
  # Profile popup

  events:
    'click .edit_profile': 'edit_profile'
    'click .to_account': 'to_account'
    'click .sign_out': 'sign_out'


  template: JST.Toolbar_profile_popup


  sign_out: (e)->
    Koemei.Model.User.logout(@options.widget.xhr)
    e.preventDefault()
    # TODO: make this a callback
    @options.widget.user = null
    $('.login_button').show()
    $('.logged_in_toolbar').hide()
    @remove()


  to_account: (e)->
    e.preventDefault()
    location.replace @options.widget.options.koemei_host


  edit_profile: (e)->
    e.preventDefault()
    location.replace @options.widget.options.koemei_host
