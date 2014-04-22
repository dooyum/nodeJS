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
        console.log(items);
    });

    $scope.callTranscript = function(variable){
      var deferred = $q.defer();
      $http({method: 'GET', url: '/files/transcript/' + variable}).
        success(function(data, status, headers, config) {
          var transcript = data.pop();
          deferred.resolve(transcript);
        }).
        error(function(data, status, headers, config) {
          console.log("there has been an error on retrieval of transcript");
        });
   
      return deferred.promise;
    };

    $scope.sampleFunction = function(variable){
      var item = uploader.queue[variable];
      $scope.callTranscript(item._id).then(function(data){
        $scope.activeTranscript = $scope.processTranscript(data);
      });      
    }

    //this has to be extracted to a transcripts service
    $scope.processTranscript = function(transcript){
      var string = "";
      var words = transcript.words;
      for(var i = 0; i < words.length; i++){
        var element = words[i];
        string = string + " " + element.word;
      }

      return string;
    };

  	$scope.addWord = function(word){
      $scope.activeTranscript.push(word);
    }

    $scope.testFunction = function(){
      console.log($scope.uploadedFiles);
      console.log($scope.activeTranscript);
      console.log() ;
    }


  });