angular.module 'ahaLuminateApp'
  .factory 'BoundlessService', [
    '$rootScope'
    '$http'
    '$sce'
    ($rootScope, $http, $sce) ->
      checkOOTDashboard: (requestData) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://khc.staging.ootqa.org/api/coordinator/dashboard/check/' + requestData
        else if $rootScope.tablePrefix is 'heartnew'
          url = 'https://khc.staging.ootqa.org/api/coordinator/dashboard/check/' + requestData
        else
          url = 'https://kidsheartchallenge.heart.org/api/coordinator/dashboard/check/' + requestData
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response

      getTeachersBySchool: (requestData) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://khc.staging.ootqa.org/api/points/leaders/school/' + requestData + '/teachers/all'
        else if $rootScope.tablePrefix is 'heartnew'
          url = 'https://khc.staging.ootqa.org/api/points/leaders/school/' + requestData + '/teachers/all'
        else
          url = 'https://kidsheartchallenge.heart.org/api/points/leaders/school/' + requestData + '/teachers/all'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response

      getLeaderboards: (requestData) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://khc.staging.ootqa.org/api/points/leaders/school/' + requestData + '/teachers/all?limit=5'
        else if $rootScope.tablePrefix is 'heartnew'
          url = 'https://khc.staging.ootqa.org/api/points/leaders/school/' + requestData + '/teachers/all?limit=5'
        else
          url = 'https://kidsheartchallenge.heart.org/api/points/leaders/school/' + requestData + '/teachers/all?limit=5'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response
      
      getBadges: (requestData) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://khc.staging.ootqa.org/api/badges/student/' + requestData
        else if $rootScope.tablePrefix is 'heartnew'
          url = 'https://khc.staging.ootqa.org/api/badges/student/' + requestData
        else
          url = 'https://kidsheartchallenge.heart.org/api/badges/student/' + requestData
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response

      getSchoolBadges: (requestData) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://khc.staging.ootqa.org/api/badges/school/' + requestData
        else if $rootScope.tablePrefix is 'heartnew'
          url = 'https://khc.staging.ootqa.org/api/badges/school/' + requestData
        else
          url = 'https://kidsheartchallenge.heart.org/api/badges/school/' + requestData
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response

      setMoveMoreFlag: (requestData) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://khc.staging.ootqa.org/api/badges/motion/' + requestData
        else if $rootScope.tablePrefix is 'heartnew'
          url = 'https://khc.staging.ootqa.org/api/badges/motion/' + requestData
        else
          url = 'https://kidsheartchallenge.heart.org/api/badges/motion/' + requestData
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response
            
      getPrizes: ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://khc.staging.ootqa.org/api/coordinator/students/standard-prizes/' +  + $rootScope.frId + '/' + $rootScope.consId 
        else if $rootScope.tablePrefix is 'heartnew'
          url = 'https://khc.staging.ootqa.org/api/coordinator/students/standard-prizes/' +  + $rootScope.frId + '/' + $rootScope.consId
        else
          url = 'https://kidsheartchallenge.heart.org/api/coordinator/students/standard-prizes/' +  + $rootScope.frId + '/' + $rootScope.consId
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response

      getRollupTotals: ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://khc.staging.ootqa.org/api/schools/totals/'
        else if $rootScope.tablePrefix is 'heartnew'
          url = 'https://khc.staging.ootqa.org/api/schools/totals/'
        else
          url = 'https://kidsheartchallenge.heart.org/api/schools/totals/'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response
      
      logEmailSent: ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://khc.staging.ootqa.org/api/points/activity/log/' + $rootScope.frId + '/' + $rootScope.consId + '/2/ecard_sent'
        else if $rootScope.tablePrefix is 'heartnew'
          url = 'https://khc.staging.ootqa.org/api/points/activity/log/' + $rootScope.frId + '/' + $rootScope.consId + '/2/ecard_sent'
        else
          url = 'https://kidsheartchallenge.heart.org/api/points/activity/log/' + $rootScope.frId + '/' + $rootScope.consId + '/2/ecard_sent'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response
      
      logPersonalPageUpdated: ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://khc.staging.ootqa.org/api/webhooks/student/personal-page-updated/' + $rootScope.frId + '/' + $rootScope.consId
        else if $rootScope.tablePrefix is 'heartnew'
          url = 'https://khc.staging.ootqa.org/api/webhooks/student/personal-page-updated/' + $rootScope.frId + '/' + $rootScope.consId
        else
          url = 'https://kidsheartchallenge.heart.org/api/webhooks/student/personal-page-updated/' + $rootScope.frId + '/' + $rootScope.consId
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response

      logFundraiserCreated: ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://khc.staging.ootqa.org/api/points/activity/log/' + $rootScope.frId + '/' + $rootScope.consId + '/10/fundraiser_created'
        else if $rootScope.tablePrefix is 'heartnew'
          url = 'https://khc.staging.ootqa.org/api/points/activity/log/' + $rootScope.frId + '/' + $rootScope.consId + '/10/fundraiser_created'
        else
          url = 'https://kidsheartchallenge.heart.org/api/points/activity/log/' + $rootScope.frId + '/' + $rootScope.consId + '/10/fundraiser_created'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response
            
      putSocialMedia: ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://khc.staging.ootqa.org/api/points/activity/log/' + $rootScope.frId + '/' + $rootScope.consId + '/10/manual_social_earn'
        else if $rootScope.tablePrefix is 'heartnew'
          url = 'https://khc.staging.ootqa.org/api/points/activity/log/' + $rootScope.frId + '/' + $rootScope.consId + '/10/manual_social_earn'
        else
          url = 'https://kidsheartchallenge.heart.org/api/points/activity/log/' + $rootScope.frId + '/' + $rootScope.consId + '/10/manual_social_earn'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response
            
      getBMLeaderboard: (requestData) ->
        motion_username = 'kidsheartapi'
        motion_password = 'mYhtYeBWCrA7cTST'
        if $rootScope.tablePrefix == 'heartdev'
          url = 'https://load.boundlessfundraising.com/mobiles/ahakhc/getMotionKhcCompanyRoster?' + requestData + '&list_size=5'
        else
          url = 'https://loadprod.boundlessfundraising.com/mobiles/ahakhc/getMotionKhcCompanyRoster?' + requestData + '&list_size=5'
        jQuery.ajax
          url: $sce.trustAsResourceUrl(url)
          async: true
          type: 'GET'
          dataType: 'json'
          contentType: 'application/json'
          beforeSend: (xhr) ->
            xhr.setRequestHeader 'Authorization', 'Basic ' + btoa(motion_username + ':' + motion_password)
            return
          success: (response) ->
            response
          error: (err) ->
            console.log 'getMotionKhcCompanyRoster err', err
            response

      defaultStandardGifts: ->
        [
          {
            "id":"KTWB-23"
            "name":"Wristband"
            "status":0
            "level":"Wristband"
            "msg_earned":"Registration Completed"
            "msg_unearned":"Complete Registration"
            "instant": 1
            "online_only":0
            "video": ""
            "post_event":0
            "vucheck": 0
          }
          {
            "id":"HEARTY-23"
            "name":"Hearty"
            "status":0
            "level":"$5"
            "msg_earned":"$5 Raised"
            "msg_unearned":"Raise $5"
            "instant": 1
            "online_only":0
            "video": ""
            "post_event":0
            "vucheck": 1
          }
          {
            "id":"LVL1WB-18"
            "name":"Water Bottle"
            "status":0
            "level":"$5"
            "msg_earned":"$5 Raised"
            "msg_unearned":"Raise $5"
            "instant": 0
            "online_only":0
            "video": ""
            "post_event":0
            "vucheck": 0
          }
          {
            "id":"BREEZE-23"
            "name":"Breeze"
            "status":0
            "level":"$10"
            "msg_earned":"$10 Raised"
            "msg_unearned":"Raise $10"
            "instant": 1
            "online_only":0
            "video": ""
            "post_event":0
            "vucheck": 1
          }
          {
            "id":"JR-23"
            "name":"Jump Rope"
            "status":0
            "level":"$15"
            "msg_earned":"$15 Raised"
            "msg_unearned":"Raise $15"
            "instant": 1
            "online_only":0
            "video": ""
            "post_event":1
            "vucheck": 0
          }
          {
            "id":"HYDRO-23"
            "name":"Hydro"
            "status":0
            "level":"$25"
            "msg_earned":"$25 Raised"
            "msg_unearned":"Raise $25"
            "instant": 1
            "online_only":0
            "video": ""
            "post_event":0
            "vucheck": 1
          }
          {
            "id":"DREAM-23"
            "name":"Dream"
            "status":0
            "level":"$40"
            "msg_earned":"$40 Raised"
            "msg_unearned":"Raise $40"
            "instant": 1
            "online_only":0
            "video": "https://vimeo.com/americanheartassociation/review/453777085/ab8611f4ce"
            "post_event":0
            "vucheck": 1
          }
          {
            "id":"KHC"
            "name":"T-Shirt"
            "status":0
            "level":"$50"
            "msg_earned":"$50 Raised"
            "msg_unearned":"Raise $50"
            "instant": 2
            "online_only":0
            "video": ""
            "post_event":1
            "vucheck": 0
          }
          {
            "id":"PBALL-23"
            "name":"Playground Ball"
            "status":0
            "level":"$75"
            "msg_earned":"$75 Raised"
            "msg_unearned":"Raise $75"
            "instant": 2
            "online_only":0
            "video": ""
            "post_event":1
            "vucheck": 0
          }
          {
            "id":"MARLEY-23"
            "name":"Marley"
            "status":0
            "level":"$100"
            "msg_earned":"$100 Raised"
            "msg_unearned":"Raise $100"
            "instant": 2
            "online_only":0
            "video": ""
            "post_event":0
            "vucheck": 1
          }
          {
            "id":"FRANKIE-23"
            "name":"Frankie"
            "status":0
            "level":"$150"
            "msg_earned":"$150 Raised"
            "msg_unearned":"Raise $150"
            "instant": 2
            "online_only":0
            "video": ""
            "post_event":0
            "vucheck": 1
          }
          {
            "id":"BAXTER-23"
            "name":"Baxter"
            "status":0
            "level":"$200"
            "msg_earned":"$200 Raised"
            "msg_unearned":"Raise $200"
            "instant": 2
            "online_only":0
            "video": ""
            "post_event":0
            "vucheck": 1
          }
          {
            "id":"SOCKS-23"
            "name":"Socks"
            "status":0
            "level":"$250"
            "msg_earned":"$250 Raised"
            "msg_unearned":"Raise $250"
            "instant": 2
            "online_only":0
            "video": ""
            "post_event":1
            "vucheck": 0
          }
          {
            "id":"FP-23"
            "name":"Mystery Popper"
            "status":0
            "level":"$500"
            "msg_earned":"$500 Raised"
            "msg_unearned":"Raise $500"
            "instant": 2
            "online_only":0
            "video": "https://vimeo.com/americanheartassociation/review/453776957/cde52d6c23"
            "post_event":1
            "vucheck": 0
          }
          {
            "id":"WATCH-23"
            "name":"Watch"
            "status":0
            "level":"$1,000"
            "msg_earned":"$1,000 Raised"
            "msg_unearned":"Raise $1,000"
            "instant": 2
            "online_only":0
            "video": "https://video.link/w/On7X"
            "post_event":1
            "vucheck": 0
          }
          {
            "id":"FINN-23"
            "name":"Finn's Lifesaver Award"
            "status":0
            "level":"Complete Finn's Mission"
            "msg_earned":"Finn's Mission Completed"
            "msg_unearned":"Complete Finn's Mission"
            "instant": 2
            "online_only":0
            "video": ""
            "post_event":0
            "vucheck": 1
          }
          {
            "id":"CHARM-23"
            "name":"Mystery Gift"
            "status":0
            "level":"Every $50"
            "msg_earned":"Every $50 Raised<br/><em>Students can earn up to 20 Mystery Gifts</em>"
            "msg_unearned":"Every $50 Raised<br/><em>Students can earn up to 20 Mystery Gifts</em>"
            "instant": 2
            "online_only":0
            "video": ""
            "post_event":0
            "vucheck": 0
          }
        ]

      giftLevels_instant: -> 
        [
          "KTWB-23"
          "HEARTY-23"
          "BREEZE-23"
          "JR-23"
          "HYDRO-23"
          "DREAM-23"
          "KHC"
          "PBALL-23"
          "MARLEY-23"
          "BAXTER-23"         
          "SOCKS-23"
          "FP-23"
          "WATCH-23"
          "FINN-23"
          "CHARM-23"
        ]

      giftLevels_noninstant: -> 
        [
          "LVL1WB-18"
          "JR-23"
          "KHC"
          "SOCKS-23"
          "FP-23"
          "WATCH-23"
        ]

      giftLevels_instant_earned: -> 
        {
          "$0": [
            "KTWB-23"
          ]
          "$5-$14":[
            "KTWB-23"
            "HEARTY-23"
            "BREEZE-23"
          ]
          "$15-$24":[
            "KTWB-23"
            "HEARTY-23"
            "BREEZE-23"
            "JR-23"
          ]
          "$25-$39":[
            "KTWB-23"
            "HEARTY-23"
            "BREEZE-23"
            "JR-23"
            "HYDRO-23"
          ]
          "$40-$49":[
            "KTWB-23"
            "HEARTY-23"
            "BREEZE-23"
            "JR-23"
            "HYDRO-23"
            "DREAM-23"
          ]
          "$50-$74":[
            "KTWB-23"
            "HEARTY-23"
            "BREEZE-23"
            "JR-23"
            "HYDRO-23"
            "DREAM-23"
            "KHC"
            "CHARM-23"
          ]
          "Green $75-$99":[
            "KTWB-23"
            "HEARTY-23"
            "BREEZE-23"
            "JR-23"
            "HYDRO-23"
            "DREAM-23"
            "KHC"
            "PBALL-23"
            "CHARM-23"
          ]
          "Blue $100-$199":[
            "KTWB-23"
            "HEARTY-23"
            "BREEZE-23"
            "JR-23"
            "HYDRO-23"
            "DREAM-23"
            "KHC"
            "PBALL-23"
            "MARLEY-23"
            "CHARM-23"
          ]
          "Red $200-$249":[
            "KTWB-23"
            "HEARTY-23"
            "BREEZE-23"
            "JR-23"
            "HYDRO-23"
            "DREAM-23"
            "KHC"
            "PBALL-23"
            "MARLEY-23"
            "BAXTER-23"
            "CHARM-23"
          ]
          "Orange $250-$499":[
            "KTWB-23"
            "HEARTY-23"
            "BREEZE-23"
            "JR-23"
            "HYDRO-23"
            "DREAM-23"
            "KHC"
            "PBALL-23"
            "MARLEY-23"
            "BAXTER-23"
            "SOCKS-23"
            "CHARM-23"
          ]
          "Brown $500-$999":[
            "KTWB-23"
            "HEARTY-23"
            "BREEZE-23"
            "JR-23"
            "HYDRO-23"
            "DREAM-23"
            "KHC"
            "PBALL-23"
            "MARLEY-23"
            "BAXTER-23"
            "SOCKS-23"
            "FP-23"
            "CHARM-23"
          ]
          "Yellow $1000+":[
            "KTWB-23"
            "HEARTY-23"
            "BREEZE-23"
            "JR-23"
            "HYDRO-23"
            "DREAM-23"
            "KHC"
            "PBALL-23"
            "MARLEY-23"
            "BAXTER-23"
            "SOCKS-23"
            "FP-23"
            "WATCH-23"
            "CHARM-23"
          ]
        }
      giftLevels_noninstant_earned: -> 
        {
          "$0": [
          ]
          "$5-$14":[
            "LVL1WB-18"
          ]
          "$15-$24":[
            "LVL1WB-18"
            "JR-23"
          ]
          "$25-$39":[
            "LVL1WB-18"
            "JR-23"
          ]
          "$40-$49":[
            "LVL1WB-18"
            "JR-23"
          ]
          "$50-$74":[
            "LVL1WB-18"
            "JR-23"
            "KHC"
          ]
          "Green $75-$99":[
            "LVL1WB-18"
            "JR-23"
            "KHC"
            "PBALL-23"
          ]
          "Blue $100-$199":[
            "LVL1WB-18"
            "JR-23"
            "KHC"
          ]
          "Red $200-$249":[
            "LVL1WB-18"
            "JR-23"
            "KHC"
          ]
          "Orange $250-$499":[
            "LVL1WB-18"
            "JR-23"
            "KHC"
            "SOCKS-23"
          ]
          "Brown $500-$999":[
            "LVL1WB-18"
            "JR-23"
            "KHC"
            "SOCKS-23"
            "FP-23"
          ]
          "Yellow $1000+":[
            "LVL1WB-18"
            "JR-22"
            "KHC"
            "SOCKS-23"
            "FP-23"
            "WATCH-23"
          ]
        }
  ]
