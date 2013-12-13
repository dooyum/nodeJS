//var transcript_uuid = '';
       /*
        var media_uuid = 'ef919104-4352-49b1-80c5-a419383a621e';
        var username = 'testuser@koemei.com';
        var password = '<CHANGEME>';
        var auth = make_base_auth(username,password);
        var static_cdn_path = 'https://d18embnwuxbhpk.cloudfront.net';
        var usermedia_cdn_path = 'rtmp://usermedia.koemei.com/cfx/st/';
        var media_streaming_path = '';
        var published = false;*/

    // get the media infos
    //getMedia(media_uuid, auth, function(media_info){
      //  transcript_uuid = media_info['current_transcript_uuid'];
       // media_streaming_path = media_info.streaming_url;
       // published = media_info.publish_status;

        try {
            // Define player with koemei.widget plugin
            player = jwplayer('player').setup({
                //'modes': [
                //        {type: 'flash', src: '/jwplayer/player.swf'}
                //],
                //'provider': 'rtmp',
                //'streamer': 'serveVideo/',
                file: '/serveVideo/big_buck_bunny.ogv',
                //'skin': '/jwplayer/koemei.zip',
                'width': '440',
                'height': '360',
                plugins: {
                    '/javascripts/koemei/koemei.widget.js': {
                        text: 'no transcript loaded',
                        position : 'bottom',
                        media_uuid : "test",
                        transcript_uuid : "test",
                        //auth : auth,
                        width : '600px', // TODO : allow this parameter to be changed (inner div width is currently not changed!)
                        height: '300px',
                        save_button_class : 'btn-2',
                        publish_button_class : 'btn-2'
                    }
                }
            });
        }
        catch(err){
            console.error("Error in setting up koemei player : "+err.message+"("+err.lineNumber+")");
        }
   // });