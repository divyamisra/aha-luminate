angular.module 'ahaLuminateControllers'
  .controller 'RegistrationWaiverCtrl', [
    '$scope'
    'SchoolLookupService'
    ($scope, SchoolLookupService) ->
      $scope.submitWaiver = ->
        angular.element('.js--registration-waiver-form').submit()
        false
      
      $scope.submitWaiver()

      setCompanyName = (companyName) ->
        $rootScope.companyName = companyName
        if not $rootScope.$$phase
          $rootScope.$apply()
      #TeamraiserCompanyService.getCompanies 'company_id=' + regCompanyId,
      #  error: ->
      #    # TODO
      #  success: (response) ->
      #    companies = response.getCompaniesResponse.company
      #    if not companies
      #      # TODO
      #    else
      #      companies = [companies] if not angular.isArray companies
      #      companyInfo = companies[0]
      #      setCompanyName companyInfo.companyName
      setCompanyName localStorage.companyName
      
      setCompanyCity = (companyCity) ->
        $rootScope.companyCity = companyCity
        if not $rootScope.$$phase
          $rootScope.$apply()
          
      setCompanyState = (companyState) ->
        $rootScope.companyState = companyState
        if not $rootScope.$$phase
          $rootScope.$apply()
          
      if localStorage.companyCity != undefined
        setCompanyCity localStorage.companyCity
        setCompanyState localStorage.companyState
      
      #
      #SchoolLookupService.getSchoolData()
      #  .then (response) ->
      #    schoolDataRows = response.data.getSchoolSearchDataResponse.schoolData
      #    angular.forEach schoolDataRows, (schoolDataRow, schoolDataRowIndex) ->
      #      if schoolDataRowIndex > 0
      #        if regCompanyId is schoolDataRow[0]
      #          setCompanyCity schoolDataRow[1]
      #          setCompanyState schoolDataRow[2]
      #          return
  ]
