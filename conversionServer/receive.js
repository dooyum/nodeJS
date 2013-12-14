var request = require('request');
request.post({
  url: 'http://localhost:3001/today',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({
    fileName: "14 Nature Feels.mp3"
  })
}, function(error, response, body){
  console.log(body);
});