class Koemei.View.TranscriptPanel extends Koemei.View.Panel

  events:
    'click .kw_label': 'click_label'
    'click .kw_segment': 'click_segment'
    # listeners for contenteditable elements
    # they should be handled by the segment view
    # but they can't be event listeners in the segment view because otherwise there would be a lot of listeners (bad!)
    'focus [contenteditable]': 'onfocus'
    'blur [contenteditable]': 'onblur'
    'keyup [contenteditable]': 'onkeyup'
    'paste [contenteditable]': 'onpaste'
    # TODO: restore those with the shortcuts dropdown
    #"click #segment_next":'seek_next_segment'
    #"click #segment_prev":'seek_previous_segment'
    #"click #next_word":'seek_next_label'
    #"click #prev_word":'seek_previous_label'
    'focus #transcript_search input':'search_on_focus'
    "submit #transcript_search":"search"

  shortcuts:
    #TODO: these movement operations should scroll the panel automatically
    'down':       'seek_next_segment'
    'up':         'seek_previous_segment'
    'tab':        'seek_next_label'
    'shift+tab':  'seek_previous_label'
    #TODO: ignore ctrl on mac
    # https://github.com/madrobby/keymaster/issues/80
    #TODO: doesn't work
    # https://github.com/madrobby/keymaster/issues/103
    'ctrl':       'play'

  initialize: ->
    Koemei.log 'Koemei.View.TranscriptPanel#initialize'
    @panel_name = "transcript"
    @widget = @options.widget
    @media_item = @options.widget.media_item
    @readonly = @widget.options.readonly
    if @widget.media_item.get('transcript')?
      @model = new Koemei.Model.Transcript
        uuid: @widget.media_item.get('transcript').uuid
        stage: @options.stage

    @template = JST.Transcript_panel

    # TODO: doc
    @segmentClick = false

    @views = {}

    @collection = new Koemei.Collection.Segments() unless @collection
    @listenTo @collection, 'reset', @renderCollection

    # init autosave
    _.bind @saved, this
    if @widget.options.autosave != 0
      setInterval (=>
        @model.save(@options.widget.xhr, @widget.options.auth, @saved, window.alert)
      ), @options.widget.options.autosave * 1000

    # init shortcuts
    _.extend this, new Backbone.Shortcuts
    @delegateShortcuts()

    # TODO: restore various buttons + add comments
#    if @widget.options.background_save
#      save_button = '<a id="kw_save-button" class="btn-2 background_save" href="#">SAVE</a>'
#    else
#      save_button = '<a id="kw_save-button" class="btn-2" href="#">SAVE</a>'
#		if @widget.options.show_exit
#      publish_button = '<a id="kw_publish-button" class="btn-2" href="#">EXIT</a>'
#    if @widget.options.service == 'kaltura'
#      publish_button = '<a id="kw_publish-button" class="btn-2" href="#">PUBLISH</a>'
#      if this.widget.media_item.publish_status
#        publish_button = '<a id="kw_publish-button" class="btn-2" href="#">UNPUBLISH</a>'
#    else
#      publish_button = ''

#		if not @widget.options.readonly
#      $(".kw_edit-controls").append(save_button).append('<span>' + save_info + '</span>').append(publish_button)

  # override View.remove so we don't remove the whole $el from the DOM
  remove: ->
    Koemei.log 'Koemei.View.TranscriptPanel#remove'
    @$el.empty()
    @stopListening()

  render: ->
    Koemei.log 'Koemei.View.TranscriptPanel#render'
    if @collection.length == 0 and @model?
      @model.fetch
        success: => @initPanel()
    else
      @initPanel()

    this

  initPanel: ->
    Koemei.log 'Koemei.View.TranscriptPanel#initPanel'

    last_saved = ''
    # TODO: (Traian) explain this ua thing (preferably link to online doc)
    if @model?
      last_saved = new Date(@model.get 'updated').getTime()/1000
      ua = $.browser
      ua = $.browser
      if ua.mozilla
        timezone_dif = new Date(@model.get 'updated').getTimezoneOffset() * 60
        if timezone_dif < 0
          last_saved = last_saved - timezone_dif
        else
          last_saved = last_saved + timezone_dif

    @$el.html @template
      height: @widget.options.widget_height
      readonly: @widget.options.readonly
      last_saved: last_saved
    @$list = @$ 'div#kw_transcript_container'

    @initCollection()

    # Unfortunately we have to call this here too in order to centre the
    # widget again (after rendering the panel)
    if @widget.options.modal
      @widget.centerWidgetModal()

  initCollection: ->
    Koemei.log 'Koemei.View.TranscriptPanel#initCollection'
    if @model?
      @collection = new Koemei.Collection.Segments(@model.segments) unless @collection.length > 0
      @current_segment = @collection.models[0]
      @current_label = @collection.models[0].labels[0]
      @renderCollection()
    else
      @$list.html "No transcript available yet for this video"

  renderCollection: ->
    Koemei.log 'Koemei.View.TranscriptPanel#renderCollection'
    Koemei.log @collection.length
    Koemei.log @$list

    if @$list and @collection.length
      @collection.each (segment) =>
        @renderModel segment
    else
      @$list.html "No segments"


  renderModel: (segment, search_string=false) ->
    #Koemei.log "Koemei.View.TranscriptPanel#renderModel#{search_string}"
    unless @views[segment.cid]?
      @views[segment.cid] = new Koemei.View.Segment
        widget: @widget
        model: segment
        $wrapper: @$list
        readonly: @readonly

    @$list.append @views[segment.cid].render(search_string).el

  onfocus: (e) ->
    @stash_current_data e

  onblur: (e) ->
    @update_segment e

  onkeyup: (e) ->
    @update_segment e
    @hide_suggestions e

  onpaste: (e) ->
    @update_segment e
    @hide_suggestions e

  stash_current_data: (e) ->
    $this = $(e.currentTarget)
    $this.data 'before', $this.text()

  update_segment: (e) ->
    $this = $(e.currentTarget)
    if $this.data('before') isnt $this.text()
      $this.data 'before', $this.text()
      $(this).parent().find('br').replaceWith(' ')
      @current_segment.update_handler $this

  #TODO: not sure about what it does
  hide_suggestions: (e) ->
    $this = $(e.currentTarget)
    $(this).children('.kw_current').removeClass('suggestion_word')

  saved: ->
    Koemei.log 'Koemei.View.TranscriptPanel#saved'
    $message = @$('.auto_save_message')
    $message.text 'Auto-saved just now'
    @$('.transcript_options ul.edit_options').show()
    save_time = moment.utc()
    interval = 1 # minute
    update_message = ->
      $message.text 'Auto-saved ' + Koemei.dateToFuzzy(save_time)
      # double the interval each time
      #interval *= 2
      # launch all other times
      setTimeout update_message, interval * 1000 * 60
    # launch first time
    setTimeout update_message, interval * 1000 * 60

  seek: (time)->
    #Koemei.log 'Koemei.View.TranscriptPanel#seek'
    @set_current_segment(time)
    @set_current_label(time)

  set_current_segment: (time)->
    #Koemei.log 'Koemei.View.TranscriptPanel#set_current_segment'
    # updates the current segment given the playback time (in seconds)
    current_segment = @collection.get_segment(time)
    #if not current_segment
    #  Koemei.log "No segment found for time #{time}0ms. Staying on the current segment."
    #else
    if current_segment != @current_segment
      #clear current segment display
      @$(".kw_current-segment").removeClass "kw_current-segment"

      @current_segment = current_segment
      $current_segment = @$("#seg_div_#{@current_segment.start}")
      @move_scroll_to_position $current_segment.position().top
      #new current segment display
      $current_segment.addClass "kw_current-segment"
      $current_segment.focus()

    this

  set_current_label: (time)->
    #Koemei.log "Koemei.View.TranscriptPanel#set_current_label#{time}"
    # updates the current label
    current_label = @current_segment.get_label(time)
    #if not current_label
    #Koemei.log "No label found for time #{time}0ms. Staying on the current label."
    #else
    if current_label != @current_label
      #clear current label display
      @$(".kw_current-label").removeClass "kw_current-label"

      @current_label = current_label
      #new current label display
      Koemei.selectText "l_" + @current_label.start
      @$("#l_" + @current_label.start).addClass "kw_current-label"

    this

  seek_next_segment: ->
    Koemei.log 'Koemei.View.TranscriptPanel#seek_next_segment'

    if @current_segment.index < @collection.length
      @current_segment = @collection.get(@current_segment.index + 1)
      @seek @current_segment.start
      @widget.player_view.player.pause(true)
    false

  seek_previous_segment: ->
    Koemei.log 'Koemei.View.TranscriptPanel#seek_previous_segment'

    if @current_segment.index > 0
      @current_segment = @collection.get(@current_segment.index - 1)
      @seek @current_segment.start
      @widget.player_view.player.pause(true)
    false

  seek_previous_label: ->
    Koemei.log 'Koemei.View.TranscriptPanel#seek_previous_label'
    $previous_label = @$el.find("#seg_div_#{@current_segment.start}").find("#l_#{@current_label.start}").prev()
    if $previous_label.length == 0
      # go to last label of previous segment
      @seek_previous_segment()
      $previous_label = @$el.find("#seg_div_#{@current_segment.start}").find(".kw_label:last")
      @current_label = @current_segment.labels[-1]
    $previous_label.click()
    false

  seek_next_label: ->
    Koemei.log 'Koemei.View.TranscriptPanel#seek_next_label'

    $next_label = @$el.find("#seg_div_#{@current_segment.start}").find("#l_#{@current_label.start}").next()
    if $next_label.length == 0
      # go to first label of next segment
      @seek_next_segment()
      $next_label = @$el.find("#seg_div_#{@current_segment.start}").find(".kw_label:first")
      @current_label = @current_segment.labels[0]
    $next_label.click()
    false

  click_label: (event) ->
    Koemei.log 'Koemei.View.TranscriptPanel#click_label'
    event.stopPropagation()
    @widget.player_view.player.pause true
    @segmentClick = false
    # go to the time (the +1 is is there because get_label checks for <= end)
    @seek parseInt(@$(event.currentTarget).attr("id").slice(2), 10) + 1
    this

  click_segment:(event) ->
    Koemei.log 'Koemei.View.TranscriptPanel#click_segment'
    _this = @
    @widget.player_view.player.pause true
    @segmentClick = true
    # go to the time (the +1 is is there because get_label checks for <= end)
    @seek parseInt(@$(event.currentTarget).find('.kw_label').first().attr("id").slice(2), 10) + 1
    this

  play: ->
    Koemei.log 'Koemei.View.TranscriptPanel#play'
    #TODO : this should be on the player view, but then it does not work (scope??)
    @widget.player_view.player.play()


  ###
  Move scroll to position
  @param top {number} top of scroll.
  ###
  move_scroll_to_position: (top) ->
    Koemei.log 'Koemei.View.TranscriptPanel#move_scroll_to_position'

    $current_segment = @$el.find("#seg_div_#{@current_segment.start}")
    segment_height_offset = parseInt($current_segment.parent().height())
    scrollTop = 0
    # top doesn't count how much we scroll, so let's add it
    scrollTop += top + @$list.scrollTop()
    # offset the position of the container
    scrollTop += - @$list.position().top
    # minus the height of a line so that we see the current one in the second line
    scrollTop += - segment_height_offset
    @$list.animate
      scrollTop: scrollTop
    , 300
    this

  search_on_focus:(e) ->
    Koemei.log "Koemei.View.Transcripts#search_on_focus"
    e.preventDefault()
    if @widget.player_view.player.getState()=="PLAYING"
      @widget.player_view.player.pause()


class Koemei.View.TranscriptPanelConfirmSavePopup extends Koemei.View.Tooltip
#TODO
class Koemei.View.TranscriptPanelConfirmPublishPopup  extends Koemei.View.Tooltip
#TODO
#        var modal = '';
#        var go_save = 0;
#        $("#kw_confirm_popup a").click(function (event) {
#			var _this = this;
#			_thisControls.transcript.save(_thisControls.widget.xhr, _thisControls.widget.options.auth,function() {Koemei.log('saved');});
#			//Koemei.log(this);
#			//Koemei.log(self);
#            var action = $(this).attr('data-action');
#            if (action === "YES") {
#
#                if (modal === "save") {
#                   _thisControls.transcript.save(_thisControls.widget.xhr, _thisControls.widget.options.auth,function() {Koemei.log('saved');});
#                }
#                if (modal === "publish") {
#                    $("#kw_publish-button").click();
#                }
#            }
#            $('#kw_confirm_popup').hide();
#        });
#
#
#
#        $("#kw_save-button").on('click',function(event) {
#			if (!$(_thisControls).hasClass('background_save')) {
#                modal = 'save';
#                event.preventDefault();
#                if (go_save === 0) {
#                    $('#kw_confirm_popup').show();
#                }
#				if (go_save === 1) {
#					go_save = 0;
#				}
#			}
#            var _this = $(this);
#            if (window.submitForm || typeof window.submitForm === 'undefined') {
#                _this.addClass('kw_loading_bg');
#				_this.addClass('btn-disabled');
#                try {
#                    //window.submitForm = false;
#                    //Koemei.log(transcript)
#                    _thisControls.transcript.save(_thisControls.widget.xhr, _thisControls.widget.options.auth,function() { Koemei.log('saved');});
#					if (window['localStorage'] !== null) {
#						localStorage.removeItem("koemei_"+_thisControls.widget.media_item.uuid);
#					}
#                    setTimeout(function () {
#                        _this.removeClass('btn-disabled');
#						_this.removeClass('kw_loading_bg');
#                    }, 200);
#                }
#                catch (e) {
#                    console.error("Error saving modifications : " + e.message + "(" + e.lineNumber + ")");
#                }
#            }
#            return false;
#        });
#
#		$("#kw_publish-button").click(function () {
#			var text = $(this).text();
#            // TODO : create 2 different popups : publish vs exit
#			if (text==="EXIT" || text==="PUBLISH") {
#				$('#kw_exit_popup').show();
#			}
#			if (text==="UNPUBLISH") {
#				_thisControls.transcript.media.unpublish(_thisControls.widget.xhr);
#				$('#kw_notify_popup div h2').html('The captions have been unpublished');
#           		 $('#kw_notify_popup').show();
#				 $(this).text('EXIT');
#			}
#		});
#