angular.module('trPcControllers').controller 'NgPcSocialViewCtrl', [
  '$scope'
  '$sce'
  '$rootScope'
  'FacebookFundraiserService'
  ($scope, $sce, $rootScope, FacebookFundraiserService) ->
    #facebook fundraising
    $rootScope.facebookFundraiserConfirmedStatus = ''
    if $scope.facebookFundraisersEnabled and $rootScope.facebookFundraiserId and $rootScope.facebookFundraiserId isnt ''
      $rootScope.facebookFundraiserConfirmedStatus = 'pending'
      FacebookFundraiserService.confirmFundraiserStatus()
        .then (response) ->
          confirmOrUnlinkFacebookFundraiserResponse = response.data.confirmOrUnlinkFacebookFundraiserResponse
          if confirmOrUnlinkFacebookFundraiserResponse?.active is 'false'
            delete $rootScope.facebookFundraiserId
            $rootScope.facebookFundraiserConfirmedStatus = 'deleted'
          else
            $rootScope.facebookFundraiserConfirmedStatus = 'confirmed'
    
    #setup social iframe
    urlPrefix = ''
    if $scope.tablePrefix is 'heartdev' or $scope.tablePrefix is 'heartnew'
      urlPrefix = 'load'
    else
      urlPrefix = 'loadaha'
    consId = $scope.consId
    frId = $rootScope.frId
    auth = $rootScope.authToken
    jsession = $rootScope.sessionCookie	
    url = 'https://' + urlPrefix + '.boundlessfundraising.com/applications/ahakhc/social/app/ui/#/addsocial/' + consId + '/' + frId + '/' + auth + '/' + jsession + '?source=PCSocial'
    $scope.socialIframeURL = $sce.trustAsResourceUrl url
    return
  ]
