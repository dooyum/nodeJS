
/*
 * GET home page.
 */

exports.index = function(req, res){
  res.render('index', { title: 'Welcome'});
};

var fs = require("fs");
var GrowingFile = require("growing-file");

exports.streamUpload = function(req,res){
	var incomingForm = req.form  // it is Formidable form object
	//incomingForm.uploadDir = "/media/damonemx/Desktop/tempo";
	console.log("incoming form");
	console.log("form information");

    incomingForm.on('error', function(err){

          console.log(error);  //handle the error

    });

    var filePath;
    var flag = false;
    incomingForm.on('fileBegin', function(name, file){
    	console.log("file is beginning: " + name);
    	//console.log("file size " + file.size);
    	//console.log(file/tmp/42128ba456dc450a2fae44a3772c2a7c);
    	console.log(file.path);
    	//fs.createReadStream(file.path);
    	filePath = file.path;
    	console.log(fs.existsSync(file.path));
    });

    incomingForm.on('file', function(name, file) {
    	console.log("file name");
    	//console.log(file);
	});

    var s = require('net').Socket();
    s.connect(5000, 'localhost');

    var incomingSocket = require('net').Socket();
    incomingSocket.connect(6000, 'localhost');

    incomingSocket.on('data', function(data){
        console.log(data.toString());
    });

    incomingForm.onPart = function(part) {
            // Handle each data chunk as data streams in
        //    if (!part.filename) {
          //      part.on('data',function(data){
            //        s.write(data);
              //  });
           // }
           //console.log(part);
            if(part.filename != ''){
                console.log(part);
                part.addListener('data', function(data) {
                   s.write(data);
                   //console.log(data);
                });
            }
            else{
                part.removeListener('data',function(){});
            }
        };


    incomingForm.on('progress', function(bytesReceived, bytesExpected) {
    	//console.log("status: "  + bytesReceived + " out of " + bytesExpected);
    	
    	if(!flag && filePath){
    		flag = true;
    		console.log("filepath ");
    		console.log(filePath);
    		//fs.createReadStream(filePath).pipe();
    		var file = GrowingFile.open(filePath);
    		var writeFile = fs.createWriteStream("/home/damonemx/Desktop/people.json");
			file.pipe(writeFile);
            

			/*
			var postReq = http.request(options, function(res) {
			    res.setEncoding('utf8');
			    res.on('data', function (chunk) {
			          console.log('Response: ' + chunk);
			    });
			});
			postReq.write(data);
			*/
            /*
            s.connect(8080, 'localhost');
            file.pipe(s);

			file.on('data', function(){
				console.log("file is growing");
                //console.log(data);
               // s.write("hello");
			});
            */
			//create post
			//write to post url

			//on end close  post
    	}
    	
	});

    /*
    incomingForm.onPart = function(part) {
    	console.log("on part");
	    console.log(part);
	};
	*/

    incomingForm.on('end', function(){
    	//postRequest.end();
        // do stuff after file upload
        s.end();
        console.log("form has finished uploading");
    });
};

exports.uploadTest = function(req, res){
	console.log(req);
//
};