angular.module('trPcControllers').controller 'NgPcSocialViewCtrl', [
  '$scope'
  '$sce'
  '$rootScope'
  ($scope, $sce, $rootScope) ->
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
