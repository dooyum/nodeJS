
/*
 * GET home page.
 */

exports.index = function(req, res){
  res.render('index', { title: 'Speech Hack Livestream'});
  //var incomingSocket = require('net').Socket();

    /*incomingSocket.connect(6000, 'localhost');

    incomingSocket.on('data', function(data){
        console.log(data.toString());
    });*/
};