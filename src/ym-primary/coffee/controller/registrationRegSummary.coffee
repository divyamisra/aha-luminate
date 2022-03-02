angular.module 'ahaLuminateControllers'
  .controller 'RegistrationRegSummaryCtrl', [
    '$rootScope'
    '$scope'
    'TeamraiserCompanyService'
    'SchoolLookupService'
    ($rootScope, $scope, TeamraiserCompanyService, SchoolLookupService) ->
      $rootScope.companyName = ''
      regCompanyId = luminateExtend.global.regCompanyId
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
      
      $scope.regSummaryInfo = {}
      
      $participantInfo = angular.element '.js--registration-regsummary-participant-info'
      $scope.regSummaryInfo.cons_first_name = jQuery.trim $participantInfo.find('.contact-info-first').text()
      $scope.regSummaryInfo.cons_last_name = jQuery.trim $participantInfo.find('.contact-info-last').text()
      $scope.regSummaryInfo.cons_email = jQuery.trim $participantInfo.find('.contact-info-email').text()
      $scope.regSummaryInfo.fr_gift = jQuery.trim $participantInfo.find('.additional-gift-amount').text().replace '.00', ''
      
      $scope.submitRegSummary = ->
        angular.element('.js--default-regsummary-form').submit()
        false
      
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

      $scope.submitRegSummary()
      
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
