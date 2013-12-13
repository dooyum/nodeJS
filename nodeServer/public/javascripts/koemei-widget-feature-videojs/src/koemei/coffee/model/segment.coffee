class Koemei.Model.Segment extends Backbone.Model

  srt=""

  constructor: (@transcript, labels_json, @index, @speaker) ->
    @cid = index
    @labels = []
    for label_json in labels_json
      @labels.push(
        new Koemei.Model.Label(
          label_json.value,
          label_json.start,
          label_json.end,
          label_json.confidence,
          label_json.transcript
        )
      )
    @start = @labels[0].start
    @end = @labels[@labels.length-1].end
    @dom_element = $('#s_' + @start)

  get_label:(time) ->
    try
      for label in @labels
        if label.start <= time and label.end >= time
          return label
    catch ex
      Koemei.error "Exception getting label for time " + time +" : " + ex
    return false

  ###
  Initialise labels
  * @param {DOMelement} html representation of segment
  ###
  init_labels : () ->
    try
      for label in @labels
        label_element = $("#l_"+label.start)
        # good luck : http://stackoverflow.com/questions/13422080/...
        # ...using-loop-to-bind-click-event-over-several-elements-not-working-in-javascript-j
        label_element.unbind("click").click do (label_element) =>
          => Koemei.Model.Label.on_click label_element, @
    catch err
      Koemei.log "Error init segment labels : " + err.message + "(" + err.lineNumber + ")"

  
  ###
  Get an object representation of a segment from an html representation
  * @param {DOMelement} html representation of segment
  * @return {Koemei.segment} segment object obtained from html input
  ###
  @get_from_html : (segment_html) ->
    try
      segment_duration = parseInt(segment_html.attr("seg-end"), 10) - parseInt(segment_html.attr("seg-start"), 10)
      segment_text = segment_html.text().trim()
      new_segment = []
      labels = segment_text.split(/\s+/)
      label_length = parseInt(segment_duration / labels.length, 10)
      label_start = parseInt(segment_html.attr("seg-start"), 10)
      label_index = 1
      label = {}

      for old_label in labels
        if old_label.trim() isnt ""
          label =
            start: label_start
            end: label_start + label_length
            confidence: 1
            id: label_index
            value: old_label.trim()

          label_start = label.end
          label_index++
          new_segment.push label

      # if the segment is empty, create a label with " " as content
      if new_segment.length is 0
        label =
          start: parseInt(segment_html.attr("seg-start"), 10)
          end: label_start + label_length
          confidence: 1
          id: label_index
          value: " "

        new_segment.push label
    catch err
      Koemei.log "Error getting segment from html : " + err.message + "(" + err.lineNumber + ")"

    new_segment

  ###
  Convert js of segment ot an html segment
  * @param {json} json segment representation
  * @return {html} html segment representation
  ###
  to_html : (segment_json) ->
    try
      segment_html=''
      for label in segment_json
        segment_html = segment_html + Koemei.Model.Label.to_html(label)

      segment_html
    catch err
      Koemei.log "Error converting segment from json to html : " + err.message + "(" + err.lineNumber + ")"

  ###
  Create subtitles for sergment labels
  * @return {html} subtitles text
  ###
  to_srt : () ->
    # get the current segment start and get the changes
    current_start = @transcript.current_segment.start
    changes = @transcript.changes
    overwrite = null
    # loop trough the changes, check if the current segment is included, if so, set it
    $.each changes, (index, value) ->
      if value.start is current_start
        overwrite = value.labels
        0
      0
    srt = ""
    
    if not overwrite
      # loop labels
      for label in @labels
        srt += label.value.trim() + " "
      srt = srt.trim()
    else
      # loop changes
      $.each overwrite, (index, label) ->
        srt += label.value.trim() + " "
      srt = srt.trim()
    $('#kw_subtitles').text(srt)


  ###
  On change listener
  @on_change : () ->
    $('body')
      .on 'focus', '[contenteditable]', ->
        $this = $(this)
        $this.data 'before', $this.html()
        return $this
      .on 'blur keyup paste', '[contenteditable]', ->
        $this = $(this)
        if $this.data('before') isnt $this.html()
          $this.data 'before', $this.html()
          segment.update_handler $this
        return $this
  ###

  ###
  Event handler for segment update
  * @param {html} html segment representation
  ###
  update_handler : (segment_html) ->
    # update the value of the segment in the transcript representation
    @new_value = Koemei.Model.Segment.get_from_html(segment_html)
    @transcript.register_changes()
    @transcript.calc_quality()
    @transcript.current_label.set_fixed()
    # update the segment srt representation and display
    @to_srt()