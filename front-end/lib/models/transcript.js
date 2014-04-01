'use strict';

var mongoose = require('mongoose'),
    Schema = mongoose.Schema;
    
/**
 * Transcript Schema
 */
 //http://mongoosejs.com/docs/schematypes.html
var TranscriptSchema = new Schema({
  name: String,
  words: Schema.Types.Mixed
});

/**
 * Validations
 */

 /*
ThingSchema.path('awesomeness').validate(function (num) {
  return num >= 1 && num <= 10;
}, 'Awesomeness must be between 1 and 10');
*/

mongoose.model('Transcript', TranscriptSchema);
