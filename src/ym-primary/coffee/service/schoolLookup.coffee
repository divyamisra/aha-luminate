angular.module 'ahaLuminateApp'
  .factory 'SchoolLookupService', [
    '$rootScope'
    '$http'
    '$sce'
    ($rootScope, $http, $sce) ->
      getSchoolCompanies: (requestData) ->
        requestUrl = '/system/proxy.jsp?__proxyURL=' + encodeURIComponent(luminateExtend.global.path.secure + 'CRTeamraiserAPI')
        if window.location.href.indexOf(luminateExtend.global.path.secure) is 0
          requestUrl = 'CRTeamraiserAPI'
        $http
          method: 'POST'
          url: $sce.trustAsResourceUrl(requestUrl)
          data: 'v=1.0&api_key=' + $rootScope.apiKey + '&response_format=json&suppress_response_codes=true&method=getCompaniesByInfo&event_type=' + encodeURIComponent('YM Kids Heart Challenge 2022') + '&' + requestData
          headers:
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
      
      getSchoolData: ->
        requestUrl = luminateExtend.global.path.nonsecure
        if window.location.protocol is 'https:'
          requestUrl = luminateExtend.global.path.secure + 'S'
        requestUrl += 'PageServer?pagename=reus_ym_khc_school_data_csv&pgwrap=n'
        $http.jsonp($sce.trustAsResourceUrl(requestUrl), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response
      
      getSchoolDataByState: (requestData) ->
        requestUrl = luminateExtend.global.path.nonsecure
        if window.location.protocol is 'https:'
          requestUrl = luminateExtend.global.path.secure + 'S'
        requestUrl += 'PageServer?pagename=reus_ym_khc_school_data_csv&state='+requestData+'&pgwrap=n'
        $http.jsonp($sce.trustAsResourceUrl(requestUrl), jsonpCallbackParam: 'callback')
          .then (response) ->
            response
          , (response) ->
            response
      
      # call returns data from DB matching filter criteria passed - school name and optionally the state      
      getSchoolDataNew: (requestData, callback) ->
        url = '//tools.heart.org/ym-khc-schools/schoolProcessing.php?method=getSchoolsByFilter' + requestData
        if $rootScope.tablePrefix is 'heartdev'
          url += '&table=dev'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            callback.success response
          , (response) ->
            callback.failure response
      
      # call returns all schools within 10 miles of lat/long passed
      getGeoSchoolData: (e, callback) ->
        url = '//tools.heart.org/ym-khc-schools/schoolProcessing.php?method=getSchoolsByDistance&lat=' + e.coords.latitude + '&long=' + e.coords.longitude
        if $rootScope.tablePrefix is 'heartdev'
          url += '&table=dev'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            callback.success response
          , (response) ->
            callback.failure response

      # call returns all schools within 10 miles of lat/long passed
      getStateByLocation: (e, callback) ->
        url = '//tools.heart.org/ym-khc-schools/schoolProcessing.php?method=getStateByLocation&lat=' + e.coords.latitude + '&long=' + e.coords.longitude
        if $rootScope.tablePrefix is 'heartdev'
          url += '&table=dev'
        $http.jsonp($sce.trustAsResourceUrl(url), jsonpCallbackParam: 'callback')
          .then (response) ->
            callback.success response
          , (response) ->
            callback.failure response

      # call returns address info for lat/long passed
      getGeoState: (e, callback) ->
        requestUrl = '//maps.googleapis.com/maps/api/geocode/json?sensor=true&latlng=' + e.coords.latitude + ',' + e.coords.longitude
        $http
          method: 'GET'
          url: $sce.trustAsResourceUrl(requestUrl)
          headers:
            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
  ]
