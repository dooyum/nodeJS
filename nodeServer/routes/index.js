
//var uploadHelper = require('./uploadHelper');
var uploadHelper = require('./formidableUploadHelper');

/*
 * GET home page.
 */

exports.index = function(req, res){
  res.render('index', { title: 'Express' });
};

exports.doUpload = function(req,res){
	uploadHelper.doUpload(req,res);
};

exports.streamUpload = function(req,res){
	uploadHelper.streamUpload(req, res);
}
