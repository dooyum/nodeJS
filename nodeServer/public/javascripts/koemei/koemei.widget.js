/**
 * Koemei edit plugin for JWPlayer
 * @version 0.7
 */

(function(jwplayer){

    var plugin_container = null;

    /**
     * Build the html div template for the plugin
     * @param {JWPlayer} player to apply the template to
     * @param {Config} config object containing the different configuration options
     * @param {HTML element} div containing the plugin template
     */
    var template = function(player, config, div) {

        /**
         * Initialization of the plugin
         * @param {response} : the response sent by the server
         */
        function initPlugin(transcript_content){
            transcript.init(transcript_content);
            transcript.display();
            transcript.initDropBox();
            player = new Player(transcript);
            player.init();

            controls = new Controls();
            controls.init(config);
        }

        /**
         * Setup the div template containing the plugin
         * @param {event} evt (not used)
         */
        function setup(evt) {
            try {
                div.innerHTML = config.text;
                plugin_container = div;
                var transcript_container = '<div class="text-box" id="transcript_container" style="height:100%"></div>';
                var heatmap_container = '<div class="heatmap-column" style="display:none">'+ '<div class="wrap" style="height:10%;top:37%;"></div>'+ '<div class="heatmap-wrap">'+ '<div class="text-box" id="heatmap_container">'+        '</div>'+        '</div>'+        '</div>';
                var controls_container = '<div class="edit-controls"></div>';
                var subtitles_container = '<div id="subtitles"></div>';
                //var savewait_container = '<div id="popup-wait" class="dialog-window dialog-message-upload-progress">Please wait... We are saving your modifications, this may take some time if your media is long.<br /><img src="https://static.koemei.com/images/loading.gif" alt="Please wait" /></div>';
                var savewait_container = "";
                // TODO : change this design
               // var help_container = '<div id="popup-help" class="dialog-window dialog-message-upload-progress">Video here<br />>A question ? <a href="#">contact us</a></div>';
                var help_container = "";
                plugin_container.innerHTML = transcript_container + heatmap_container + controls_container+subtitles_container+savewait_container+help_container;

				console.log("finished setting up");

                transcript = new Transcript(config.transcript_uuid, config.auth);
                //transcript = new Transcript();
                //$('.custom-scroll').customScrollV({lineWidth: 7});
                auth = config.auth;
                getTranscript(config.transcript_uuid, config.auth, initPlugin);
            }
            catch(err){
                //console.err("Error in Koemei plugin setup : "+err.message+"("+err.lineNumber+")");
                console.log("Error in Koemei plugin setup : "+err.message+"("+err.lineNumber+")");
            }
        };

        player.onReady(setup);

        /**
         * Resize the div containing the template plugin
         * @param {integer} width
         * @param {integer} height
         */
        this.resize = function(width, height) {
            _style({
                position : 'relative',
                background: 'white',
                color: 'black',
                height: config.height,
                width: config.width,
            });
        };

        /**
         * Apply style to the template div
         * @param object containing the style to apply to the div
         * @private
         */
        function _style(object) {
            for(var style in object) {
                div.style[style] = object[style];
            }
        };
    };

    jwplayer().registerPlugin('koemei.widget', template);

})(jwplayer);