
//https://github.com/felixge/node-formidable
//http://everythingnode.blogspot.com/p/file-upload-using-nodejs-and-html-5-ui.html
var multipart = require("../node_modules/multipart/lib/multipart.js");
var fs = require("fs");
var fileName;
var path = require('path');

var formidable = require('formidable'),
    http = require('http'),
    util = require('util'),
    sys = require('sys');

var fileStream = null;
/**
 * Stream upload using multi part
 */
function streamUpload(req, res) {
	console.log("stream upload method");
	var form = new formidable.IncomingForm();
	
	//2 ways to obtain filename:
	//A) Obtain it directyl from request (Hardcode input field name)
	//B) Use events provided by Formidable module
	//console.log(req);
	//form.uploadDir = process.cwd();
	
	//THIS METHOD IS NOT BEING TRIGGERED!!!
	form.on('fileBegin', function(name, file) {
		console.log("file upload has begun");
		//console.log(file);
	});
	
	form.on('file', function(name, file) {
		console.log("a file has been detected");
	});
	
	
	//Everytime a "chunk (node.js buffer)" is uploaded, this will be triggered, it does the writing
	form.onPart = function(part) {
	  part.addListener('data', function(chunk) {
	  	//If stream has not been created yet, create it
	  	if(fileStream == null){
	  		var filePath = path.resolve(__dirname) + "/../../input/";
	  		var fileName = part.filename
	    	var writeFilePath = filePath + fileName;
	    	fileStream = fs.createWriteStream(filePath + fileName);
	    	fileStream.addListener("error", function(err) {
	        	console.log("Got error while writing to file '" + filePath + "': ", err);
	    	});
	  	}
	    //This version should be much faster, formidable library parses quicker
	    console.log("writing chunk, uploaded: " + form.bytesReceived + " expected: " + form.bytesExpected);
	    fileStream.write(chunk, "binary");
	  });
	};
	
	//Triggered after chunk has been parsed, this should update GUI
	form.on('progress', function(bytesReceived, bytesExpected) {
		//console.log("chunk has been parsed");
	});
	
	//response
    form.parse(req, function(fields, files) {
    	res.writeHead(200, {'content-type': 'text/plain'});
    	res.write('received upload:\n\n');
    	res.end(sys.inspect({fields: fields, files: files}));
    });
    
    form.on('end', function() {
    	fileStream.addListener("drain", function() {
           fileStream.end();
        });
    	console.log("Upload has finished");
	});
    
    return;
}

exports.streamUpload = streamUpload;