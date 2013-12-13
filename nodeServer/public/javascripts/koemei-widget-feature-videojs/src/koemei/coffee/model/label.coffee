class Koemei.Model.Label
  constructor: (@value, start, end, confidence, @transcript) ->
    @start = Number(start)
    @end = Number(end)
    @confidence = Number(confidence)
    @dom_element = $('#l_' + @start)

  ###
  Convert js of label ot an html label
  * @param {json} json label representation
  * @return {html} html label representation
  ###
  @to_html: (label_json) ->
    try
      '<div id="l_' + label_json.start + '" class="kw_label">' + label_json.value + '</div> '
    catch err
      Koemei.log "Error converting label from json to html : " + err.message + "(" + err.lineNumber + ")"

  ###
  Set the label as fixed : confidence goes to 1 and is not underlined anymore
  ###
  set_fixed : () ->
    @confidence = 1
    @dom_element.removeClass('suggestion_word')