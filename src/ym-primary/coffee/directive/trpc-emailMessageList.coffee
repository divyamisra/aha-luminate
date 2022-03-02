angular.module 'trPcApp'
  .directive 'pcEmailMessageList', [
    'APP_INFO'
    (APP_INFO) ->
      templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/directive/emailMessageList.html'
      restrict: 'E'
      replace: true
      scope:
        messages: '='
        selectMessage: '='
        deleteMessage: '='
      controller: [
        '$timeout'
        '$scope'
        ($timeout, $scope) ->
          focusPanel = ->
            $elem = angular.element '.ng-pc-msg-list a'
            if $elem.length > 0  
              $elem[0].focus()
          
          $scope.$$postDigest ->
            focusPanel()
      ]
  ]
