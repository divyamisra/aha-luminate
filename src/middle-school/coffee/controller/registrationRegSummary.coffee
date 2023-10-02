angular.module 'ahaLuminateControllers'
  .controller 'RegistrationRegSummaryCtrl', [
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
      
      $scope.regSummaryInfo = {}
      
      $participantInfo = angular.element '.js--registration-regsummary-participant-info'
      $scope.regSummaryInfo.cons_first_name = jQuery.trim $participantInfo.find('.contact-info-first').text()
      $scope.regSummaryInfo.cons_last_name = jQuery.trim $participantInfo.find('.contact-info-last').text()
      $scope.regSummaryInfo.cons_email = jQuery.trim $participantInfo.find('.contact-info-email').text()
      $scope.regSummaryInfo.fr_gift = jQuery.trim $participantInfo.find('.additional-gift-amount').text().replace '.00', ''

      # if there is an additional gift amount, put it in local storage for DtD
      if angular.element(document).find('.additional-gift-amount').text() != '$0.00'
        console.log 'there is a gift value'
        addlGiftAmt = angular.element(document).find('.additional-gift-amount').text()
        addlGiftAmtClean = addlGiftAmt.replace(/[^0-9.]/g, '')
        addlGiftAmtFormatted = '$'.concat(addlGiftAmtClean);
        localStorage.addlGiftAmt = addlGiftAmtFormatted
      else
        console.log 'clear addGiftAmt'
        localStorage.addlGiftAmt = ''

      $scope.submitRegSummary = ->
        angular.element('.js--default-regsummary-form').submit()
        false
        
      $scope.submitRegSummary()
  ]
