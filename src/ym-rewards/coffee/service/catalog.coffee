angular.module 'ahaLuminateApp'
  .factory 'CatalogService', [
    '$rootScope'
    '$http'
    '$sce'
    '$filter'
    'LuminateRESTService'
    ($rootScope, $http, $sce, $filter, LuminateRESTService) ->
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

      getStudentDetail: (requestData, callback) ->
        if $rootScope.tablePrefix is 'heartdev'
          url = '//tools.heart.org/ym-school-plan/schoolPlan.php?env=_dev&EventProgram=KHC&method=GetStudentDetail' + requestData
        else if $rootScope.tablePrefix is 'heartnew'
          url = '//tools.heart.org/ym-school-plan/schoolPlan.php?env=_new&EventProgram=KHC&method=GetStudentDetail' + requestData
        else
          url = '//tools.heart.org/ym-school-plan/schoolPlan.php?EventProgram=KHC&method=GetStudentDetail' + requestData
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            if response.data.success is false
              callback.error response
            else
              callback.success response
          , (response) ->
            callback.failure response
            
      getRegistration: ->
        LuminateRESTService.teamraiserRequest 'method=getRegistration', true, true
          .then (response) ->
            participantRegistration = response.data.getRegistrationResponse?.registration
            if not participantRegistration
              $scope.participantRegistration = -1
            else
              participantRegistration.goalFormatted = if participantRegistration.goal then $filter('currency')(participantRegistration.goal / 100, '$').replace('.00', '') else '$0'
              $scope.participantRegistration = participantRegistration
              if not participantRegistration.companyInformation?.companyId
                $scope.companyInfo = -1
            response
  ]
