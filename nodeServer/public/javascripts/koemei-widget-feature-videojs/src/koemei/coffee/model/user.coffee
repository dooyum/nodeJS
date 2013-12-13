class Koemei.Model.User extends Backbone.Model
  ###
  Constructor for the Koemei.User object
  * @param {uuid} user uuid (can ben external or koemei uuid)
  * @param {json} information on the user
  ###
  initialize: ->
    #Koemei.log "Koemei.Model.User#initialize"

  ###
  Get the specified user
  * @param {xhr} crossdomain magic
  * @param {String} uuid : user identifier
  * @param {function} success_callback : success callback function
  * @param {function} error_callback : error callback function
  ###
  @get_one : (xhr, uuid, success_callback, error_callback) ->
    try
      req =
        url: "../REST/users/"+uuid,
        method: "GET",
        headers:
          Accept : 'application/json'
      xhr.request req,
        ((response) ->
          info = jQuery.parseJSON(response.data).user
          user = new Koemei.Model.User
            uuid: info.uuid
            email: info.email
            client_uuid: info.client_uuid
            firstname: info.firstname
            lastname: info.lastname
          success_callback user
        ),
        (response) ->
          error_callback response
    catch err
      console.error "Error in Koemei.User.get_one : "+err.message+"("+err.lineNumber+")"

  ###
  Register the user.
  If the user exists, the backend will throw a HTTPConflict error
  * @param {xhr} crossdomain magic
  * @param {String} email of the user
  * @param {String} password of the user
  * @param {function} success_callback : success callback function
  * @param {function} error_callback : error callback function
  ###
  @register : (xhr, email, password, success_callback, error_callback) ->
    try
      req =
        url: "../REST/users",
        method: "POST",
        data:
          email: email,
          password: password,
          firstname: 'Firstname',
          lastname: 'Lastname'
        headers:
          Accept : 'application/json'
      xhr.request req,
        ((response) ->
          info = jQuery.parseJSON(response.data)
          user = Koemei.Model.User
            uuid: info.user.uuid
            email: info.user.email
            client_uuid: info.user.client_uuid
            firstname: info.user.firstname
            lastname: info.user.lastname
          success_callback user
        ),
        (response) ->
          error_callback response
    catch err
      console.error "Error in Koemei.User.register : "+err.message+"("+err.lineNumber+")"

  ###
  Log the user in.
  If the user exists, the backend will throw a HTTPConflict error
  * @param {xhr} crossdomain magic
  * @param {String} email of the user
  * @param {String} password of the user
  * @param {function} success_callback : success callback function
  * @param {function} error_callback : error callback function
  ###
  @login : (xhr, email, password, success_callback, error_callback) ->
    try
      req =
        url: "../login_handler",
        method: "POST",
        data:
          login: email,
          password: password,
        headers:
          Accept : 'application/json'
      xhr.request req,
        ((response) ->
          info = jQuery.parseJSON(response.data)
          if not info.user
            error_callback "Your login and/or password is incorrect"
          else
            playlists = new Koemei.Collection.Playlists()
            playlists.fetch
              reset: yes

            user = new Koemei.Model.User
              uuid: info.user.uuid
              email: info.user.email
              client_uuid: info.user.client_uuid
              firstname: info.user.firstname
              lastname: info.user.lastname
              playlists: playlists

            success_callback user
        ),
        (response) ->
          error_callback response
    catch err
      console.error "Error in Koemei.User.login : "+err.message+"("+err.lineNumber+")"

  @logout : (xhr, success_callback, error_callback) ->
    try
      req =
        url: "../logout_handler",
        method: "GET",
        headers:
          Accept : 'application/json'
      xhr.request req,
        ((response) ->
          success_callback?(response)
        ),
        (response) ->
          error_callback?(response)
    catch err
      console.error "Error in Koemei.User.logout : "+err.message+"("+err.lineNumber+")"

