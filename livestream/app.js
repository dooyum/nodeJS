
/**
 * Module dependencies.
 */

var express = require('express');
var routes = require('./routes');
var user = require('./routes/user');
var http = require('http');
var path = require('path');
var app = express();
var server = require('http').createServer(app);
var io = require('socket.io').listen(server);
var carrier = require('carrier');

// all environments
app.set('port', process.env.PORT || 3000);
app.set('views', __dirname + '/views');
app.set('view engine', 'jade');
app.use(express.favicon());
app.use(express.logger('dev'));
app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(app.router);
app.use(require('stylus').middleware(__dirname + '/public'));
app.use(express.static(path.join(__dirname, 'public')));

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}

server.listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});

app.get('/', function (req, res) {
  res.sendfile(__dirname + '/index.html');
});

var incomingSocket = require('net').Socket();
//connect to HydraTCPClient
incomingSocket.connect(6000, 'localhost');

var timeoutFactor = 1;
incomingSocket.on('error', function(err) {
  console.log('Unable to connect to Hydra TCP Client');
  setTimeout(function(){incomingSocket.connect(6000, 'localhost');}, 5000 * timeoutFactor);
  timeoutFactor += timeoutFactor/2;
});

io.sockets.on('connection', function (socket) {
  socket.send('{"word":"Closed Captions Enabled"}');

  incomingSocket.on('data', function(data){
    //carrier.carry(incomingSocket, function(line) {
      //console.log("line: "+line);
      //socket.send(line);
    //}, "utf8");
  socket.send(data.toString());
  });
});