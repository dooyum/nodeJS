'use strict';

angular.module('frontEndApp')
  .controller('UploaderCtrl', function ($scope, $http, $fileUploader) {
  	console.log("testing upload controller");
  	this.variable = "test";	
    $scope.uploadedFiles = new Array();
    this.should = "sdf";
	// create a uploader with options
	
    var uploader = $scope.uploader = $fileUploader.create({
        scope: $scope, // to automatically update the html. Default: $rootScope
        url: 'files/upload',
        filters: []
    });  

    uploader.bind('progress', function (event, item, progress) {
      //console.info('Progress: ' + progress, item);
    });

    uploader.bind('success', function(event, xhr, item, response){
      console.log("success event");
      item._id = response._id;
    });

    uploader.bind('error', function (event, xhr, item, response) {
      console.info('Error', xhr, item, response);
    });
    
    uploader.bind('completeall', function (event, items) {
        $scope.uploadedFiles.push("test");
    });

  	this.sampleFunction = function(){
  		console.log("running sample function");
     // console.log(uploader.queue);
     console.log($scope.uploadedFiles);
  	};
  	//this can be removed
    $http.get('/api/awesomeThings').success(function(awesomeThings) {
   		console.log("ran awesome things");
       $scope.awesomeThings = awesomeThings;
    });
  });
