angular.module 'ahaLuminateApp'
  .factory 'ZuriService', [
    '$rootScope'
    '$http'
    '$sce'
    ($rootScope, $http, $sce) ->
      getSchoolChallenges: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/aha_ahc23_dev/api/program/school/' + requestData + '?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc23_testing/api/program/school/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc23/api/program/school/' + requestData + '?key=B78AEYxzbU9br6Cq'
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
          url = '//tools.heart.org/aha_ahc23_dev/api/student/challenges/' + requestData + '?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc23_testing/api/student/challenges/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc23/api/student/challenges/' + requestData + '?key=B78AEYxzbU9br6Cq'
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
          url = '//tools.heart.org/aha_ahc23_dev/api/student/challenge/' + requestData + '&key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc23_testing/api/student/challenge/' + requestData + '&key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc23/api/student/challenge/' + requestData + '&key=B78AEYxzbU9br6Cq'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')

          .then (response) ->
            callback.success response
          , (response) ->
            callback.failure response
      
      logChallenge: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/aha_ahc23_dev/api/student/' + requestData + '?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc23_testing/api/student/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc23/api/student/' + requestData + '?key=B78AEYxzbU9br6Cq'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            callback.success response
          , (response) ->
            callback.failure response
      
      getStudent: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/aha_ahc23_dev/api/student/' + requestData + '?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc23_testing/api/student/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc23/api/student/' + requestData + '?key=B78AEYxzbU9br6Cq'
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
          url = '//tools.heart.org/aha_ahc23_dev/api/program/school/' + requestData + '?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc23_testing/api/program/school/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc23/api/program/school/' + requestData + '?key=B78AEYxzbU9br6Cq'
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
          url = '//tools.heart.org/aha_ahc23_dev/api/program/team/' + requestData + '?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc23_testing/api/program/team/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc23/api/program/team/' + requestData + '?key=B78AEYxzbU9br6Cq'
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
          url = '//tools.heart.org/aha_ahc23_dev/api/program?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc23_testing/api/program?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc23/api/program?key=B78AEYxzbU9br6Cq'
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
          url = '//tools.heart.org/aha_ahc23_dev/api/school/' + requestData + '/meta?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc23_testing/api/school/' + requestData + '/meta?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc23/api/school/' + requestData + '/meta?key=B78AEYxzbU9br6Cq'
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
          url = '//tools.heart.org/aha_ahc23_dev/api/school/' + requestData + '&key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc23_testing/api/school/' + requestData + '&key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc23/api/school/' + requestData + '&key=B78AEYxzbU9br6Cq'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            callback.success response
          , (response) ->
            callback.failure response
            
      getVolunteerData: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/aha_ahc23_dev/api/volunteerism/' + requestData + '?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc23_testing/api/volunteerism/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc23/api/volunteerism/' + requestData + '?key=B78AEYxzbU9br6Cq'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            callback.success response
          , (response) ->
            callback.failure response
            
      getVolunteerAdminData: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/volunteer/volunteer-admin-report.php?env=_dev&school_id=' + requestData
        else
          url = '//tools.heart.org/volunteer/volunteer-admin-report.php?school_id=' + requestData
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            if response.data.success is false
              callback.error response
            else
              callback.success response
          , (response) ->
            callback.failure response
            
      createVolunteerData: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/aha_ahc23_dev/api/volunteerism?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc23_testing/api/volunteerism?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc23/api/volunteerism?key=B78AEYxzbU9br6Cq'
        $http({method: 'POST', url: $sce.trustAsResourceUrl(url), data: requestData})
          .then (response) ->
            callback.success response
          , (response) ->
            callback.failure response

      saveVolunteerData: (id, requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/aha_ahc23_dev/api/volunteerism/' + id + '?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc23_testing/api/volunteerism/' + id + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc23/api/volunteerism/' + id + '?key=B78AEYxzbU9br6Cq'
        $http({method: 'PUT', url: $sce.trustAsResourceUrl(url), data: JSON.stringify(requestData)})
          .then (response) ->
            callback.success response
          , (response) ->
            callback.failure response
            
      deleteVolunteerData: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/aha_ahc23_dev/api/volunteerism/' + requestData + '?key=RByQUbXzYLBchS3n'
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/aha_ahc23_testing/api/volunteerism/' + requestData + '?key=XgUnZxvFcjZ4jEMT'
        else
          url = '//tools.heart.org/aha_ahc23/api/volunteerism/' + requestData + '?key=B78AEYxzbU9br6Cq'
        $http({method: 'DELETE', url: $sce.trustAsResourceUrl(url)})
          .then (response) ->
            callback.success response
          , (response) ->
            callback.failure response

      getSchools: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/ym-school-plan/schoolPlan.php?env=_dev&EventProgram=AHC&method=GetSchools' + requestData
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/ym-school-plan/schoolPlan.php?env=_new&EventProgram=AHC&method=GetSchools' + requestData
        else
          url = '//tools.heart.org/ym-school-plan/schoolPlan.php?EventProgram=AHC&method=GetSchools' + requestData
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            if response.data.success is false
              callback.error response
            else
              callback.success response
          , (response) ->
            callback.failure response

      getSchoolDetail: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/ym-school-plan/schoolPlan.php?env=_dev&EventProgram=AHC&method=GetSchoolDetail' + requestData
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/ym-school-plan/schoolPlan.php?env=_new&EventProgram=AHC&method=GetSchoolDetail' + requestData
        else
          url = '//tools.heart.org/ym-school-plan/schoolPlan.php?EventProgram=AHC&method=GetSchoolDetail' + requestData
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            if response.data.success is false
              callback.error response
            else
              callback.success response
          , (response) ->
            callback.failure response
            
      schoolPlanData: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/ym-school-plan/schoolPlan.php?env=_dev&EventProgram=AHC' + requestData
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/ym-school-plan/schoolPlan.php?env=_new&EventProgram=AHC' + requestData
        else
          url = '//tools.heart.org/ym-school-plan/schoolPlan.php?EventProgram=AHC' + requestData
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            if response.data.success is false
              callback.error response
            else
              callback.success response
          , (response) ->
            callback.failure response
  ]
