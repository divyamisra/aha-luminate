angular.module('trPcControllers').controller 'NgPcSocialViewCtrl', [
  '$scope'
  '$sce'
  '$rootScope'
  ($scope, $sce, $rootScope) ->
    console.log 'middle school'
    urlPrefix = ''
    if $scope.tablePrefix is 'heartdev'
      urlPrefix = 'load'
    else
      urlPrefix = 'loadprod'
    consId = $scope.consId
    frId = $rootScope.frId
    auth = $rootScope.authToken
    jsession = $rootScope.sessionCookie
    url = 'https://' + urlPrefix + '.boundlessfundraising.com/applications/ahatgr/social/app/ui/#/addsocial/' + consId + '/' + frId + '/' + auth + '/' + jsession + '?source=PCSocial'
    $scope.socialIframeURL = $sce.trustAsResourceUrl url
    return
  ]