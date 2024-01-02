angular.module 'trPcApp'
  .factory 'NgPcTeamraiserReportsService', [
    '$rootScope'
    '$http'
    ($rootScope, $http) ->
      getSchoolDetailReport: (prevFrId, prevCompanyId) ->
        requestUrl = 'SPageServer?pagename=getYmKhcSchoolDetailReport&pgwrap=n&fr_id=' + $rootScope.frId
        if prevFrId
          requestUrl += '&prev_fr_id=' + prevFrId
        if prevCompanyId
          requestUrl += '&prev_company_id=' + prevCompanyId
        requestUrl += '&response_format=json'
        $http
          method: 'GET'
          url: requestUrl
        .then (response) ->
          response

      getSchoolChallengeReport: (frId) ->
        requestUrl = 'SPageServer?pagename=getYmKhcSchoolChallengeReport&pgwrap=n&fr_id=' + $rootScope.frId
        requestUrl += '&response_format=json'
        $http
          method: 'GET'
          url: requestUrl
        .then (response) ->
          response



  ]
