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
app.use(express.bodyParser());
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
app.get('/serveFile/:fileName', routes.serveFile);
app.get('/getMetadata/:fileName', routes.getMetadata);
app.get('/getTranscript/:fileName', routes.getTranscript);
app.get('/serveVideo/:fileName', routes.serveVideo);
app.get('/serveSubtitles/:fileName', routes.serveSubtitles);
app.post('/today', function(req,res){
	console.log(req.body);

	res.writeHead(200, { 'Content-Type': 'text/plain' }); //content type should be dynamic
	res.end("test", 'utf-8');
});

app.get('/file/:fileRoute', function(req, res){ 
	//res.sendfile('../output/' + req.params.fileRoute);
	console.log("sending file");
	console.log(req.params.fileRoute);
	fs.readFile('../input/' + req.params.fileRoute , function(error, content) {
		if (error) {
			res.writeHead(500);
			res.end();
		}
		else {
			//determine content type
			res.writeHead(200, { 'Content-Type': 'audio/wav' }); //content type should be dynamic
			res.end(content, 'utf-8');
		}
	});
});

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
	var Grid = require('mongodb').Grid;

	// Connect to the db
	MongoClient.connect("mongodb://localhost:27017/local", function(err, db) {
		if(!err) 
			console.log("We are connected");
			
		//Using GridFS for FileStorage
		/*
		var grid = new Grid(db, 'fs');
		var buffer = new Buffer("Hello world");
		grid.put(buffer, {metadata:{category:'text'}, content_type: 'text'}, function(err, fileInfo) {
			grid.get(fileInfo._id, function(err, data) {
		    console.log("Retrieved data: " + data.toString());
		 });
		});	
		*/
		
		//Simple MongoDb CR
		var collection = db.createCollection('sample', {w:1}, function(err, collection) { 
			if(err){
				console.log("there has been an error creating the collection. ");
			}
			var doc1 = {'hello':'doc1'};
			var doc2 = {'hello':'doc2'};
			var lotsOfDocs = [{'hello':'doc3'}, {'hello':'doc4'}];
			
			//Insert a new document
			collection.insert(doc2, {w:1}, function(err, result) {
				
				collection.find().toArray(function(err, items) {}); //this query will fetch all the document in the collection and return them as an array of items. BAD Performance
			    collection.findOne({'hello':'doc1'}, function(err, item) {
			    	console.log(item);
			    }); //special supported function to retrieve just one specific document bypassing the need for a cursor object.
				
			});
		});
		
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
