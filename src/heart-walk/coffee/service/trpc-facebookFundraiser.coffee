angular.module 'trPcApp'
  .factory 'FacebookFundraiserService', [
    '$rootScope'
    'LuminateRESTService'
    ($rootScope, LuminateRESTService) ->
      createFundraiser: (requestData) ->
        dataString = 'method=createAndLinkFacebookFundraiser&cons_id=' + $rootScope.consId
        dataString += '&' + requestData if requestData and requestData isnt ''
        LuminateRESTService.teamraiserRequest dataString, true, true
      
      confirmFundraiserStatus: (requestData) ->
        dataString = 'method=confirmOrUnlinkFacebookFundraiser'
        dataString += '&' + requestData if requestData and requestData isnt ''
        LuminateRESTService.teamraiserRequest dataString, true, true
  ]