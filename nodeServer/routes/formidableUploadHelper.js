
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

/**
 * Stream upload using multi part
 */
function streamUpload(req, res) {
	console.log("beginning upload with formidable");
	var form = new formidable.IncomingForm();
	
	//2 ways to obtain filename:
	//A) Obtain it directyl from request (Hardcode input field name)
	//B) Use events provided by Formidable module
	console.log(req);
	//form.uploadDir = process.cwd();
	
	//part.filename
	form.on('file', function(name, file) {
		console.log("file upload has begun");
		console.log(file);
	});
	
	//Everytime a "chunk (node.js buffer)" is uploaded, this will be triggered
	form.onPart = function(part) {
	  part.addListener('data', function(chunk) {
	    //This version should be much faster, formidable library parses quicker
	    //console.log("writing chunk, uploaded: " + form.bytesReceived + " expected: " + form.bytesExpected);
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
    return;
}

exports.streamUpload = streamUpload;