angular.module 'trPcApp'
  .factory 'FacebookFundraiserService', [
    '$rootScope'
    'NgPcLuminateRESTService'
    ($rootScope, NgPcLuminateRESTService) ->
      createFundraiser: (requestData) ->
        dataString = 'method=createAndLinkFacebookFundraiser&cons_id=' + $rootScope.consId
        dataString += '&' + requestData if requestData and requestData isnt ''
        NgPcLuminateRESTService.teamraiserRequest dataString, true, true
      
      confirmFundraiserStatus: (requestData) ->
        dataString = 'method=confirmOrUnlinkFacebookFundraiser'
        dataString += '&' + requestData if requestData and requestData isnt ''
        NgPcLuminateRESTService.teamraiserRequest dataString, true, true
  ]