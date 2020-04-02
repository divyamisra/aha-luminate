angular.module 'ahaLuminateControllers'
  .controller 'RegistrationPtypeCtrl', [
    '$rootScope'
    '$scope'
    '$filter'
    '$timeout'
    'TeamraiserCompanyService'
    'SchoolLookupService'
    ($rootScope, $scope, $filter, $timeout, TeamraiserCompanyService, SchoolLookupService) ->
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
      
      if not $scope.participationOptions
        $scope.participationOptions = {}
      
      $participationType = angular.element('.js--registration-ptype-part-types input[name="fr_part_radio"]').eq 0
      $scope.participationOptions.fr_part_radio = $participationType.val()
      
      $scope.toggleDonationLevel = (event, type, levelAmount) ->
        if type is 'level' or (type is 'other' and $scope.participationOptions.ng_donation_level_other_amount isnt '') 
          $scope.participationOptions.ng_donation_level = levelAmount
          $scope.participationOptionsForm.ng_donation_level_other_amount.$setValidity('amount', true)
          angular.forEach $scope.donationLevels.levels, (donationLevel, donationLevelIndex) ->
            if donationLevel.amount is levelAmount
              $scope.donationLevels.activeLevel = donationLevel
 
        if levelAmount isnt '-1'
          $scope.participationOptions.ng_donation_level_other_amount = ''
      
      $scope.donationLevels = 
        levels: []
      $donationLevels = angular.element '.js--registration-ptype-donation-levels .donation-level-row-container'
      angular.forEach $donationLevels, ($donationLevel) ->
        $donationLevel = angular.element $donationLevel
        $donationLevelRadio = $donationLevel.find 'input[type="radio"][name^="donation_level_form_"]'
        levelAmount = $donationLevelRadio.val()
        isOtherAmount = levelAmount is '-1'
        isNoDonation = levelAmount is '$0.00'
        levelAmountFormatted = null
        if not isOtherAmount and not isNoDonation
          levelAmountFormatted = $filter('currency')(Number(levelAmount.replace('$', '').replace(/,/g, '')), '$').replace '.00', ''
        askMessage = $donationLevel.find('.donation-level-description-text').text()
        if isOtherAmount
          askMessage = 'Enter an amount that\'s meaningful for you.'
        $scope.donationLevels.levels.push
          amount: levelAmount
          amountFormatted: levelAmountFormatted
          isOtherAmount: isOtherAmount
          isNoDonation: isNoDonation
          askMessage: askMessage
        if $donationLevelRadio.is '[checked]'
          setTimeout ->
            $scope.toggleDonationLevel levelAmount
        if isOtherAmount
          otherAmount = $donationLevel.find('input[name^="donation_level_form_input_"]').val()
          if otherAmount
            $scope.participationOptions.ng_donation_level_other_amount = otherAmount
      
      $scope.previousStep = ->
        $scope.ng_go_back = true
        $timeout ->
          $scope.submitPtype()
        , 500
        false
      
      $scope.submitPtype = ->
        if $scope.donationLevels.activeLevel?.isOtherAmount
          if $scope.participationOptionsForm.ng_donation_level_other_amount.$viewValue is undefined 
            amt = 0
          else 
            amt = parseInt($scope.participationOptionsForm.ng_donation_level_other_amount.$viewValue)
          if amt < 10 or !angular.isNumber(amt) or isNaN(amt) or amt is ''
            $scope.participationOptionsForm.ng_donation_level_other_amount.$setValidity('amount', false)
          else
            $scope.participationOptionsForm.ng_donation_level_other_amount.$setValidity('amount', true)
        else
          $scope.participationOptionsForm.ng_donation_level_other_amount.$setValidity('amount', true)
        if not $scope.participationOptionsForm.$valid
          goalElem = angular.element '#participationOptions-fr_goal'
          if goalElem.is '.ng-invalid'
            goalElem.focus()
          else
            window.scrollTo 0, 0
        else
          if $scope.donationLevels.activeLevel is undefined
            $scope.toggleDonationLevel '$0.00'
          angular.element('.js--default-ptype-form').submit()
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
