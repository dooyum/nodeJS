
//var uploadHelper = require('./uploadHelper');
var uploadHelper = require('./helpers/formidableUploadHelper');
var mongoHelper  = require('./helpers/mongoHelper');

//Mongo
var mongo = require('mongodb'), Db = mongo.Db, Grid = mongo.Grid;

/*
 * GET home page.
 */

exports.index = function(req, res){
	res.render('index', { title: 'Welcome'});
}

exports.streamUpload = function(req,res){
	//console.log(uploadHelper.streamUpload(req, res));
	uploadHelper.streamUpload(req, res, function(fileRoute){
		var fileName = fileRoute;
		
		//refactor this to another file, just send mongo the chunks
		Db.connect("mongodb://localhost:27017/local", function(err, db) {
			if(err) return console.dir(err);

			//https://github.com/mongodb/node-mongodb-native/blob/master/docs/gridfs.md
			var gridStore = new mongo.GridStore(db, fileName, "w", {root:'fs'});
			//gridStore.chunkSize = 1024 * 256;
			
			gridStore.open(function(err, gridStore) {
			    gridStore.writeFile('../input/' + fileName, function(err, doc) {
					if(err){ console.log("error writing file");
						console.log(err);
					}
					
					console.log("writing file");
			    });
			});

 		});
		
		console.log("testing callback");
		console.log(fileRoute);
		res.render('success', {fileRoute: fileRoute});
	});
}

exports.serveFile = function(req, res){
	var fileName = req.params.fileName;
	console.log("serving file: " + fileName);
	Db.connect("mongodb://localhost:27017/local", function(err, db) {
		if(err) return console.dir(err);
			
		//var gridStore = new mongo.GridStore(db, fileName, "w", {root:'fs'});
		mongo.GridStore.read(db, fileName, function(err, fileData) {
			if(err){
				console.log("error when reading from GridFS");
				console.log(err);
			}
			//assert.equal(data.toString('base64'), fileData.toString('base64'))
			//assert.equal(fileSize, fileData.length);
			res.writeHead(200, { 'Content-Type': 'audio/wav' }); //content type should be dynamic
			res.end(fileData, 'utf-8');
			db.close();
		});
	});
};

exports.index_old = function(req, res){
  res.render('index', { title: 'Express' });
};

exports.doUpload = function(req,res){
	uploadHelper.doUpload(req,res);
};

exports.streamUpload_old = function(req,res){
	uploadHelper.streamUpload(req, res);
}

exports.success = function(req, res){
	res.render('success', { title: 'Success'});
}
