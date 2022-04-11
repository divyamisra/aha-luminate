angular.module 'ahaLuminateApp'
  .factory 'ZuriService', [
    '$rootScope'
    '$http'
    '$sce'
    ($rootScope, $http, $sce) ->
      getChallenges: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/aha_ym22_dev/api/student/challenges/' + requestData + '?key=k7wvZXDpmDpenVcp'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ym22_testing/api/student/challenges/' + requestData + '?key=k7wvZXDpmDpenVcp'
        else
          url = '//tools.heart.org/aha_ym22/api/student/challenges/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            if response.data.success is false
              callback.error response
            else
              callback.success response
          , (response) ->
            callback.failure response
      
      updateChallenge: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/aha_ym22_dev/api/student/challenge/' + requestData + '&key=k7wvZXDpmDpenVcp'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ym22_testing/api/student/challenge/' + requestData + '&key=k7wvZXDpmDpenVcp'
        else
          url = '//tools.heart.org/aha_ym22/api/student/challenge/' + requestData + '&key=XgUnZxvFcjZ4jEMT'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')

          .then (response) ->
            callback.success response
          , (response) ->
            callback.failure response
      
      logChallenge: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/aha_ym22_dev/api/student/' + requestData + '?key=k7wvZXDpmDpenVcp'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ym22_testing/api/student/' + requestData + '?key=k7wvZXDpmDpenVcp'
        else
          url = '//tools.heart.org/aha_ym22/api/student/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            callback.success response
          , (response) ->
            callback.failure response
      
      getStudent: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/aha_ym22_dev/api/student/' + requestData + '?key=k7wvZXDpmDpenVcp'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ym22_testing/api/student/' + requestData + '?key=k7wvZXDpmDpenVcp'
        else
          url = '//tools.heart.org/aha_ym22/api/student/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            if response.data.success is false
              callback.error response
            else
              callback.success response
          , (response) ->
            callback.failure response
      
      getSchool: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/aha_ym22_dev/api/program/school/' + requestData + '?key=k7wvZXDpmDpenVcp'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ym22_testing/api/program/school/' + requestData + '?key=k7wvZXDpmDpenVcp'
        else
          url = '//tools.heart.org/aha_ym22/api/program/school/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            if response.data.success is false
              callback.error response
            else
              callback.success response
          , (response) ->
            callback.failure response
      
      getTeam: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/aha_ym22_dev/api/program/team/' + requestData + '?key=k7wvZXDpmDpenVcp'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ym22_testing/api/program/team/' + requestData + '?key=k7wvZXDpmDpenVcp'
        else
          url = '//tools.heart.org/aha_ym22/api/program/team/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            if response.data.success is false
              callback.error response
            else
              callback.success response
          , (response) ->
            callback.failure response
      
      getProgram: (callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/aha_ym22_dev/api/program?key=k7wvZXDpmDpenVcp'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ym22_testing/api/program?key=k7wvZXDpmDpenVcp'
        else
          url = '//tools.heart.org/aha_ym22/api/program?key=XgUnZxvFcjZ4jEMT'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            if response.data.success is false
              callback.error response
            else
              callback.success response
          , (response) ->
            callback.failure response
      
      eCardTracking: (requestData) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/aha_ym22_dev/visitlink_record.php?ecard_linktrack=' + requestData
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ym22_testing/visitlink_record.php?ecard_linktrack=' + requestData
        else
          url = '//tools.heart.org/aha_ym22/visitlink_record.php?ecard_linktrack=' + requestData
        $http
          method: 'POST'
          url: $sce.trustAsResourceUrl(url)
      
      getAvatar: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//khc.staging.ootqa.org/api/points/student/' + requestData
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//khc.staging.ootqa.org/api/points/student/' + requestData
        else
          url = '//kidsheartchallenge.heart.org/api/points/student/' + requestData
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            if response.data.success is false
              callback.error response
            else
              callback.success response
          , (response) ->
            callback.failure response

      getSchoolData: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/aha_ym22_dev/api/school/' + requestData + '/meta?key=k7wvZXDpmDpenVcp'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ym22_testing/api/school/' + requestData + '/meta?key=k7wvZXDpmDpenVcp'
        else
          url = '//tools.heart.org/aha_ym22/api/school/' + requestData + '/meta?key=XgUnZxvFcjZ4jEMT'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            if response.data.success is false
              callback.error response
            else
              callback.success response
          , (response) ->
            callback.failure response

      updateSchoolData: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/aha_ym22_dev/api/school/' + requestData + '&key=k7wvZXDpmDpenVcp'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ym22_testing/api/school/' + requestData + '&key=k7wvZXDpmDpenVcp'
        else
          url = '//tools.heart.org/aha_ym22/api/school/' + requestData + '&key=XgUnZxvFcjZ4jEMT'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            callback.success response
          , (response) ->
            callback.failure response
            
      schoolPlanData: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/ym-school-plan/schoolPlan.php?env=_dev&EventProgram=KHC' + requestData
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/ym-school-plan/schoolPlan.php?env=_new&EventProgram=KHC' + requestData
        else
          url = '//tools.heart.org/ym-school-plan/schoolPlan.php?EventProgram=KHC' + requestData
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            if response.data.success is false
              callback.error response
            else
              callback.success response
          , (response) ->
            callback.failure response
            
  ]
