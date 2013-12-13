KoemeiWidget = Backbone.View.extend({

    config: {
        toolbar_height: 37
    },

    initialize:function (options) {
        Koemei.log("Koemei.View.Widget#initialize")
		$('body').css('position','static');

        //default config
        var defaults = {
			el:'',
            service:'videojs',
            debug: true,
            width:458,
            video_height:324,
            video_width: 458,
            widget_height:299,
            panel:'transcript',
            search_string:'',
            toolbar:true,
            left_space:45,
			captions:true,
            right_space:37,
            alternatives:false,
            modal:false,
            readonly:false,
            display_related_media:false,
            display_speakers:true,
            improve_popup:false,
			autosave:60,
			solid_overlay:false,
			black_overlay:false,
			media_uuid:'',
			type:'widget',
			search_mode:'prompt',
			start_time:0,
			autoplay:false,
			background_save: true,
            player_id:false,
			override_access_levels:false,
			show_exit:true,
            detach_info: false,
            show_confidence: false,
			koemei_host:'https://www.koemei.com',
			static_cdn_path:Koemei.setDocumentProtocol('//d18embnwuxbhpk.cloudfront.net'),
            koemei_css_path: Koemei.setDocumentProtocol('//d18embnwuxbhpk.cloudfront.net/widget/latest/css/koemei-widget.css'),
            custom_css_path: null,
			usermedia_cdn_path: 'rtmp://usermedia.koemei.com/cfx/st/',
			mode:'edit',
            // todo : overriding this is not working properly(have to specify each option)
            features:{
                transcript:true,
                notes:true,
                videos:true,
                binders:false, // disable this for now
                feedback:false,
                walkthrough:false
            },

            // callback when all widget data ready but before render
            cb_before_render: null
        };

        this.options = $.extend({}, defaults, this.options);
		if ( ! this.options.el) {
				//TODO: only append if there isn't a div already
				$('body').append('<div id="kw_container"></div>');
                this.setElement($('#kw_container'));
		}

		_.bindAll(this, 'keypress', 'close','error_handler');

        // enable/disable debug logging
        Koemei.setDebug(this.options.debug);

        // init crossdomain magic
        this.initXDM();

        // check for unknown config options
		$.each(this.options,function(key,value) {
			if (key!=='features') {
                if (!defaults.hasOwnProperty(key)) {
                    Koemei.log('"'+key+'" is not a valid widget config option, got "'+value+'" for it');
                }
			}
		});

        // Load the css files
        // Always load the widget CSS so that the custom CSS provided only needs
        // to override a minimum set of rules.
        Koemei.log("Loading css file: "+this.options.koemei_css_path)
        Koemei.loadCssFile('kwidget', this.options.koemei_css_path);
        if (this.options.custom_css_path)
            Koemei.loadCssFile('customCss', this.options.custom_css_path);
		Koemei.loadCssFile('fonts', Koemei.setDocumentProtocol('http://fonts.googleapis.com/css?family=Arimo:400,700,400italic,700italic'));

        // Log the user in if he has a cookie (i.e. access login_handler without providing credentials)
        var widget = this;
        Koemei.Model.User.login(
          this.xhr,
          null,
          null,
          function(user){
              widget.user = user;
              user.playlists = new Koemei.Collection.Playlists();
              user.playlists.fetch();
              widget.switch_type();
          },
          function(error){
              // TODO: currently it goes here if the user is not logged in, should check if the user has the cookie first?
              Koemei.log(error);
              widget.switch_type();
          }
        );
    },

    switch_type: function(){
        this.$el.empty();
        this.$el.show();
        // based on the type, init the right type of widget
        if (this.options.type=="widget") {
            this.init_widget();
		} else if (this.options.type=="search_portal") {
            this.init_search_portal();
		} else if (this.options.type=="user_portal") {
            this.init_user_portal();
		}
    },

    init_user_portal: function(){
        Koemei.log("Koemei.View.Widget#init_user_portal");
        // initialize the user portal
        this.user_portal = new Koemei.View.UserPortal({
            el: this.$el,
            widget: this
        });
        // T: dont call render here :)
    },

    init_search_portal: function(){
        Koemei.log("Koemei.View.Widget#init_search_portal");
        // initialize the search portal
        this.search_portal = new Koemei.View.SearchPortal({
            el: this.$el,
            widget: this
        });
        this.search_portal.render(
            this.options.search_string,
            this.options.search_mode
        );
    },

    init_widget: function(){
        // initialize the widget (calulate options based on screen size, etc)
        Koemei.log("Koemei.View.Widget#init_widget");
        // Predefined modes for the widget, will overwrite the options specified above
        switch(this.options.mode) {
            case 'edit':
                this.options.features.improve_popup = false;
            break;
            case 'embed':
                this.options.readonly = true;
                this.options.captions = false;
            break;
            case 'play':
                this.options.widget_height = this.config.toolbar_height;
            break;
            case 'minimal':
                this.options.widget_height = this.config.toolbar_height;
                this.options.captions = false;
            break;
            default:
                Koemei.error("Ivalid mode provided")
            break;
        }

        // TODO : what does this do?
        $(window).keyup(this.keypress);

        //var total_height = this.options.video_height + this.options.widget_height;
        //var viewportHeight = $(window).height();
        //if (viewportHeight<total_height) {
        //    var new_height = viewportHeight-30;
        //    var percentage = new_height/total_height;
        //    this.options.video_height = parseInt(this.options.video_height*percentage);
        //    this.options.widget_height = parseInt(this.options.widget_height*percentage);
        //    this.options.width = parseInt(this.options.width*percentage);
        //}

        this.init_media();
    },

    init_media: function(){
        Koemei.log("Koemei.View.Widget#init_media")

        var widget = this;
        var finished = false;
        // Init the media item
        this.media_item = new Koemei.Model.Media({
            uuid: this.options.media_uuid
        });
        // Init the connections collection
        this.connections = new Koemei.Collection.Connections();
        this.media_item.notes = new Koemei.Collection.Notes();
        this.media_item.fetch({
            // only call `widget.render()` after both connections and notes are fetched
            success: function (model) {
                widget.connections.fetch({
                    data: {media_uuid: model.id},
                    success: function(){
                        if (finished)
                            widget.render();
                        finished = true;
                    }
                });
                widget.media_item.notes.fetch({
                    data: {video: model.id},
                    success: function(){
                        if (finished)
                            widget.render();
                        finished = true;
                    }
                });
            }
        });
    },

    render: function () {
        Koemei.log("Koemei.View.Widget#render")

        if(this.options.cb_before_render){
            this.options.cb_before_render();
        }

        // Render the widget
        var template_variables = {
            width:this.options.width,
            height:this.options.widget_height,
            modal: this.options.modal
        };
        var template = JST.Widget(template_variables);
        this.$el.html(template);

        this.$widgetDiv = this.$('.koemei_widget');
        this.$widgetOverlay = this.$('.kw_widget_overlay');

		this.$widgetOverlay.topZIndex();
		this.$widgetDiv.topZIndex();

		this.height = $(window).height()/2;

        // Modal mode
		if (this.options.modal) {
            this.bindWindowResize();
            this.centerWidget();
        } else {
			this.$widgetOverlay.hide();
		}

        // Overlay
		if (this.options.solid_overlay) {
			this.$widgetOverlay.addClass('kw_solid_overlay');
		}
		if (this.options.black_overlay) {
			this.$widgetOverlay.addClass('kw_black_overlay');
		}

		this.fixIeBug();

        // if media is not yet transcribed, display the widget in a minimal form
        if (!this.media_item.is_transcribed()) {
			if (this.options.mode!=="minimal") {
                Koemei.log("Media is not yet transcribed, switch to minimal mode");
				this.$el.empty();
				this.options.mode="minimal";
				this.options.widget_height=this.config.toolbar_height;
				this.initialize();
			}
		}

		// if media is private
		if (this.media_item.is_private()) {
            if (!this.options.override_access_levels) {
                this.options.readonly = true;
            }
        }

        // Render the player pane
        this.player_view = new Koemei.View.Player({
            el: this.$('.widget_player'),
            widget: this
        });

        // Render the toolbar
        if (this.options.toolbar) {
            this.toolbar = new Koemei.View.Toolbar({
                el: this.$('.widget_bar'),
                widget: this
            });
        }
        // Render the transcript panel
        if (this.options.features.transcript) {
            this.transcript_panel = new Koemei.View.TranscriptPanel({
                el: this.$('.widget_hold_panel'),
                widget: this,
                stage: (this.options.mode=='edit'?'drafts':null),
                search_string: this.options.search_string
            });
            // TODO: use the init_panel feature thingy
            this.transcript_panel.render();
        }

        // Init the notes panel
        if (this.options.features.notes) {
            this.notes_panel = new Koemei.View.NotesPanel({
                el: this.$('.widget_hold_panel'),
                height: this.options.widget_height,
                widget: this
            });
        }
        // Init the videos panel
        if (this.options.features.videos) {
            this.videos_panel = new Koemei.View.VideosPanel({
                el: this.$('.widget_hold_panel'),
                height: this.options.widget_height,
                widget: this
            });
        }

        // TODO : explain what this does
		if (this.options.mode==="minimal") {
            $('.kw_koemei_widget').removeClass('auto');
        }
        // TODO : this is horrible + explain in readme what play mode implies (especially the difference with minimal mode)
        if (this.options.mode=="play") {
            this.$el.children('.kw_koemei_widget').children('#widget_toolbar_hold').children('#kw_toolbar').children('ul').children('li').not(this.$el.children('.kw_koemei_widget').children('#widget_toolbar_hold').children('#kw_toolbar').children('ul').children('.captions_item')).removeClass('kw_active');
        }
    },

    initXDM: function(){
        // crossdomain request initialization
        this.xhr = new easyXDM.Rpc({
            remote: this.options.koemei_host+"/cors/"
        }, {
            remote: {
                request: {} // request is exposed by /cors/
            }
        });
        Backbone.easyXDMxhr = new easyXDM.Rpc({
            remote: this.options.koemei_host+"/cors/"
        }, {
            remote: {
                request: {}
            }
        });
        Backbone.ajax = function() {
            var options = arguments[0];
            options.method = options.type;
            // We force the response to be json
            options.headers = {"Accept": 'application/json'}
            Backbone.easyXDMxhr.request(options, function(response) {
                options.success && options.success(JSON.parse(response.data), response.status);
            }, function(response) {
                options.error && options.error(JSON.parse(response.data.data), response.data.status);
            });
        };

    },

    events:{
        "click #kw_close":"close", //TODO: SHOULD BE 'CLOSE_HANDLER', THERE WAS SOME EXIT POPUP
        "click .search_result":"search_result_click",
        "click .kw_seeker span":"seeker_click",
        "click #kw_subtitles":"toogle_captions",
        "click #widget_play":'widget_play',
        'click #kw_notify_popup a':'hide_notify',
		'click #kw_exit_popup a':'exit_widget',

		//show various popups
		'click .close_popup': 'hide_popups',

		'mouseenter .tooltip_invoker':'sumon_tooltip',
		'mouseleave .tooltip_invoker':'hide_tooltips',

		//events Search Portal
        "click .kw_sort_mode li a":'sort_mode_set',
        "click #kw_search_form .cancel":'remove',
		"click .kw_result_list .kw_caption p":'expand_list',
		"click .kw_search_error":'hide_error',
		"focus #kw_search_form input":'hide_error',
		'keypress #kw_search_form input':'trigger_change'
    },


    //fixes a IE bug regarding events not triggered on buttons with backbone
	fixIeBug: function(){
		if(!$.browser.msie || $.browser.version > 8){
			return;
		}
		var delegateEventSplitter = /^(\S+)\s*(.*)$/;
		var events = this.events;
		if($.isFunction(events)){
			events = events.apply(this);
		}
		var handleEvents = ['change', 'submit', 'reset', 'focus', 'blur']
		for (var key in events) {
			var method = events[key];
			if (!_.isFunction(method)) method = this[events[key]];
			if (!method) throw new Error('Method "' + events[key] + '" does not exist');
			var match = key.match(delegateEventSplitter);
			var eventName = match[1], selector = match[2];
			if( _.indexOf(handleEvents, eventName) == -1){ continue; }
			method = _.bind(method, this);
			if (selector === '') {
			} else {
				var self = this;
				(function(eventName,method){
					//Koemei.log('trying to set "on" handler for %s, key=%s', eventName, key);
					self.$(selector).on(eventName, function(e){
						//Koemei.log('got it, eventName=%s', eventName);
						return method(e);
					})
				})(eventName,method);
			}
		}
	},

	error_handler:function(data) {
        // TODO: make this beautiful!
		$('.kw_koemei_widget').hide();
        var error = new Koemei.View.Error();
        error.render(data.message+'('+data.code+')');
	},

    reinit:function (event) {
        event.preventDefault();
        var element = event.currentTarget;
        this.close();
        var media_uuid = $(element).attr('data-uuid');
        var string = $(element).attr('data-string');
        this.options.media_uuid = media_uuid;
        this.options.panel = 'search';
        this.options.search_string = string;
        this.$el.empty();
        this.$el.show();
        this.render();
    },
	keypress: function(event) {
		var key = event.keyCode;
		if (key==27 && this.options.modal) {
			this.close();
		}
	},
    hide_notify:function (event) {
        event.preventDefault();
        $('#kw_notify_popup').hide();
    },

    widget_play:function (event) {
        event.preventDefault();
        var target = event.currentTarget;
        if ($(target).hasClass('kw_t_play')) {
            this.player_view.player.play();
        } else {
            this.player_view.player.pause();
        }
    },
	exit_widget:function(event) {
        event.preventDefault();
		var button = event.currentTarget;
		this.media_item.transcript.save(this.xhr, this.options.auth,function() {Koemei.log('saved');});
		var action = $(button).attr('data-action');
		if (action === "YES") {
			$('#kw_publish-button').addClass('btn-disabled');
			this.media_item.transcript.media.publish(this.xhr, this.options.service, this.options.auth);
			$('#kw_publish-button').text('UNPUBLISH');
			setTimeout(function () {
				$('#kw_publish-button').removeClass('btn-disabled');
			}, 200);
			$('#kw_exit_popup').hide();
			this.close();
		} else {
			if (this.options.modal) {
				this.close();
			}
		}
	},

    toogle_captions:function (event) {
		event.preventDefault();
        $("#kw_subtitles").toggleClass('hidden');
        $("#kw_toolbar ul li.captions_item").removeClass('kw_active');
        $("#kw_subtitles").hide();

    },

    close:function () {
        if(this.interval!==undefined) {
            clearInterval(this.interval);
        }
        this.$el.empty();
        this.$el.hide();
        this.undelegateEvents();
        if (this.options.modal)
            this.unbindWindowResize();
    },

    close_handler:function(event) {
        if (this.media_item.transcript && this.media_item.transcript.changes.length || !this.media_item.publish_status) {
           //if the transcript has changes, or if no modifications are made,
           //show the publish popup
           $('#kw_exit_popup').show();
        } else {
           //if it's published and no modifications are made, just close, no need to show the popup
            this.close();
        }
    },

	expand_panel:function(panel) {
		if (this.options.mode=="play" || this.options.mode=="minimal" ) {
		if ($('.kw_koemei_widget').hasClass('auto')) {
				$('.kw_koemei_widget').removeClass('auto');
			} else {
				if (!$('.kw_koemei_widget').hasClass('expanded')) {
					this.options.widget_height=400;
					var total_h = this.options.widget_height+this.options.video_height;
					var viewportHeight = $(window).height();
					if (total_h>viewportHeight) {
						total_h = viewportHeight-30;
						dif = total_h - this.options.video_height;
						this.options.widget_height = dif;
					}
					var mg_top = total_h/2;
					$('.kw_koemei_widget').animate({height:total_h,marginTop:'-'+mg_top});
					$('#kw_subtitles').animate({bottom:this.options.widget_height});
					$('.kw_koemei_widget').addClass('expanded');
					$('#transcript_panel_container').css('height',this.options.widget_height-37);
					if (this.options.readonly) {
						$('#kw_transcript_container').css('height',this.options.widget_height-87);
					} else {
						$('#kw_transcript_container').css('height',this.options.widget_height-122);
					}
					$('#help_popup').animate({height:'100%'});
				} else {
					if ((this.options.mode=="play" && $('.kw_koemei_widget').hasClass('close_wid') && panel!='search') || (this.options.mode=="minimal" && $('.kw_koemei_widget').hasClass('close_wid') && panel!='search')) {
						$('.kw_koemei_widget').removeClass('expanded');
						var total_h = this.options.video_height+37;
						var mg_top = total_h/2;
						this.options.widget_height =total_h;
						$('.kw_koemei_widget').animate({height:total_h,marginTop:'-'+mg_top});
						$('#kw_subtitles').animate({bottom:37});
						this.$el.children('.kw_koemei_widget').children('#widget_toolbar_hold').children('#kw_toolbar').children('ul').children('li').not(this.$el.children('.kw_koemei_widget').children('#widget_toolbar_hold').children('#kw_toolbar').children('ul').children('.captions_item')).removeClass('kw_active');
						$('.kw_koemei_widget').removeClass('close_wid');
						$('#help_popup').animate({height:0});
					}


				}
			}
		}
	},


// -----------------------------------------------------
// --------------------NEW functions--------------------
// -----------------------------------------------------

	hide_popups:function(event) {
		Koemei.hide_popups(this.$el);
	},


    // Binds the window `resize` event so that the widget is re-centered
    // according to the new viewport size.
    bindWindowResize: function() {
        var widget = this;
        $(window).on('resize.koemei_widget', function(){
            widget.centerWidgetModal();
        });
    },


    unbindWindowResize: function() {
        $(window).off('resize.koemei_widget');
    },


    // this function should be called when the widget is a modal
    centerWidget: function() {
        this.$el.topZIndex();
        this.$widgetOverlay.topZIndex();
        this.$widgetDiv.topZIndex();
        this.$el.css({
            position: 'absolute',
            width: '100%',
            height: '100%',
            top: 0,
            left: 0
        });
        this.centerWidgetModal();
    },

    // This centers the widget modal in case it fits the window, otherwise lets
    // the user scroll to see it.
    // Positions the widget where the current scroll is.
    centerWidgetModal: function() {
        var $window = $(window);
        var widgetHeight = this.$widgetDiv.height();
        var top, left;
        var marginTop = $window.scrollTop();
        var marginLeft = $window.scrollLeft();

        // Center vertically.
        if ($window.height() > widgetHeight) {
            top = '50%';
            marginTop -= widgetHeight / 2;
        } else {
            top = 0;
            marginTop += 20;
        }

        // Center horizontally.
        if ($window.width() > this.options.width) {
            left = '50%';
            marginLeft -= this.options.width / 2;
        } else {
            left = 0;
            marginLeft += 20;
        }

        this.$widgetDiv.css({
            left: left,
            top: top,
            marginLeft: marginLeft,
            marginTop: marginTop
        });
    },

	jump_to_time:function(event) {
        Koemei.error("Deprecated!")
		event.preventDefault();
		var el = event.currentTarget;
		var time = $(el).attr('data-timestamp');
		var state = this.player_view.player.getState();
		if (state!=='PLAYING') {
			this.player_view.player.play();
		}
		this.player_view.player.seek(time);
	},


	sumon_tooltip:function(event) {
		event.preventDefault();
        var element = event.currentTarget;
        this.hide_tooltips();
        var pos = $(element).position();
        var left = 12;
        var top = 36;
        if ($(element).attr('data-top')!=undefined) {
        	top = $(element).attr('data-top');
        }
        if ($(element).attr('data-left')!=undefined) {
        	left = $(element).attr('data-left');
        }

        var template = JST.Tooltip({
            left: pos.left - left,
            top: pos.top - top,
            title: $(element).attr('data-tooltip-text')
        });
        this.$el.children('.koemei_widget').append(template);

	},

	hide_tooltips:function() {
		$('.tip').remove();
	},

	toogle_time_link:function(event) {
		event.preventDefault();
		var element = event.currentTarget;
		if (!$(element).hasClass('checked')) {
			$(element).addClass('checked');
			$('#kw_link_to_time').val('1');

		} else {

			$(element).removeClass('checked');
			$('#kw_link_to_time').val('0');
		}

	},

    //click on search result: seek to the segment clicked
    search_result_click:function (event) {
        Koemei.log("Koemei.View.Widget#search_result_click");
        Koemei.error("Deprecated!")
		if (this.player_view.player) {
            var element = event.currentTarget;
            if (this.player_view.player.getState() == "PAUSED" || this.player_view.player.getState() == "IDLE") {
                this.player_view.player.play();
        }
        var position = $(element).attr('data-start');
        var pos = Koemei.timestamp_to_seconds(position);
        pos = pos - 1;
        if (pos<0) { pos = 0; }
        Koemei.log("Seeeeeeeek #{pos}");
        this.player_view.player.seek(pos);
        if ($(element).hasClass('open')) {
            $(this).css('white-space', 'nowrap');
            $(this).removeClass('open');
        } else {
            $(element).css('white-space', 'normal');
            $(element).addClass('open');
        }
		}
		this.hide_popups();
        // TODO : close the search result pane and open the transcript pane
        // TODO: cross to clear the search result input field
    },

    //click on a seeker
    seeker_click:function (event) {
        Koemei.error("Deprecated?")
		if (this.player_view.player) {
        var element = event.currentTarget;
        if (this.player_view.player.getState() == "PAUSED" || this.player_view.player.getState() == "IDLE") {
            this.player_view.player.play();
        }
        var position = $(element).attr('data-start');
        var pos = Koemei.timestamp_to_seconds(position);
        pos = pos - 1;
        if (pos<0) { pos = 1; }
        this.player_view.player.seek(pos);
		}
    },

	//search portal functions start here

    //remove the search widget
    remove:function () {
			this.$el.empty();
			this.$el.show();
			this.render_sp();
    },

    //open/close the sort
    sort_mode:function (event) {
        $(event.currentTarget).toggleClass('open');
    },

    //set the sorting mode
    sort_mode_set:function (event) {
    	event.preventDefault();
        var type = $(event.currentTarget).attr('data-type');
        $('.sort_mode').attr('sort_mode', type);
        $('.kw_sort_mode li').removeClass('active');
        var par = $(event.currentTarget).parent();
        $(par).addClass('active');
        var val = $('#search_phrase').val();
        if (val!=='') {
        	$('#kw_search_form').submit();
        }
    },

	trigger_change: function() {
		$('.kw_display-mode').attr('display-mode','kw_result_list');
	},

	expand_list: function(event) {
		event.preventDefault();
		var id = $(event.currentTarget).attr('data-id');
		var start = $(event.currentTarget).attr('data-start');
		$('body').append('<span id="video_click_id" style="display:none">'+id+'</span>');
		$('body').append('<span id="video_start_id" style="display:none">'+start+'</span>');
		$('#btn_grid').click();
	},


	hide_error:function() {
        // TODO (Traian) : restore this
		$('.kw_search_error').fadeOut(100);
	}

});
