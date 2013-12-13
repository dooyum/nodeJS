class Koemei.Model.Transcript extends Backbone.Model

  idAttribute: 'uuid'

  urlRoot: '../REST/transcripts/'


  defaults:
    # main
    confidence: 0
    version:    0

    # references
    kobject_id: null
    media_id:   null

    # actions
    created:  null
    deleted:  null
    indexed:  null
    migrated: null

  initialize: ->
    Koemei.log 'Koemei.Model.Transcript#initialize'
    @segments = []
    @changes = []
    # meh...
    @left_key = 0
    @right_key = 0

  # Gets the model from the response and parses some fields appropriately.
  parse: (resp) ->
    resp.created.replace('"', '').split('.')[0]
    if resp.updated? then resp.updated.replace('"', '').split('.')[0] else resp.updated = resp.created.split('.')[0]

    index = 0
    for segment_json in resp.segmentation
      @segments.push(new Koemei.Model.Segment(@, segment_json.labels, index, segment_json.speaker))
      index++

    @current_label = @segments[0].labels[0]
    @current_segment = @segments[0]

    resp.quality = Math.round(resp.confidence * 100)

    resp


  url: ->
    if @get 'stage'
      super() + '?stage=' + @get 'stage'
    else
      super()


  render_bak: (readonly, display_speakers)->
    # quality indicator
    $(".kw_transcription_toolbar .kw_progress").show()
    @update_quality()
    h = 0
    div = []
    for segment in @segments
      # speaker change
      if display_speakers and readonly
        unless old_spk is segment.speaker
          div[h++] = "<br><br>"
          old_spk = segment.speaker
      div[h++] = segment.display(@get 'readonly', @get 'display_speakers')

    $("#kw_transcript_container").append div.join("")
    # in case widget is hidden, no width/height to initialize the custom scroll with.
    # fix : checks if the widget is now visible and if so, then reinitialises the customscroll,
    shown = false
    setInterval ->
      if $("#kw_transcript_container").is(":visible") and not shown
        shown = true
        return 0
    , 500

    # init segments labels
    for segment in @segments
      segment.init_labels()
      segment.on_click()
    #segment.on_change()

    #TODO : this should be a class method of segment but then it does not seem to work
    # TODO : there is an inconsistend identation here, but it seems to work like this...
    transcript = @
    $('#kw_transcript_container')
    .on 'focus', '[contenteditable]', ->
      $this = $(this)
      $this.data 'before', $this.text()
      return $this
    .on 'blur keyup paste', '[contenteditable]', ->
      $this = $(this)
      if $this.data('before') isnt $this.text()
        $this.data 'before', $this.text()
        $(this).parent().find('br').replaceWith(' ')
        transcript.current_segment.update_handler $this
        return $this
    .on 'keyup paste', '[contenteditable]', ->
      $this = $(this)
      $(this).children('.kw_current').removeClass('suggestion_word')
    this

  ###
  Save the transcript
  ###
  save_version: (xhr, auth, success_callback, error_callback) ->
    try
      req =
        url: "../REST/transcripts/" + @id + "/save_version",
        method: "PUT",
        timeout: 500000,
        headers:
          Authorization: auth,
          Accept: 'application/json'
      xhr.request req,
        ((response) =>
          #resp = jQuery.parseJSON(response.data)
          #success_callback(xhr, auth)
        ),
        (response) ->
          console.error "Error saving transcript : " + response
    catch ex
      console.error "Exception saving transcript version " + ex + "\n" + @changes

  ###
  Create a version for the transcript
  ###
  save: (xhr, auth, success_callback, error_callback) ->
    try
      if @changes.length > 0
        # escape the slashes twice because it seems it goes through 2 parsers (stringify and...?).
        for change in @changes
          for label in change
            label.value = change.value.replace(/\"/g, "\\\"")

        req =
          url: "../REST/transcripts/" + @id,
          method: "POST",
          data:
            transcript_content: JSON.stringify(@changes)
          timeout: 500000,
          headers:
            Authorization: auth,
            Accept: 'application/json'
        xhr.request req,
          ((response) =>
            resp = jQuery.parseJSON(response.data)
            timestamp = new Date().getTime()
            timestamp = timestamp / 1000
            $(".kw_edit-controls span strong").attr "data-livestamp", timestamp
            @updated = timestamp
            @changes = []
            @save_version(xhr, auth, success_callback, error_callback)
            success_callback(xhr, auth)
          ),
          (response) ->
            console.error "Error saving transcript : " + response
            error_callback 'Error saving transcript, please try again later.'

      else
        #Koemei.log("No changes to save");
    catch ex
      console.error "Exception saving transcripr changes " + ex + "\n" + @changes

  ###
  Compute quality for the transcript
  ###
  calc_quality: () ->
    if @changes.length > 0
      nb_labels = 0
      total_confidence = 0
      for segment in @segments
        for label in segment.labels
          nb_labels++
          total_confidence += label.confidence

      @quality = Math.round(total_confidence / nb_labels * 100)
      @update_quality()

  ###
  Update quality display
  ###
  update_quality: () ->
    $(".kw_progress").attr "title", "Progress : " + @quality + "%"
    $(".kw_transcription_toolbar span").css "width", @quality + "%"
    $(".kw_transcription_toolbar strong").html @quality + "%"
    $(".kw_transcription_toolbar strong").addClass "white"  if @quality > 56

  ###
  Get the changes to the transcript
  ###
  register_changes: () ->
    try
      for segment in @segments
        if segment.new_value
          new_segment_changed = true

          i = 0
          while i < @changes.length
            if @changes[i].start is segment.start
              new_segment_changed = false
              @changes[i] = {labels: segment.new_value, start: segment.start}
            i++

          @changes.push {labels: segment.new_value, start: segment.start}  if new_segment_changed
          segment.new_value = null
          false
    catch err
      console.error "Exception getting changes " + err


  ###
  Handle current segment change
  @param time {number} time in millisecs of the playback position.
  ###
  set_current_segment_bak: (time) ->
    @left_key = 0
    @right_key = 0

    #Koemei.log "setting current segment to #{time}"
    try
      if @startFrom isnt @current_segment.start
        $(".kw_current-segment").removeClass "kw_current-segment"

        # get the corresponding segment from json
        @current_segment = @get_segment(time)
        @current_segment.to_srt()
        localStorage.setItem "koemei_" + @media.uuid, time  if window["localStorage"] isnt null and time > 200

        unless @segmentClick
          @move_scroll_to_position $("#s_" + @current_segment.start).parents("div.kw_segment").position().top

        # highlight and focus on the corresponding div
        $("#seg_div_" + @current_segment.start).addClass "kw_current-segment"
        $("#seg_div_" + @current_segment.start).focus()
        element_position = parseInt($('.kw_current-segment').position().top)
        @startFrom = @current_segment.start #start time of the current segment
        if element_position is 0
          $("#kw_transcript_container").css "background-position", "left -34px"
        else
          $("#kw_transcript_container").css "background-position", "left 0%"
      else
        element_position = parseInt($('.kw_current-segment').parent().position().top)
        if element_position is 0
          $("#kw_transcript_container").css "background-position", "left -34px"
        else
          $("#kw_transcript_container").css "background-position", "left 0%"
    catch err
      console.error "Error setting current segment : " + err.message + "(" + err.lineNumber + ")"

    #Koemei.log("SetCurrentSegment : time="+time+"
    # - current_segment : ("+this.current_segment.id+","+this.current_segment.start+","+this.current_segment.end+")
    # current_label : ("+this.current_label.id+","+this.current_label.start+","+this.current_label.end+")");
    try

    # check segment change
      if time <= @current_segment.start or time >= @current_segment.end
        $(".kw_current-segment").removeClass "kw_current-segment"

        # get the corresponding segment from json
        @current_segment = @get_segment(time)
        # highlight and focus on the corresponding div
        $("#seg_div_" + @current_segment.start).addClass "kw_current-segment"
        $("#seg_div_" + @current_segment.start).focus()

    # TODO : commented by seb because otherwise it will make the scroll jump to the beginning each time...
    # (I think this was added for the smooth scrolling.)
    #unless @segmentClick
    #@move_scroll_to_position $("#s_" + @current_segment.start).parents("div.kw_segment").position().top

    catch err
      console.error "Error setting current segment : " + err.message + "(" + err.lineNumber + ")"

    @set_current_label(time)
    $(".koemei_widget").scrollTop 0

  #Koemei.log("SetCurrentSegment after : time="+time+"
  # - current_segment : ("+this.current_segment.id+","+this.current_segment.start+","+this.current_segment.end+")
  # current_label : ("+this.current_label.id+","+this.current_label.start+","+this.current_label.end+")");

  ###
  Set the current label
  * @param time {number} time in millisecs of the playback position.
  ###
  set_current_label_bak: (time) ->
    # check label change

    # get the corresponding label from json
    new_label = @get_label(time)
    if $("#l_" + new_label.start).length > 0
      $("#l_" + @current_label.start).removeClass "kw_current-label"
      @current_label = new_label
      Koemei.selectText "l_" + @current_label.start
      $("#l_" + @current_label.start).addClass "kw_current-label"
      # TODO : this needs comments (segment?)
      if $("#transcript_panel_container").hasClass("kw_readonly_panel")
        cur_segment = $(".kw_current-label")
        cur_segment = cur_segment[0]
        $(".kw_label").removeClass "kw_shown"
        ind = $(".kw_label").index(cur_segment)
        $(".kw_label").slice(0, ind).addClass "kw_shown"
    else
      Koemei.error "Koemei.Model.Transcript.set_current_label : No label found for time " + time
      Koemei.error "approx was label " + new_label.start