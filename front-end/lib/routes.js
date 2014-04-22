'use strict';

var api = require('./controllers/api'),
    index = require('./controllers'),
    files = require('./controllers/files'),
    transcripts = require('./controllers/transcripts');

var multipart = require('connect-multiparty');
var multipartMiddleware = multipart();

/**
 * Application routes
 */
module.exports = function(app) {

  // 
  app.post('/files/list', files.list);
  app.post('/files/upload', files.upload);
  app.get('/files/stream/:fileId', files.stream);
  app.get('/files/transcript/:fileId', files.transcript); //this should be extracted to a transcripts controller
  app.get('/transcripts/list', transcripts.listAll);
  app.get('/transcripts/delete/:id', transcripts.delete);

  // Server API Routes
  app.get('/api/awesomeThings', api.awesomeThings);
  

  // All other routes to use Angular routing in app/scripts/app.js
  app.get('/partials/*', index.partials);
  app.get('/*', index.index);
};