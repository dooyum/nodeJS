/*
 * Serve content over a socket
 */
var backendSocketCPU = require('net').Socket();
var carrierCPU = require('carrier');

var backendSocketGPU = require('net').Socket();
var carrierGPU = require('carrier');

var cpuCount = 0;
var gpuCount = 0;
var speedFactor = 0.5;


module.exports = function (socket) {
	//when connection to web socket has been made is when we should start piping content
	socket.on('init', function (data) {
		backendSocketCPU.connect(7000, "localhost");	//Connect to socket

		backendSocketCPU.on("error", function(error){
			console.log(error);
		}); 

		carrierCPU.carry(backendSocketCPU, function(line){
			try {
			  line = JSON.parse(line);
			  console.log(line);
			  socket.emit('cpu:data', line);
			  cpuCount++;
			} catch (e) {
			  console.error("Parsing error:", e); 
			}
		});

		/*setInterval(function () {
			backendSocketCPU.write("testing" + (new Date()).toString());
		}, 3000);*/

		backendSocketGPU.connect(6000, "localhost");	//Connect to socket

		backendSocketGPU.on("error", function(error){
			console.log(error);
		}); 

		carrierGPU.carry(backendSocketGPU, function(line){
			try {
			  line = JSON.parse(line);
			  console.log(line);
			  socket.emit('gpu:data', line);
			  gpuCount++;
			} catch (e) {
			  console.error("Parsing error:", e); 
			}
		});

		/*setInterval(function () {
			backendSocketGPU.write("testing" + (new Date()).toString());
		}, 3000);*/

		setInterval(function () {
			socket.emit('cpu:count', {
		      count: cpuCount
		    });
			cpuCount = 0;

			socket.emit('gpu:count', {
		      count: gpuCount
		    });
			gpuCount = 0;
		}, 1000 * speedFactor);
	});

};
