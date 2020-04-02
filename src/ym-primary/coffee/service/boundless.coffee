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
          url = 'https://khc.dev.ootqa.org/api/coordinator/dashboard/check/' + requestData
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
          url = 'https://khc.dev.ootqa.org/api/points/leaders/school/' + requestData + '/teachers/all'
        else
          url = 'https://kidsheartchallenge.heart.org/api/points/leaders/school/' + requestData + '/teachers/all'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response

      getLeaderboardRaised: (requestData) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://khc.staging.ootqa.org/api/points/leaders/school/' + requestData + '/teachers/most-dollars?limit=5'
        else if $rootScope.tablePrefix is 'heartnew'
          url = 'https://khc.dev.ootqa.org/api/points/leaders/school/' + requestData + '/teachers/most-dollars?limit=5'
        else
          url = 'https://kidsheartchallenge.heart.org/api/points/leaders/school/' + requestData + '/teachers/most-dollars?limit=5'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response
      
      getLeaderboardStudents: (requestData) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://khc.staging.ootqa.org/api/points/leaders/school/' + requestData + '/teachers/most-students?limit=5'
        else if $rootScope.tablePrefix is 'heartnew'
          url = 'https://khc.dev.ootqa.org/api/points/leaders/school/' + requestData + '/teachers/most-students?limit=5'
        else
          url = 'https://kidsheartchallenge.heart.org/api/points/leaders/school/' + requestData + '/teachers/most-students?limit=5'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response
      
      getBadges: (requestData) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://khc.staging.ootqa.org/api/badges/student/' + requestData
        else if $rootScope.tablePrefix is 'heartnew'
          url = 'https://khc.dev.ootqa.org/api/badges/student/' + requestData
        else
          url = 'https://kidsheartchallenge.heart.org/api/badges/student/' + requestData
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response
      
      getPrizes: ->
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://khc.staging.ootqa.org/api/coordinator/students/standard-prizes/' +  + $rootScope.frId + '/' + $rootScope.consId 
        else if $rootScope.tablePrefix is 'heartnew'
          url = 'https://khc.dev.ootqa.org/api/coordinator/students/standard-prizes/' +  + $rootScope.frId + '/' + $rootScope.consId
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
          url = 'https://khc.dev.ootqa.org/api/schools/totals/'
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
          url = 'https://khc.dev.ootqa.org/api/points/activity/log/' + $rootScope.frId + '/' + $rootScope.consId + '/2/ecard_sent'
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
          url = 'https://khc.dev.ootqa.org/api/webhooks/student/personal-page-updated/' + $rootScope.frId + '/' + $rootScope.consId
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
          url = 'https://khc.dev.ootqa.org/api/points/activity/log/' + $rootScope.frId + '/' + $rootScope.consId + '/10/fundraiser_created'
        else
          url = 'https://kidsheartchallenge.heart.org/api/points/activity/log/' + $rootScope.frId + '/' + $rootScope.consId + '/10/fundraiser_created'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response
            
      defaultStandardGifts: ->
        [
          {
            "id":"WB-20"
            "name":"Worded Wristband"
            "status":0
            "level":""
            "level_desc":""
            "instant": 1
            "earned_title":"You're Awesome!"
            "earned_subtitle1":"Thanks for registering online!"
            "earned_subtitle2":"a wristband"
            "online_only":0
          }
          {
            "id":"CLIPPERRIE-20"
            "name":"Perrie"
            "status":0
            "level":"$5"
            "instant": 1
            "earned_title":"Check, Mate!"
            "earned_subtitle1":"You've raised $5!"
            "earned_subtitle2":"a Perrie charm"
            "online_only":0
          }
          {
            "id":"LVL1WB-20"
            "name":"Water Bottle"
            "status":0
            "level":"$5"
            "instant": 0
            "earned_title":"Stay Hydrated!"
            "earned_subtitle1":"You've raised $5!"
            "earned_subtitle2":"a water bottle"
            "online_only":0
          }
          {
            "id":"CHARMKNOX-20"
            "name":"Knox"
            "status":0
            "level":"$10 online"
            "instant": 1
            "earned_title":"Give us 2 high fives!"
            "earned_subtitle1":"You just raised $10 online!"
            "earned_subtitle2":"a Knox charm"
            "online_only":1
          }
          {
            "id":"JR-20"
            "name":"Jump Rope"
            "status":0
            "level":"$15"
            "instant": 2
            "earned_title":"Jumping for joy!"
            "earned_subtitle1":"Way to jump in and raise $15!"
            "earned_subtitle2":"a jump rope"
            "online_only":0
          }
          {
            "id":"CLIPNICO-20"
            "name":"Nico"
            "status":0
            "level":"$25"
            "instant": 1
            "earned_title":"You're a Super hero!"
            "earned_subtitle1":"You're the best for raising $25!"
            "earned_subtitle2":"a Nico charm"
            "online_only":0
          }
          {
            "id":"CHARMSOFIE-20"
            "name":"Sofie"
            "status":0
            "level":"$40 online"
            "instant": 1
            "earned_title":"Color us happy!"
            "earned_subtitle1":"Nice job raising $40 online!"
            "earned_subtitle2":"a Sofie charm"
            "online_only":1
          }
          {
            "id":"KHC"
            "name":"T-Shirt"
            "status":0
            "level":"$50"
            "instant": 2
            "earned_title":"You're a real hero!"
            "earned_subtitle1":"You've raised $50!"
            "earned_subtitle2":"a t-shirt"
            "online_only":0
          }
          {
            "id":"PBALL-20"
            "name":"Playground Ball"
            "status":0
            "level":"$75"
            "instant": 2
            "earned_title":"Bouncin' High!"
            "earned_subtitle1":"Way to raise $75!"
            "earned_subtitle2":"a playground ball"
            "online_only":0
          }
          {
            "id":"CLIPCRUSH-20"
            "name":"Crush"
            "status":0
            "level":"$100"
            "instant": 1
            "earned_title":"Crushin' It!"
            "earned_subtitle1":"Nice job cruising to $100!"
            "earned_subtitle2":"a Crush charm"
            "online_only":0
          }
          {
            "id":"CLIPSUNNY-20"
            "name":"Sunny"
            "status":0
            "level":"$200"
            "instant": 1
            "earned_title":"Jam on!"
            "earned_subtitle1":"You are rockin' it to $200!"
            "earned_subtitle2":"a Sunny charm"
            "online_only":0
          }
          {
            "id":"MGRIP-20"
            "name":"Monster Grip"
            "status":0
            "level":"$250"
            "instant": 2
            "earned_title":"You're Grrreat!"
            "earned_subtitle1":"Check you out &mdash; $250 raised!"
            "earned_subtitle2":"Stretch"
            "online_only":0
          }
          {
            "id":"POPPER-20"
            "name":"Popper"
            "status":0
            "level":"$500"
            "instant": 2
            "earned_title":"You're Poppin'!"
            "earned_subtitle1":"You're amazing for raising $500!"
            "earned_subtitle2":"a popper"
            "online_only":0
          }
          {
            "id":"EARBUDS-20"
            "name":"Earbuds"
            "status":0
            "level":"$1,000"
            "instant": 2
            "earned_title":"You did it!"
            "earned_subtitle1":"You hit $1,000!"
            "earned_subtitle2":"ear pods that rock like you"
            "online_only":0
          }
        ]

      giftLevels_instant: -> 
        {
          "$0": [
            "WB-20"
          ]
          "$5-$14":[
            "WB-20"
            "CLIPPERRIE-20"
            "CHARMKNOX-20"
          ]
          "$15-$24":[
            "WB-20"
            "CLIPPERRIE-20"
            "CHARMKNOX-20"
            "JR-20"
          ]
          "$25-$39":[
            "WB-20"
            "CLIPPERRIE-20"
            "CHARMKNOX-20"
            "JR-20"
            "CLIPNICO-20"
          ]
          "$40-$49":[
            "WB-20"
            "CLIPPERRIE-20"
            "CHARMKNOX-20"
            "JR-20"
            "CLIPNICO-20"
            "CHARMSOFIE-20"
          ]
          "$50-$74":[
            "WB-20"
            "CLIPPERRIE-20"
            "CHARMKNOX-20"
            "JR-20"
            "CLIPNICO-20"
            "CHARMSOFIE-20"
            "KHC"
          ]
          "Green $75-$99":[
            "WB-20"
            "CLIPPERRIE-20"
            "CHARMKNOX-20"
            "JR-20"
            "CLIPNICO-20"
            "CHARMSOFIE-20"
            "KHC"
            "PBALL-20"
          ]
          "Blue $100-$199":[
            "WB-20"
            "CLIPPERRIE-20"
            "CHARMKNOX-20"
            "JR-20"
            "CLIPNICO-20"
            "CHARMSOFIE-20"
            "KHC"
            "PBALL-20"
            "CLIPCRUSH-20"
          ]
          "Red $200-$249":[
            "WB-20"
            "CLIPPERRIE-20"
            "CHARMKNOX-20"
            "JR-20"
            "CLIPNICO-20"
            "CHARMSOFIE-20"
            "KHC"
            "PBALL-20"
            "CLIPCRUSH-20"
            "CLIPSUNNY-20"
          ]
          "Orange $250-$499":[
            "WB-20"
            "CLIPPERRIE-20"
            "CHARMKNOX-20"
            "JR-20"
            "CLIPNICO-20"
            "CHARMSOFIE-20"
            "KHC"
            "PBALL-20"
            "CLIPCRUSH-20"
            "CLIPSUNNY-20"
            "MGRIP-20"
          ]
          "Brown $500-$999":[
            "WB-20"
            "CLIPPERRIE-20"
            "CHARMKNOX-20"
            "JR-20"
            "CLIPNICO-20"
            "CHARMSOFIE-20"
            "KHC"
            "PBALL-20"
            "CLIPCRUSH-20"
            "CLIPSUNNY-20"
            "MGRIP-20"
            "POPPER-20"
          ]
          "Yellow $1000+":[
            "WB-20"
            "CLIPPERRIE-20"
            "CHARMKNOX-20"
            "JR-20"
            "CLIPNICO-20"
            "CHARMSOFIE-20"
            "KHC"
            "PBALL-20"
            "CLIPCRUSH-20"
            "CLIPSUNNY-20"
            "MGRIP-20"
            "POPPER-20"
            "EARBUDS-20"
          ]
        }
      giftLevels_noninstant: -> 
        {
          "$0": [
            "WB-20"
          ]
          "$5-$14":[
            "WB-20"
            "LVL1WB-20"
            "CHARMKNOX-20"
          ]
          "$15-$24":[
            "WB-20"
            "LVL1WB-20"
            "CHARMKNOX-20"
            "JR-20"
          ]
          "$25-$39":[
            "WB-20"
            "LVL1WB-20"
            "CHARMKNOX-20"
            "JR-20"
            "CLIPNICO-20"
          ]
          "$40-$49":[
            "WB-20"
            "LVL1WB-20"
            "CHARMKNOX-20"
            "JR-20"
            "CLIPNICO-20"
            "CHARMSOFIE-20"
          ]
          "$50-$74":[
            "WB-20"
            "LVL1WB-20"
            "CHARMKNOX-20"
            "JR-20"
            "CLIPNICO-20"
            "CHARMSOFIE-20"
            "KHC"
          ]
          "Green $75-$99":[
            "WB-20"
            "LVL1WB-20"
            "CHARMKNOX-20"
            "JR-20"
            "CLIPNICO-20"
            "CHARMSOFIE-20"
            "KHC"
            "PBALL-20"
          ]
          "Blue $100-$199":[
            "WB-20"
            "LVL1WB-20"
            "CHARMKNOX-20"
            "JR-20"
            "CLIPNICO-20"
            "CHARMSOFIE-20"
            "KHC"
            "PBALL-20"
            "CLIPCRUSH-20"
          ]
          "Red $200-$249":[
            "WB-20"
            "LVL1WB-20"
            "CHARMKNOX-20"
            "JR-20"
            "CLIPNICO-20"
            "CHARMSOFIE-20"
            "KHC"
            "PBALL-20"
            "CLIPCRUSH-20"
            "CLIPSUNNY-20"
          ]
          "Orange $250-$499":[
            "WB-20"
            "LVL1WB-20"
            "CHARMKNOX-20"
            "JR-20"
            "CLIPNICO-20"
            "CHARMSOFIE-20"
            "KHC"
            "PBALL-20"
            "CLIPCRUSH-20"
            "CLIPSUNNY-20"
            "MGRIP-20"
          ]
          "Brown $500-$999":[
            "WB-20"
            "LVL1WB-20"
            "CHARMKNOX-20"
            "JR-20"
            "CLIPNICO-20"
            "CHARMSOFIE-20"
            "KHC"
            "PBALL-20"
            "CLIPCRUSH-20"
            "CLIPSUNNY-20"
            "MGRIP-20"
            "POPPER-20"
          ]
          "Yellow $1000+":[
            "WB-20"
            "LVL1WB-20"
            "CHARMKNOX-20"
            "JR-20"
            "CLIPNICO-20"
            "CHARMSOFIE-20"
            "KHC"
            "PBALL-20"
            "CLIPCRUSH-20"
            "CLIPSUNNY-20"
            "MGRIP-20"
            "POPPER-20"
            "EARBUDS-20"
          ]
        }
  ]
