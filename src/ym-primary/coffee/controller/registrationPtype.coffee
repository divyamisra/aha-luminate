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
      #      companies = [companies] if not angurlar.isArray companies
      #      companyInfo = companies[0]
      #      setCompanyName companyInfo.companyName
      setCompanyName localStorage.companyName
      
      if not $scope.participationOptions
        $scope.participationOptions = {}
      
      $participationType = angular.element('.js--registration-ptype-part-types input[name="fr_part_radio"]').eq 0
      $scope.participationOptions.fr_part_radio = $participationType.val()
      
      $scope.toggleDonationLevel = (event, type, levelAmount) ->
        console.log('TOGGLEDONATIONLEVEL type ' + type + ' levelAmount ' + levelAmount)
        console.log('TOGGLEDONATIONLEVEL $scope.participationOptions.ng_donation_level_other_amount' + $scope.participationOptions.ng_donation_level_other_amount)

        if levelAmount != '$0.00'
          console.log('removing coverfee check box disabled')
          angular.element('input[name="cover-fee-checkbox"]').removeAttr('disabled')
        else if levelAmount == '$0.00'
          console.log('adding coverfee check box disabled')
          angular.element('input[name="cover-fee-checkbox"]').attr('disabled',true)

        if type is 'level' and $scope.coverFee == true
          $scope.coverFee = false

        if type is 'level' and $scope.coverFee == false
          console.log('TOGGLEDONATIONLEVEL coverfee ' + $scope.coverFee)
          angular.element('.ym-registration-ptype-donation-levels .btn-enter').val('')
          angular.element('.ym-registration-ptype-donation-levels .btn-enter').removeClass('active')

        if type is 'level' or (type is 'other' and $scope.participationOptions.ng_donation_level_other_amount isnt '') 
          console.log('type is level or type is other and other is not blank')
          $scope.participationOptions.ng_donation_level = levelAmount
          $selectedDonAmt = levelAmount
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
        console.log('$donationLevelRadio id' + $donationLevelRadio.attr('id'))
        levelAmount = $donationLevelRadio.val()
        isOtherAmount = levelAmount is '-1'
        isNoDonation = levelAmount is '$0.00'
        levelAmountFormatted = null
        if not isOtherAmount and not isNoDonation
          levelAmountFormatted = $filter('currency')(Number(levelAmount.replace('$', '').replace(/,/g, '')), '$').replace '.00', ''
        askMessage = $donationLevel.find('.donation-level-description-text').text()
        #if isOtherAmount
        #  askMessage = 'Enter an amount that\'s meaningful for you.'
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

  
      angular.element('btn-enter').keydown ->
        console.log('btn-enger keydown function')
        $scope.coverFee = false

      $scope.coverFee = false
      if angular.element('input[name="cover-fee-checkbox"]').attr('checked') is true
        $scope.coverFee = true
      else if angular.element('input[name="cover-fee-checkbox"]').attr('disabled') is true
        $scope.coverFee = 'disabled'
      console.log("coverFee " + $scope.coverFee)

      $scope.coverFeeMsg = ->
        console.log('cover fee message ')
        if angular.element('input[name="cover-fee-checkbox"]').attr('disabled') is 'disabled'
          $scope.coverFee = 'disabled'
          console.log("$scope.coverFee " + $scope.coverFee)
  
      $scope.disableCoverFee = ->
        $scope.coverFee = false


      $scope.getAmount = (levelAmt) ->
        if levelAmt
          originalGiftAmt = levelAmt
        else
          originalGiftAmt = angular.element('.ym-registration-ptype-donation-levels .btn.active').prop('title')
        console.log('getamount function original gift amount ' + originalGiftAmt)

        if $scope.coverFee == true

          if originalGiftAmt == 'Other Amount'
            originalGiftAmt = angular.element('.btn-enter').val()
            console.log("OTHER originalGiftAmt " + originalGiftAmt)
          else
            originalGiftAmt = originalGiftAmt.split('$')[1]
            console.log("originalGiftAmt " + originalGiftAmt)

          originalGiftAmt = Number(originalGiftAmt)
          console.log("originalGiftAmt " + originalGiftAmt)
          localStorage.setItem('storedAmt', originalGiftAmt)
        
          newGiftAmt =  (originalGiftAmt * 2.6 / 100 + 0.26 + originalGiftAmt).toFixed 2
          console.log("newGiftAmt " + newGiftAmt)
          return newGiftAmt

        else

          storedGiftAmt = localStorage.getItem('storedAmt');
          console.log('storedGiftAmt ' + storedGiftAmt)
          if storedGiftAmt
            #oldGiftAmt = (Math.round(currentGiftAmt / 1.026 - 0.26)).toFixed 2
            oldGiftAmt = Number(storedGiftAmt).toFixed 2
          else 
            oldGiftAmt = 0
          return oldGiftAmt


      $scope.toggleCoverFee = ->
        console.log('$scope.coverFee ' + $scope.coverFee)

        console.log(' is any level chosen? ' + angular.element('.ym-registration-ptype-donation-levels .btn.active').length + angular.element('.ym-registration-ptype-donation-levels .btn.active').prop('title'))

        if angular.element('.ym-registration-ptype-donation-levels .btn.active').length != 0 and angular.element('.ym-registration-ptype-donation-levels .btn.active').prop('title') != 'No Thanks'

          if angular.element('#cover-fee-checkbox').prop('checked') is true
            console.log('cover fee click function')

            amount = $scope.getAmount()
            console.log('amount ' + amount)

            angular.element('.ym-registration-ptype-donation-levels .btn.active').removeClass('active')
            angular.element('.ym-registration-ptype-donation-levels .btn-enter').val(amount)
            $scope.participationOptions.ng_donation_level_other_amount = amount
            angular.element('.ym-registration-ptype-donation-levels .btn-enter').addClass('active')
            angular.element('.ym-registration-ptype-donation-levels .btn-enter').trigger('blur')

          else
            console.log('turn off cover fee')
            amount = $scope.getAmount()
            console.log('amount ' + amount)
            $scope.participationOptions.ng_donation_level_other_amount = amount
            angular.element('.ym-registration-ptype-donation-levels .btn-enter').val(amount)
            angular.element('.ym-registration-ptype-donation-levels .btn-enter').addClass('active')
            angular.element('.ym-registration-ptype-donation-levels .btn-enter').trigger('blur')


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

          # If the participant chooses to make a gift, check for the Double the Donation field
          # and record the chosen company in local storage if it exists
          console.log('ptype submit function')
          if angular.element(document).find('input[name="doublethedonation_company_id"]').length > 0
            if angular.element(document).find('input[name="doublethedonation_company_id"]').val().length > 0
              console.log('found dtd value!')
              dtdCoId = angular.element(document).find('input[name="doublethedonation_company_id"]').val()
              console.log('dtdCoId ' + dtdCoId)
              localStorage.dtdCompanyId = dtdCoId
            else
              console.log('clear dtd company id');
              localStorage.dtdCompanyId = ''

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
