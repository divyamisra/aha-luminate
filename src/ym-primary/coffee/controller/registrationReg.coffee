angular.module 'ahaLuminateControllers'
  .controller 'RegistrationRegCtrl', [
    '$rootScope'
    '$scope'
    '$filter'
    '$uibModal'
    'APP_INFO'
    'TeamraiserCompanyService'
    'TeamraiserRegistrationService'
    'SchoolLookupService'
    'BoundlessService'
    ($rootScope, $scope, $filter, $uibModal, APP_INFO, TeamraiserCompanyService, TeamraiserRegistrationService, SchoolLookupService, BoundlessService) ->
      $rootScope.companyName = ''
      $scope.teachers = []
      $scope.teachersByGrade = []
      $scope.companyId = angular.element('[name=s_frCompanyId]').val()
      
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
      
      $scope.registrationInfoErrors =
        errors: []
      $fieldErrors = angular.element '.ErrorMessage'
      angular.forEach $fieldErrors, (fieldError) ->
        $fieldError = angular.element fieldError
        $fieldErrorLabel = $fieldError.closest('.form-error').find('label .input-label')
        $fieldErrorText = $fieldError.find('.field-error-text')
        if $fieldErrorText.length > 0
          $fieldErrorText.html $fieldErrorText.html().replace(':&nbsp;is a required field', '&nbsp;is a required field')
          fieldErrorText = jQuery.trim $fieldErrorText.text()
          fieldErrorText = fieldErrorText.replace ': is a required field', ' is a required field'
          if $fieldErrorLabel.length > 0
            fieldErrorLabel = jQuery.trim $fieldErrorLabel.text()
            if fieldErrorLabel and fieldErrorLabel isnt ''
              fieldErrorText = fieldErrorText.replace 'Error: Please enter a valid response.', fieldErrorLabel + ' - Please enter a valid response.'
              fieldErrorText = fieldErrorText.replace ': - Please enter a valid response.', ' - Please enter a valid response.'
          $scope.registrationInfoErrors.errors.push
            text: fieldErrorText
      
      $scope.registrationHiddenFields = 
        fr_cstm_reg: 't'
      $scope.registrationQuestions = {}
      $scope.registrationInfo = {}
      
      $contactInfo = angular.element '.js--registration-reg-contact-info'
      $contactInfoHiddenFields = $contactInfo.find 'input[type="hidden"][name]'
      angular.forEach $contactInfoHiddenFields, (contactInfoHiddenField) ->
        $contactInfoHiddenField = angular.element contactInfoHiddenField
        questionName = $contactInfoHiddenField.attr 'name'
        questionValue = $contactInfoHiddenField.val()
        $scope.registrationHiddenFields[questionName] = questionValue
      $contactInfoQuestions = $contactInfo.find 'input[type="text"], input[type="email"], input[type="tel"], select'
      angular.forEach $contactInfoQuestions, (contactInfoQuestion) ->
        $contactInfoQuestion = angular.element contactInfoQuestion
        questionName = $contactInfoQuestion.attr 'name'
        questionId = $contactInfoQuestion.attr 'id'
        $questionLabel = angular.element 'label[for="' + questionId + '"]'
        questionLabel = undefined
        if $questionLabel.find('.input-label').length > 0
          questionLabel = jQuery.trim $questionLabel.find('.input-label').text()
        questionValue = $contactInfoQuestion.val() or ''
        questionMaxLength = $contactInfoQuestion.attr('maxlength') or ''
        questionHasError = $contactInfoQuestion.is '.form-error *'
        $scope.registrationQuestions[questionName] =
          label: questionLabel
          value: questionValue
          maxLength: questionMaxLength
          hasError: questionHasError
        $scope.registrationInfo[questionName] = questionValue
      
      $optIns = angular.element '.js--registration-reg-opt-ins'
      $optInHiddenFields = $optIns.find 'input[type="hidden"][name]'
      angular.forEach $optInHiddenFields, (optInHiddenField) ->
        $optInHiddenField = angular.element optInHiddenField
        questionName = $optInHiddenField.attr 'name'
        questionValue = $optInHiddenField.val()
        $scope.registrationHiddenFields[questionName] = questionValue
      $optInQuestions = $optIns.find 'input[type="checkbox"]'
      angular.forEach $optInQuestions, (optInQuestion) ->
        $optInQuestion = angular.element optInQuestion
        questionName = $optInQuestion.attr 'name'
        questionId = $optInQuestion.attr 'id'
        questionChecked = $optInQuestion.is '[checked]'
        $questionLabel = angular.element 'label[for="' + questionId + '"]'
        questionLabel = undefined
        if $questionLabel.find('.input-label').length > 0
          questionLabel = jQuery.trim $questionLabel.find('.input-label').text()
        $scope.registrationQuestions[questionName] =
          label: questionLabel
        $scope.registrationInfo[questionName] = questionChecked
      
      $loginInfo = angular.element '.js--registration-reg-login-info'
      $loginInfoHiddenFields = $loginInfo.find 'input[type="hidden"][name]'
      angular.forEach $loginInfoHiddenFields, (loginInfoHiddenField) ->
        $loginInfoHiddenField = angular.element loginInfoHiddenField
        questionName = $loginInfoHiddenField.attr 'name'
        questionValue = $loginInfoHiddenField.val()
        $scope.registrationHiddenFields[questionName] = questionValue
      $loginInfoQuestions = $loginInfo.find 'input[type="text"], input[type="password"]'
      angular.forEach $loginInfoQuestions, (loginInfoQuestion) ->
        $loginInfoQuestion = angular.element loginInfoQuestion
        questionName = $loginInfoQuestion.attr 'name'
        questionId = $loginInfoQuestion.attr 'id'
        $questionLabel = angular.element 'label[for="' + questionId + '"]'
        questionLabel = undefined
        if $questionLabel.find('.input-label').length > 0
          questionLabel = jQuery.trim $questionLabel.find('.input-label').text()
        questionValue = $loginInfoQuestion.val() or ''
        questionMaxLength = $loginInfoQuestion.attr('maxlength') or ''
        questionHasError = $loginInfoQuestion.is '.form-error *'
        $scope.registrationQuestions[questionName] =
          label: questionLabel
          value: questionValue
          maxLength: questionMaxLength
          hasError: questionHasError
        $scope.registrationInfo[questionName] = questionValue
      
      $additionalInfo = angular.element '.js--registration-reg-additional-info'
      $additionalInfoHiddenFields = $additionalInfo.find 'input[type="hidden"][name]'
      angular.forEach $additionalInfoHiddenFields, (additionalInfoHiddenField) ->
        $additionalInfoHiddenField = angular.element additionalInfoHiddenField
        questionName = $additionalInfoHiddenField.attr 'name'
        questionValue = $additionalInfoHiddenField.val()
        $scope.registrationHiddenFields[questionName] = questionValue
      $additionalInfoQuestions = $additionalInfo.find 'input[type="text"], input[type="number"], textarea, select'
      angular.forEach $additionalInfoQuestions, (additionalInfoQuestion) ->
        $additionalInfoQuestion = angular.element additionalInfoQuestion
        questionType = $additionalInfoQuestion.prop('tagName').toLowerCase()
        questionName = $additionalInfoQuestion.attr 'name'
        questionId = $additionalInfoQuestion.attr 'id'
        $questionLabel = angular.element 'label[for="' + questionId + '"]'
        questionLegend = undefined
        if $additionalInfoQuestion.is '[class*="survey-date-"] select'
          $questionLegend = $additionalInfoQuestion.closest('fieldset').find 'legend'
          if $questionLegend.find('.input-label').length > 0
            questionLegend = jQuery.trim $questionLegend.find('.input-label').text()
        questionLabel = undefined
        if $questionLabel.find('.input-label').length > 0
          questionLabel = jQuery.trim $questionLabel.find('.input-label').text()
        questionOptions = []
        if questionType is 'select'
          $questionOptions = $additionalInfoQuestion.find 'option'
          angular.forEach $questionOptions, (questionOption) ->
            $questionOption = angular.element questionOption
            questionOptionValue = $questionOption.attr 'value'
            questionOptionText = jQuery.trim $questionOption.text()
            questionOptions.push
              value: questionOptionValue
              text: questionOptionText
        questionValue = $additionalInfoQuestion.val() or ''
        questionMaxLength = $additionalInfoQuestion.attr('maxlength') or ''
        questionHasError = $additionalInfoQuestion.is '.form-error *'
        $scope.registrationQuestions[questionName] =
          type: questionType
          legend: questionLegend
          label: questionLabel
          options: questionOptions
          value: questionValue
          maxLength: questionMaxLength
          hasError: questionHasError
        $scope.registrationInfo[questionName] = questionValue
      
      $scope.participationType = {}
      setParticipationType = (participationType) ->
        $scope.participationType = participationType
        if not $scope.$$phase
          $scope.$apply()
      TeamraiserRegistrationService.getParticipationTypes
        error: ->
          # TODO
        success: (response) ->
          participationTypes = response.getParticipationTypesResponse.participationType
          participationTypes = [participationTypes] if not angular.isArray participationTypes
          participationType = participationTypes[0]
          waiverContent = participationType.waiver?.content
          if waiverContent
            participationType.waiver.content = waiverContent.replace /(?:\r\n|\r|\n)/g, '<br />'
          setParticipationType participationType
      $scope.$watch 'participationType.id', (newValue) ->
        if newValue
          initCustomQuestions = ->
            if not $scope.registrationCustomQuestions
              $scope.registrationCustomQuestions = {}
            if not $scope.$$phase
              $scope.$apply()
          setRegistrationQuestionSurveyKey = (questionName, surveyKey) ->
            $scope.registrationQuestions[questionName].surveyKey = surveyKey
            questionLegend = $scope.registrationQuestions[questionName].legend
            if surveyKey is 'ym_khc_email_type' or surveyKey is 'ym_khc_grade' or surveyKey is 'ym_khc_school' or surveyKey is 'ym_khc_teacher_title' or surveyKey is 'ym_khc_teacher_name' or surveyKey is 'ym_khc_school_city' or surveyKey is 'ym_khc_school_state' or surveyKey is 'ym_khc_parentfirstname' or surveyKey is 'ym_khc_parentlastname' or surveyKey is 'ym_khc_student_state' or surveyKey is 'ym_khc_instruction_type'
              initCustomQuestions()
              $scope.registrationCustomQuestions[surveyKey] = questionName
            else if questionLegend isnt 'Event Date' and surveyKey isnt 'ym_khc_challenge_info' and surveyKey isnt 'ym_khc_ecards_sent' and surveyKey isnt 'ym_khc_ecards_shared' and surveyKey isnt 'ym_khc_ecards_open' and surveyKey isnt 'ym_khc_ecards_clicked' and surveyKey isnt 'ym_khc_ym_game_points' and surveyKey isnt 'bb_facebook_connector_id'
              if not $scope.registrationAdditionalQuestions
                $scope.registrationAdditionalQuestions = {}
              $scope.registrationAdditionalQuestions[questionName] = questionName
            if not $scope.$$phase
              $scope.$apply()
          TeamraiserRegistrationService.getRegistrationDocument 'participation_id=' + newValue,
            error: ->
              # TODO
            success: (response) ->
              registrationQuestions = response.processRegistrationRequest?.primaryRegistration?.question
              if registrationQuestions
                registrationQuestions = [registrationQuestions] if not angular.isArray registrationQuestions
                angular.forEach registrationQuestions, (registrationQuestion, registrationQuestionIndex) ->
                  registrationQuestionKey = registrationQuestion.key
                  registrationQuestionId = registrationQuestion.id
                  angular.forEach $scope.registrationQuestions, (questionObj, questionName) ->
                    if questionName.match('_' + registrationQuestionId + '$')
                      registrationQuestions[registrationQuestionIndex].ng_questionName = questionName
                registrationQuestions = $filter('orderBy') registrationQuestions, 'ng_questionName', false
                angular.forEach registrationQuestions, (registrationQuestion) ->
                  if registrationQuestion.ng_questionName
                    setRegistrationQuestionSurveyKey registrationQuestion.ng_questionName, registrationQuestion.key
              initCustomQuestions()
      
      $scope.toggleAcceptWaiver = (acceptWaiver) ->
        $scope.acceptWaiver = acceptWaiver
      
      $scope.previousStep = ->
        $scope.ng_go_back = true
        $timeout ->
          $scope.submitReg()
        , 500
        false
      
      $scope.familyChallengePopup = false
      $scope.submitFamilyChallengePopup = ->
        angular.element('.js--default-reg-form').submit()
      
      $scope.submitReg = ->
        if $scope.acceptWaiver isnt 'yes' and not $scope.ng_go_back
          window.scrollTo 0, 0
          $scope.registrationInfoErrors.errors = [
            {
              text: 'You must agree to the waiver.'
            }
          ]
        else
          if not $scope.familyChallengePopup
            $scope.familyChallengePopup = true
            $scope.showFamilyChallengePopup = $uibModal.open
              scope: $scope
              templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/modal/showFamilyChallengePopup.html'
          else 
            angular.element('.js--default-reg-form').submit()
        false

      BoundlessService.getTeachersBySchool $scope.companyId
      .then (response) ->
        $scope.teachers = response.data.teachers

      $scope.getTeacherList = () ->
        selectedGrade = $scope.registrationInfo[$scope.registrationCustomQuestions.ym_khc_grade]
        $scope.teachersByGrade = []
        teachersByGrade = []
        angular.forEach $scope.teachers, (teacher) ->
          if teacher.grade == selectedGrade
            teachersByGrade.push teacher_name: teacher.teacher_name
        $scope.teachersByGrade = teachersByGrade
        
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
