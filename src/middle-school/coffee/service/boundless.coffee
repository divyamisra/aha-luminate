angular.module 'ahaLuminateApp'
  .factory 'BoundlessService', [
    '$rootScope'
    '$http'
    '$sce'
    ($rootScope, $http, $sce) ->
      getBadges: (requestData) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://ahc.staging.ootqa.org/api/badges/student/' + requestData 
        else
          url = 'https://middleschool.heart.org/api/badges/student/' + requestData
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response
      
      getRollupTotals: ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://ahc.staging.ootqa.org/api/schools/totals/'
        else
          url = 'https://middleschool.heart.org/api/schools/totals/'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response

      getSchoolRollupTotals: (requestData) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://ahc.staging.ootqa.org/api/schools/totals/' + requestData
        else
          url = 'https://middleschool.heart.org/api/schools/totals/' + requestData
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response
            
      logEmailSent: ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://ahc.staging.ootqa.org/api/points/activity/log/' + $rootScope.frId + '/' + $rootScope.consId + '/2/ecard_sent'
        else if $rootScope.tablePrefix is 'heartnew'
          url = 'https://ahc.dev.ootqa.org/api/points/activity/log/' + $rootScope.frId + '/' + $rootScope.consId + '/2/ecard_sent'
        else
          url = 'https://middleschool.heart.org/api/points/activity/log/' + $rootScope.frId + '/' + $rootScope.consId + '/2/ecard_sent'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response
            
      logPersonalPageUpdated: ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://ahc.staging.ootqa.org/api/webhooks/student/personal-page-updated/' + $rootScope.frId + '/' + $rootScope.consId 
        else
          url = 'https://middleschool.heart.org/api/webhooks/student/personal-page-updated/' + $rootScope.frId + '/' + $rootScope.consId
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response
            
      logFundraiserCreated: ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://ahc.staging.ootqa.org/api/points/activity/log/' + $rootScope.frId + '/' + $rootScope.consId + '/10/fundraiser_created'
        else if $rootScope.tablePrefix is 'heartnew'
          url = 'https://ahc.dev.ootqa.org/api/points/activity/log/' + $rootScope.frId + '/' + $rootScope.consId + '/10/fundraiser_created'
        else
          url = 'https://middleschool.heart.org/api/points/activity/log/' + $rootScope.frId + '/' + $rootScope.consId + '/10/fundraiser_created'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response
  ]
