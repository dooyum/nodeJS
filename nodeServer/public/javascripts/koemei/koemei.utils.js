/**
 * Convert timestamp to mm:ss string format.
 *
 * @param {timestamp} timestamp to convert
 * @return {string} formatted mm:ss string
 */
function timestamp_to_mmss(timestamp){
    var temp = Math.round(timestamp/6000*100)/100;
    var minutes = Math.floor(temp);
    var aft_virg = temp - minutes;
    var second = Math.round(aft_virg*60);

    if (minutes < 10) {
        minutes = '0' + minutes;
    }
    if(second< 10){
        second = '0'+second;
    }
    return minutes+':'+second;
}

/**
 * Generate basic auth from username+password
 * @param {String} user name
 * @param {String} password
 * @return {String} basic auth string
 */
function make_base_auth(user, password) {
    var tok = user + ':' + password;
    var hash = btoa(tok);
    return "Basic " + hash;
};

