var MongoClient = require('mongodb').MongoClient;
var Grid = require('mongodb').Grid;



function storeFile(req, res){
		// Connect to the db
	MongoClient.connect("mongodb://localhost:27017/local", function(err, db) {
		//Simple MongoDb CR
		//Using GridFS for FileStorage
		var grid = new Grid(db, 'fs');
		var buffer = new Buffer("Hello world");
		grid.put(buffer, {metadata:{category:'text'}, content_type: 'text'}, function(err, fileInfo) {
			grid.get(fileInfo._id, function(err, data) {
		    	console.log("Retrieved data: " + data.toString());
			});
		});
		
	});
}

function storeRecord(jsonObject){
	MongoClient.connect("mongodb://localhost:27017/local", function(err, db) {
		//Simple MongoDb CR
		var collection = db.createCollection('sample', {w:1}, function(err, collection) { 
			if(err)
				console.log("there has been an error creating the collection. ");
			//var doc1 = {'hello':'doc1'};
			//Insert a new document
			collection.insert(jsonObject, {w:1}, function(err, result) {
				if(err){
					console.log("there has been an error inserting record");
					return false;
				}
					
				return true;
			});
		});
		
	});
}

function getFile(){
	MongoClient.connect("mongodb://localhost:27017/local", function(err, db) {
		grid.get(fileInfo._id, function(err, data) {
			console.log("Retrieved data: " + data.toString());
		});
	});
}


exports.storeFile = storeFile;