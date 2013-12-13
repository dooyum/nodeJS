
//var uploadHelper = require('./uploadHelper');
var uploadHelper = require('./helpers/simpleUploadHelper');
var mongoHelper  = require('./helpers/mongoHelper');
var fHandler  = require('./helpers/fileHandling');

//Mongo
var mongo = require('mongodb'), Db = mongo.Db, Grid = mongo.Grid, ObjectID = mongo.ObjectID;

/*
 * GET home page.
 */

exports.index = function(req, res){
	res.render('index', { title: 'Welcome'});
}

exports.streamUpload = function(req,res){
	//console.log(uploadHelper.streamUpload(req, res));
	uploadHelper.streamUpload(req, res, function(files){
			
		//refactor this to another file, just send mongo the chunks
		Db.connect("mongodb://localhost:27017/local", function(err, db) { //esta mandando la funcion, y para cuando conecto el for ya va en el segundo archivo
			if(err) return console.dir(err);

			for(var x in files){
				var fileInformation = files[x];
				//console.log(files[x]);
				//if(fileInformation.fileType == "video/ogg"){
				//this is how we will relate the files
				//var options = {"content_type": "image/png", "metadata":{ "author": "Daniel" }, "chunk_size": 1024*4, root: 'fs'};
				db.createCollection("transcripts", function(err, collection){
					var sampleTranscript = {
						transcript:  [{"start": 0, "confidence": 1, "end": 30, "id": 1, "value": "This is the first sentence"}, 
							{"start": 31, "confidence": 1, "end": 61, "id": 2, "value": "On to the second sentence"}
						]
					};
				    collection.insert(sampleTranscript, {safe: true}, function(err, records){
						var options = {"content_type": fileInformation.fileType, "metadata":{ "file_name": fileInformation.fileName, "content_type": fileInformation.fileType }, root: 'fs'};
						var gridStore = new mongo.GridStore(db, records[0]._id.toHexString() , "w", options);

						gridStore.open(function(err, gridStore) {
						if(fileInformation.uuid != ""){
						    gridStore.writeFile('../input/' + fileInformation.uuid, function(err, doc) {
								if(err) console.log(err);							
						    });
						}
					   
					    //if it's last name in array then close connection and render response
						//if(i == Object.keys(files).length){
						res.render('success', {fileRoute: records[0]._id.toHexString(), fileType: fileInformation.fileType });
						gridStore.close();
						//}
					});

					});	
				});

					//https://github.com/mongodb/node-mongodb-native/blob/master/docs/gridfs.md
					//var options = {"content_type": fileInformation.fileType, "metadata":{ "fileName": fileInformation.fileName }, root: 'fs'};
					//var gridStore = new mongo.GridStore(db, fileInformation.uuid , "w", options);
					//gridStore.chunkSize = 1024 * 256;
					
					/*
					gridStore.open(function(err, gridStore) {
						if(fileInformation.uuid != ""){
						    gridStore.writeFile('../input/' + fileInformation.uuid, function(err, doc) {
								if(err) console.log(err);							
						    });
						}
					   
					    //if it's last name in array then close connection and render response
						//if(i == Object.keys(files).length){
							res.render('success', {fileRoute: fileInformation.uuid});
							gridStore.close();
						//}
					});
					*/
				//}
				
			}

			/*
			var i = 0;
			for(var fileName in files){	
				i++;
				var fileType = fHandler.ext.getContentType(fHandler.ext.getExt(files[fileName]));
				
				//Depending on file type analyze
				console.log(fileType);
				if(fileType == "video/ogg"){
					var videoFile = fileName;
				
					//this is how we will relate the files
					//var options = {"content_type": "image/png", "metadata":{ "author": "Daniel" }, "chunk_size": 1024*4, root: 'fs'};
					
					//https://github.com/mongodb/node-mongodb-native/blob/master/docs/gridfs.md
					var options = {"content_type": fileType, "metadata":{  }, root: 'fs'};
					var gridStore = new mongo.GridStore(db, fileName, "w", options);
					//gridStore.chunkSize = 1024 * 256;
					
					gridStore.open(function(err, gridStore) {
						if(fileName != ""){
						    gridStore.writeFile('../input/' + fileName, function(err, doc) {
								if(err) console.log(err);							
						    });
						}
					   
					    //if it's last name in array then close connection and render response
						//if(i == Object.keys(files).length){
							res.render('success', {fileRoute: videoFile});
							gridStore.close();
						//}
					});
				}
			}
			*/
		});
	});
	
}

exports.getMetadata = function(req, res){
	var fileName = req.params.fileName;
	Db.connect("mongodb://localhost:27017/local", function(err, db) {
		if(err) return console.dir(err);
			
		var gridStore = new mongo.GridStore(db, fileName, "r", {root: 'fs'});
		gridStore.open(function(err, result){
			if(err) console.log("error on open");
		});

	});
}

exports.getTranscript = function(req, res){
	var fileName = req.params.fileName;
	Db.connect("mongodb://localhost:27017/local", function(err, db) {

		db.collection("transcripts", function(err, collection){
			collection.findOne({_id: ObjectID.createFromHexString(fileName)  }, function(err, result){
				if(err) console.log("Error when retrieving transcript");
				res.jsonp(result);
			});
		});	
	});	
}

exports.serveFile = function(req, res){
	var fileName = req.params.fileName;
	Db.connect("mongodb://localhost:27017/local", function(err, db) {
		if(err) return console.dir(err);
			
		//var gridStore = new mongo.GridStore(db, fileName, "w", {root:'fs'});
		// Create a new instance of the gridstore
		// Verify that the file exists
		var gridStore = new mongo.GridStore(db, fileName, "r", {root: 'fs'});
		gridStore.open(function(err, result){
			if(err) console.log("error on open");

			mongo.GridStore.read(db, fileName, function(err, fileData) {
				if(err) console.log(err);

				res.writeHead(200, { 'Content-Type': 'audio/wav' }); //content type should be dynamic
				res.end(fileData, 'utf-8');
				db.close();
			}); 

		});

		/*
        mongo.GridStore.open(db, fileName, function(err, result) {
          //assert.equal(null, err);
          //assert.equal(true, result);
          console.log(result);

          db.close();
        });*/


		/*
		mongo.GridStore.read(db, fileName, function(err, fileData) {
			if(err){
				console.log("error when reading from GridFS");
				console.log(err);
			}

			console.log(fileData);

			//assert.equal(data.toString('base64'), fileData.toString('base64'))
			//assert.equal(fileSize, fileData.length);
			res.writeHead(200, { 'Content-Type': 'audio/wav' }); //content type should be dynamic
			res.end(fileData, 'utf-8');
			db.close();
		}); 
		*/
	});
};

exports.serveVideo = function(req, res){
	var fileName = req.params.fileName;
	console.log("serving video: " + fileName);
	Db.connect("mongodb://localhost:27017/local", function(err, db) {
		if(err) return console.dir(err);
		mongo.GridStore.read(db, fileName, function(err, fileData) {
			if(err){
				console.log("error when reading from GridFS");
				console.log(err);
			}
			console.log("here goes the video");
			res.writeHead(200, { 'Content-Type': 'video/mp3' }); //content type should be dynamic
			res.end(fileData, 'utf-8');
			db.close();
		});
	});
};

exports.serveSubtitles = function(req, res){
	var fileName = req.params.fileName;
	Db.connect("mongodb://localhost:27017/local", function(err, db) {
		if(err) return console.dir(err);
		
		mongo.GridStore.read(db, "vsshort-en.srt", function(err, fileData) {
			if(err) console.log(err);
	
			res.writeHead(200, { 'Content-Type': 'text/plain' }); //content type should be dynamic
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
