angular.module 'ahaLuminateApp'
  .factory 'ZuriService', [
    '$rootScope'
    '$http'
    '$sce'
    ($rootScope, $http, $sce) ->
      getSchoolChallenges: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//hearttools.heart.org/aha_ahc20_dev/api/program/school/' + requestData + '?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//hearttools.heart.org/aha_ahc20_testing/api/program/school/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//hearttools.heart.org/aha_ahc20/api/program/school/' + requestData + '?key=B78AEYxzbU9br6Cq'
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
          url = '//hearttools.heart.org/aha_ahc20_dev/api/student/challenges/' + requestData + '?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//hearttools.heart.org/aha_ahc20_testing/api/student/challenges/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//hearttools.heart.org/aha_ahc20/api/student/challenges/' + requestData + '?key=B78AEYxzbU9br6Cq'
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
          url = '//hearttools.heart.org/aha_ahc20_dev/api/student/challenge/' + requestData + '&key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//hearttools.heart.org/aha_ahc20_testing/api/student/challenge/' + requestData + '&key=XgUnZxvFcjZ4jEMT'
        else
          url = '//hearttools.heart.org/aha_ahc20/api/student/challenge/' + requestData + '&key=B78AEYxzbU9br6Cq'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')

          .then (response) ->
            callback.success response
          , (response) ->
            callback.failure response
      
      logChallenge: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//hearttools.heart.org/aha_ahc20_dev/api/student/' + requestData + '?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//hearttools.heart.org/aha_ahc20_testing/api/student/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//hearttools.heart.org/aha_ahc20/api/student/' + requestData + '?key=B78AEYxzbU9br6Cq'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            callback.success response
          , (response) ->
            callback.failure response
      
      getStudent: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//hearttools.heart.org/aha_ahc20_dev/api/student/' + requestData + '?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//hearttools.heart.org/aha_ahc20_testing/api/student/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//hearttools.heart.org/aha_ahc20/api/student/' + requestData + '?key=B78AEYxzbU9br6Cq'
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
          url = '//hearttools.heart.org/aha_ahc20_dev/api/program/school/' + requestData + '?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//hearttools.heart.org/aha_ahc20_testing/api/program/school/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//hearttools.heart.org/aha_ahc20/api/program/school/' + requestData + '?key=B78AEYxzbU9br6Cq'
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
          url = '//hearttools.heart.org/aha_ahc20_dev/api/program/team/' + requestData + '?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//hearttools.heart.org/aha_ahc20_testing/api/program/team/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//hearttools.heart.org/aha_ahc20/api/program/team/' + requestData + '?key=B78AEYxzbU9br6Cq'
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
          url = '//hearttools.heart.org/aha_ahc20_dev/api/program?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//hearttools.heart.org/aha_ahc20_testing/api/program?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//hearttools.heart.org/aha_ahc20/api/program?key=B78AEYxzbU9br6Cq'
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
          url = '//hearttools.heart.org/aha_ahc20_dev/api/school/' + requestData + '/years-participated?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//hearttools.heart.org/aha_ahc20_testing/api/school/' + requestData + '/years-participated?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//hearttools.heart.org/aha_ahc20/api/school/' + requestData + '/years-participated?key=B78AEYxzbU9br6Cq'
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
          url = '//hearttools.heart.org/aha_ahc20_dev/api/school/' + requestData + '&key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//hearttools.heart.org/aha_ahc20_testing/api/school/' + requestData + '&key=XgUnZxvFcjZ4jEMT'
        else
          url = '//hearttools.heart.org/aha_ahc20/api/school/' + requestData + '&key=B78AEYxzbU9br6Cq'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            callback.success response
          , (response) ->
            callback.failure response
  ]
