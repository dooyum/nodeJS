'use strict';

var api = require('./controllers/api'),
    index = require('./controllers'),
    files = require('./controllers/files');

var multipart = require('connect-multiparty');
var multipartMiddleware = multipart();

/**
 * Application routes
 */
module.exports = function(app) {

  // 
  app.post('/files/upload', files.upload);

  // Server API Routes
  app.get('/api/awesomeThings', api.awesomeThings);
  

  // All other routes to use Angular routing in app/scripts/app.js
  app.get('/partials/*', index.partials);
  app.get('/*', index.index);
};