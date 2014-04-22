'use strict';

var mongoose = require('mongoose'),
    Transcript = mongoose.model('Transcript');

/**
 * Get awesome things
 */
exports.listAll = function(req, res){
	return Transcript.find(function (err, things) {
	    if (!err) {
	      return res.json(things);
	    } else {
	      return res.send(err);
	    }
	  });
};

exports.delete = function(req, res){
	return res.json({success: true});
}