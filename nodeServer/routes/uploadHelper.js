
var multipart = require("../node_modules/multipart/lib/multipart.js");
var fs = require("fs");
var fileName;
var path = require('path');

var formidable = require('formidable'),
    http = require('http'),
    util = require('util');

/**
 * Stream upload using multi part
 */
function streamUpload(req, res) {
	console.log("will begin to stream upload");
	console.log("this is the streaming directory: " + path.resolve(__dirname));
	fileName="";
	req.setEncoding("binary");
	var stream = parseMultipart(req);
	var filePath = path.resolve(__dirname) + "/../../input/";
	console.log("will write to: ");
	console.log(filePath);
	
    // Hanlder for request part
    stream.onPartBegin = function(part) {
    	// Form the file name
    	var writeFilePath = "";
    	fileName=stream.part.filename;
    	writeFilePath = filePath + fileName;
    	// Create filestream to write the file now
    	fileStream = fs.createWriteStream(writeFilePath);
    	fileStream.addListener("error", function(err) {
        	console.log("Got error while writing to file '" + filePath + "': ", err);
    	});
    	// Add drain (all queued data written) handler to resume receiving request data
    	fileStream.addListener("drain", function() {
        	req.resume();
    	});
    };

    // write the chunks now using filestream
    stream.onData = function(chunk) {
        console.log("Writing chunk now................");
        fileStream.write(chunk, "binary");
    };

    // Create handler for completely reading the request
    stream.onEnd = function() {
        fileStream.addListener("drain", function() {
           fileStream.end();
           uploadComplete(res);
        });
    };
}

/**
 * Multipart parser for request
 */
function parseMultipart(req) {
	var parser = multipart.parser();
    // using the parsed request headers
    parser.headers = req.headers;
    // Add listeners to request, transfering data to parser to write the chunks
    req.addListener("data", function(chunk) {
        parser.write(chunk);
    });
    req.addListener("end", function() {
        parser.close();
    });
    return parser;
}

/**
 * Multipart- Upload COmplete
 */
function uploadComplete(res) {
    if(fileName!=null && fileName!="")
		console.log("fileName uploaded ==> ...."+fileName); 
                               
}

exports.streamUpload = streamUpload;