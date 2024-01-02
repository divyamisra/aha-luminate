angular.module 'ahaLuminateControllers'
  .controller 'RegistrationUtypeCtrl', [
    '$rootScope'
    '$scope'
    'TeamraiserCompanyService'
    ($rootScope, $scope, TeamraiserCompanyService) ->
      $rootScope.companyName = ''
      regCompanyId = luminateExtend.global.regCompanyId
      setCompanyName = (companyName) ->
        $rootScope.companyName = companyName
        if not $rootScope.$$phase
          $rootScope.$apply()
      TeamraiserCompanyService.getCompanies 'company_id=' + regCompanyId,
        error: ->
          # TODO
        success: (response) ->
          companies = response.getCompaniesResponse.company
          if not companies
            # TODO
          else
            companies = [companies] if not angular.isArray companies
            companyInfo = companies[0]
            setCompanyName companyInfo.companyName
      
      $scope.toggleUserType = (userType) ->
        $scope.userType = userType
        if userType is 'new'
          angular.element('.js--default-utype-new-form').submit()
          false
      
      $scope.submitUtypeLogin = ->
        angular.element('.js--default-utype-existing-form').submit()
        false
      
      $scope.toggleForgotLogin = (showHide) ->
        $scope.showForgotLogin = showHide is 'show'
      
      $scope.submitForgotLogin = ->
        angular.element('.js--default-utype-send-username-form').submit()
        false
  ]
