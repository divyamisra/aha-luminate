angular.module 'trPcApp'
  .factory 'NgPcSurveyService', [
    'NgPcLuminateRESTService'
    (NgPcLuminateRESTService) ->
      submitSurvey: (requestData) ->
        dataString = 'method=submitSurvey'
        dataString += '&' + requestData if requestData and requestData isnt ''
        NgPcLuminateRESTService.surveyRequest dataString, true
          .then (response) ->
            response
  ]
