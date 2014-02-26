'use strict';

var path = require('path'),
  fs = require("fs"),
  growingFile = require("growing-file"),
  multiparty = require('multiparty'),
  mongoose = require('mongoose'), //Modules are cached after the first time they are loaded. 
  Grid = require('gridfs-stream');

/**
 * Send our single page app
 */
exports.index = function(req, res) {
  res.render('index');
};

/**
 * Process the upload form
 * 1. Opens socket to hydra server and pipes the incoming file
 * 2. Stores file in mongodb
 */
exports.upload = function(req,res){
  var form = new multiparty.Form();
  var filePath;
  var filename;
  var gfs = Grid(mongoose.connection.db, mongoose.mongo);
  var externalSocket = require('net').Socket();

  externalSocket.connect(8080, 'localhost'); //error handler for this socket, so it doesn't break the flow

  externalSocket.on('error', function(error){
    console.log(error);
  })

  //Required for multipart to process form
  form.parse(req, function(err, fields, files) { 
  });

  form.on('part', function(part){
    if(part.name == "file"){
      console.log(part.filename);
      part.pipe(externalSocket); 
      filename = part.filename;
      part.pipe(fs.createWriteStream("./temp/" + filename));
    }
  });

  form.on('file', function(name,file){
    if(name == "file"){
    }
  });

  form.on('close', function(){
    var writeStream = gfs.createWriteStream({
      filename: filename
    });
    fs.createReadStream('./temp/' + filename).pipe(writeStream);
    console.log("file written to mongodb and through res");
    writeStream.on('close', function (file) {
      res.json({ success: true, _id : file._id });
    });
  });


};