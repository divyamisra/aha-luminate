angular.module 'trPcControllers'
  .controller 'NgPcMainCtrl', [
    '$rootScope'
    '$scope'
    '$location'
    'APP_INFO'
    ($rootScope, $scope, $location, APP_INFO) ->
      $rootScope.$location = $location
      $rootScope.baseUrl = $location.absUrl().split('#')[0]
      
      $scope.location = $location.path()
      $rootScope.$on '$routeChangeSuccess', ->
        $scope.location = $location.path()
        return
      
      $scope.$on '$viewContentLoaded', ->
        if $rootScope.clipboard
          $rootScope.clipboard.destroy()
          delete $rootScope.clipboard
        $rootScope.clipboard = new ClipboardJS '[data-clipboard-target]'
        $rootScope.clipboard.on 'success', (e) ->
          alert(e.action)
          return
  ]
