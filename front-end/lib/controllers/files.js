'use strict';

var path = require('path'),
  fs = require("fs"),
  growingFile = require("growing-file"),
  multiparty = require('multiparty'),
  mongoose = require('mongoose'), //Modules are cached after the first time they are loaded. 
  Transcript = mongoose.model('Transcript'),
  Grid = require('gridfs-stream'), 
  carrier = require('carrier');

/**
 * Send our single page app
 */
exports.index = function(req, res) {
  console.log("index");
  res.render('index');
};

exports.list = function(){
  console.log("list");
  res.render('test');
};

exports.transcript = function(req, res){
  //53560a3e263ae6510e000006
  //var fileId = req.params.fileId;
  var fileId = "53560a3e263ae6510e000006";
  console.log("file id of transcript: " + fileId);
  //var fileId = "531a391ceb24dd291e000006";
  Transcript.find({_id: fileId}, function(err, transcript){
    if(err) console.log(err);

    res.json(transcript);
  });
}

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
  var words = new Array
  var transcript;

  externalSocket.connect(11530, 'localhost');

  externalSocket.on('error', function(error){
    console.log("Error with socket that sends file");
    console.log(error);
  })

  var test = false;

  carrier.carry(externalSocket, function(line){
      try {
        line = JSON.parse(line);
        console.log(line);
        words.push(line);
        //if(transcript){
         // transcript.words = words;
         // console.log(transcript);
        //}
      } catch (e) {
        console.error("Parsing error:", e); 
      }
    });

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
      responseSocket.write("connection to response socket");

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

    console.log("File has been written to MongoDB.");
    writeStream.on('close', function (file) {
      var promise = Transcript.create({
          _id   : file._id, 
          name  : filename,
          words : words
        }, function() {
          res.json({ success: true, _id : file._id });
        }
      );

      promise.then(function(savedTranscript){
        transcript = savedTranscript;
      });

    });
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

