/**
 * Resources files, this file makes requests to Koemei API
 */

/*
var xhr = new easyXDM.Rpc({
    remote: "https://www.koemei.com/cors/"
}, {
    remote: {
        request: {} // request is exposed by /cors/
    }
});
*/

/**
 * Get the specified media
 * @param {String} media uuid
 * @return {JSON object} the media
 */
function getMedia(media_uuid, auth, callback){
    try {
    	$.ajax({
			dataType: "json",
			url: "/serveVideo/big_buck_bunny.ogv"
		}).done(function( data ) {
			console.log(data);
		  	callback(data);
		});
    	/*
    	/*
        xhr.request({
            url: "../REST/media/"+media_uuid,
            method: "GET",
            headers: {
                "Authorization" : auth,
                "Accept" : 'application/json'
            }
        }, function(response) {
            callback(jQuery.parseJSON(response.data).media_item);
        }, function(response){
            console.error("Error in getMedia : "+response);
        });*/
    }
    catch(err){
        console.error("Error in getMedia : "+err.message+"("+err.lineNumber+")");
    }
}

/**
 * Get the specified transcript
 * @param {String} transcript uuid
 * @return {JSON object} the transcript
 */
function getTranscript(transcript_uuid, auth, callback){
    try {
    	console.log("getting");
		
		$.ajax({
			dataType: "json",
			url: "/javascripts/koemei/recreate-sample.json"
		}).done(function( data ) {
			console.log(data);
		  	callback(data);
		});
    	/*
        xhr.request({
            url: "../REST/transcripts/"+transcript_uuid,
            method: "GET",
            headers: {
                "Authorization" : auth,
                "Accept" : 'application/json'
            }
        }, function(response) {
            callback(jQuery.parseJSON(response.data));
        }, function(response){
            console.error("Error in getTranscript : "+response);
        });
        */
    }
    catch(err){
        //console.error("Error in getTranscript : "+err.message+"("+err.lineNumber+")");
        console.log("Error in getTranscript : "+err.message+"("+err.lineNumber+")");
    }
}

/**
 * Save the transcript to the server
 * @param {string} transcript unique identifier
 * @param {string} data of the transcript content in json form
 * @param {callback} success callback function
 * @param {callback} error callback function
 */
function saveTranscript(transcript_uuid, data, auth, callback) {
    xhr.request({
        url: "../REST/transcripts/"+transcript_uuid,
        method: "PUT",
        data : {transcript_content : data},
        timeout : 500000,
        headers: {
            "Authorization" : auth,
            "Accept" : 'application/json'
        }
    }, function(response) {
        callback(jQuery.parseJSON(response.data));
    }, function(response){
        console.error("Error in saveTranscript : "+response);
    });
}


/**
 * Publish media current transcript
 * @param {String} media uuid
 * @return {String} status code
 */
function publishMedia(media_uuid, auth, callback, success_callback_url, error_callback_url){
    try {
        xhr.request({
            url: "../REST/media/"+media_uuid+"/publish",
            method: "PUT",
            headers: {
                "Authorization" : auth,
                "Accept" : 'application/json'
            },
            data : {
                success_callback_url : success_callback_url,
                error_callback_url : error_callback_url
            }
        }, function(response) {
            callback(jQuery.parseJSON(response.data));
        }, function(response){
            console.error("Error in publishMedia : "+response);
        });
    }
    catch(err){
        console.error("Error in publishMedia : "+err.message+"("+err.lineNumber+")");
    }
}

/**
 * Publish media current transcript
 * @param {String} media uuid
 * @return {String} status code
 */
function unpublishMedia(media_uuid, auth, callback, success_callback_url, error_callback_url){
    try {
        xhr.request({
            url: "../REST/media/"+media_uuid+"/unpublish",
            method: "PUT",
            headers: {
                "Authorization" : auth,
                "Accept" : 'application/json'
            },
            data : {
                success_callback_url : success_callback_url,
                error_callback_url : error_callback_url
            }
        }, function(response) {
            callback(jQuery.parseJSON(response.data));
        }, function(response){
            console.error("Error in unpublishMedia : "+response);
        });
    }
    catch(err){
        console.error("Error in unpublishMedia : "+err.message+"("+err.lineNumber+")");
    }
}