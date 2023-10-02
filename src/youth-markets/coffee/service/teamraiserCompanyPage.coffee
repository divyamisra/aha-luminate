angular.module 'ahaLuminateApp'
  .factory 'TeamraiserCompanyPageService', [
    '$rootScope'
    '$http'
    '$sce'
    'LuminateRESTService'
    ($rootScope, $http, $sce, LuminateRESTService) ->
      getCompanyPhoto: (callback) ->
        LuminateRESTService.luminateExtendTeamraiserRequest 'method=getCompanyPhoto', true, true, callback
      
      updateCompanyPageInfo: (requestData, callback) ->
        dataString = 'method=updateCompanyPageInfo'
        dataString += '&' + requestData if requestData and requestData isnt ''
        LuminateRESTService.luminateExtendTeamraiserRequest dataString, true, true, callback

  ]
