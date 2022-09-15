angular.module 'trPcControllers'
  .controller 'NgPcMainCtrl', [
    '$rootScope'
    '$scope'
    '$location'
    '$timeout'
    'LocaleService'
    'TeamraiserParticipantPageService'
    'TeamraiserEventService'
    'RichTextService'
    'FacebookFundraiserService'
    ($rootScope, $scope, $location, $timeout, LocaleService, TeamraiserParticipantPageService, TeamraiserEventService, RichTextService, FacebookFundraiserService) ->
      $rootScope.$location = $location
      
      $rootScope.baseUrl = $location.absUrl().split('#')[0]
      
      LocaleService.setLocale $rootScope.locale
      
      $rootScope.changeLocale = ->
        LocaleService.setLocale()
      
      $scope.$on '$viewContentLoaded', ->
        addThisChecks = 0
        checkAddThis = ->
          addThisChecks++
          if angular.element('.addthis_toolbox').length > 0
            addthis.toolbox '.addthis_toolbox'
          else if addThisChecks < 13
            $timeout checkAddThis, 250
        checkAddThis()
      
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
              else
                FB.api '/me/permissions', (response) ->
                  manageFundraisersPermisson = null
                  angular.forEach response.data, (permissionObject) ->
                    if permissionObject.permission is 'manage_fundraisers'
                      manageFundraisersPermisson = permissionObject
                  if not manageFundraisersPermisson
                    $rootScope.facebookFundraiserLoginStatus = 'permission_error'
                  else if manageFundraisersPermisson.status is 'declined'
                    $rootScope.facebookFundraiserLoginStatus = 'declined_manage_fundraisers'
                  else
                    $rootScope.facebookFundraiserLoginStatus = 'complete'
                    $rootScope.facebookFundraiserCreateStatus = 'pending'
                    TeamraiserParticipantPageService.getPersonalPageInfo
                      error: ->
                        $rootScope.facebookFundraiserCreateStatus = 'create_fundraiser_error'
                      success: (response) ->
                        getPersonalPageResponse = response.getPersonalPageResponse
                        if not getPersonalPageResponse
                          $rootScope.facebookFundraiserCreateStatus = 'create_fundraiser_error'
                        else
                          TeamraiserEventService.getConfig()
                            .then (response) ->
                              getTeamraiserConfigResponse = response.data.getTeamraiserConfigResponse
                              if not getTeamraiserConfigResponse?.teamraiserConfig
                                $rootScope.facebookFundraiserCreateStatus = 'create_fundraiser_error'
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
                                    else
                                      $rootScope.facebookFundraiserCreateStatus = 'complete'
                                      $rootScope.facebookFundraiserId = facebookFundraiserId
                                      $rootScope.facebookFundraiserUrl =
                                        url: 'https://www.facebook.com/donate/' + $rootScope.facebookFundraiserId + '/'
                                      $rootScope.facebookFundraiserConfirmedStatus = 'confirmed'
                                      $timeout ->
                                        if jQuery('.js--facebook-fundraiser-completed-section').length > 0
                                          jQuery('html, body').animate
                                            scrollTop: jQuery('.js--facebook-fundraiser-completed-section').offset().top - 150
                                          , 250
                  toggleFacebookFundraiserStatus()
          , scope: 'manage_fundraisers'
  ]