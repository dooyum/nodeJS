'use strict';

angular.module('frontEndApp')
  .controller('NavbarCtrl', function ($scope, $location) {
    $scope.menu = [{
    	'title': 'Home',
    	'link': '/index'
    },{
    	'title': 'View all transcripts',
    	'link' : '/list'
    }];
    
    $scope.isActive = function(route) {
      return route === $location.path();
    };
  });
