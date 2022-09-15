angular.module 'trPcControllers'
  .controller 'NgPcMainCtrl', [
    '$rootScope'
    '$scope'
    '$location'
    '$timeout'
    'APP_INFO'
    'TeamraiserParticipantPageService'
    'NgPcTeamraiserEventService'
    'RichTextService'
    'FacebookFundraiserService'
    ($rootScope, $scope, $location, $timeout, APP_INFO, TeamraiserParticipantPageService, NgPcTeamraiserEventService, RichTextService, FacebookFundraiserService) ->
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
          if angular.element('.clipboard-copy').length == 0
            angular.element(e.trigger).after '<div class=\'clipboard-copy text-center small\' role=\'alert\' aria-atomic=\'true\'>Text copied to clipboard</div>'
          return      
        
      if $rootScope.facebookFundraisersEnabled
        toggleFacebookFundraiserStatus = ->
          if not $rootScope.$$phase
            $rootScope.$apply()
        $rootScope.loginToFacebook = ->
          $rootScope.facebookFundraiserLoginStatus = 'pending'
          toggleFacebookFundraiserStatus()
          FB.login (response) ->
            authResponse = response.authResponse
            if not authResponse
              $rootScope.facebookFundraiserLoginStatus = 'login_error'
              toggleFacebookFundraiserStatus()
            else
              facebookUserId = response.authResponse.userID
              accessToken = response.authResponse.accessToken
              if not facebookUserId or not accessToken
                $rootScope.facebookFundraiserLoginStatus = 'login_error'
                toggleFacebookFundraiserStatus()
              else
                FB.api '/me/permissions', (response) ->
                  manageFundraisersPermisson = null
                  angular.forEach response.data, (permissionObject) ->
                    if permissionObject.permission is 'manage_fundraisers'
                      manageFundraisersPermisson = permissionObject
                  if not manageFundraisersPermisson
                    $rootScope.facebookFundraiserLoginStatus = 'permission_error'
                    toggleFacebookFundraiserStatus()
                  else if manageFundraisersPermisson.status is 'declined'
                    $rootScope.facebookFundraiserLoginStatus = 'declined_manage_fundraisers'
                    toggleFacebookFundraiserStatus()
                  else
                    $rootScope.facebookFundraiserLoginStatus = 'complete'
                    $rootScope.facebookFundraiserCreateStatus = 'pending'
                    toggleFacebookFundraiserStatus()
                    TeamraiserParticipantPageService.getPersonalPageInfo
                      error: ->
                        $rootScope.facebookFundraiserCreateStatus = 'create_fundraiser_error'
                      success: (response) ->
                        getPersonalPageResponse = response.getPersonalPageResponse
                        if not getPersonalPageResponse
                          $rootScope.facebookFundraiserCreateStatus = 'create_fundraiser_error'
                          toggleFacebookFundraiserStatus()
                        else
                          NgPcTeamraiserEventService.getConfig()
                            .then (response) ->
                              getTeamraiserConfigResponse = response.data.getTeamraiserConfigResponse
                              if not getTeamraiserConfigResponse?.teamraiserConfig
                                $rootScope.facebookFundraiserCreateStatus = 'create_fundraiser_error'
                                toggleFacebookFundraiserStatus()
                              else
                                personalPage = getPersonalPageResponse.personalPage
                                fundraiserName = getTeamraiserConfigResponse.teamraiserConfig.facebookDefaultTitle or ''
                                fundraiserDescription = getTeamraiserConfigResponse.teamraiserConfig.facebookDefaultDescription or ''
                                if personalPage?.richText
                                  fundraiserDescription = RichTextService.richTextToPlainText personalPage.richText
                                FacebookFundraiserService.createFundraiser 'user_access_token=' + accessToken + '&name=' + fundraiserName + '&description=' + fundraiserDescription
                                  .then (response) ->
                                    facebookFundraiserId = response.data.createAndLinkFacebookFundraiserResponse?.fundraiserId
                                    if not facebookFundraiserId
                                      $rootScope.facebookFundraiserCreateStatus = 'create_fundraiser_error'
                                      toggleFacebookFundraiserStatus()
                                    else
                                      $rootScope.facebookFundraiserCreateStatus = 'complete'
                                      $rootScope.facebookFundraiserId = facebookFundraiserId
                                      $rootScope.facebookFundraiserUrl =
                                        url: 'https://www.facebook.com/donate/' + $rootScope.facebookFundraiserId + '/'
                                      $rootScope.facebookFundraiserConfirmedStatus = 'confirmed'
                                      toggleFacebookFundraiserStatus()
                                      $timeout ->
                                        if jQuery('.js--facebook-fundraiser-completed-section').length > 0
                                          jQuery('html, body').animate
                                            scrollTop: jQuery('.js--facebook-fundraiser-completed-section').offset().top - 150
                                          , 250
          , scope: 'manage_fundraisers'
  ]