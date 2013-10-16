//http://markdawson.tumblr.com/post/18359176420/asynchronous-file-uploading-using-express-and-node-js
//http://blog.ijasoneverett.com/2013/03/a-sample-app-with-node-js-express-and-mongodb-part-1/
/**
 * Module dependencies.
 */

var express = require('express');
var routes = require('./routes');
var user = require('./routes/user');
var http = require('http');
var path = require('path');
var sys = require('sys');
var fs = require('fs');

var app = express();

//~=== EXPRESS CONFIGURATION OPTIONS
// all environments
app.set('port', 3001);
//app.set('port', process.env.PORT || 3000);
app.set('views', __dirname + '/views');
app.set('view engine', 'jade');
app.use(express.favicon());
app.use(express.logger('dev'));
//app.use(express.bodyParser());
app.use(express.methodOverride());
app.use(app.router);
app.use(require('stylus').middleware(__dirname + '/public'));
app.use(express.static(path.join(__dirname, 'public')));

// development only
if ('development' == app.get('env')) {
  app.use(express.errorHandler());
}
//~=== END EXPRESS CONFIGURATION OPTIONS

app.get('/', routes.index);
app.post('/streamUpload', routes.streamUpload);
//app.get('/users', user.list);

var formidable = require('formidable');

app.get('/staticFile', function(req, res){
	fs.readFile('../output/nyan_cat.wav', function(error, content) {
		if (error) {
			res.writeHead(500);
			res.end();
		}
		else {
			res.writeHead(200, { 'Content-Type': 'audio/wav' });
			res.end(content, 'utf-8');
		}
	});
});

app.get('/test', function(req, res) {
	res.render('success');
	
	//testing MongoDB
	var MongoClient = require('mongodb').MongoClient;

	// Connect to the db
	MongoClient.connect("mongodb://localhost:27017/exampleDb", function(err, db) {
	  if(!err) 
	    console.log("We are connected");
	});
	
	
	//end testing MongoDB
});

function hash(fileName) {
    console.log("will generate hash for: " + fileName);
}

app.post('/api/file', function(req, res) {
	console.log(JSON.stringify(req.files));
	//var serverPath = '/images/' + req.files.userPhoto.name;
	var newFileFolder = path.resolve(__dirname) + "/../input/";
 
 	var fs = require('fs');
 	console.log(fs.createReadStream);
 	var is = fs.createReadStream(req.files.upload_file.path);
 	var newFilePath = newFileFolder + req.files.upload_file.originalFilename;
 	console.log(hash(newFilePath));
	var os = fs.createWriteStream(newFileFolder + req.files.upload_file.originalFilename);
	is.pipe(os);
	is.on('end',function() {
	    fs.unlinkSync(req.files.upload_file.path);
	});
	
	res.send({
		path: 'File conversion is starting....'
	});
 
 	/* this will usually work, but since we in my dev machine I have to copy in different partitions
    require('fs').rename( req.files.upload_file.path, newFileFolder + req.files.upload_file.originalFilename , function(error) {
    			console.log(error);
	            if(error) {
					res.send({ error: 'Ah crap! Something bad happened' });
	            	return;
	            }
	 
	            res.send({
					path: serverPath
	            });
			}
    );
	*/
	
	//POST request starts here
	console.log("will call conversion script...");
 	
 	var querystring = require('querystring');
 	
 	var data = querystring.stringify({fileName: req.files.upload_file.originalFilename});
 	
 	var options = {
	    host: 'localhost',
	    port: 3000,
	    path: '/convertFile',
	    method: 'POST',
	    headers: {
	        'Content-Type': 'application/x-www-form-urlencoded',
	        'Content-Length': Buffer.byteLength(data)
		    }
	};
	
	//this waits for file conversion, upon response triggers callback
	var request2 = http.request(options, function(response2) {
	    response2.setEncoding('utf8');
	    response2.on('data', function (chunk) {
	        console.log("body: " + chunk); //chunk is the new hash
	        console.log("CALLBACK from conversion has finished");
	    });
	});
	
	request2.write(data);
	request2.end();
	
	
});

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});
