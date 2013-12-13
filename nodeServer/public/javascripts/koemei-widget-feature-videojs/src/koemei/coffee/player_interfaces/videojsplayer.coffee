class Koemei.VideoJSInterface

  constructor : (@widget) ->

    @media_item = @widget.media_item
    @config =
      techorder: [
        "Html5"
      ]
      width: "100%"
      height: "100%"
      autoplay: false
      controls: "controls"
      preload: "none"

  render: (options) ->
    
    # DOM accessors
    @wrapper = document.getElementsByClassName('widget_player_wrapper')[0]
    @video = document.getElementsByClassName('player_content')[0]

    ###
    # VJS Constructor Function
    # @param ["widget_player"]    ID of <video>
    # @param [@config]            Player options
    # @param [function()]         Ready callback function 
    ###
    @player = videojs "widget_player", @config
      #@wrapper.appendChild(@video)
      #@wrapper.insertBefore(@wrapper, document.getElementsByClassName('heatmap_notes')[0])  

    @player.widget = @widget 

    # This grants maximum call stack size exceeded:
    # @player.el_ = @video
    
    #@player.play = () ->
    #  console.log "playing video"
    #  this.el_.play()
    
    #@player.pause = () ->
    #  this.el_.pause()

    # Plugin Initialization
    # @player.rangeslider options
    # @player.hoverbox options

    ###
      this.on('ended', this.onEnded);
      this.on('play', this.onPlay);
      this.on('firstplay', this.onFirstPlay);
      this.on('pause', this.onPause);
      this.on('progress', this.onProgress);
      this.on('durationchange', this.onDurationChange);
      this.on('error', this.onError);
      this.on('fullscreenchange', this.onFullscreenChange);
    ###

  play : () ->
    @video.play()

  pause : (flag) ->
    @video.pause()

  # VJS Seek == currentTime(@param)
  seek : (pos) ->
    @player.currentTime pos

  getState : () ->
    @player.getState()

  getPosition : () ->
    @player.currentTime

  onTime : (callback) ->
    @video.addEventListener 'timeupdate', (event) =>
      callback.call null
      return
    return
    
  onSeek : (callback) ->
    if @player.seeking
      callback.call null
      #@player.

  onPlay : (callback) ->
    @player.onPlay callback

  onPause : (callback) ->
    @player.onPause callback

  onStateChange : (callback) ->

  @onStateChangeCallback : (state) ->