/*
 * Serve content over a socket
 */
var backendSocket = require('net').Socket();
var carrier = require('carrier');

var cpuCount = 0;


module.exports = function (socket) {
	//when connection to web socket has been made is when we should start piping content
	socket.on('init', function (data) {
		backendSocket.connect(11530, "localhost");	//Connect to socket

		backendSocket.on("error", function(error){
			console.log(error);
		}); 

		carrier.carry(backendSocket, function(line){
			try {
			  line = JSON.parse(line);
			  socket.emit('cpu:data', line);
			  cpuCount++;
			} catch (e) {
			  console.error("Parsing error:", e); 
			}
		});

		setInterval(function () {
			backendSocket.write("testing" + (new Date()).toString());
		}, 1000);

		setInterval(function () {
			socket.emit('cpu:count', {
		      count: cpuCount
		    });
			cpuCount = 0;
		}, 1000);
	});

};
