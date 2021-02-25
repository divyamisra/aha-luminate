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
            "id":"WB1RED-21"
            "name":"Red Wristband"
            "status":0
            "level":""
            "level_desc":""
            "instant": 1
            "earned_title":"Get ready for fun"
            "earned_subtitle1":"Thank you for joining Kids Heart Challenge and registering online!"
            "earned_subtitle2":"You earned a wristband with a secret message!"
            "earned_subtitle3":"and you'll earn a wristband."
            "online_only":0
            "video": ""
          }
          {
            "id":"DASHCLIP-21"
            "name":"Dash"
            "status":0
            "level":"$5"
            "instant": 1
            "earned_title":"doin' a happy dance"
            "earned_subtitle1":"We're so happy you earned Dash for raising $5!"
            "earned_subtitle2":"It's important to move daily like Dash."
            "earned_subtitle3":"and you'll earn Dash."
            "online_only":0
            "video": ""
          }
          {
            "id":"LVL1WB-21"
            "name":"Water Bottle"
            "status":0
            "level":"$5"
            "instant": 0
            "earned_title":"Stay Hydrated!"
            "earned_subtitle1":"You've raised $5!"
            "earned_subtitle2":"a water bottle"
            "earned_subtitle3":"and you'll earn a water bottle."
            "online_only":0
            "video": ""
          }
          {
            "id":"SAMCLIP-21"
            "name":"Sam"
            "status":0
            "level":"$10"
            "instant": 1
            "earned_title":"Kickin' it ninja style"
            "earned_subtitle1":"Take a bow for earning Sam for raising $10!"
            "earned_subtitle2":"Always make a good choice like Sam and say NO to vaping and tobacco."
            "earned_subtitle3":"and you'll earn Sam."
            "online_only":1
            "video": ""
          }
          {
            "id":"YOYO-21"
            "name":"Spaghetti YoYo"
            "status":0
            "level":"$15"
            "instant": 2
            "earned_title":"You're on a roll"
            "earned_subtitle1":"A spaghetti yoyo is on the way for raising $15!"
            "earned_subtitle2":"Keep working hard towards your goal."
            "earned_subtitle3":"and you'll earn a spaghetti yoyo."
            "online_only":0
            "video": "https://vimeo.com/americanheartassociation/review/453777085/ab8611f4ce"
          }
          {
            "id":"IKERCLIP-21"
            "name":"Iker"
            "status":0
            "level":"$25"
            "instant": 1
            "earned_title":"Leading the pack"
            "earned_subtitle1":"Be proud you earned Iker by raising $25!"
            "earned_subtitle2":"Stand up for what's right like Iker."
            "earned_subtitle3":"and you'll earn Iker."
            "online_only":0
            "video": "https://video.link/w/D17X"
          }
          {
            "id":"KAICLIP-21"
            "name":"Kai"
            "status":0
            "level":"$40"
            "instant": 1
            "earned_title":"You're rad"
            "earned_subtitle1":"You earned Kai for raising $40!"
            "earned_subtitle2":"Keep it cool just like Kai."
            "earned_subtitle3":"and you'll earn Kai."
            "online_only":1
            "video": "https://vimeo.com/americanheartassociation/review/453778802/c7317f5ef3"
          }
          {
            "id":"KHC"
            "name":"T-Shirt"
            "status":0
            "level":"$50"
            "instant": 2
            "earned_title":"Tee it up"
            "earned_subtitle1":"Because you raised $50 you'll receive a challenge shirt!"
            "earned_subtitle2":"Show off your spirit for being healthy."
            "earned_subtitle3":"and you'll earn a t-shirt."
            "online_only":0
            "video": ""
          }
          {
            "id":"PBALL-21"
            "name":"Playground Ball"
            "status":0
            "level":"$75"
            "instant": 2
            "earned_title":"Have a ball"
            "earned_subtitle1":"Thanks for all your hard work and raising $75!"
            "earned_subtitle2":"You've earned a playground ball."
            "earned_subtitle3":"and you'll earn a playground ball."
            "online_only":0
            "video": ""
          }
          {
            "id":"JOURNEYCLIP-21"
            "name":"Journey"
            "status":0
            "level":"$100"
            "instant": 1
            "earned_title":"Lots o' love for you"
            "earned_subtitle1":"We're so happy you earned Journey by raising $100!"
            "earned_subtitle2":"Be kind to others just like Journey."
            "earned_subtitle3":"and you'll earn Journey."
            "online_only":0
            "video": ""
          }
          {
            "id":"TAYESCOUTCLIP-21"
            "name":"Taye & Scout"
            "status":0
            "level":"$200"
            "instant": 1
            "earned_title":"You're paw-some"
            "earned_subtitle1":"Nice job earning Taye & Scout for raising $200!"
            "earned_subtitle2":"Always help others just like them."
            "earned_subtitle3":"and you'll earn Taye & Scout."
            "online_only":0
            "video": "https://vimeo.com/americanheartassociation/review/453776957/cde52d6c23"
          }
          {
            "id":"SOCKS-21"
            "name":"Dash's Socks"
            "status":0
            "level":"$250"
            "instant": 2
            "earned_title":"Jump in feet first"
            "earned_subtitle1":"You're knocking our socks off so you earned a pair for raising $250!"
            "earned_subtitle2":"Take a walk...with your new socks."
            "earned_subtitle3":"and you'll earn Dash's Socks."
            "online_only":0
            "video": "https://vimeo.com/americanheartassociation/review/453778215/f7dc25f047"
          }
          {
            "id":"POPPER-21"
            "name":"Ball Launcher"
            "status":0
            "level":"$500"
            "instant": 2
            "earned_title":"Top of the pops"
            "earned_subtitle1":"Your hard work raising $500 earned you a Ball Launcher!"
            "earned_subtitle2":"Stop drinking pop...pick water instead."
            "earned_subtitle3":"and you'll earn a Ball Launcher."
            "online_only":0
            "video": ""
          }
          {
            "id":"SPEAKER-21"
            "name":"Speaker"
            "status":0
            "level":"$1,000"
            "instant": 2
            "earned_title":"Way to go!"
            "earned_subtitle1":"Nice job raising $1,000!"
            "earned_subtitle2":"Your hard work earned you a Kai speaker that totally rocks like you."
            "earned_subtitle3":"and you'll earn a Kai speaker."
            "online_only":0
            "video": "https://video.link/w/On7X"
          }
        ]

      giftLevels_instant: -> 
        {
          "$0": [
            "WB1RED-21"
          ]
          "$5-$14":[
            "WB1RED-21"
            "DASHCLIP-21"
            "SAMCLIP-21"
          ]
          "$15-$24":[
            "WB1RED-21"
            "DASHCLIP-21"
            "SAMCLIP-21"
            "YOYO-21"
          ]
          "$25-$39":[
            "WB1RED-21"
            "DASHCLIP-21"
            "SAMCLIP-21"
            "YOYO-21"
            "IKERCLIP-21"
          ]
          "$40-$49":[
            "WB1RED-21"
            "DASHCLIP-21"
            "SAMCLIP-21"
            "YOYO-21"
            "IKERCLIP-21"
            "KAICLIP-21"
          ]
          "$50-$74":[
            "WB1RED-21"
            "DASHCLIP-21"
            "SAMCLIP-21"
            "YOYO-21"
            "IKERCLIP-21"
            "KAICLIP-21"
            "KHC"
          ]
          "Green $75-$99":[
            "WB1RED-21"
            "DASHCLIP-21"
            "SAMCLIP-21"
            "YOYO-21"
            "IKERCLIP-21"
            "KAICLIP-21"
            "KHC"
            "PBALL-21"
          ]
          "Blue $100-$199":[
            "WB1RED-21"
            "DASHCLIP-21"
            "SAMCLIP-21"
            "YOYO-21"
            "IKERCLIP-21"
            "KAICLIP-21"
            "KHC"
            "PBALL-21"
            "JOURNEYCLIP-21"
          ]
          "Red $200-$249":[
            "WB1RED-21"
            "DASHCLIP-21"
            "SAMCLIP-21"
            "YOYO-21"
            "IKERCLIP-21"
            "KAICLIP-21"
            "KHC"
            "PBALL-21"
            "JOURNEYCLIP-21"
            "TAYESCOUTCLIP-21"
          ]
          "Orange $250-$499":[
            "WB1RED-21"
            "DASHCLIP-21"
            "SAMCLIP-21"
            "YOYO-21"
            "IKERCLIP-21"
            "KAICLIP-21"
            "KHC"
            "PBALL-21"
            "JOURNEYCLIP-21"
            "TAYESCOUTCLIP-21"
            "SOCKS-21"
          ]
          "Brown $500-$999":[
            "WB1RED-21"
            "DASHCLIP-21"
            "SAMCLIP-21"
            "YOYO-21"
            "IKERCLIP-21"
            "KAICLIP-21"
            "KHC"
            "PBALL-21"
            "JOURNEYCLIP-21"
            "TAYESCOUTCLIP-21"
            "SOCKS-21"
            "POPPER-21"
          ]
          "Yellow $1000+":[
            "WB1RED-21"
            "DASHCLIP-21"
            "SAMCLIP-21"
            "YOYO-21"
            "IKERCLIP-21"
            "KAICLIP-21"
            "KHC"
            "PBALL-21"
            "JOURNEYCLIP-21"
            "TAYESCOUTCLIP-21"
            "SOCKS-21"
            "POPPER-21"
            "SPEAKER-21"
          ]
        }
      giftLevels_noninstant: -> 
        {
          "$0": [
            "WB1RED-21"
          ]
          "$5-$14":[
            "WB1RED-21"
            "LVL1WB-21"
            "SAMCLIP-21"
          ]
          "$15-$24":[
            "WB1RED-21"
            "LVL1WB-21"
            "SAMCLIP-21"
            "YOYO-21"
          ]
          "$25-$39":[
            "WB1RED-21"
            "LVL1WB-21"
            "SAMCLIP-21"
            "YOYO-21"
            "IKERCLIP-21"
          ]
          "$40-$49":[
            "WB1RED-21"
            "LVL1WB-21"
            "SAMCLIP-21"
            "YOYO-21"
            "IKERCLIP-21"
            "KAICLIP-21"
          ]
          "$50-$74":[
            "WB1RED-21"
            "LVL1WB-21"
            "SAMCLIP-21"
            "YOYO-21"
            "IKERCLIP-21"
            "KAICLIP-21"
            "KHC"
          ]
          "Green $75-$99":[
            "WB1RED-21"
            "LVL1WB-21"
            "SAMCLIP-21"
            "YOYO-21"
            "IKERCLIP-21"
            "KAICLIP-21"
            "KHC"
            "PBALL-21"
          ]
          "Blue $100-$199":[
            "WB1RED-21"
            "LVL1WB-21"
            "SAMCLIP-21"
            "YOYO-21"
            "IKERCLIP-21"
            "KAICLIP-21"
            "KHC"
            "PBALL-21"
            "JOURNEYCLIP-21"
          ]
          "Red $200-$249":[
            "WB1RED-21"
            "LVL1WB-21"
            "SAMCLIP-21"
            "YOYO-21"
            "IKERCLIP-21"
            "KAICLIP-21"
            "KHC"
            "PBALL-21"
            "JOURNEYCLIP-21"
            "TAYESCOUTCLIP-21"
          ]
          "Orange $250-$499":[
            "WB1RED-21"
            "LVL1WB-21"
            "SAMCLIP-21"
            "YOYO-21"
            "IKERCLIP-21"
            "KAICLIP-21"
            "KHC"
            "PBALL-21"
            "JOURNEYCLIP-21"
            "TAYESCOUTCLIP-21"
            "SOCKS-21"
          ]
          "Brown $500-$999":[
            "WB1RED-21"
            "LVL1WB-21"
            "SAMCLIP-21"
            "YOYO-21"
            "IKERCLIP-21"
            "KAICLIP-21"
            "KHC"
            "PBALL-21"
            "JOURNEYCLIP-21"
            "TAYESCOUTCLIP-21"
            "SOCKS-21"
            "POPPER-21"
          ]
          "Yellow $1000+":[
            "WB1RED-21"
            "LVL1WB-21"
            "SAMCLIP-21"
            "YOYO-21"
            "IKERCLIP-21"
            "KAICLIP-21"
            "KHC"
            "PBALL-21"
            "JOURNEYCLIP-21"
            "TAYESCOUTCLIP-21"
            "SOCKS-21"
            "POPPER-21"
            "SPEAKER-21"
          ]
        }
  ]
