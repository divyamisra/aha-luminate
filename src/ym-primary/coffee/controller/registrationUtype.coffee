angular.module 'ahaLuminateControllers'
  .controller 'RegistrationUtypeCtrl', [
    '$rootScope'
    '$scope'
    'TeamraiserCompanyService',
    'SchoolLookupService'
    ($rootScope, $scope, TeamraiserCompanyService, SchoolLookupService) ->
      $rootScope.companyName = ''
      localStorage.companyName = ''
      localStorage.companyCity = ''
      localStorage.companyState = ''
      $rootScope.regCompanyId = luminateExtend.global.regCompanyId
      regCompanyId = luminateExtend.global.regCompanyId
      
      setCompanyName = (companyName) ->
        $rootScope.companyName = companyName
        localStorage.companyName = companyName
        if not $rootScope.$$phase
          $rootScope.$apply()
          
      setCompanyCity = (companyCity) ->
        $rootScope.companyCity = companyCity
        localStorage.companyCity = companyCity
        if not $rootScope.$$phase
          $rootScope.$apply()
          
      setCompanyState = (companyState) ->
        $rootScope.companyState = companyState
        localStorage.companyState = companyState
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

      SchoolLookupService.getSchoolData()
        .then (response) ->
          schoolDataRows = response.data.getSchoolSearchDataResponse.schoolData
          angular.forEach schoolDataRows, (schoolDataRow, schoolDataRowIndex) ->
            if schoolDataRowIndex > 0
              if regCompanyId is schoolDataRow[0]
                setCompanyCity schoolDataRow[1]
                setCompanyState schoolDataRow[2]
                return
  ]
