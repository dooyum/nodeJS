'use strict';

var path = require('path');
var mongoose = require('mongoose'),
    Transcript = mongoose.model('Transcript');

/**
 * Send partial, or 404 if it doesn't exist
 */
exports.partials = function(req, res) {
  var stripped = req.url.split('.')[0];
  var requestedView = path.join('./', stripped);
  res.render(requestedView, function(err, html) {
    if(err) {
      res.send(404);
    } else {
      res.send(html);
    }
  });
};

/**
 * Send our single page app
 */
exports.index = function(req, res) {

  /*
  Transcript.find({}).remove(function() {
    Transcript.create({
      name : 'Test transcript created /index',
      words : {s1: {"start":"06.32", "word":"hello","end":"06.34"}, s2: {"start":"06.35", "word":"hello","end":"06.54"}}
    }, function() {
        console.log('finished populating things');
      }
    );
  });
  */
  console.log("index");
  res.render('index');
};
