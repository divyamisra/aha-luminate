
angular.module 'ahaLuminateApp'
  .factory 'CompanyService', [
    '$rootScope'
    '$http'
    '$sce'
    'LuminateRESTService'
    ($rootScope, $http, $sce, LuminateRESTService) ->
      getSchoolDates: (requestData) ->
        requestUrl = luminateExtend.global.path.nonsecure
        if window.location.protocol is 'https:'
          requestUrl = luminateExtend.global.path.secure + 'S'
        requestUrl += 'PageServer?pagename=reus_ym_ahc_school_dates_csv&evid='+$rootScope.frId+'&pgwrap=n'
        $http.jsonp($sce.trustAsResourceUrl(requestUrl), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response
      

  ]
