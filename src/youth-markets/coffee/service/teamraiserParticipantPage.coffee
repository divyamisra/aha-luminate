angular.module 'ahaLuminateApp'
  .factory 'TeamraiserParticipantPageService', [
    '$rootScope'
    'LuminateRESTService'
    ($rootScope, LuminateRESTService) ->
      getPersonalPhotos: (callback) ->
        LuminateRESTService.luminateExtendTeamraiserRequest 'method=getPersonalPhotos', true, true, callback
      
      getPersonalPageInfo: (callback) ->
        LuminateRESTService.luminateExtendTeamraiserRequest 'method=getPersonalPageInfo', true, true, callback
      
      updatePersonalPageInfo: (requestData, callback) ->
        dataString = 'method=updatePersonalPageInfo'
        dataString += '&' + requestData if requestData and requestData isnt ''
        LuminateRESTService.luminateExtendTeamraiserRequest dataString, true, true, callback
  ]