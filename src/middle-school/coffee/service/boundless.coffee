angular.module 'ahaLuminateApp'
  .factory 'BoundlessService', [
    '$rootScope'
    '$http'
    '$sce'
    ($rootScope, $http, $sce) ->
      checkOOTDashboard: (requestData) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://ahc.staging.ootqa.org/api/coordinator/dashboard/check/' + requestData
        else if $rootScope.tablePrefix is 'heartnew'
          url = 'https://ahc.dev.ootqa.org/api/coordinator/dashboard/check/' + requestData
        else
          url = 'https://middleschool.heart.org/api/coordinator/dashboard/check/' + requestData
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response
            
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

      getSchoolBadges: (requestData) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://ahc.staging.ootqa.org/api/badges/school/' + requestData
        else if $rootScope.tablePrefix is 'heartnew'
          url = 'https://ahc.dev.ootqa.org/api/badges/school/' + requestData
        else
          url = 'https://middleschool.heart.org/api/badges/school/' + requestData
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response

      getPrizes: ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://ahc.staging.ootqa.org/api/coordinator/students/standard-prizes/' +  + $rootScope.frId + '/' + $rootScope.consId 
        else
          url = 'https://middleschool.heart.org/api/coordinator/students/standard-prizes/' +  + $rootScope.frId + '/' + $rootScope.consId
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
            
      putSocialMedia: ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://ahc.staging.ootqa.org/api/points/activity/log/' + $rootScope.frId + '/' + $rootScope.consId + '/10/manual_social_earn'
        else if $rootScope.tablePrefix is 'heartnew'
          url = 'https://ahc.staging.ootqa.org/api/points/activity/log/' + $rootScope.frId + '/' + $rootScope.consId + '/10/manual_social_earn'
        else
          url = 'https://middleschool.heart.org/api/points/activity/log/' + $rootScope.frId + '/' + $rootScope.consId + '/10/manual_social_earn'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response
                        
      defaultStandardGifts: ->
        [
          {
            "id":"STK-23"
            "name":"Sticker"
            "status":0
            "level":"Sticker"
            "msg_earned":"App Downloaded and Registered"
            "msg_unearned":"Download the App and Register"
          }
          {
            "id":"PW-23"
            "name":"Sticky Phone Wallet"
            "status":0
            "level":"$10"
            "msg_earned":"$10 Raised Online"
            "msg_unearned":"Raise $10 Online"
          }
          {
            "id":"FHP-23"
            "name":"Fidget Popper*"
            "status":0
            "level":"$25"
            "msg_earned":"$25 Raised"
            "msg_unearned":"Raise $25"
          }
          {
            "id":"AHC"
            "name":"T-Shirt*"
            "status":0
            "level":"$50"
            "msg_earned":"$50 Raised"
            "msg_unearned":"Raise $50"
          }
          {
            "id":"SNB-23"
            "name":"Notebook*"
            "status":0
            "level":"$100"
            "msg_earned":"$100 Raised"
            "msg_unearned":"Raise $100"
          }
          {
            "id":"HP-23"
            "name":"Hydration Pack*"
            "status":0
            "level":"$200"
            "msg_earned":"$200 Raised"
            "msg_unearned":"Raise $200"
          }
          {
            "id":"BN-23"
            "name":"Beanie*"
            "status":0
            "level":"Complete Finn's Heart Card"
            "msg_earned":"Finn's Heart Card Mission Completed"
            "msg_unearned":"Complete 8 Action Tiles in Finn's Mission"
          }
        ]
  ]
