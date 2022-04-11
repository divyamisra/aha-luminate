angular.module 'trPcApp'
  .factory 'NgPcConstituentService', [
    'NgPcLuminateRESTService'
    (NgPcLuminateRESTService) ->
      getUserRecord: (requestData) ->
        dataString = 'method=getUser'
        dataString += '&' + requestData if requestData and requestData isnt ''
        NgPcLuminateRESTService.consRequest dataString, true
          .then (response) ->
            response
            
      updateUserRecord: (requestData) ->
        dataString = 'method=update'
        dataString += '&' + requestData if requestData and requestData isnt ''
        NgPcLuminateRESTService.consRequest dataString, true
          .then (response) ->
            response

  ]
