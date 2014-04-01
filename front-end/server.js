'use strict';

var express = require('express'),
    path = require('path'),
    fs = require('fs'),
    mongoose = require('mongoose');

/**
 * Main application file
 */

// Default node environment to development
process.env.NODE_ENV = process.env.NODE_ENV || 'development';

// Application Config
var config = require('./lib/config/config');

// Connect to database
var db = mongoose.connect(config.mongo.uri, config.mongo.options);

//This shouldn't be a global variable
global.responseSocket = require('net').Socket();
responseSocket.on('error', function(error){
    console.log("Error when connecting to response socket");
    console.log(error);
});
responseSocket.on("data", function(data){
	console.log(data.toString());
});


db.connection.on('open', function callback () {
  console.log("Connected to mongo");
});

mongoose.connection.on('error', function(err){
	console.log("Could not connect to MongoDB");
	console.log(err);
});

mongoose.connection.on('disconnect',function(){
	console.log('Connection to MongoDB lost.');
});

// Bootstrap models
var modelsPath = path.join(__dirname, 'lib/models');
fs.readdirSync(modelsPath).forEach(function (file) {
  require(modelsPath + '/' + file);
});

// Populate empty DB with sample data
require('./lib/config/dummydata');

var app = express();

// Express settings
require('./lib/config/express')(app);

// Routing
require('./lib/routes')(app);

// Start server
app.listen(config.port, function () {
  console.log('Express server listening on port %d in %s mode', config.port, app.get('env'));
});

// Expose app
exports = module.exports = app;
exports.db = db;