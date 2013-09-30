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

app.get('/', routes.index);

app.get('/users', user.list);

app.post('/api/file', function(req, res) {
	console.log(JSON.stringify(req.files));
	//var serverPath = '/images/' + req.files.userPhoto.name;
	var newFileFolder = path.resolve(__dirname) + "/audio_files/";
 
 	var fs = require('fs');
 	console.log(fs.createReadStream);
 	var is = fs.createReadStream(req.files.upload_file.path);
	var os = fs.createWriteStream(newFileFolder + req.files.upload_file.originalFilename);
	is.pipe(os);
	is.on('end',function() {
	    fs.unlinkSync(req.files.upload_file.path);
	});
	
	res.send({
		path: 'Success, file moved'
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
});

http.createServer(app).listen(app.get('port'), function(){
  console.log('Express server listening on port ' + app.get('port'));
});
