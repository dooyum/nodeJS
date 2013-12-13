class Koemei.View.Player extends Backbone.View

  events:
    'click .video_info_button': 'toggle_info'

  initialize: ->
    Koemei.log 'Koemei.View.Player#initialize'
    @template = JST.Player
    # tells if the segment navigation is enabled or not
    @segment_nav_on = true
    #interval when resuming playback
    @resume_playback_interval = -100

    @widget = @options.widget
    @media_item = @widget.media_item
    @start_time = @widget.options.start_time
    switch @widget.options.service
      when 'koemei' then @player = new Koemei.JWPlayerInterface(@widget)
      when 'videojs' then @player = new Koemei.VideoJSInterface(@widget)
      when 'kaltura'
        @player = new Koemei.KalturaPlayerInterface(@widget)
        # TODO: move this inside the KPI
        @player.onStateChange(Koemei.KalturaPlayerInterface.onStateChangeCallback)
      when 'mediaelement' then @player = new Koemei.MediaElementInterface(@widget)
      else
        Koemei.error('Error: Unspecified service')

    @render()

  render: ->
    Koemei.log 'Koemei.View.Player#render'
    @$el.html @template
      show_info: not @widget.options.detach_info
      bar_width: @widget.options.video_width - @widget.options.left_space + @widget.options.right_space
      left_space: @widget.options.left_space
      file_name: @media_item.get 'clientfilename'
      videojs: @widget.options.service == 'videojs'
      width: @widget.options.video_width
      height: @widget.options.video_height

    @player.render()

    # init listeners (the player needs to be rendered!)
    @initialize_listeners()

    @info_overlay = new Koemei.View.Info
      detach_info: @widget.options.detach_info
      show_confidence: @widget.options.show_confidence
      media_item: @media_item

    @notes_heatmap = new Koemei.View.NotesHeatmap
      media_item: @media_item
      bar_width: @widget.options.video_width - @widget.options.left_space + @widget.options.right_space
      left_space: @widget.options.left_space
      el: @$el


    # autoplay and autoresume
    if window.localStorage?
      seek_to = window.localStorage.getItem("koemei_" + @media_item.uuid)
      if seek_to?
        @widget.transcript_panel.seek seek_to
        if @widget.options.autoplay?
          @player.play()

    # start time specified as a widget option
    if @start_time != 0
      if @widget.transcript_panel?
        @widget.transcript_panel.seek @start_time
        if @widget.options.autoplay?
          @player.play()


  toggle_info: ->
    Koemei.log 'Koemei.View.Player#toggle_info'
    @notes_heatmap.hide()
    @info_overlay.toggle()

  toggle_heatmap: ->
    @info_overlay.hide()
    @notes_heatmap.toggle()


  initialize_listeners: () ->
    Koemei.log 'Koemei.View.Player#initialize_listeners'

    # initialize listeners on the player interface
    @player.onTime @onTime_callback
    @player.onSeek @onSeek_callback
    @player.onPause @onPause_callback
    @player.onPlay @onPlay_callback

    #@player.onSeek ->
    #  _this.segment_nav_on = true  unless _this.segment_nav_on


  onTime_callback: (event) =>
    # callback for the ontime event.
    switch @widget.options.service
      #TODO: this is ugly, is it because of Kaltura player??

      when 'koemei' then time = parseInt(event.position * 100, 10)
      when 'kaltura' then time = parseInt(event * 100, 10)  if isNaN(event.position)
      # this might need to be currentTime * 100
      when 'videojs' then time = parseInt(@player.video.currentTime * 100, 10)
    # Koemei.log "Player OnTime player\n\t position : #{@getPosition()}\n\ttranscript time: #{time}"
    @widget.transcript_panel.seek time
    this

  onSeek_callback: (event) =>
    # callback for the onSeek event.
    if not @segment_nav_on
      @segment_nav_on = true
    this

  onPause_callback: (event) =>
    # callback for the onPause event.
    # TODO: Restore this once we display the shortcuts again
    #$('#widget_play').addClass('kw_t_play').removeClass('kw_t_pause')
    # TODO: what does this do?
    #$('.kw_seeker').fadeIn(100)
    @segment_nav_on = false
    this 

  onPlay_callback: (event) =>
    # TODO: Test if commenting this `preventDefault` breaks something!
    #event.preventDefault()
    # callback for the onPlay event.

    # resume playing
    if @start_time > 0
      @seek @start_time - 1 
      pos_to_seek = 0

    # TODO: what does this do? restore? kw_koemei_widget does not exists anymore...
    #$(".kw_koemei_widget").scrollTop 0

    # TODO: restore kw_subtitles
    if not $("#kw_subtitles").hasClass("hidden") and @widget.options.captions
      $("#kw_toolbar ul li.captions_item").addClass "kw_active"
      $("#kw_subtitles").show()

    # TODO: Restore this once we display the shortcuts again
    #$("#widget_play").addClass "kw_t_pause"
    #$("#widget_play").removeClass "kw_t_play"
    @widget.transcript_panel.segmentClick = false

    #Koemei.log("Player OnPlay current_label : "+transcript.current_label.start);

    # On click on a label, resume the playback a bit before
    pos_to_seek = 0
    unless @segment_nav_on #play or pause normal mode
      @segment_nav_on = true
    segment_start = $("#l_" + @widget.transcript_panel.current_label.start).parent().attr("seg-start")
    if segment_start > parseInt(@widget.transcript_panel.current_label.start, 10) + @resume_playback_interval
      pos_to_seek = Math.ceil(segment_start / 100)
    else
      pos_to_seek = Math.ceil((parseInt(@widget.transcript_panel.current_label.start, 10) + @resume_playback_interval) / 100)

    @seek pos_to_seek
    this

  # Interface to the player object
  play: ->
    @player.play()

  pause: (flag)->
    @player.pause(flag)

  seek: (pos)->
    @player.seek(pos)

  getState: ->
    @player.getState()

  getPosition: ()->
    @player.getPosition()

  onTime: (callback)->
    @player.onTime(callback)

  onSeek: (callback)->
    @player.onSeek(callback)

  onPlay: (callback)->
    @player.onPlay(callback)

  onPause: (callback)->
    @player.onPause(callback)

  onStateChange: (callback)->
    @player.onStateChange(callback)

