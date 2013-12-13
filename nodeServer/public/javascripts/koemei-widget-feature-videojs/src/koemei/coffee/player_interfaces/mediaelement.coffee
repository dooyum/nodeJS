class Koemei.MediaElementInterface

  debug: false

  constructor: (@widget) ->
    @media_item = @widget.media_item
    if @widget.options.player_id
      if typeof @widget.options.player_id == 'string'
        elem = document.getElementById @widget.options.player_id
      else
        elem = @widget.options.player_id
    if not elem
      throw Error 'Cannot load MediaElement without specifying an element via options.player_id'

    parent = document.getElementById 'widget_player'
    parent.appendChild elem

    @player = MediaElementPlayer elem, @widget.options.mediaelement

    @pausing = false
    @status = 'IDLE'

    @onPlay =>
      @status = 'PLAYING'

    @onPause =>
      @status = 'PAUSED'

    @player.media.addEventListener 'ended', (e) =>
      @status = 'IDLE'

  render: ->
    return

  ###
  Start playback.
  If the player is already playing, this should be a no-op.
  ###
  play: () ->
    Koemei.log 'Player.play' if @debug
    @player.play()
    return

  ###
  Pause playback.
  If the player is already paused, this should be a no-op.
  ###
  pause: () ->
    Koemei.log 'Player.pause' if @debug
    @pausing = true
    @player.pause()
    return

  ###
  Jump to the specified time in seconds.
  ###
  seek: (seconds) ->
    Koemei.log 'Player.seek(' + seconds + ')' if @debug
    @player.setCurrentTime(seconds)
    return

  ###
  Returns one of 'IDLE', 'PLAYING', or 'PAUSED'.
  We cannot reliably tell when the player is buffering in both HTML5 and Flash,
  so 'BUFFERING' is never returned by this interface.
  ###
  getState: () ->
    Koemei.log 'Player.getState() == ' + @statu if @debugs
    return @status

  ###
  Returns the current playback position in seconds, as a number.
  ###
  getPosition: () ->
    seconds = @player.getCurrentTime()
    Koemei.log 'Player.getCurrentTime() == ' + seconds if @debug
    return seconds

  ###
  Register a callback to fire during playback with the updated current time.
  The callback will receive one arg: the current time in seconds, as a number.
  ###
  onTime: (callback) ->
    @player.media.addEventListener 'timeupdate', (event) =>
      if @pausing
        return
      seconds = @player.getCurrentTime()
      Koemei.log 'Player.onTime ', seconds if @debug
      callback.call(null, seconds)
      return
    return

  ###
  Register a callback to fire after a seek has occurred.
  The callback will not be passed any args.
  ###
  onSeek: (callback) ->
    @player.media.addEventListener 'seeked', (event) =>
      Koemei.log 'Player.onSeek' if @debug
      callback.call(null)
      return
    return

  ###
  Register a callback to fire when playback starts.
  The callback will not be passed any args.
  ###
  onPlay: (callback) ->
    @player.media.addEventListener 'play', (event) =>
      Koemei.log 'Player.onPlay' if @debug
      callback.call(null)
      return
    return

  ###
  Register a callback to fire when playback stops.
  The callback will be not passed any args.
  ###
  onPause: (callback) ->
    @player.media.addEventListener 'pause', (event) =>
      Koemei.log 'Player.onPause' if @debug
      @pausing = false
      callback.call(null)
      return
    return