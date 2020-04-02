angular.module 'trPcApp'
  .factory 'TeamraiserParticipantPageService', [
    '$rootScope'
    'LuminateRESTService'
    ($rootScope, LuminateRESTService) ->
      getPersonalPhotos: (callback) ->
        LuminateRESTService.luminateExtendTeamraiserRequest 'method=getPersonalPhotos', true, true, callback

      getPersonalPageInfo: (callback) ->
        LuminateRESTService.luminateExtendTeamraiserRequest 'method=getPersonalPageInfo', true, true, callback

      getPersonalVideoUrl: (callback) ->
        LuminateRESTService.luminateExtendTeamraiserRequest 'method=getPersonalVideoUrl', true, true, callback
      
      getCompanyPhoto: (callback) ->
        LuminateRESTService.luminateExtendTeamraiserRequest 'method=getCompanyPhoto', true, true, callback

      updatePersonalPageInfo: (requestData, callback) ->
        dataString = 'method=updatePersonalPageInfo'
        dataString += '&' + requestData if requestData and requestData isnt ''
        LuminateRESTService.luminateExtendTeamraiserRequest dataString, true, true, callback
      
      updatePersonalVideoUrl: (requestData, callback) ->
        dataString = 'method=updatePersonalVideoUrl'
        dataString += '&' + requestData if requestData and requestData isnt ''
        LuminateRESTService.luminateExtendTeamraiserRequest dataString, true, true, callback
  ]

angular.module 'trPcApp'
  .factory 'TeamraiserSurveyResponseService', [
    '$rootScope'
    'LuminateRESTService'
    ($rootScope, LuminateRESTService) ->
      getSurveyResponses: (callback) ->
        LuminateRESTService.luminateExtendTeamraiserRequest 'method=getSurveyResponses', true, true, callback
  ]