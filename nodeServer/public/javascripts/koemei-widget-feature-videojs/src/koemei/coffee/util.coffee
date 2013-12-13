###
Load a stylesheet if it has not been loaded already.
See http://stackoverflow.com/questions/574944/how-to-load-up-css-files-using-javascript
###
Koemei.loadCssFile = (cssId, url) ->
  Koemei.log "Loading css at #{url}"
  if document.getElementById(cssId)
    Koemei.log "css already present at id #{cssId}"
    return
  if document.createStyleSheet
    # Ie fix (see http://www.vidalquevedo.com/how-to-load-css-stylesheets-dynamically-with-jquery)
    document.createStyleSheet(url)
  else
    head = document.getElementsByTagName('head')[0]
    link = document.createElement('link')
    link.id = cssId
    link.rel = 'stylesheet'
    link.type = 'text/css'
    link.href = url
    link.media = 'all'
    head.appendChild(link)

###
Update the given URL to use the same protocol as the current page.
Valid inputs:
  - //domain.com...
  - http://domain...
  - https://domain...
###
Koemei.setDocumentProtocol = (url) ->
  return url.replace(/^(https?:)?\/\//, document.location.protocol + '//')


(($) ->
  $.fn.serializeFormJSON = ->
    o = {}
    a = @serializeArray()
    $.each a, ->
      if o[@name]
        o[@name] = [o[@name]]  unless o[@name].push
        o[@name].push @value or ""
      else
        o[@name] = @value or ""

    o
) jQuery

Koemei.display_popup = ($element, $popup, orientation, options) ->
  ep = $element.position()
  ew = $element.outerWidth()
  eh = $element.outerHeight()
  pw = $popup.outerWidth()
  ph = $popup.outerHeight()
  arrow_width = 8
  _options = {}
  defaultOptions = {arrow_space: 8}
    
  _options = $.extend {}, defaultOptions, options

  switch orientation
    when 'top'
      $popup.css
        top: ep.top - ph - _options.arrow_space
        left: ep.left + ew/2 - pw/2
      $popup.find('.arrow').addClass('bottom').css {left: pw/2 - arrow_width}
    when 'bottom'
      $popup.css
        top: ep.top + eh + _options.arrow_space
        left: ep.left + ew/2 - pw/2
      $popup.find('.arrow').addClass('top').css {left: pw/2 - arrow_width}

  #$('html').click ->
  #  $element.removeClass('active')
  #  $popup.hide()
  $popup.addClass('active').show()

  
Koemei.hide_popups = ($el) ->
  $el.find('.kw_bar_options .active').removeClass('active')
  $el.find('.popup').hide()


Koemei.hide_single_popup = ($el, $popup) ->
  $el.find('.kw_bar_options .active').removeClass('active')
  $popup.hide()

# Highlight text in a html document
# @param {string} element_id : id of the element to highlight
Koemei.selectText = (element_id) ->
  doc = document
  text = doc.getElementById(element_id)
  range
  if doc.body.createTextRange
    range = document.body.createTextRange()
    range.moveToElementText(text)
    range.select()
  else if window.getSelection
    selection = window.getSelection()
    range = document.createRange()
    if text
      range.selectNodeContents(text)
      selection.removeAllRanges()
      selection.addRange(range)


# replace all words of a string by "replace"
Koemei.replaceAll = (str, find, replace, case_insensitive=true) ->
  if case_insensitive then cs = "gi" else cs = "g"
  str = str.replace(new RegExp(find, cs), replace)
  return str

# TODO : check if used. If yes, add comments, if no remove
if typeof String.prototype.trim != 'function'
  String::trim = () ->
    @replace(/^\s+|\s+$/g, '')

# Convert seconds to mm:ss string format.
# @param {secs} secconds
# @return {s} formatted mm:ss string
Koemei.secondstotime = (secs) ->
  t = new Date(1970,0,1)
  t.setSeconds(secs)
  s = t.toTimeString().substr(0,8)
  if secs > 86399
    s = Math.floor((t - Date.parse("1/1/70")) / 3600000) + s.substr(2)
  s

# Convert timestamp to seconds.
# @param {timestamp} timestamp to convert
# @return {integer} rounded number of seconds corresponding to the input timestamp
Koemei.timestamp_to_seconds = (timestamp) ->
  temp = Math.round(timestamp/6000*100)/100
  temp = Math.round(temp*60)
  temp

Handlebars.registerHelper "displayName", (person) ->
  if person?
    if person.firstname == "Firstname"
      return person.email
    else
      return "#{person.firstname} #{person.lastname}"

Handlebars.registerHelper "getAvatarPath", (person) ->
  if person?
    "//www.gravatar.com/avatar/#{$.md5 person.email}.jpg"

Handlebars.registerHelper "secsToString", (timestamp) ->
  Koemei.secsToString timestamp

Handlebars.registerHelper "millisecsToString", (timestamp) ->
  Koemei.secsToString Math.round timestamp / 100

Handlebars.registerHelper "timestampToSeconds", (timestamp) ->
  Koemei.timestamp_to_seconds timestamp

Handlebars.registerHelper "confidenceColor", (confidence) ->
  # TODO : make this a widget config option
  if confidence < 0.50 then "kw_low_confidence_label" else ""

Handlebars.registerHelper "dateDisplay", (date) ->
  # display the date in a human form (remove milliseconds and stuff)
  date.substr(0,19)

Handlebars.registerHelper "dateToFuzzy", (timestamp) ->
  Koemei.dateToFuzzy timestamp

Handlebars.registerHelper "heatmapMargin", (timestamp, granularity) ->
  timestamp * granularity

Handlebars.registerHelper "highlightMatches", (text, search_string) ->
  #Koemei.log 'highlightMatches'
  if text?
    search_words = search_string.split(" ")
    for word in search_words
      text = Koemei.replaceAll(text, word, '<strong>' + word + '<\/strong>')
    # do not escape the strong tags
    return new Handlebars.SafeString text
  return ""

Handlebars.registerHelper "view", (player) ->
  debugger