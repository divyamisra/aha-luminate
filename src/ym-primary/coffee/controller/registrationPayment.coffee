angular.module 'ahaLuminateControllers'
  .controller 'RegistrationPaymentCtrl', [
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
      
      $scope.paymentInfoErrors =
        errors: []
      $fieldErrors = angular.element '.ErrorMessage'
      angular.forEach $fieldErrors, (fieldError) ->
        $fieldError = angular.element fieldError
        if $fieldError.find('.field-error-text').length > 0
          fieldErrorText = jQuery.trim $fieldError.find('.field-error-text').text()
          $scope.paymentInfoErrors.errors.push
            text: fieldErrorText
      
      $scope.paymentHiddenFields = {}
      $scope.paymentQuestions = {}
      $scope.paymentInfo = {}
      
      $billingInfo = angular.element '.js--registration-payment-billing-info'
      $billingInfoHiddenFields = $billingInfo.find 'input[type="hidden"][name]'
      angular.forEach $billingInfoHiddenFields, (billingInfoHiddenField) ->
        $billingInfoHiddenField = angular.element billingInfoHiddenField
        questionName = $billingInfoHiddenField.attr 'name'
        questionValue = $billingInfoHiddenField.val()
        $scope.paymentHiddenFields[questionName] = questionValue
      $billingInfoQuestions = $billingInfo.find 'input[type="text"], select'
      angular.forEach $billingInfoQuestions, (billingInfoQuestion) ->
        $billingInfoQuestion = angular.element billingInfoQuestion
        questionType = $billingInfoQuestion.prop('tagName').toLowerCase()
        questionName = $billingInfoQuestion.attr 'name'
        questionId = $billingInfoQuestion.attr 'id'
        questionOptions = []
        if questionType is 'select'
          $questionOptions = $billingInfoQuestion.find 'option'
          angular.forEach $questionOptions, (questionOption) ->
            $questionOption = angular.element questionOption
            questionOptionValue = $questionOption.attr 'value'
            questionOptionText = jQuery.trim $questionOption.text()
            questionOptions.push
              value: questionOptionValue
              text: questionOptionText
        questionValue = $billingInfoQuestion.val() or ''
        questionMaxLength = $billingInfoQuestion.attr('maxlength') or ''
        questionHasError = $billingInfoQuestion.is '.form-error *'
        $scope.paymentQuestions[questionName] =
          type: questionType
          options: questionOptions
          value: questionValue
          maxLength: questionMaxLength
          hasError: questionHasError
        $scope.paymentInfo[questionName] = questionValue
      
      $accountInfo = angular.element '.js--registration-payment-account-info'
      $accountInfoHiddenFields = $accountInfo.find 'input[type="hidden"][name]'
      angular.forEach $accountInfoHiddenFields, (accountInfoHiddenField) ->
        $accountInfoHiddenField = angular.element accountInfoHiddenField
        questionName = $accountInfoHiddenField.attr 'name'
        questionValue = $accountInfoHiddenField.val()
        $scope.paymentHiddenFields[questionName] = questionValue
      $accountInfoQuestions = $accountInfo.find 'input[type="text"], select'
      angular.forEach $accountInfoQuestions, (accountInfoQuestion) ->
        $accountInfoQuestion = angular.element accountInfoQuestion
        questionType = $accountInfoQuestion.prop('tagName').toLowerCase()
        questionName = $accountInfoQuestion.attr 'name'
        questionId = $accountInfoQuestion.attr 'id'
        questionOptions = []
        if questionType is 'select'
          $questionOptions = $accountInfoQuestion.find 'option'
          angular.forEach $questionOptions, (questionOption) ->
            $questionOption = angular.element questionOption
            questionOptionValue = $questionOption.attr 'value'
            questionOptionText = jQuery.trim $questionOption.text()
            questionOptions.push
              value: questionOptionValue
              text: questionOptionText
        questionValue = $accountInfoQuestion.val() or ''
        questionMaxLength = $accountInfoQuestion.attr('maxlength') or ''
        questionHasError = $accountInfoQuestion.is '.form-error *'
        $scope.paymentQuestions[questionName] =
          type: questionType
          options: questionOptions
          value: questionValue
          maxLength: questionMaxLength
          hasError: questionHasError
        $scope.paymentInfo[questionName] = questionValue
      if angular.element('#responsive_payment_typepay_typeradiopaypal').length > 0
        questionValue = angular.element('[name="responsive_payment_typepay_typeradio"]:checked').val()
        $scope.paymentQuestions.responsive_payment_typepay_typeradio =
          value: questionValue
        $scope.paymentInfo.responsive_payment_typepay_typeradio = questionValue
      
      $scope.togglePaymentType = (paymentType) ->
        $scope.paymentInfo.responsive_payment_typepay_typeradio = paymentType
      
      $scope.previousStep = ->
        window.history.go(-3)
        #$scope.ng_go_back = true
        #$timeout ->
        #  $scope.submitPayment()
        #, 500
        false

      submitted = false

      $scope.submitPayment = ->

        console.log("submitPayment")
        if submitted
          alert 'You have already submitted this payment. Please wait....'
          #false
        else
          submitted = true
          #true
          angular.element('.js--default-payment-form').submit()
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
