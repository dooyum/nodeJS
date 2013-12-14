
/**
 * Module dependencies.
 */

var express = require('express');
var routes = require('./routes');
var user = require('./routes/user');
var http = require('http');
var path = require('path');

var app = express();

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

/*
  POST: Insert a new element 
var xmlObject = "<task><name>Nueva Nota via XML</name><notes>Done</notes></task>";

$.ajax({
	url: "http://localhost:3000/tasks.xml",
	dataType: "xml",
	type: "POST",
	processData: false,
	contentType: "text/xml",
	data: xmlObject
});
 */

app.post('/convertFile', function(req, res) {

	var sys = require('sys')
	var exec = require('child_process').exec;
	function puts(error, stdout, stderr) { sys.puts(stdout) }
	var fileName = req.body.fileName;
	//exec("cd ..; cd conversionScript; bash convert.sh " + fileName, puts);
	console.log(req.body);
	res.send("ok");
});

//The following will be on the parent server
app.post('/convertedFile', function(req, res) {
	//File conversion was successfull
	console.log("File conversion was successfull. Here's some information");
	console.log(req.body);
	res.send("ok");
});

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});
