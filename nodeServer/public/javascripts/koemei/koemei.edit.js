var transcript;
var player;
var segment_nav_on = true; //tells if the segment navigation is enabled or not
var segmentStep = 40; //the number of processing elements in a single cycle
var resume_playback_interval = -100; //interval when resuming playback
var tolerance = 0.50; // default tolerance for highlighting a low confidence label
var koemei_api_path = 'https://www.koemei.com/REST/';
var plugin_container = null;
var display_speaker = false; // flag to display speaker in the transcript container
// TODO : FIX AUTH!!!
var auth = '';

function Controls()
{
    /**
     * Initialization of the controls container
     */
    this.init = function init(config){
        var save_button = '<a id="save-button" class="'+config.save_button_class+'" href="#">SAVE</a>';
        var publish_button = '<a id="publish-button" class="'+config.publish_button_class+'" href="#">PUBLISH</a>';
      //  if (published) {
        //    publish_button = '<a id="publish-button" class="'+config.publish_button_class+'" href="#">UNPUBLISH</a>';
        //}

        // TODO : this should be dynamic
        var save_info = "Last saved : 12/01/2013 13:30";
        var help_button = '<a class="ud-popup q-mark" data-wrapcss="static-content-wrapper" data-width="600" data-autosize="false" style="margin-top: 295px; right: 10px" id="help_button"></a>';
        /*
        $(".edit-controls").append(save_info).append('&nbsp;').append(save_button).append('&nbsp;').append(publish_button).append('&nbsp;').append(help_button);
		*/
        $("#help_button").click(function(){
            $("#popup-help").dialog('open');
        });
        

        $("#save-button").click(function() {
            var _this = $(this);
            if(window.submitForm || typeof window.submitForm == 'undefined'){
                _this.addClass('btn-disabled');

                try {
                    if(transcript.hasChanges()) {
                        $(transcript).trigger('clearModif');
                        // escape the slashes twice because it seems it goes through 2 parsers (stringify and...?).
                        for (var i=0; i < transcript.content.segments.length; i++) {
                                for (var j=0; j < transcript.content.segments[i].label_seqs.length; j++){
                                    for (var k=0; k < transcript.content.segments[i].label_seqs[j].labels.length; k++)
                                        transcript.content.segments[i].label_seqs[j].labels[k].value=transcript.content.segments[i].label_seqs[j].labels[k].value.replace(/\"/g, "\\\"");
                            }
                        }

                        window.submitForm = false;
                        var seg = JSON.stringify(transcript.content);
                        $('#popup-wait').dialog("open").show().delay(100).queue(function() {
                            var _this = $(this);
                            setTimeout(function(){
                                _this.removeClass('btn-disabled');
                            }, 500);

                            saveTranscript(
                                transcript_uuid,
                                seg,
                                auth,
                                function(){
                                    _this.dialog("close");
                                    $.jnotify("Your modifications have been saved.");
                                    transcript.redisplay();
                                    let_leave = true;
                                },
                                function(){$.jnotify("The server encountered an error while saving your modifications.","error",true);}
                            );
                            $(this).dequeue();
                        });
                    }
                    else
                        console.log("No changes to save");
                    setTimeout(function(){
                        _this.removeClass('btn-disabled');
                    }, 200);
                }
                catch(e){
                    console.error("Error saving modifications : "+e.message+"("+e.lineNumber+")");
                }
            }
            return false;
        });

        $("#publish-button").click(function() {
            var _this = $(this);
            if(window.submitForm || typeof window.submitForm == 'undefined'){
                _this.addClass('btn-disabled');

                try {
                    if (published) {
                        unpublishMedia(media_uuid, auth,
                            function(){
                                $.jnotify("The captions are not published anymore");
                                _this.text('PUBLISH');
                                _this.removeClass('btn-disabled');
                                published = false;
                            },
                            function(){
                                $.jnotify("The server encountered an error while unpublishing.","error",true);
                            }
                        );
                        setTimeout(function(){
                            _this.removeClass('btn-disabled');
                        }, 500);
                    }
                    else {
                        if(transcript.hasChanges()) {
                            $(transcript).trigger('clearModif');
                            // escape the slashes twice because it seems it goes through 2 parsers (stringify and...?).
                            for (var i=0; i < transcript.content.segments.length; i++) {
                                for (var j=0; j < transcript.content.segments[i].label_seqs.length; j++){
                                    for (var k=0; k < transcript.content.segments[i].label_seqs[j].labels.length; k++)
                                        transcript.content.segments[i].label_seqs[j].labels[k].value=transcript.content.segments[i].label_seqs[j].labels[k].value.replace(/\"/g, "\\\"");
                                }
                            }

                            window.submitForm = false;
                            var seg = JSON.stringify(transcript.content);
                            $('#popup-wait').dialog("open").show().delay(100).queue(function() {
                                var _this = $(this);
                                setTimeout(function(){
                                    _this.removeClass('btn-disabled');
                                }, 500);

                                saveTranscript(
                                    transcript_uuid,
                                    seg,
                                        auth,
                                    function(){
                                        _this.dialog("close");
                                            transcript.redisplay();
                                            let_leave = true;
                                    },
                                    function(){$.jnotify("The server encountered an error while saving your modifications.","error",true);}
                                );
                                $(this).dequeue();
                            });
                        }
                        else
                            console.log("No changes to save");

                        publishMedia(media_uuid, auth,
                            function(){
                                $.jnotify("The captions have been published");
                                _this.text('UNPUBLISH');
                                _this.removeClass('btn-disabled');
                                published = true;
                            },
                            function(){
                                $.jnotify("The server encountered an error while publishing.","error",true);
                            }
                        );

                        setTimeout(function(){
                            _this.removeClass('btn-disabled');
                        }, 200);
                    }
                }
                catch(e){
                    console.error("Error publishing media : "+e.message+"("+e.lineNumber+")");
                }
            }
            return false;
        });

        $( "#popup-wait" ).dialog({
            autoOpen: false,
            resizable: false,
            draggable: false,
            modal: true,
            width:300,
            height : 100,
            dialogClass : 'popup-wait'
        });
        $( "#popup-help" ).dialog({
            autoOpen: false,
            resizable: false,
            draggable: false,
            modal: true,
            width:400,
            height : 300,
            dialogClass : 'popup-wait'
        });

    }
    /*
     * Display control panel
     * */
    this.display = function display() {
    }
};

function Transcript(transcript_uuid)
{
    /**
     * Initialization of the transcript container
     * @param {JSON object} the transcript in json format
     */
    this.init = function init(transcript_content) {
        this.content = transcript_content;
        this.current_segment = this.content.segments[0];
        this.current_label = this.current_segment.label_seqs[0].labels[0];
        this.changes = [];
        this.preloader = $('.text-box-holder > div.preloader');
        this.quality = 0;
        //this.initModif();
        //this.allText = '';
    };

    /*
     * Display main center edit panel
     * */
    this.display = function display(callback) {
        var _this = this;
        var h = 0;
        var i = 0;
        var step = 0;
        var div = [];
        var segment;
        this.labelLength = 0;
        this.loadElement = true;
        var start = true;

        $('#transcript_container').html('');

        function eachStep(){
            if(_this.content.segments.length > i){
                segment = _this.content.segments[i];
                div[h++] = '<div class="tr-segment" id="seg_div_'+segment.start+'">';
                div[h++] = '<div class="time" id="st_'+segment.start+'">'+timestamp_to_mmss(segment.start)+'<br/>';
                if (display_speaker)
                    div[h++] = '<span class="speaker">'+segment.speaker+'</span>';
                div[h++] = '</div>';
                div[h++] = '<div class="text-body segment-content" contentEditable="true" ' +
                    'id="s_'+segment.start+'" ' +
                    'seg-id="'+segment.id+'" ' +
                    'seg-start="'+segment.start+'" ' +
                    'seg-end="'+segment.end+'">';

                $.each(segment.label_seqs, function(j, labelseq){
                    if(labelseq.labels.length > 1 && labelseq.confidence != 1) div[h++] = '<div id="l_'+labelseq.labels[0].start+'" class="label '+confidenceLevelColor(labelseq)+' union-label">';

                    $.each(labelseq.labels, function(k, label){
                        if(labelseq.labels.length > 1 && labelseq.confidence != 1){
                            div[h++] = '<span>'+label.value+'</span>';
                            div[h++] = ' ';
                            _this.labelLength++;
                        }
                        else{
                            div[h++] = '<div id="l_'+label.start+'" class="label '+confidenceLevelColor(labelseq)+'">'+label.value+'</div> ';
                            _this.labelLength++;
                        }
                    });
                    if(labelseq.labels.length > 1 && labelseq.confidence != 1) div[h++] = '</div>';
                });
                div[h++] = '</div>';
                div[h++] = '</div>';
                i++;
                if(Math.floor(i/segmentStep) > step){
                    if(start){
                        $('#transcript_container').append(div.join(''));
                        start = false;
                    }
                    else{
                        $('#transcript_container .scroll-hold').append(div.join(''));
                    }
                }
                else{
                    eachStep();
                }
            }
            else{
                if(start){
                    $('#transcript_container').append(div.join(''));
                    start = false;
                }
                else{
                    $('#transcript_container .scroll-hold').append(div.join(''));
                }
            }
        }
        eachStep();
        $(_this).bind('loadNextStep', function(){
            _this.loadElement = true;
            div = [];
            step++;
            eachStep();
        });
    };

    this.redisplay = function redisplay() {
        getTranscript(
            transcript_uuid,
            auth,
            function(transcript_content){
                transcript.init(transcript_content);
                transcript.display();
            }
        );
    }

    /*
     * On click segment handler
     * Change current segment, move playback to clicked label and pause the playback
     * */
    this.onClickSegment = function onClickSegment(start) {
        if(start != this.current_segment.start){
            $('div.segment-content > div.current').removeClass("current");
            segment_nav_on = false;
            this.setCurrentSegment(start);
        }
    }

    /**
     * Check if the transcript has been changed
     */
    this.hasChanges = function hasChanges() {
        var changes = false;
        for (var i=0; i < transcript.content.segments.length; i++) {
            if (transcript.content.segments[i].new_value) {
                changes = true;
                transcript.content.segments[i].label_seqs = []
                transcript.content.segments[i].label_seqs[0] = new Object();
                transcript.content.segments[i].label_seqs[0].id  =1;
                transcript.content.segments[i].label_seqs[0].confidence  =1;
                transcript.content.segments[i].label_seqs[0].labels = transcript.content.segments[i].new_value;
                transcript.content.segments[i].new_value = null;
                //console.log("New segment value : ");
                //console.log(transcript.content.segments[i]);
            }
        }
        return changes;
    }

    /**
     * Initialization Drop Box
     */
    this.initDropBox = function initDropBox(){
        var $this = this;
        var link;
        var segmentContent = $('#transcript_container div.segment-content');
        var segmentContentMap = $('#heatmap_container div.tr-segment');
        var current_segment = $this.current_segment;
        var step = 0;
        var word;
        var currentClick;
        var show = $('input#show');
        var hide = $('input#hide');

        if(show.is(':checked')) $('#main').removeClass('alternatives-off');
        else $('#main').addClass('alternatives-off');

        show.change(function(){
            if(show.is(':checked')) $('#main').removeClass('alternatives-off');
        });
        hide.change(function(){
            if(hide.is(':checked')) $('#main').addClass('alternatives-off');
        });

        $this.createDropBox();

        // processing of words which have alternative
        function startBox(){
            $this.dropBox.css({left: -9999, top:-9999});
            var blockMap = $('#heatmap_container div.tr-segment');
            var blockContent = $('#transcript_container div.segment-content');
            var i = 0;

            function eachStep(){
                if(blockContent.length > i){
                    $('.preloader .total > span').text((i/(blockContent.length/36)+64).toFixed(0)+'%' );

                    blockContent.eq(i).find('.label').each(function(){
                        var hold = $(this);
                        hold.unbind('click').click(function(){
                            word = $(this).text();
                            currentClick = $(this);
                            $this.dropBox.css({left: -9999, top:-9999});
                            var _this = this;
                            player.pause(true);
                            $this.segmentClick = true;
                            var value = hold.text();
                            var list = false;
                            var _time;
                            $(window).trigger('clearDropBoxTimeout');

                            if(!$('#main').hasClass('alternatives-off')) list = $this.getSuggestion(hold.attr('id').slice(2), hold.parent().attr('seg-start'));

                            if(list){
                                $this.dropBox.find('> ul').empty();
                                $.each(list.suggestions, function(i, word){
                                    $this.dropBox.find('> ul').append($('<li><a href="#">'+word+'</a></li>'));
                                });

                                // show a drop-down box
                                setTimeout(function(){
                                    $this.dropBox.css({
                                        left: $(_this).offset().left,
                                        top: $(_this).offset().top + 25
                                    }).hover(function(){
                                            if(_time) clearTimeout(_time);
                                        }, function(){
                                            _time = setTimeout(function(){
                                                $this.dropBox.css({left: -9999, top:-9999});
                                            }, dropBoxTimeout);
                                        });

                                    $(_this).hover(function(){
                                        if(_time) clearTimeout(_time);
                                    }, function(){
                                        _time = setTimeout(function(){
                                            $this.dropBox.css({left: -9999, top:-9999});
                                        }, dropBoxTimeout);
                                    });
                                    $(window).bind('clearDropBoxTimeout', function(){
                                        if(_time) clearTimeout(_time);
                                    });
                                }, 100);

                                reLink(list, hold);
                                $this.onClickSegment(parseInt($(this).attr("id").slice(2))+1);
                                if($this.current_segment != current_segment){
                                    current_segment = $this.current_segment;
                                }
                            }
                            else{
                                $this.onClickSegment(parseInt($(_this).attr("id").slice(2))+1);
                                $('#l_'+parseInt($(_this).attr("id").slice(4))).trigger('click');
                            }
                            return false;
                        });
                        $('body').unbind('keyup').keyup(function(){
                            if(typeof currentClick != 'undefined' && word != currentClick.text()){
                                currentClick.removeClass('orange_background');

                            }
                        });
                    });
                    blockMap.eq(i).find('.label').each(function(){
                        var hold = $(this);
                        hold.unbind('click').click(function(){

                            word = $(this).text();
                            currentClick = $(this);
                            $this.dropBox.css({left: -9999, top:-9999});
                            var _this = this;
                            player.pause(true);
                            $this.segmentClick = true;
                            var value = hold.text();
                            var _time;
                            $(window).trigger('clearDropBoxTimeout');

                            if (!hold.hasClass('hm_') && !hold.hasClass('hm_orange_background')) {
                                $this.onClickSegment(parseInt($(_this).attr("id").slice(2))+1);
                                $('#l_'+parseInt($(_this).attr("id").slice(4))).trigger('click');
                            }
                            else{
                                $this.moveScrollToPosition($('#l_'+parseInt($(_this).attr("id").slice(4))).parents('.tr-segment').position().top, function(){
                                    $('#l_'+parseInt($(_this).attr("id").slice(4))).trigger('click');
                                });
                            }

                            return false;
                        });
                        $('body').unbind('keyup').keyup(function(){
                            if(typeof currentClick != 'undefined' && word != currentClick.text()){
                                currentClick.removeClass('orange_background');
                            }
                        });
                    });
                    i++;
                    if(Math.floor(i/segmentStep) > step){
                        step++;
                        //setTimeout(function(){
                        eachStep();
                        //}, 100);
                    }
                    else{
                        eachStep();
                    }
                }
                else{
                    /*
                     * Fix for issues #245 & #298 : The playback position is updated when clicking in the space between 2 words, the current word is after the space
                     */
                    segmentContent.unbind('click').click(function(e){
                        var flag = true;
                        $(this).find('div.label').each(function(){
                            if($(this).offset().left > e.pageX && ($(this).offset().top < e.pageY && $(this).offset().top + $(this).outerHeight() > e.pageY) && flag){
                                flag = false;
                                $(this).trigger('click');
                            }
                        });
                        if(flag){
                            //$(this).find('div.label:eq(0)').trigger('click');
                            $this.onClickSegment(parseInt($(this).find('div.label:eq(0)').attr("id").slice(2))+1);
                        }
                        return false;
                    });
                    segmentContent.parent().unbind('click').click(function(){
                        //$(this).find('div.label:eq(0)').trigger('click');
                        $this.onClickSegment(parseInt($(this).find('div.label:eq(0)').attr("id").slice(2))+1);
                        return false;
                    });
                    segmentContentMap.unbind('click').click(function(e){
                        var _t = this;
                        player.pause(true);
                        var flag = true;
                        $(this).find('div.label').each(function(){
                            if($(this).offset().left > e.pageX && ($(this).offset().top < e.pageY && $(this).offset().top + $(this).outerHeight() > e.pageY) && flag){
                                flag = false;
                                $(this).trigger('click');
                            }
                        });
                        if(flag){
                            $this.moveScrollToPosition($('#l_'+parseInt($(this).find('div.label:eq(0)').attr("id").slice(4))).parents('.tr-segment').position().top, function(){
                                $this.onClickSegment(parseInt($(_t).find('div.label:eq(0)').attr("id").slice(4))+1);
                            });
                        }
                        return false;
                    });
                    segmentContentMap.parent().unbind('click').click(function(){
                        player.pause(true);
                        $this.onClickSegment(parseInt($(this).find('div.label:eq(0)').attr("id").slice(4))+1);
                        return false;
                    });
                    $this.preloader.fadeOut(300);
                }
            }
            eachStep();
            $($this).bind('nextDropBox', function(){
                segmentContent = $('#transcript_container div.segment-content');
                segmentContentMap = $('#heatmap_container div.tr-segment');
                blockMap = $('#heatmap_container div.tr-segment');
                blockContent = $('#transcript_container div.segment-content');
                step++;
                eachStep();
            });
        }
        startBox();

        // processing the selected alternative
        function reLink(list, hold){
            link = $this.dropBox.find('a');

            link.unbind('click').click(function(){
                var active = link.index(this);
                var lenght = list.alt_label_seqs[active].labels.length;
                var d = list.labels[0].start;
                var k;
                var text = '';

                // replacement the values on an alternative

                $.each(list.labels, function(i, label){
                    text = '';
                    $.each(list.alt_label_seqs[active].labels, function(i2, label2){
                        if (label2) {
                            text += '<span>' + label2.value + '</span> ';
                        }
                        else{
                            $('#l_'+label.start).remove();
                            $('#lhm_'+label.start).remove();
                        }
                    });

                });

                function addEvents2(divs) {
                    for(var i=0; i<divs.length; i++) {
                        divs[i].innerHTML = i
                        divs[i].onclick = function(x) {
                            return function() { alert(x) }
                        }(i)
                    }
                }

                text.substring(0, text.length-2);

                $($this).trigger('addModif', {
                    startHtml: $('#l_'+list.labels[0].start).html(),
                    startId: list.labels[0].start,
                    endHtml: text,
                    endId: list.alt_label_seqs[active].labels[0].start,
                    active: active
                });

                $('#l_'+list.labels[0].start).removeClass('union-label').empty().append(text).attr('id', 'l_'+list.alt_label_seqs[active].labels[0].start);
                $('#lhm_'+list.labels[0].start).removeClass('hm_orange_background').empty().addClass('hm_').append(text).attr('id', 'lhm_'+list.alt_label_seqs[active].labels[0].start);

                $this.dropBox.css({left: -9999, top:-9999});

                // reverse all alternatives for the word
                $this.content.segments[list.segment].label_seqs[list.id].confidence = "1";
                var last = $this.content.segments[list.segment].label_seqs[list.id].labels;
                $this.content.segments[list.segment].label_seqs[list.id].labels = list.alt_label_seqs[active].labels;
                $this.content.segments[list.segment].label_seqs[list.id].alt_label_seqs[active].labels = last;
                //delete $this.content.segments[list.segment].label_seqs[list.id].alt_label_seqs;

                hold.trigger('keyup');
                $this.updateSegment();
                setTimeout(function(){
                    step = 0;
                    //startBox();
                }, 300);

                return false;
            });
        }
    };
    /**
     * Create drop-down box
     */
    this.createDropBox = function createDropBox(){
        var $this = this;
        $this.dropBox = $('<div class="drop-box"><ul><ul></div>');

        $("body")
            .append($this.dropBox)
           /* .mousewheel(function(e){ // hide the drop-down box with a mousewheel over the content
                $this.dropBox.css({left: -9999, top:-9999});
            })*/
            .click(function(){ // hide the drop-down box when you click a drop-down block aisles
                if(!$this.dropBox.hasClass('hovering')){
                    $this.dropBox.css({left: -9999, top:-9999});
                }
            });

        $this.dropBox.hover(function(){
            $this.dropBox.addClass('hovering');
        }, function(){
            $this.dropBox.removeClass('hovering');
        });
    };

    /**
     * Get suggestion
     * @param label_id
     * @param segment_id
     */
    this.getSuggestion = function getSuggestion(label_id, segment_id){
        var $this = this;
        var k = 0;
        var obj = false;
        var word = false;
        var suggestion = [];
        var new_segment, new_id;
        var text = '';

        // choose the necessary sigment
        while(k <= $this.content.segments.length && !obj){
            if($this.content.segments[k].start == segment_id){
                obj = $this.content.segments[k];
                new_segment = k;
            }
            k++;
        }
        $this.current_segment = obj;

        k = 0;

        // find our word
        while(k < obj.label_seqs.length && !word){
            $.each(obj.label_seqs[k].labels, function(i, label){
                if(label.start == label_id){
                    word = obj.label_seqs[k];
                    new_id = k;
                }
            });
            k++;
        }

        $this.current_label = obj.label_seqs[0].labels[0];
        if(word.alt_label_seqs){
            for (k = 0; k < word.alt_label_seqs.length; k++){
                text = '';
                for (var i = 0; i < word.alt_label_seqs[k].labels.length; i++){
                    text += word.alt_label_seqs[k].labels[i].value + ' ';
                };
                suggestion.push(text);
            };
            // if there is have alternatives, then return the object
            return 	{
                labels: word.labels, // object with the current values
                alt_label_seqs: word.alt_label_seqs, // object with the alternatives
                suggestions: suggestion, // array of alternatives (words)
                segment: new_segment,
                id: new_id
            } ;
        }
        else{
            return false; // if there is no alternatives
        }
    };

    /*
     * Create subtitles on the fly to display in the player
     * */
    this.createCurrentSegmentSubtitles = function createCurrentSegmentSubtitles(obj){
        var srt = [];
        var current_srt_segment = "";
        var srt_idx = 0;
        var stime = null;
        var etime = null;
        var current_label = null;
        var maxlen = 40;

        // loop label_seq
        for (var labseq_idx=0;labseq_idx< obj["label_seqs"].length;labseq_idx++){
            // loop labels
            for (var labs_idx=0;labs_idx< obj["label_seqs"][labseq_idx]["labels"].length;labs_idx++){
                current_label = obj["label_seqs"][labseq_idx]["labels"][labs_idx];
                // if end of current_srt_segment, display new
                if(stime != null
                    && etime != null
                    && (current_srt_segment.trim().length+current_label["value"].trim() >= maxlen || etime-stime > 300)
                    ) {
                    srt.push({
                        start: stime,
                        end: etime,
                        text: current_srt_segment.trim()
                    });
                    current_srt_segment = "";
                }

                // add label value to current_srt_segment
                if(current_srt_segment.trim().length ==0){
                    stime = current_label["start"];
                    current_srt_segment = current_label["value"].trim();
                }
                else
                    current_srt_segment += " "+current_label["value"].trim();

                etime = current_label["end"];
                current_label= null;
            }
        }

        if (current_srt_segment.length > 0) {
            srt.push({
                start: stime,
                end: etime,
                text: current_srt_segment.trim()
            });
        }

        this.currentSubtitles = srt;
    }

    /** Handle current segment/label change
     * @param {Integer} time : time in millisecs of the playback position
     * @return
     */
    this.setCurrentSegment = function setCurrentSegment(time){
        try {
            //console.log("SCS"+time+"|startfrom:"+this.startFrom+"| cs.start"+this.current_segment.start)
            // handle subtitles and #245
            var lastTime = 0;

            if(this.startFrom != this.current_segment.start){
                this.createCurrentSegmentSubtitles(this.current_segment);
                for (var i = 0; i < this.currentSubtitles.length; i++){
                    if(time > this.currentSubtitles[i].start && time < this.currentSubtitles[i].end){
                        $('#subtitles').text(this.currentSubtitles[i].text);
                        lastTime = this.currentSubtitles[i].end;
                    }
                };
                $('.current-segment').removeClass('current-segment');
                // if segment dirty, update it
                if(this.current_segment.dirty) this.updateSegment();

                // get the corresponding segment from json
                this.current_segment = this.getSegment(time);
                if(!this.segmentClick)
                    this.moveScrollToPosition($('#s_'+this.current_segment.start).parents('div.tr-segment').position().top);
                // highlight and focus on the corresponding div
                //console.log('#s_'+this.current_segment.start);
                $('#s_'+this.current_segment.start+', #shm_'+this.current_segment.start).addClass('current-segment');
                $('#s_'+this.current_segment.start).focus();
                this.startFrom = this.current_segment.start;

                //move custom Scroll

            }
            else{
                if(time > lastTime){
                    for (var i = 0; i < this.currentSubtitles.length; i++){
                        if(time > this.currentSubtitles[i].start && time < this.currentSubtitles[i].end){
                            $('#subtitles').text(this.currentSubtitles[i].text);
                            lastTime = this.currentSubtitles[i].end;
                        }
                    };
                }
            }
        }
        catch (err){
            console.err("Error setting current segment : "+err.message+"("+err.lineNumber+")");
        }

        //console.log("SetCurrentSegment : time="+time+" - current_segment : ("+this.current_segment.id+","+this.current_segment.start+","+this.current_segment.end+") current_label : ("+this.current_label.id+","+this.current_label.start+","+this.current_label.end+")");
        try{
            // check segment change
            if(time <= this.current_segment.start || time >= this.current_segment.end){
                $('.current-segment').removeClass('current-segment');

                // if segment dirty, update it
                if(this.current_segment.dirty)
                    this.updateSegment();

                // get the corresponding segment from json
                this.current_segment = this.getSegment(time);

                // highlight and focus on the corresponding div
                $('#s_'+this.current_segment.start+', #shm_'+this.current_segment.start).addClass('current-segment');
                $('#s_'+this.current_segment.start).focus();
            }
            // check label change

            // get the corresponding label from json
            this.new_label = this.getLabel(time);
            if($('#l_'+this.new_label.start).length > 0){
                $('#l_'+this.current_label.start).removeClass("current");
                this.current_label = this.new_label;
                SelectText('l_'+this.current_label.start);
                $('#l_'+this.current_label.start).addClass("current");
            }
        }
        catch (err){
            console.err("Error setting current segment : "+err.message+"("+err.lineNumber+")");
        }
        //console.log("SetCurrentSegment after : time="+time+" - current_segment : ("+this.current_segment.id+","+this.current_segment.start+","+this.current_segment.end+") current_label : ("+this.current_label.id+","+this.current_label.start+","+this.current_label.end+")");

    };

    /**
     * Get the segment corresponding to the parameter time
     * @param time : the time in milliseconds
     * */
    this.getSegment = function getSegment(time){
        var return_segment = this.current_segment;
        $.each(this.content.segments, function(i, segment){
            if(parseInt(segment.start)<=parseInt(time) && parseInt(segment.end)>parseInt(time)){
                return_segment = segment;
                return false;
            }
        });
        return return_segment;
    };

    /**
     * Get the label corresponding to the parameter time
     * */
    this.getLabel = function getLabel(time){
        if (time < 100) var return_label = this.current_segment.label_seqs[0].labels[0];
        else var return_label = this.current_label;
        $.each(this.current_segment.label_seqs, function(i, label_seq){
            $.each(label_seq.labels, function(j, label){
                if(parseInt(label.start)<=parseInt(time) && parseInt(label.end)>=parseInt(time)){
                    return_label = label;
                    return false;
                }
            });
        });
        return return_label;
    };

    /**
     * Get the label sequence corresponding to the parameter time
     * */
    this.getLabelSeq = function getLabelSeq(time){
        var return_label_seq = this.current_segment.label_seqs[0];
        $.each(this.current_segment.label_seqs, function(i, label_seq){
            $.each(label_seq.labels, function(j, label){
                if(parseInt(label.start)<=parseInt(time) && parseInt(label.end)>=parseInt(time)){
                    return_label_seq = label_seq;
                    return false;
                }
            });
        });
        return return_label_seq;
    };

    /** Move scroll to position
     * @param top : top of scroll,
     * @param callback : callback function
     * */
    this.moveScrollToPosition = function moveScrollToPosition(top, callback){
        var $this = this;
        if(top-200 > $('#transcript_container .scroll-content').outerHeight() - $('#transcript_container').outerHeight()) top = $('#transcript_container .scroll-content').outerHeight() - $('#transcript_container').outerHeight() + 200;
        if(-top + 200 < 0){
            $('#transcript_container .scroll-content').animate({top: -top + 200}, 300, function(){
                //refresh custom Scroll
                $('#transcript_container').customScrollV();
                if(typeof callback == 'function') callback.call();
            });
        }
        else{
            $('#transcript_container .scroll-content').animate({top: 0}, 300, function(){
                //refresh custom Scroll
                $('#transcript_container').customScrollV();
                if(typeof callback == 'function') callback.call();
            });
        }
    };

}

function Player(transcript)
{
    this.transcript = transcript;
    this.player = jwplayer();

    this.init = function() {
        this.initShortcuts(this.player);
        this.initControls();
        this.initListeners(this.player, this.transcript);
    };

    this.initShortcuts = function initShortcuts(player){
        var isCtrl = false;
        var isShift = false;
        var flag = true;
        var win = $('html').hasClass('win');

        /* Play/pause shortcut */
        $(document).keyup(function(e){
            var code = e.keyCode ? e.keyCode : e.which;

            if(((code == 17 && win) || (code == 91 && !win) || code == 224) && flag) { //Ctrl / command keycode

                //console.log("CTRL pressed, player state : "+player.getState());
                e.preventDefault();

                if (segment_nav_on) { //play or pause normal mode
                    player.play();
                }else{
                    if (player.getState() == "PAUSED" || player.getState() == "IDLE") { //if we navigate through segment manually we have to adjust the player position
                        if(transcript.current_segment.dirty)
                            transcript.updateSegment();
                        var position = Math.ceil(transcript.current_label.start -2000 / 100);
                        player.seek(position/100);

                    }else if(player.getState() == "PLAYING"){
                        player.pause();
                    }
                    segment_nav_on = true; //we disable the segment navigation so that the next time video will just toggle playback
                }
                $('#l_'+transcript.current_label.start).focus();
            }
        });
        $(document).bind('keyup keydown keypress', function(e){
            console.log($(e.target).text().length);
        });

        /* Enter shortcut*/
        $(document).keydown(function(e){
            var code = e.keyCode ? e.keyCode : e.which;
            if(code == 13) { //Enter keycode
                e.preventDefault();
                console.log('Enter pressed');
                if(transcript.current_segment.dirty)
                    transcript.updateSegment();
            }
        });

        /* Next / previous segment shortcut */
        $(document).keyup(function (e) {
            var code = e.keyCode ? e.keyCode : e.which;
            if (code == 16) {
                isShift = false;
                flag = true;
            }
        }).keydown(function (e) {
                var code = e.keyCode ? e.keyCode : e.which;

                if(code == 16) isShift=true;
                if(code == 9) {
                    transcript.dropBox.css({left: -9999, top:-9999});
                    flag = false;
                    var segments = $('#transcript_container .segment-content');
                    var current_segment = segments.index(segments.filter('.current-segment'));
                    if(current_segment < 0) current_segment = -1;
                    if(isShift){
                        current_segment--;
                        if(current_segment < segments.length){
                            transcript.moveScrollToPosition(segments.eq(current_segment).parents('div.tr-segment').position().top, function(){
                                transcript.setCurrentSegment(segments.eq(current_segment).attr('seg-start')/1);
                                flag = true;
                            });
                            //player.seek(Math.ceil(segments.eq(current_segment).attr('seg-start') / 100));
                            player.pause(true);
                        }
                    }
                    else{
                        current_segment++;
                        if(current_segment < segments.length){
                            transcript.moveScrollToPosition(segments.eq(current_segment).parents('div.tr-segment').position().top, function(){
                                transcript.setCurrentSegment(segments.eq(current_segment).attr('seg-start')/1);
                                flag = true;
                            });
                            //player.seek(Math.ceil(segments.eq(current_segment).attr('seg-start') / 100));
                            player.pause(true);
                        }

                    }

                    return false;
                }
            });

        // next/previous word with low confidence (i.e. next/previous red underlined word), lets use"ctrl + right/left arrow
        $(document).keyup(function (e) {
            var code = e.keyCode ? e.keyCode : e.which;

            if ((code == 17 && win) || (code == 91 && !win)) {
                isCtrl = false;
                flag = true;
            }
        }).keydown(function (e) {
                var code = e.keyCode ? e.keyCode : e.which;

                if((code == 17 && win) || (code == 91 && !win)) isCtrl=true;
                if(code == 39 && isCtrl || code == 37 && isCtrl) {
                    transcript.dropBox.css({left: -9999, top:-9999});
                    flag = false;
                    var current = $('#transcript_container .current'); // does this line do something?
                    var label = $('#transcript_container .label');
                    var current = label.index(label.filter('.current'));

                    if(code == 39){
                        while(current < label.length){
                            current++;
                            if(label.eq(current).hasClass('orange_background')) break;
                        }
                        if(current < label.length)
                            transcript.moveScrollToPosition(label.eq(current).parents('div.tr-segment').position().top, function(){
                                label.eq(current).trigger('click');
                            });
                        flag = true;
                    }
                    else{
                        while(current > 0){
                            current--;
                            if(label.eq(current).hasClass('orange_background')) break;
                        }
                        if(current > 0)
                            transcript.moveScrollToPosition(label.eq(current).parents('div.tr-segment').position().top, function(){
                                label.eq(current).trigger('click');
                            });
                        flag = true;
                    }

                    return false;
                }
            });
    };


    this.initControls = function initControls(){
        // init custom scroll
        
        $('#transcript_container').customScrollV({
            lineWidth: 7,
            afterMouseWheel: function(){
                if(typeof transcript == 'object' && transcript.dropBox){
                    transcript.dropBox.css({left: -9999, top:-9999});
                }
            }
        });
    };

    this.initListeners = function initListeners(player, transcript){
        player.onTime(function(event){
            //console.log("Player OnTime pos : "+player.getPosition()+" / "+parseInt(event.position*100));
            if(parseInt(event.position*100) != 0) transcript.setCurrentSegment(parseInt(event.position*100), true);
        });
        player.onSeek(function(event){
            var log = "Player OnSeek ---- event.offset : "+ event.offset+" - event.position : "+event.position+" - player.getPosition : "+player.getPosition();
            //transcript.setCurrentSegment(event.offset*100);
            //console.log(log+"\n after setCurrentSegment ---- event.offset : "+ event.offset+" - event.position : "+event.position+" - player.getPosition : "+player.getPosition()+"\n seg_nav_on : "+segment_nav_on);

            if(!segment_nav_on) {
                segment_nav_on = false;
            }
        });
        player.onPlay(function(event){
            $('.control-column .play-btn').addClass('player-on');
            transcript.dropBox.css({left: -9999, top:-9999});
            transcript.segmentClick = false;
            //console.log("Player OnPlay current_label : "+transcript.current_label.start);

            /*
             * When the user clicks on a word, the playback is set
             * at the beginning of the word and is paused. So when the user resumes the
             * playback, it starts resume_playback_interval/100 seconds before the beginning of the word that was clicked.
             * (or at start of segment if start of label is < 2s from start of segment)
             * after pausing and hitting play again
             */
            var pos_to_seek = 0;
            if (!segment_nav_on) { //play or pause normal mode
                segment_nav_on = true;

                if(parseInt($('#l_'+transcript.current_label.start).parent().attr('seg-start')) > parseInt(transcript.current_label.start)+resume_playback_interval){
                    pos_to_seek = Math.ceil($('#l_'+transcript.current_label.start).parent().attr('seg-start') / 100);
                }
                else{
                    pos_to_seek = Math.ceil((parseInt(transcript.current_label.start)+resume_playback_interval) / 100);
                }
                player.seek(pos_to_seek);
            }
        });

        player.onPause(function(event){
            segment_nav_on = false;
            $('.control-column .play-btn').removeClass('player-on');
        });

        $('.control-column .play-btn').click(function(){
            if(!$(this).hasClass('player-on')){
                $(this).addClass('player-on');
                player.play();
            }
            else{
                $(this).removeClass('player-on');
                player.pause(true);
            }
            return false;
        });

        var getSegmentFromHtml = this.getSegmentFromHtml;

        // add onchange behaviour
        
        //NOTE: THIS HAS BEEN SEVERELY MODIFIED, 2 live binders were removed
        $('[contenteditable]').focus( function() {
            var $this = $(this);
            $this.data('before', $this.text());
            return $this;
        }).blur( function() {
                var $this = $(this);
                if ($this.data('before') !== $this.text()) {
                    $this.data('before', $this.html());
                    var id = parseInt($this.attr("seg-id"))-1;
                    transcript.content.segments[id].new_value = getSegmentFromHtml($this);
                    if(transcript.content.segments[id].dirty != 1) {
                        transcript.content.segments[id].dirty = 1;
                        //$('#st_'+transcript.content.segments[id].start).append("*");
                        //console.log("Segment marked as dirty : "+id);
                    }
                    $this.trigger('change');
                }
                return $this;
            });
    };

    this.getSegmentFromHtml = function getSegmentFromHtml(segment){
        // get segment length
        var segment_length = parseInt(segment.attr('seg-end')) - parseInt(segment.attr('seg-start'));

        var segment_text = segment.text().trim();
        var new_segment = [];
        try{
            var labels = segment_text.split(/\s+/);
            var label_length = parseInt(segment_length / labels.length);
            var label_start = parseInt(segment.attr('seg-start'));
            var label_index = 1;

            for (var i in labels) {
                if (labels[i].trim() !== '') {
                    var label = new Object();
                    label.start = label_start;
                    label.end = label_start + label_length;
                    /* We could remove the confidence here? */
                    label.confidence = 1;
                    label.id = label_index;
                    label.value = labels[i].trim();
                    label_start = label.end;
                    label_index++;
                    new_segment.push(label);
                }
            }
            if (new_segment.length == 0) {
                var label = new Object();
                label.start = parseInt(segment.attr('seg-start'));
                label.end = label_start + label_length;
                /* We could remove the confidence here? */
                label.confidence = 1;
                label.id = label_index;
                label.value = " ";
                new_segment.push(label);
            }
        }
        catch (err){
            console.err("Error getting segment from html : "+err.message+"("+err.lineNumber+")");
        }
        //console.log("New segment : ");
        //console.log(new_segment);
        return new_segment;
    }
}

/**
 * Return the class name with the corresponding background color according to confidence level
 * @param {String} label_seq
 * @return {String} css class
 */
function confidenceLevelColor(label_seq){
    var confidence = parseFloat(label_seq.confidence);
    var label_color = "";

    if(confidence < tolerance){
        label_color='orange_background';
    }
    return label_color;
}

/**
 * Highlight text in a html document
 * @param {string} the id of the element to hisghlight
 */
function SelectText(element) {
    var doc = document;
    var text = doc.getElementById(element);
    if (doc.body.createTextRange) {
        var range = document.body.createTextRange();
        range.moveToElementText(text);
        range.select();
    } else if (window.getSelection) {
        var selection = window.getSelection();
        var range = document.createRange();
        if (text) {
            range.selectNodeContents(text);
            selection.removeAllRanges();
            selection.addRange(range);
        }
    }
};