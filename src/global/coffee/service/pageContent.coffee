angular.module 'ahaLuminateApp'
  .factory 'PageContentService', [
    '$http'
    ($http) ->
      getPageContent: (page) ->
        $http
          method: 'GET'
          url: luminateExtend.global.path.secure + 'SPageServer?pagename=getPageContent&pgwrap=n&get_pagename='+ page
        .then (response) ->
          response.data
          
  ]
