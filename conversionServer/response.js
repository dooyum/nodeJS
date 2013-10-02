var fileName = process.argv[2];
var request = require('request');
request.post({
  url: 'http://localhost:3000/convertedFile',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    fileName: fileName,
    status: "ok"
  })
}, function(error, response, body){
  console.log(body);
});