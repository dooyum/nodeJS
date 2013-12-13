###
  This file mocks requests to resources Koemei API
###

getMedia = (media_uuid, auth, callback) ->
  ###
  Get the specified media
  @param {String} media_uuid : media identifier
  @param {String} auth : authentification
  @param {String} callback : success callback function
  TODO : add error callback function
  ###
  console.log test_media
  try
    callback(test_media)
  catch err
    console.error "Error in getMedia : " + err.message + "(" + err.lineNumber + ")"

getMediaList = (criteria, auth, user_uuid, callback) ->
  ###
  Get a list of media items
  @param {String} criteria is the list of criteria for the request
  @param {String} auth : authentification
  @param {String} user_uuid : user id
  @param {String} callback : success callback function
  TODO : add error callback function
  ###
  try
    ###if(user_uuid){
      var uid = '&user_uuid='+user_uuid;
    } else { var uid='' }
    ###
    if criteria.search_query?
      callback test_media_list_search
    else
      callback test_media_list
  catch err
    console.error "Error in getMediaList : " + err.message + "(" + err.lineNumber + ")"

getTranscript = (transcript_uuid, auth, callback, stage) ->
  ###
  Get the specified transcript
  @param {String} transcript_uuid : transcript identifier
  @param {String} auth : authentification
  @param {String} callback : success callback function
  TODO : add error callback function
  ###
  try
    callback {'segments': test_transcript}
  catch err
    console.error "Error in getTranscript : " + err.message + "(" + err.lineNumber + ")"

saveTranscript = (transcript_uuid, data, auth, callback, error_callback) ->
  ###
  Save the transcript to the server
  @param {string} transcript_uuid : transcript unique identifier
  @param {string} data : transcript content in json form
  @param {callback} success callback function
  @param {callback} error callback function
  ###
  try
    callback
  catch err
    console.error "Error in saveTranscript : " + err.message + "(" + err.lineNumber + ")"

publishMedia = (media_uuid, auth, callback, success_callback_url, error_callback_url) ->
  ###
  Publish media current transcript
  @param {String} media_uuid : media identifier
  @param {String} auth : authentification
  @param {String} callback : success callback function
  @param {String} success_callback_url : success callback url
  @param {String} error_callback_url : error callback url
  TODO : add error callback function
  ###
  try
    callback
  catch err
    console.error "Error in publishMedia : " + err.message + "(" + err.lineNumber + ")"

unpublishMedia = (media_uuid, auth, callback, success_callback_url, error_callback_url) ->
  ###
  Publish media current transcript
  @param {String} media_uuid : media identifier
  @param {String} auth : authentification
  @param {String} callback : success callback function
  @param {String} success_callback_url : success callback url
  @param {String} error_callback_url : error callback url
  TODO : add error callback function
  ###
  try
    callback
  catch err
    console.error "Error in unpublishMedia : " + err.message + "(" + err.lineNumber + ")"