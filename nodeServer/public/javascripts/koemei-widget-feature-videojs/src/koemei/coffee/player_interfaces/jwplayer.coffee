class Koemei.JWPlayerInterface

  constructor: (@widget) ->
    @media_item = @widget.media_item
    @config = 
      modes: [
        type: "flash"
        src: @widget.options.static_cdn_path + "/javascript/libraries/jwplayer/player.swf"
      ]
      file: @media_item.get('streaming_url')
      skin: @widget.options.static_cdn_path + "/widget/latest/skins/koemei.swf"
      width: @widget.options.video_width
      height: @widget.options.video_height
      controlbar: "over"
      stretching: "fill"
      plugins: "https://"+@widget.options.static_cdn_path + "/widget/latest/skins/plugin.swf"

    if @config.file.indexOf("http://www.youtube.com/watch?v=") isnt 0
      @config.provider = "rtmp"
      @config.streamer = @widget.options.usermedia_cdn_path
    if @widget.options.mode is 'minimal' and @media_item.status is 5
      
      @config.tracks =
        [
          file: @widget.options.koemei_host+"/REST/transcripts/"+@media_item.current_transcript_uuid+".srt",
          kind: "captions",
          label: "English",
          "default": true
        ]

  render: () ->
    @player = jwplayer("widget_player").setup(@config)
    @player.widget = @widget

  play : () ->
    console.log "play was called!"
    @player.play()

  pause : (flag) ->
    @player.pause true

  seek : (pos) ->
    @player.seek pos


  getState : () ->
    @player.getState()

  getPosition : () ->
    @player.getPosition()

  onTime : (callback) ->
    @player.onTime callback

  onSeek : (callback) ->
    @player.onSeek callback

  onPlay : (callback) ->
    @player.onPlay callback

  onPause : (callback) ->
    @player.onPause callback
