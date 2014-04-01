'use strict';

angular.module('frontEndApp')
  .controller('UploaderCtrl', function ($scope, $http, $q, $fileUploader) {
  	console.log("testing upload controller");
  	this.variable = "test";	
    $scope.uploadedFiles = new Array();
    this.should = "sdf";
    $scope.activeVideo;
    $scope.activeTranscript;
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

    $scope.callTranscript = function(variable){
      var deferred = $q.defer();
 
      console.log("calling transcript");
      
      $http({method: 'GET', url: '/files/transcript/test'}).
        success(function(data, status, headers, config) {
          //console.log(data);
          var transcript = data.pop();
          deferred.resolve(transcript);
          //return "gonad";
        }).
        error(function(data, status, headers, config) {
          console.log("there has been an error on retrieval of transcript");
        });
   
      return deferred.promise;
    };

    $scope.sampleFunction = function(variable){
      console.log("running sample function");
      $scope.activeVideo = variable;
      $scope.callTranscript("testing").then(function(data){ 
        $scope.activeTranscript = $scope.processTranscript(data);
      });
    }

  	$scope.addWord = function(word){
      $scope.activeTranscript.push(word);
    }

    this.testFunction = function($scope){
      console.log($scope.activeTranscript);
      console.log();
    }

  	//this can be removed
    $http.get('/api/awesomeThings').success(function(awesomeThings) {
   		console.log("ran awesome things");
       $scope.awesomeThings = awesomeThings;
    });

    //this has to be extracted to a transcripts service
    $scope.processTranscript = function(transcript){
      console.log("process transcript");
      console.log(transcript);
      var array = new Array();
      for(var x in transcript.words){
        //array.push(transcript.words[x].word);
        array.push({word: transcript.words[x].word});
      }
      console.log(array);
      return array;
    };

  });