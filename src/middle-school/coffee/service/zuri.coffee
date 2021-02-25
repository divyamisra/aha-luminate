angular.module 'ahaLuminateApp'
  .factory 'ZuriService', [
    '$rootScope'
    '$http'
    '$sce'
    ($rootScope, $http, $sce) ->
      getSchoolChallenges: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/aha_ahc21_dev/api/program/school/' + requestData + '?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc21_testing/api/program/school/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc21/api/program/school/' + requestData + '?key=B78AEYxzbU9br6Cq'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            if response.data.success is false
              callback.error response
            else
              callback.success response
          , (response) ->
            callback.failure response

      getChallenges: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/aha_ahc21_dev/api/student/challenges/' + requestData + '?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc21_testing/api/student/challenges/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc21/api/student/challenges/' + requestData + '?key=B78AEYxzbU9br6Cq'
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
          url = '//tools.heart.org/aha_ahc21_dev/api/student/challenge/' + requestData + '&key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc21_testing/api/student/challenge/' + requestData + '&key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc21/api/student/challenge/' + requestData + '&key=B78AEYxzbU9br6Cq'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')

          .then (response) ->
            callback.success response
          , (response) ->
            callback.failure response
      
      logChallenge: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/aha_ahc21_dev/api/student/' + requestData + '?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc21_testing/api/student/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc21/api/student/' + requestData + '?key=B78AEYxzbU9br6Cq'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            callback.success response
          , (response) ->
            callback.failure response
      
      getStudent: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/aha_ahc21_dev/api/student/' + requestData + '?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc21_testing/api/student/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc21/api/student/' + requestData + '?key=B78AEYxzbU9br6Cq'
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
          url = '//tools.heart.org/aha_ahc21_dev/api/program/school/' + requestData + '?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc21_testing/api/program/school/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc21/api/program/school/' + requestData + '?key=B78AEYxzbU9br6Cq'
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
          url = '//tools.heart.org/aha_ahc21_dev/api/program/team/' + requestData + '?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc21_testing/api/program/team/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc21/api/program/team/' + requestData + '?key=B78AEYxzbU9br6Cq'
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
          url = '//tools.heart.org/aha_ahc21_dev/api/program?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc21_testing/api/program?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc21/api/program?key=B78AEYxzbU9br6Cq'
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
          url = '//tools.heart.org/aha_ahc21_dev/api/school/' + requestData + '/meta?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc21_testing/api/school/' + requestData + '/meta?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc21/api/school/' + requestData + '/meta?key=B78AEYxzbU9br6Cq'
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
          url = '//tools.heart.org/aha_ahc21_dev/api/school/' + requestData + '&key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc21_testing/api/school/' + requestData + '&key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc21/api/school/' + requestData + '&key=B78AEYxzbU9br6Cq'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            callback.success response
          , (response) ->
            callback.failure response
  ]
