angular.module 'ahaLuminateControllers'
  .controller 'DonationCtrl', [
    '$scope'
    '$rootScope'
    '$compile'
    'DonationService'
    '$timeout'
    '$q'
    ($scope, $rootScope, $compile, DonationService, $timeout, $q) ->
      $scope.paymentInfoErrors =
        errors: []
      $scope.donationGiftType = "installment";
      if jQuery('#level_installmentduration').length is 0
        $scope.donationGiftType = "flexible"

      angular.element('.page-error:contains("There was a problem processing your request")').remove()
      $fieldErrors = angular.element '.ErrorMessage'
      angular.forEach $fieldErrors, (fieldError) ->
        $fieldError = angular.element fieldError
        if $fieldError.find('.field-error-text').length > 0
          fieldErrorText = jQuery.trim $fieldError.find('.field-error-text').text()
          $scope.paymentInfoErrors.errors.push
            text: fieldErrorText

      $errorContainer = angular.element '.form-error'
      angular.forEach $errorContainer, (error) ->
        $error = angular.element error
        angular.element($error).addClass 'has-error'
        angular.element($error).removeClass 'form-error'

      $scope.donationInfo =
        validate: 'true'
        form_id: angular.element('#df_id').val()
        fr_id: angular.element('#FR_ID').val()
        billing_text: angular.element('#billing_info_same_as_donor_row label').text()
        giftType: 'onetime'
        monthly: false
        numberPayments: 1
        amount: ''
        installmentAmount: ''
        sustainingAmount: ''
        sustainingDuration: ''
        sustainingFrequency: ''
        levelType: 'level'
        otherAmt: ''
        otherLevelId: null
        coverFee: false
        levelChecked: ''

      $scope.donationLevels = []

      calculateInstallment = (number) ->
        amount = angular.element('.donation-level-total-amount').text()
        amount = amount.split('$')[1]
        $scope.donationInfo.installmentAmount = amount
        $scope.donationInfo.numberPayments = number
        localStorage['installmentAmount'] = amount
        localStorage['numberPayments'] = number

      calculateSustaining = (duration, freq) ->
        $scope.donationInfo.sustainingDuration = duration
        localStorage['sustainingDuration'] = duration
        $scope.donationInfo.sustainingFrequency = freq
        localStorage['sustainingFrequency'] = freq

      sustainingDropdown = ->
        duration = angular.element('#level_flexibleduration option:selected').text()
        freq = ''
        if duration.indexOf('month') > 0
          freq = 'monthly'
        if duration.indexOf('quarter') > 0
          freq = 'quarterly'
        if duration.indexOf('year') > 0
          freq = 'yearly'
        if duration is ''
          duration = 'an unlimited time period'
        $timeout ->
          calculateSustaining(duration,freq)
        , 500

      installmentDropdown = ->
        number = angular.element('#level_installmentduration').val()
        number = Number number.split(':')[1]
        if number is 0
          number = 1
        $timeout ->
          calculateInstallment(number)
        , 500

      if $scope.donationGiftType is "installment"
        document.getElementById('level_installmentduration').onchange = ->
          installmentDropdown()

        document.getElementById('level_installmentduration').onblur = ->
#          console.log('installment gift type blur')
          $timeout ->
            installmentDropdown()
          , 500

      if $scope.donationGiftType is "flexible"

        document.getElementById('level_flexibleduration').onchange = ->
          sustainingDropdown()

        document.getElementById('level_flexibleduration').onblur = ->
#          console.log('flexible gift type blur')
          $timeout ->
            sustainingDropdown()
          , 500

        angular.element('#level_flexiblegift_type1').trigger 'click'

      $scope.giftType = (type) ->
        $scope.donationInfo.giftType = type
        localStorage['giftType'] = type
        $scope.donationInfo.monthly = false
        if type is 'monthly'
          angular.element('.ym-donation-levels__type--onetime').removeClass 'active'
          angular.element('.ym-donation-levels__type--monthly').addClass 'active'
          if $scope.donationGiftType is "installment"
            angular.element('#level_installment_row').removeClass 'hidden'
            number = 1
            $timeout ->
              calculateInstallment(number)
            , 500
          if $scope.donationGiftType is "flexible"
            angular.element('#level_flexibleduration_row').removeClass 'hidden'
            angular.element('#level_flexibletotal_row').removeClass 'hidden'
            angular.element('#level_flexiblegift_type2').prop 'checked', true
            angular.element('#level_flexiblegift_type2').trigger 'click'
            if $scope.donationInfo.levelType is 'level'
              if $scope.donationInfo.amount is ''
                $scope.donationInfo.amount = "$0"
              amount = Number $scope.donationInfo.amount.split('$')[1]
            else
              amount = Number $scope.donationInfo.amount
            $scope.donationInfo.sustainingAmount = amount
            localStorage['sustainingAmount'] = amount
            $timeout ->
              sustainingDropdown()
            , 500
          angular.element('#pstep_finish span').remove()
          # $scope.donationInfo.monthly = true
        else
          angular.element('.ym-donation-levels__type--onetime').addClass 'active'
          angular.element('.ym-donation-levels__type--monthly').removeClass 'active'
          if $scope.donationGiftType is "installment"
            angular.element('#level_installment_row').addClass 'hidden'
            angular.element('#level_installmentduration').val 'S:0'
            angular.element('#level_installmentduration').click()
            if $scope.donationInfo.amount is undefined
              amount = 0
            else
              amount = Number $scope.donationInfo.amount.split('$')[1]
            $timeout ->
              calculateInstallment(number)
            , 500
          if $scope.donationGiftType is "flexible"
            angular.element('#level_flexibleduration_row').addClass 'hidden'
            angular.element('#level_flexibletotal_row').addClass 'hidden'
            angular.element('#level_flexiblegift_type1').prop 'checked', true
            angular.element('#level_flexiblegift_type1').trigger 'click'
            $scope.donationInfo.sustainingAmount = $scope.donationInfo.amount
            localStorage['sustainingAmount'] = $scope.donationInfo.amount
            $timeout ->
              sustainingDropdown()
            , 500

          $scope.donationInfo.monthly = false
          populateBtnAmt $scope.donationInfo.levelType

      $scope.selectLevel = (event, type, level, amount, addFee) ->
#        console.log('selectLevel event: ' + event + ' type: ' + type + ' level: ' + level + ' amount: ' + amount + ' addFee ' + addFee)
        if amount is undefined
          amount = $scope.donationInfo.otherAmt
#          console.log('amount ' + amount)

        coverFee = angular.element('#cover_fee_radio_Yes').prop 'checked'
#        console.log('coverFee ' + coverFee)
        addFee = addFee
#        console.log('addFee ' + addFee)

#        if coverFee == true && addFee != true
#          angular.element('#cover-fee-checkbox').prop 'checked' false
#          angular.element('#cover-fee-checkbox').click()

#        console.log('type ' + type)

        levelSelect = ->
#          console.log('levelSelect')

          angular.element('.ym-donation-levels__amount .btn-toggle.active').removeClass 'active'
          angular.element('.ym-donation-levels__amount .btn-toggle.level' + level).addClass 'active'
          angular.element('.ym-donation-levels__amount').removeClass 'active'
          angular.element('.ym-donation-levels__amount .btn-toggle.level' + level).parent().addClass 'active'
          angular.element('.ym-donation-levels__message').removeClass 'active'
          angular.element('.ym-donation-levels__message.level' + level).addClass 'active'
          angular.element('.donation-level-container.level' + level + ' input').click()

          $scope.donationInfo.amount = amount
#          console.log('$scope.donationInfo.amount ' +$scope.donationInfo.amount)
          $scope.donationInfo.levelType = type
#          console.log('$scope.donationInfo.levelType ' +$scope.donationInfo.levelType)
          localStorage['levelType'] = type
#          console.log('localStorage[levelType] ' +localStorage['levelType'])

          populateBtnAmt type

          if type is 'level'
#            console.log('if type is level')
            angular.element('.btn-enter').val ''
            $scope.donationInfo.otherAmt = ''
            if amount isnt undefined
#              console.log('amount is not undefined')
              localStorage['amount'] = amount
            localStorage['otherAmt'] = ''

          if $scope.donationGiftType is "installment"

#            console.log('$scope.donationGiftType is installment')

            if $scope.donationInfo.monthly is true
#              console.log('$scope.donationInfo.monthly is true')

              number = angular.element('#level_installmentduration').val()
              number = Number number.split(':')[1]
              if number is 0
                number = 1
              if $scope.donationInfo.levelType is 'level'
                amount = Number($scope.donationInfo.amount.split('$')[1]) / number
              else
                amount = Number $scope.donationInfo.amount
              $timeout ->
                calculateInstallment(number)
              , 500
            else
#              console.log('installment is not monthly')
              $scope.donationInfo.installmentAmount = amount
              $scope.donationInfo.numberPayments = 1

          if $scope.donationGiftType is "flexible"

#            console.log('$scope.donationGiftType is flexible')
#            console.log('$scope.donationInfo.giftType  ' + $scope.donationInfo.giftType )

            if $scope.donationInfo.monthly is true
              #angular.element('#level_flexiblegift_type2').trigger 'click'
              if $scope.donationInfo.levelType is 'level'
                amount = Number amount.split('$')[1]
              else
                amount = Number amount
              $timeout ->
                sustainingDropdown()
              , 500

            if coverFee == true && addFee == true
              if $scope.donationInfo.giftType == 'monthly'
                if $scope.donationGiftType is "installment"
                  document.getElementById('level_installmentduration').blur() 
                if $scope.donationGiftType is "flexible"
#                  console.log('trying to trigger level_flexibleduration blur')
                  angular.element('#level_flexibleduration').blur()


            $scope.donationInfo.sustainingAmount = amount
            localStorage['sustainingAmount'] = amount

          if coverFee == true && addFee != true
#            console.log('is this the place?')
            giftAmt = calculateGiftAmt('add')
#            console.log('new gift amount: ' + giftAmt)
            $scope.enterAmount giftAmt
            $scope.selectLevel null, 'other', $scope.donationInfo.otherLevelId, giftAmt, true

        if type is 'other'
#          console.log('type is other? ' + type)
#          console.log('donationInfo.levelType ' + $scope.donationInfo.levelType)
#          console.log('$scope.donationInfo.otherAmt ' + $scope.donationInfo.otherAmt)

          if type isnt $scope.donationInfo.levelType and $scope.donationInfo.otherAmt isnt ''
#            console.log('running levelSelect')
            levelSelect()

          if coverFee == true && addFee == true
            if $scope.donationInfo.giftType == 'monthly'
              if $scope.donationGiftType is "installment"
                document.getElementById('level_installmentduration').blur() 
              if $scope.donationGiftType is "flexible"
#                console.log('trying to trigger level_flexibleduration blur')
                angular.element('#level_flexibleduration').blur()

          if coverFee == true && addFee != true
#            console.log('is this the other place?')
            giftAmt = calculateGiftAmt('add')
#            console.log('new gift amount: ' + giftAmt)
            $scope.enterAmount giftAmt
            $scope.selectLevel null, 'other', $scope.donationInfo.otherLevelId, giftAmt, true

        else
#          console.log('else type is ' + type)
          levelSelect()

      $scope.enterAmount = (amount) ->
#        console.log('enter amount function')
#        console.log('amount ' + amount)
        angular.element('#pstep_finish span').text ''
        angular.element('#pstep_finish span').prepend ' $' + amount
        angular.element('.donation-level-user-entered input').val amount
        $scope.donationInfo.amount = amount
        $scope.donationInfo.otherAmt = amount
        localStorage['amount'] = amount
        localStorage['otherAmt'] = amount

        if $scope.donationGiftType is "installment"
          if $scope.donationInfo.monthly is true
            number = angular.element('#level_installmentduration').val()
            number = Number number.split(':')[1]
            if number is 0
              number = 1
            amount = amount / number
            $timeout ->
              calculateInstallment(number)
            , 500
            angular.element('#level_installmentduration').click()
        populateBtnAmt()

      $scope.focus = "focus"

      populateBtnAmt = (type) ->
        angular.element('#pstep_finish span').remove()
        if $scope.donationInfo.giftType is 'onetime'
          if type is 'level'
            levelAmt = ' <span>' + $scope.donationInfo.amount + ' <i class="fa fa-chevron-right" hidden aria-hidden="true"></i></span>'
          else
            levelAmt = '<span> $' + $scope.donationInfo.amount + '  <i class="fa fa-chevron-right" hidden aria-hidden="true"></i></span>'
          angular.element('#pstep_finish').append levelAmt

#      employerMatchFields = ->
#        angular.element('.employer-address-container').addClass 'hidden'
#        angular.element('.matching-gift-container').addClass 'hidden'
#        angular.element('label[for="match_checkbox_dropdown"]').before("<input type='hidden' name='match_checkbox_dropdown' id='match_checkbox_dropdown' value=''>")
#        angular.element('label[for="match_checkbox_dropdown"]').parent().parent().parent().addClass 'ym-employer-match'
#        empCheck = angular.element('#match_checkbox_radio').prop 'checked'
#        if empCheck is true
#          angular.element('.ym-employer-match__message').removeClass 'hidden'
#          angular.element('.matching-gift-container').removeClass 'hidden'

#      document.getElementById('match_checkbox_radio').onclick = ->
#        angular.element('.ym-employer-match__message').toggleClass 'hidden'
#        angular.element('.matching-gift-container').toggleClass 'hidden'

#      $scope.toggleEmployerMatch = ->
#        angular.element('.ym-employer-match__message').toggleClass 'hidden'
#        angular.element('.matching-gift-container').toggleClass 'hidden'

      donorRecognitionFields = ->
        angular.element('#tr_show_gift_to_public_row').addClass 'hidden ym-donor-recognition__fields'
        angular.element('#tr_recognition_nameanonymous_row').addClass 'hidden ym-donor-recognition__fields'
        angular.element('#tr_recognition_namerec_name_row').addClass 'hidden ym-donor-recognition__fields'

      $scope.toggleDonorRecognition = ->
        angular.element('.ym-donor-recognition__fields').toggleClass 'hidden'

      $scope.togglePersonalNote = ->
        angular.element('#tr_message_to_participant_row').toggleClass 'hidden'

      $scope.tributeGift = (type) ->
        if type is 'honor'
          angular.element('.btn-toggle--honor').toggleClass 'active'

          if not angular.element('.btn-toggle--honor').is '.active'
            document.activeElement.blur()

          if angular.element('.btn-toggle--honor').is '.active'
            angular.element('.btn-toggle--memory').removeClass 'active'
            angular.element('#tribute_type').val 'tribute_type_value2'
            angular.element('#tribute_show_honor_fieldsname').prop 'checked', true
            angular.element('#tribute_honoree_name_row').show()
          else
            angular.element('#tribute_type').val ''
            angular.element('#tribute_show_honor_fieldsname').prop 'checked', false
            angular.element('#tribute_honoree_name_row').hide()
        else
          angular.element('.btn-toggle--memory').toggleClass 'active'

          if not angular.element('.btn-toggle--memory').is '.active'
            document.activeElement.blur()

          if angular.element('.btn-toggle--memory').is '.active'
            angular.element('.btn-toggle--honor').removeClass 'active'
            angular.element('#tribute_type').val 'tribute_type_value1'
            angular.element('#tribute_show_honor_fieldsname').prop 'checked', true
            angular.element('#tribute_honoree_name_row').show()
          else
            angular.element('#tribute_type').val ''
            angular.element('#tribute_show_honor_fieldsname').prop 'checked', false
            angular.element('#tribute_honoree_name_row').hide()

      billingAddressFields = ->
        angular.element('#billing_first_name_row').addClass 'billing-info'
        angular.element('#billing_last_name_row').addClass 'billing-info'
        angular.element('#billing_addr_street1_row').addClass 'billing-info'
        angular.element('#billing_addr_street2_row').addClass 'billing-info'
        angular.element('#billing_addr_city_row').addClass 'billing-info'
        angular.element('#billing_addr_state_row').addClass 'billing-info'
        angular.element('#billing_addr_zip_row').addClass 'billing-info'
        angular.element('#billing_addr_country_row').addClass 'billing-info'
        angular.element('.billing-info').addClass 'hidden'

      addOptional = ->
        optional = '<span class="ym-optional">Optional</span>'
        angular.element('#donor_phone_row label').append optional
        angular.element('#donor_addr_street2_row label').append optional
        angular.element('#billing_addr_street2_row label').append optional

      ariaAdjustments = ->
#        angular.element('.ym-employer-match label').append '<span class="sr-only">Checkbox 1 of 3</span>'
        angular.element('.ym-donor-recognition label').append '<span class="sr-only">Checkbox 2 of 3</span>'
        angular.element('.ym-personal-note label').append '<span class="sr-only">Checkbox 3 of 3</span>'

      $scope.togglePaymentType = (paymentType) ->
        if paymentType is 'paypal'
          angular.element('#responsive_payment_typepay_typeradiopaypal').click()
          angular.element('#payment_cc_container').hide()
          angular.element('.btn--credit').removeClass 'active'
          angular.element('.btn--paypal').addClass 'active'
        else
          angular.element('#responsive_payment_typepay_typeradiocredit').click()
          angular.element('#payment_cc_container').show()
          angular.element('.btn--credit').addClass 'active'
          angular.element('.btn--paypal').removeClass 'active'

      $scope.toggleBillingInfo = ->
        angular.element('.billing-info').toggleClass 'hidden'
        inputStatus = angular.element('#billing_info').prop 'checked'

        if inputStatus is true
          angular.element('#billing_info_same_as_donorname').prop 'checked', true
        else
          angular.element('#billing_info_same_as_donorname').prop 'checked', false

      $scope.submitDonationForm = (e) ->
        # remove any credit card numbers from input fields other than the cc field
        r = /((?:\d{4}[ -]?){3}\d{3,4})/gm
        jQuery('[type=text]:not(#responsive_payment_typecc_numbername)').each ->
          jQuery(this).val jQuery(this).val().replace(r, '')
          return

        loading = '<div class="ym-loading text-center h3">Processing Gift <i class="fa fa-spinner fa-spin"></i></div>'
        angular.element('.button-sub-container').append loading
        angular.element('#pstep_finish').addClass 'hidden'

#        console.log('level type ' + $scope.donationInfo.levelType)
#        console.log('other amt ' + $scope.donationInfo.otherAmt)
#        console.log('parseint other amt ' + parseInt($scope.donationInfo.otherAmt))
#        console.log('amount in the damned field ' + angular.element('#other_amount').val())

        if $scope.donationInfo.levelType is 'other' || $scope.donationInfo.levelType is 'addFee'
#          console.log('level type is other or addFee')
          if $scope.donationInfo.otherAmt is undefined or !(parseInt($scope.donationInfo.otherAmt) >= 10)
#            console.log('otheramt ' + $scope.donationInfo.otherAmt)
#            console.log('parseint otheramt ' + parseInt($scope.donationInfo.otherAmt))
            e.preventDefault()
            jQuery('html, body').animate
              scrollTop: jQuery('a[name="donationLevels"]').offset().top
            , 0
            $scope.otherAmtError = true
            if not $scope.$$phase
              $scope.$apply()
            angular.element('#pstep_finish').removeClass 'hidden'
            angular.element('.ym-loading').addClass 'hidden'
#          console.log('amount in the damned field 2 ' + angular.element('#other_amount').val())
      angular.element("#ProcessForm").submit $scope.submitDonationForm

      loggedInForm = ->
        angular.element('#donor_first_name_row').addClass 'hidden'
        angular.element('#donor_last_name_row').addClass 'hidden'
        angular.element('#donor_email_address_row').addClass 'hidden'
        angular.element('#donor_phone_row').addClass 'hidden'
        angular.element('#donor_addr_street1_row').addClass 'hidden'
        angular.element('#donor_addr_street2_row').addClass 'hidden'
        angular.element('#donor_addr_city_row').addClass 'hidden'
        angular.element('#donor_addr_state_row').addClass 'hidden'
        angular.element('#donor_addr_zip_row').addClass 'hidden'
        angular.element('#donor_addr_country_row').addClass 'hidden'
        angular.element('.billing_info_toggle').addClass 'hidden'
        angular.element('h2.section-header-container:contains("Donor Information")').addClass 'hidden'
        angular.element('.billing-info').toggleClass 'hidden'
        angular.element('#billing_info').prop 'checked', false
        angular.element('#billing_info_same_as_donorname').prop 'checked', false

      loadLocalStorage = ->
        if localStorage['giftType']
          $scope.donationInfo.giftType = localStorage['giftType']
          if localStorage['giftType'] is 'monthly'
            $scope.donationInfo.monthly = true
            $scope.donationInfo.installmentAmount = localStorage['installmentAmount']
            $scope.donationInfo.numberPayments = localStorage['numberPayments']
            $scope.donationInfo.sustainingAmount = localStorage['sustainingAmount']
            $scope.donationInfo.sustainingDuration = localStorage['sustainingDuration']
            $scope.donationInfo.sustainingFrequency = localStorage['sustainingFrequency']
        if localStorage['amount']
          if localStorage['amount'] is 'undefined'
            $scope.donationInfo.otherAmt = ''
          else
            $scope.donationInfo.amount = localStorage['amount']
        if localStorage['levelType']
          $scope.donationInfo.levelType = localStorage['levelType']
          if localStorage['levelType'] is 'other'
            if localStorage['otherAmt'] is 'undefined'
              $scope.donationInfo.otherAmt = ''
            else
              $scope.donationInfo.otherAmt = localStorage['otherAmt']
          else
            $scope.donationInfo.otherAmt = ''
            localStorage['otherAmt'] = ''

      loadLevels = ->
        $q (resolve) ->
          DonationService.getDonationFormInfo 'form_id=' + $scope.donationInfo.form_id + '&fr_id=' + $scope.donationInfo.fr_id
            .then (response) ->
              levels = response.data.getDonationFormInfoResponse.donationLevels.donationLevel

              angular.forEach levels, (level) ->
                levelId = level.level_id
                amount = level.amount.formatted
                amount = amount.split('.')[0]
                userSpecified = level.userSpecified
                if jQuery('#level_installmentduration').length > 0
                  inputId = '#level_installmentexpanded' + levelId
                else
                  inputId = '#level_flexibleexpanded' + levelId
                classLevel = 'level' + levelId

                angular.element(inputId).parent().parent().parent().parent().addClass classLevel
                levelLabel = angular.element('.' + classLevel).find('.donation-level-expanded-label p').text()
                levelChecked = angular.element('.' + classLevel + ' .donation-level-label-input-container input').prop 'checked'

                if userSpecified is 'true'
                  $scope.donationInfo.otherLevelId = levelId
                if levelChecked is true
                  if userSpecified is 'true'
                    $scope.donationInfo.amount = $scope.donationInfo.otherAmt
                    $scope.donationInfo.sustainingAmount = $scope.donationInfo.otherAmt
                    installmentAmount = Number($scope.donationInfo.otherAmt)/Number($scope.donationInfo.numberPayments)
                    $scope.donationInfo.installmentAmount = installmentAmount.toFixed 2
                  else
                    $scope.donationInfo.amount = amount
                    $scope.donationInfo.sustainingAmount = amount
                    if localStorage['installmentAmount']
                      $scope.donationInfo.installmentAmount = localStorage['installmentAmount']
                    else
                      $scope.donationInfo.installmentAmount = level.amount.decimal
                  $scope.donationInfo.levelChecked = classLevel
                  if $scope.donationInfo.monthly is false
                    angular.element('.finish-step').append '<span> '+ amount + ' <i class="fa fa-chevron-right" hidden aria-hidden="true"></i></span>'
                  else
                    angular.element('.finish-step').append '<span> <i class="fa fa-chevron-right" hidden aria-hidden="true"></i></span>'
                $scope.donationLevels.push
                  levelId: levelId
                  classLevel: classLevel
                  amount: amount
                  userSpecified: userSpecified
                  levelLabel: levelLabel
                  levelChecked: levelChecked
          resolve()

      calculateGiftAmt = (type) ->
        if type == 'add'
          amount = $scope.donationInfo.amount.replace '$', ''
          amount = Number amount
          (amount * 2.6 / 100 + 0.26 + amount).toFixed 2
        else
          amount = $scope.donationInfo.amount.replace '$', ''
          amount = Number amount
          (Math.round(amount / 1.026 - 0.26)).toFixed 2

      $scope.toggleCoverFeeCheckbox = (state) ->
        angular.element('#cover_fee_radio_Yes').prop 'checked', state
#        console.log('$scope.donationGiftType ' + $scope.donationGiftType)
        if state is true
          giftAmt = calculateGiftAmt('add')
          $scope.enterAmount giftAmt
          $scope.selectLevel null, 'other', $scope.donationInfo.otherLevelId, giftAmt, true
          return
        else
          giftAmt = calculateGiftAmt('remove')
          $scope.enterAmount giftAmt
          $scope.selectLevel null, 'other', $scope.donationInfo.otherLevelId, giftAmt, true
          return

      addFeeCheckbox = ->
        elmCoverFeeRadio = angular.element '#cover_fee_radio_Yes'
        if elmCoverFeeRadio.length > 0
          $scope.donationInfo.coverFee = elmCoverFeeRadio.prop 'checked'
          elmAddFeeCheckbox = angular.element '<input type="checkbox" name="cover-fee-checkbox" id="cover-fee-checkbox" ng-model="donationInfo.coverFee" ng-change="toggleCoverFeeCheckbox(donationInfo.coverFee)"><label for="cover-fee-checkbox">&nbsp;I\'d like to cover all of the transaction fees so 100% of my donation goes to support the AHA</label>'
          elmCoverFeeRadio.after elmAddFeeCheckbox
          angular.element('#cover_fee_radio_Yes').hide()
          $compile(elmAddFeeCheckbox) $scope

      loadLevels().then ->
        $scope.otherAmtError = false
        if $scope.paymentInfoErrors.errors.length > 0
          loadLocalStorage()
        if $scope.donationInfo.giftType is 'onetime'
          angular.element('#level_installment_row').addClass 'hidden'
          angular.element('#level_flexibleduration_row').addClass 'hidden'
          angular.element('#level_flexibletotal_row').addClass 'hidden'
        $requiredField = angular.element '.field-required'
        angular.forEach $requiredField, (required) ->
          $req = angular.element required
          if not angular.element($req).parent().parent().parent().is '.payment-field-container' or angular.element($req).is '.btn'
            if not angular.element($req).parent().parent().is '.form-donation-level'
              angular.element($req).parent().parent().addClass 'form-row-required'
        angular.element('#tr_message_to_participant_row').addClass 'hidden'
        angular.element('#billing_info').parent().addClass 'billing_info_toggle'
        angular.element('#payment_cc_container').append '<div class="clearfix" />'
        angular.element('#responsive_payment_typecc_cvv_row .FormLabelText').text 'CVV:'
        angular.element('#tr_recognition_namerec_namename').attr 'placeholder', 'Example: Jane Hero, Heart Hero Family, From Jane - In memory of Grandma'
        angular.element('#tr_message_to_participantname').attr 'placeholder', 'Write a message of encouragement. 255 characters max.'
        addOptional()
        addFeeCheckbox()
#        employerMatchFields()
        billingAddressFields()
        donorRecognitionFields()
        ariaAdjustments()
        if angular.element('body').is '.cons-logged-in'
          hideDonorInfo = true
          $reqInput = angular.element '.form-row-required input[type="text"]'
          $reqSelect = angular.element '.form-row-required select'
          angular.forEach $reqInput, (req) ->
            if angular.element(req).val() is ''
              hideDonorInfo = false
          angular.forEach $reqSelect, (req) ->
            if angular.element(req).val() is ''
              hideDonorInfo = false
          if hideDonorInfo is true
            loggedInForm()
        return
      , (reason) ->
        # TODO
      #setTimeout ->
      #  angular.element("input[name=otherAmt]").click().focus()
      #, 1000
  ]
