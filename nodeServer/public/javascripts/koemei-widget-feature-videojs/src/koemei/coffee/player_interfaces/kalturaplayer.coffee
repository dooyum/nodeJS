class Koemei.KalturaPlayerInterface
  constructor : (@widget) ->
    @media_item = @widget.media_item
    @player = document.getElementById(@widget.options.player_id)
    @status = "UNDEFINED"

  render: ->
    return

  play: () ->
    Koemei.log "PLAY"
    if $("#widget_play").hasClass("kw_t_pause")
      @player.sendNotification "doPause"
    else
      @player.sendNotification "doPlay"

  pause: (flag) ->
    Koemei.log "PAUSE"
    @player.sendNotification "doPause"

  seek: (pos) ->
    @player.sendNotification "doSeek", pos

  getState: () ->
    @status

  getPosition : () ->
    @player.evaluate "{video.player.currentTime}"

  onTime : (callback) ->
    @player.kBind "playerUpdatePlayhead.koemeiOnPage", callback

  onSeek: (callback) ->
    @player.kBind "playerSeekEnd.koemeiOnPage", callback

  onPlay: (callback) ->
    @player.kBind "playerPlayed.koemeiOnPage", callback

  onPause: (callback) ->
    @player.kBind "playerPaused.koemeiOnPage", callback

  onStateChange: (callback) ->
    @player.kBind "playerStateChange.koemeiOnPage", callback

  @onStateChangeCallback : (state) ->
    Koemei.log "state change from "+@status+" to " + state
    @status=state
    Koemei.log @status
