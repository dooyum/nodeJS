'use strict';

var path = require('path'),
  fs = require("fs"),
  growingFile = require("growing-file"),
  multiparty = require('multiparty'),
  mongoose = require('mongoose'), //Modules are cached after the first time they are loaded. 
  Transcript = mongoose.model('Transcript'),
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
    console.log("Error with socket that sends file");
    console.log(error);
  })

  //Required for multipart to process form
  form.parse(req, function(err, fields, files) { 
  });

  var fileToWrite;
  form.on('part', function(part){ //Emitted when a part is encountered in the request
    if(part.name == "file"){
      part.pipe(externalSocket); 
      filename = part.filename;
      fileToWrite = fs.createWriteStream("./temp/" + filename);
      part.pipe(fileToWrite);
      //currently we will get filename from this method, HYDRA server should send the filename
      responseSocket.connect(6000, 'localhost');
      responseSocket.on('connect', function(){
        console.log("connection to response socket has been made");
      });
      responseSocket.write("cdcdsacds");

    }
  });

  form.on('file', function(name,file){
    if(name == "file"){
    }
  });

  form.on('close', function(){
    fileToWrite.close();
    var writeStream = gfs.createWriteStream({
      filename: filename
    });
    fs.createReadStream('./temp/' + filename).pipe(writeStream);
    console.log("file written to mongodb and through res");
    writeStream.on('close', function (file) {
      //Write to MongoDB
      Transcript.create({
          _id   : file._id, 
          name  : 'Test transcript created /index',
          words : {
            s1: {"start":"06.32", "word":"Word1","end":"06.34"}, 
            s2: {"start":"06.35", "word":"Word2","end":"06.54"},
            s3: {"start":"06.55", "word":"Word3","end":"06.88"},
            s4: {"start":"06.89", "word":"Word4","end":"07.28"},
            s5: {"start":"07.29", "word":"Word5","end":"07.76"},
            s6: {"start":"07.77", "word":"Word6","end":"08.01"},
            s7: {"start":"08.02", "word":"Word7","end":"08.55"}
          }
        }, function() {
          res.json({ success: true, _id : file._id });
        }
      );
      //res.json({ success: true, _id : file._id });
    });

    //responseSocket.close();
  });


};

/**
 * Stream a file that is stored in GridFS
 */
exports.stream = function(req, res){
  var fileId = req.params.fileId;
  //res.sendfile("./temp/05 - Owls.mp3");
  //var rs = fs.createReadStream("./temp/17.hotelCalifornia.mp3");
  //console.log(rs);
  /*
  res.on('data',function(chunk){
    res.pipe(chunk);
  });

  res.on('end',function(){
    res.end();
  });
*/

  var gfs = Grid(mongoose.connection.db, mongoose.mongo);
  var readstream = gfs.createReadStream({
      _id: fileId
    });
  readstream.pipe(res);



  //res.writeHead(200, { 'Content-Type': 'audio/mpeg' }); //content type should be dynamic
  //res.end(rs, 'utf-8');

//  var mongo = require('mongodb'), Db = mongo.Db, Grid = mongo.Grid, ObjectID = mongo.ObjectID;



  //var gfs = Grid(mongoose.connection.db, mongoose.mongo);

  /*
  console.log(fileId);
  gfs.files.find({ filename:"05 - Owls.mp3"}).toArray(function (err, files) {
    if (err) 
      console.log("file not found");

    console.log("files");
    console.log(files);

    res.writeHead(200, {
      'Content-Type': 'audio/mpeg',
      'Content-Length': 8793034
    });

    var readstream = gfs.createReadStream({
      _id: fileId
    });

    //console.log(readstream);
    readstream.on('error', function (err) {
      console.log('Error ocurred on open file from GridFS', err);
      throw err;
    });
    readstream.pipe(res);
  });
  */
 // res.writeHead(200, {
   //   'Content-Type': 'audio/mpeg',
    //  'Content-Length': 8793034
    //});


  
}

exports.transcript = function(req, res){
  //var fileId = req.params.fileId;
  var fileId = "531a391ceb24dd291e000006";
  Transcript.find({_id: fileId}, function(err, transcript){
    if(err) console.log(err);

    res.json(transcript);
  });
}