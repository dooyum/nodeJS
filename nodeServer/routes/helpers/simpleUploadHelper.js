
//https://github.com/felixge/node-formidable
//http://everythingnode.blogspot.com/p/file-upload-using-nodejs-and-html-5-ui.html
var fileName;
var path = require('path');
var request = require('request');

var http = require('http'),
    util = require('util'),
    sys = require('sys');
var fs = require('fs'),
	util = require('util');

var fileStream = null;
var fileHandling  = require('./fileHandling');


//Function will execute supplied callback, sending filepath as parameter to callback 
function streamUpload(req, res, callbackFunction){

	var fileRoutes = new Array();
	if(req.files.upload_file.originalFilename != ""){
		var uuid = storeFile(fileType, req.files.upload_file.path);
		var fileType = fileHandling.ext.getContentType(fileHandling.ext.getExt(req.files.upload_file.originalFilename));
		fileRoutes.push({
			fileName : req.files.upload_file.originalFilename,
			uuid: uuid,
			filePath: uuid + "." + fileType,
			fileType: fileType
		});
	}

	if(req.files.text_file.originalFilename != ""){
		var uuid = storeFile(fileType, req.files.text_file.path);
		var fileType = fileHandling.ext.getContentType(fileHandling.ext.getExt(req.files.text_file.originalFilename));
		fileRoutes.push({
			fileName : req.files.text_file.originalFilename,
			uuid: uuid,
			filePath: uuid + "." + fileType,
			fileType: fileType
		});
	}

	//if(req.files.upload_file.originalFilename != "")
	//	fileRoutes[req.files.upload_file.originalFilename] = storeFile(req.files.upload_file.originalFilename, req.files.upload_file.path);
	//if(req.files.text_file.originalFilename != "")
	//	fileRoutes[req.files.text_file.originalFilename] = storeFile(req.files.text_file.originalFilename, req.files.text_file.path); 
	
	callbackFunction(fileRoutes);	
    return;
}

function storeFile(fileType, filePath){
	var fileName = generateUUID();

	var newFileFolder = path.resolve(__dirname) + "/../../../input/";
 	var fs = require('fs');
 	//var is = fs.createReadStream(filePath);
 	var newFilePath = newFileFolder + fileName;
 	
 	console.log(filePath);
 	var is = fs.createReadStream(filePath)
	var os = fs.createWriteStream(newFilePath);

	is.pipe(os);
	return fileName;

 	//generate hash for filename here
 	//console.log(hash(newFilePath));
 	/*
	var os = fs.createWriteStream(newFilePath);
	is.pipe(os);
	is.on('end',function() {
	    fs.unlinkSync(filePath);
	});
	*/
	
	//return fileName;
 	/* this will usually work, but since we in my dev machine I have to copy in different partitions
    require('fs').rename( req.files.upload_file.path, newFileFolder + req.files.upload_file.originalFilename , function(error) {
    			console.log(error);
	            if(error) {
					res.send({ error: 'Ah! Something bad happened' });
	            	return;
	            }
	 
	            res.send({
					path: serverPath
	            });
			}
    );
	*/
}

function generateUUID(){
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
        var r = Math.random()*16|0, v = c === 'x' ? r : (r&0x3|0x8);
        return v.toString(16);
    });
}

exports.streamUpload = streamUpload;