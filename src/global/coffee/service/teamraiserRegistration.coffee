angular.module 'ahaLuminateApp'
  .factory 'TeamraiserRegistrationService', [
    'LuminateRESTService'
    (LuminateRESTService) ->
      getParticipationTypes: (callback) ->
        dataString = 'method=getParticipationTypes'
        LuminateRESTService.luminateExtendTeamraiserRequest dataString, false, true, callback
      
      getRegistrationDocument: (requestData, callback) ->
        dataString = 'method=getRegistrationDocument'
        dataString += '&' + requestData if requestData and requestData isnt ''
        LuminateRESTService.luminateExtendTeamraiserRequest dataString, false, true, callback
      
      getRegistration: (callback) ->
        dataString = 'method=getRegistration'
        LuminateRESTService.luminateExtendTeamraiserRequest dataString, true, true, callback

      getSurveyResponses: (requestData, callback) ->
        dataString = 'method=getSurveyResponses'
        dataString += '&' + requestData if requestData and requestData isnt ''
        LuminateRESTService.luminateExtendTeamraiserRequest dataString, true, false, callback
      
  ]