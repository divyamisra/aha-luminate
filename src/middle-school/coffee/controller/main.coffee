angular.module 'ahaLuminateControllers'
  .controller 'MainCtrl', [
    '$rootScope'
    '$scope'
    '$httpParamSerializer'
    'AuthService'
    'TeamraiserParticipantService'
    '$timeout'
    ($rootScope, $scope, $httpParamSerializer, AuthService, TeamraiserParticipantService, $timeout) ->
      $dataRoot = angular.element '[data-aha-luminate-root]'
      consId = $dataRoot.data('cons-id') if $dataRoot.data('cons-id') isnt ''
      $scope.regEventId = ''
      
      setRegEventId = (numberEvents = 0, regEventId = '') ->
        $scope.numberEvents = numberEvents
        $scope.regEventId = regEventId
        if not $scope.$$phase
          $scope.$apply()
      if not consId or not luminateExtend.global.isParticipant
        setRegEventId()
      else
        TeamraiserParticipantService.getRegisteredTeamraisers 'cons_id=' + consId + '&event_type=' + encodeURIComponent('American Heart Challenge 2021'),
          error: ->
            setRegEventId()
          success: (response) ->
            teamraisers = response.getRegisteredTeamraisersResponse?.teamraiser
            if not teamraisers
              setRegEventId()
            else
              teamraisers = [teamraisers] if not angular.isArray teamraisers
              numberEvents = teamraisers.length
              regEventId = ''
              if numberEvents is 1
                regEventId = teamraisers[0].id
              setRegEventId numberEvents, regEventId
      
      $scope.toggleLoginMenu = ->
        if $scope.loginMenuOpen
          delete $scope.loginMenuOpen
        else
          $scope.loginMenuOpen = true
      
      angular.element('body').on 'click', (event) ->
        if $scope.loginMenuOpen and angular.element(event.target).closest('.ym-header-login').length is 0
          $scope.toggleLoginMenu()
        if not $scope.$$phase
          $scope.$apply()
      
      $scope.headerLoginInfo = 
        user_name: ''
        password: ''
      
      $scope.submitHeaderLogin = ->
        AuthService.login $httpParamSerializer($scope.headerLoginInfo), 
          error: ->
            angular.element('.js--default-header-login-form').submit()
          success: ->
            if not $scope.headerLoginInfo.ng_nexturl or $scope.headerLoginInfo.ng_nexturl is ''
#              window.location = window.location.href
              window.location = $rootScope.secureDomain + 'site/SPageServer?pagename=middle_school_my_events'
            else
              window.location = $scope.headerLoginInfo.ng_nexturl
      
      $scope.toggleWelcomeMenu = ->
        if $scope.welcomeMenuOpen
          angular.element("button.ym-header-welcome-toggle").attr("aria-expanded","false");
          delete $scope.welcomeMenuOpen
        else
          angular.element("button.ym-header-welcome-toggle").attr("aria-expanded","true");
          $scope.welcomeMenuOpen = true
          focusDropdown = ->
            document.getElementById('js--header-welcome-ul').focus()
          $timeout focusDropdown, 100
          
      angular.element('body').on 'click', (event) ->
        if $scope.welcomeMenuOpen and angular.element(event.target).closest('.ym-header-welcome').length is 0
          $scope.toggleWelcomeMenu()
        if not $scope.$$phase
          $scope.$apply()
      
      $scope.toggleSiteMenu = ->
        if $scope.siteMenuOpen
          delete $scope.siteMenuOpen
        else
          $scope.siteMenuOpen = true
      
      angular.element('body').on 'click', (event) ->
        if $scope.siteMenuOpen and angular.element(event.target).closest('.ym-site-menu').length is 0
          $scope.toggleSiteMenu()
        if not $scope.$$phase
          $scope.$apply()
      
      $scope.delegatedAddThis = (targetToolboxContainer, shareType) ->
        angular.element(targetToolboxContainer).find('.addthis_button_' + shareType).click()
        false
  ]
