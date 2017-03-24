angular.module 'ahaLuminateApp'
  .factory 'ZuriService', [
    '$rootScope'
    '$http'
    '$sce'
    ($rootScope, $http, $sce) ->
      getZooStudent: (requestData, callback) ->
        url = 'http://hearttools.heart.org/aha_ym18/api/student/'+requestData+'?key=6Mwqh5dFV39HLDq7'
        urlSCE = $sce.trustAsResourceUrl(url)
        $http.jsonp(urlSCE, jsonpCallbackParam: 'callback').then (response) ->
          if response.data.success == false
            callback.error(response)
          else
            callback.success(response)

      getZooSchool: (requestData, callback) ->
        url = 'http://hearttools.heart.org/aha_ym18/api/program/school/'+requestData+'?key=6Mwqh5dFV39HLDq7'
        urlSCE = $sce.trustAsResourceUrl(url)
        $http.jsonp(urlSCE, jsonpCallbackParam: 'callback').then (response) ->
          if response.data.success == false
            callback.error(response)
          else
            callback.success(response)

      getZooTeam: (requestData, callback) ->
        url = 'http://hearttools.heart.org/aha_ym18/api/program/team/'+requestData+'?key=6Mwqh5dFV39HLDq7'
        urlSCE = $sce.trustAsResourceUrl(url)
        $http.jsonp(urlSCE, jsonpCallbackParam: 'callback').then (response) ->
          if response.data.success == false
            callback.error(response)
          else
            callback.success(response)

      getZooProgram: (requestData, callback) ->
        url = 'http://hearttools.heart.org/aha_ym18/api/program/'+requestData+'?key=6Mwqh5dFV39HLDq7'
        urlSCE = $sce.trustAsResourceUrl(url)
        $http.jsonp(urlSCE, jsonpCallbackParam: 'callback').then (response) ->
          if response.data.success == false
            callback.error(response)
          else
            callback.success(response)

      getZooTest: (callback) ->
        url = 'http://hearttools.heart.org/aha_ym18/api/program/event/1163033?key=6Mwqh5dFV39HLDq7'
        urlSCE = $sce.trustAsResourceUrl(url)
        $http.jsonp(urlSCE, jsonpCallbackParam: 'callback').then (response) ->
          if response.data.success == false
            callback.error(response)
          else
            callback.success(response)
  ]