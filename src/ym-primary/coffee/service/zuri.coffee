angular.module 'ahaLuminateApp'
  .factory 'ZuriService', [
    '$rootScope'
    '$http'
    '$sce'
    ($rootScope, $http, $sce) ->
      getChallenges: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//hearttools.heart.org/aha_ym20_dev/api/student/challenges/' + requestData + '?key=k7wvZXDpmDpenVcp'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//hearttools.heart.org/aha_ym20_testing/api/student/challenges/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//hearttools.heart.org/aha_ym20/api/student/challenges/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
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
          url = '//hearttools.heart.org/aha_ym20_dev/api/student/challenge/' + requestData + '&key=k7wvZXDpmDpenVcp'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//hearttools.heart.org/aha_ym20_testing/api/student/challenge/' + requestData + '&key=XgUnZxvFcjZ4jEMT'
        else
          url = '//hearttools.heart.org/aha_ym20/api/student/challenge/' + requestData + '&key=XgUnZxvFcjZ4jEMT'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')

          .then (response) ->
            callback.success response
          , (response) ->
            callback.failure response
      
      logChallenge: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//hearttools.heart.org/aha_ym20_dev/api/student/' + requestData + '?key=k7wvZXDpmDpenVcp'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//hearttools.heart.org/aha_ym20_testing/api/student/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//hearttools.heart.org/aha_ym20/api/student/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            callback.success response
          , (response) ->
            callback.failure response
      
      getStudent: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//hearttools.heart.org/aha_ym20_dev/api/student/' + requestData + '?key=k7wvZXDpmDpenVcp'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//hearttools.heart.org/aha_ym20_testing/api/student/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//hearttools.heart.org/aha_ym20/api/student/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
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
          url = '//hearttools.heart.org/aha_ym20_dev/api/program/school/' + requestData + '?key=k7wvZXDpmDpenVcp'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//hearttools.heart.org/aha_ym20_testing/api/program/school/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//hearttools.heart.org/aha_ym20/api/program/school/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
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
          url = '//hearttools.heart.org/aha_ym20_dev/api/program/team/' + requestData + '?key=k7wvZXDpmDpenVcp'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//hearttools.heart.org/aha_ym20_testing/api/program/team/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//hearttools.heart.org/aha_ym20/api/program/team/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
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
          url = '//hearttools.heart.org/aha_ym20_dev/api/program?key=k7wvZXDpmDpenVcp'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//hearttools.heart.org/aha_ym20_testing/api/program?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//hearttools.heart.org/aha_ym20/api/program?key=XgUnZxvFcjZ4jEMT'
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
          url = '//hearttools.heart.org/aha_ym20_dev/visitlink_record.php?ecard_linktrack=' + requestData
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//hearttools.heart.org/aha_ym20_testing/visitlink_record.php?ecard_linktrack=' + requestData
        else
          url = '//hearttools.heart.org/aha_ym20/visitlink_record.php?ecard_linktrack=' + requestData
        $http
          method: 'POST'
          url: $sce.trustAsResourceUrl(url)
      
      getAvatar: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//khc.staging.ootqa.org/api/points/student/' + requestData
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//khc.dev.ootqa.org/api/points/student/' + requestData
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

      getSchoolYears: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//hearttools.heart.org/aha_ym20_dev/api/school/' + requestData + '/years-participated?key=k7wvZXDpmDpenVcp'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//hearttools.heart.org/aha_ym20_testing/api/school/' + requestData + '/years-participated?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//hearttools.heart.org/aha_ym20/api/school/' + requestData + '/years-participated?key=XgUnZxvFcjZ4jEMT'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            if response.data.success is false
              callback.error response
            else
              callback.success response
          , (response) ->
            callback.failure response

      updateSchoolYears: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//hearttools.heart.org/aha_ym20_dev/api/school/' + requestData + '&key=k7wvZXDpmDpenVcp'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//hearttools.heart.org/aha_ym20_testing/api/school/' + requestData + '&key=XgUnZxvFcjZ4jEMT'
        else
          url = '//hearttools.heart.org/aha_ym20/api/school/' + requestData + '&key=XgUnZxvFcjZ4jEMT'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            callback.success response
          , (response) ->
            callback.failure response
            
  ]
