'use strict';

angular.module('frontEndApp', [
  'ngCookies',
  'ngResource',
  'ngSanitize',
  'ngRoute', 
  'angularFileUpload'
])
  .config(function ($routeProvider, $locationProvider) {
    $routeProvider
      .when('/', {
        templateUrl: 'partials/main',
        controller: 'UploaderCtrl'
      })
      .when('/player', {
        templateUrl: 'partials/player',
        controller: 'PlayerCtrl'
      })
      .otherwise({
        redirectTo: '/'
      });
      
    $locationProvider.html5Mode(true);
  });