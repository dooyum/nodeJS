'use strict';

angular.module('frontEndApp')
  .controller('TranscriptsCtrl', function ($scope, $http, $q) {
  	$scope.transcripts;

  	$scope.getTranscripts = function(){
  		var deferred = $q.defer();
  		$http({method: 'GET', url: '/transcripts/list'}).
  			success(function(data,status, headers, config){
  				console.log(data);
          $scope.transcripts = data;
  			}).
  			error(function(data, status,headers,config){
  				console.log("error on get transcripts");
  			});
  	};

    $scope.deleteTranscript = function(transcriptId){ 
      console.log(transcriptId);
      var deferred = $q.defer();
      $http({method: 'GET', url: '/transcripts/delete/' + variable}).
        success(function(data, status, headers, config) {
          console.log(data);
          if(data.success)
            return true;
        }).
        error(function(data, status, headers, config) {
          console.log("there has been an error on retrieval of transcript");
        });
   
      return deferred.promise;
    };

    var init = function () {
       $scope.getTranscripts();
    };
    init(); //function to be executed on load

  });