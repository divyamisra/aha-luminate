angular.module 'trPcControllers'
  .controller 'EmailComposeViewCtrl', [
    '$rootScope'
    '$scope'
    '$routeParams'
    '$timeout'
    '$location'
    '$anchorScroll'
    '$httpParamSerializer'
    '$uibModal'
    'APP_INFO'
    'TeamraiserEventService'
    'TeamraiserEmailService'
    'ContactService'
    'ConstituentService'
    ($rootScope, $scope, $routeParams, $timeout, $location, $anchorScroll, $httpParamSerializer, $uibModal, APP_INFO, TeamraiserEventService, TeamraiserEmailService, ContactService, ConstituentService) ->
      $scope.messageType = $routeParams.messageType
      $scope.messageId = $routeParams.messageId
      $scope.baseDomain = $location.absUrl().split('/site/')[0]

      $scope.emailPromises = []

      $scope.getMessageCounts = (refresh) ->
        $scope.messageCounts = {}
        messageTypes = [
          'draft'
          'sentMessage'
        ]
        angular.forEach messageTypes, (messageType) ->
          apiMethod = 'get' + messageType.charAt(0).toUpperCase() + messageType.slice(1) + 's'
          messageCountPromise = TeamraiserEmailService[apiMethod] 'list_page_size=1'
            .then (response) ->
              $scope.messageCounts[messageType + 's'] = response.data[apiMethod + 'Response'].totalNumberResults
              response
          if not refresh
            $scope.emailPromises.push messageCountPromise
      $scope.getMessageCounts()



      $scope.getContactCounts = ->
        $scope.contactCounts = {}
        contactFilters = [
          'email_rpt_show_all'
          'email_rpt_show_never_emailed'
          'email_rpt_show_nondonors_followup'
          'email_rpt_show_unthanked_donors'
          'email_rpt_show_donors'
          'email_rpt_show_nondonors'
        ]
        # TODO: email_rpt_show_teammates and email_rpt_show_nonteammates
        angular.forEach contactFilters, (filter) ->
          contactCountPromise = ContactService.getTeamraiserAddressBookContacts 'tr_ab_filter=' + filter + '&skip_groups=true&list_page_size=1'
            .then (response) ->
              $scope.contactCounts[filter] = response.data.getTeamraiserAddressBookContactsResponse?.totalNumberResults or '0'
              response
          $scope.emailPromises.push contactCountPromise
      $scope.getContactCounts()

      $scope.resetSelectedContacts = ->
        $rootScope.selectedContacts =
          contacts: []
      if not $rootScope.selectedContacts?.contacts
        $scope.resetSelectedContacts()

      setEmailComposerDefaults = ->
        defaultStationeryId = $scope.teamraiserConfig.defaultStationeryId
        selectedContacts = $rootScope.selectedContacts.contacts
        $scope.emailComposer =
          message_id: ''
          recipients: selectedContacts.join ', '
          suggested_message_id: ''
          subject: ''
          prepend_salutation: true
          message_body: ''
          layout_id: if defaultStationeryId is not '-1' then defaultStationeryId else ''
      setEmailComposerDefaults()

      setEmailMessageBody = (messageBody = '') ->
        if not messageBody or not angular.isString(messageBody)
          messageBody = ''
        $scope.emailComposer.message_body = messageBody

      getEmailMessageBody = ->
        messageBody = $scope.emailComposer.message_body
        messageBody

      if $scope.messageType is 'draft' and $scope.messageId
        TeamraiserEmailService.getDraft 'message_id=' + $scope.messageId
          .then (response) ->
            if response.data.errorResponse
              # TODO
            else
              messageInfo = response.data.getDraftResponse?.messageInfo
              if messageInfo
                $scope.emailComposer.message_id = $scope.messageId
                # TODO: recipients
                $scope.emailComposer.subject = messageInfo.subject
                $scope.emailComposer.prepend_salutation = messageInfo.prependsalutation is 'true'
                messageBody = messageInfo.messageBody
                setEmailMessageBody messageBody
      else if $scope.messageType is 'copy' and $scope.messageId
        TeamraiserEmailService.getSentMessage 'message_id=' + $scope.messageId
          .then (response) ->
            if response.data.errorResponse
              # TODO
            else
              messageInfo = response.data.getSentMessageResponse?.messageInfo
              if messageInfo
                $scope.emailComposer.subject = messageInfo.subject
                messageBody = messageInfo.messageBody
                setEmailMessageBody messageBody

      $scope.emailTabNames = []
      suggestedMessagesPromise = TeamraiserEmailService.getSuggestedMessages()
        .then (response) ->
          suggestedMessages = response.data.getSuggestedMessagesResponse.suggestedMessage
          suggestedMessages = [suggestedMessages] if not angular.isArray suggestedMessages
          $scope.suggestedMessages = []
          pcSetMessages = {}
          angular.forEach suggestedMessages, (message) ->
            pcSetMessages = {}
            if message.active is 'true'
              $scope.suggestedMessages.push message
            switch message.name
              when 'Ask 2: Donation Reminder'
                pcSetMessages.header = 'Donation Reminder'
                pcSetMessages.messageID = message.messageId
                pcSetMessages.headerID = 'send_email_donation_reminder'
                $timeout ->
                  document.getElementById('send_email_donation_reminder').getElementsByTagName('a')[0].onclick = ->
                    _gaq.push(['t2._trackEvent', 'HW PC', 'click', 'Send Email - Donation Reminder'])
                , 500
                loadSuggestedMessagePC(pcSetMessages)
              when 'Ask 3: Help me Reach my Goal'
                pcSetMessages.header = 'Additional Request'
                pcSetMessages.messageID = message.messageId
                pcSetMessages.headerID = 'send_email_additional_request'
                $timeout ->
                  document.getElementById('send_email_additional_request').getElementsByTagName('a')[0].onclick = ->
                    _gaq.push(['t2._trackEvent', 'HW PC', 'click', 'Send Email - Additional Request'])
                , 500
                loadSuggestedMessagePC(pcSetMessages)
              when 'Ask 1: Donation Solicitation'
                pcSetMessages.header = 'Ask for Donations'
                pcSetMessages.messageID = message.messageId
                pcSetMessages.headerID = 'send_email_ask_donations'
                $timeout ->
                  document.getElementById('send_email_ask_donations').getElementsByTagName('a')[0].onclick = ->
                    _gaq.push(['t2._trackEvent', 'HW PC', 'click', 'Send Email - Ask for Donations'])
                , 500
                loadSuggestedMessagePC(pcSetMessages)
              when 'Donation Thank You'
                pcSetMessages.header = 'Thank Donors'
                pcSetMessages.messageID = message.messageId
                pcSetMessages.headerID = 'send_email_thank_donors'
                $timeout ->
                  document.getElementById('send_email_thank_donors').getElementsByTagName('a')[0].onclick = ->
                    _gaq.push(['t2._trackEvent', 'HW PC', 'click', 'Send Email - Thank Donors'])
                , 500
                loadSuggestedMessagePC(pcSetMessages)
          response
      $scope.emailPromises.push suggestedMessagesPromise

      loadSuggestedMessagePC = (pcSetMessages) ->
        pcSetMessages.content = ''
        if pcSetMessages.messageID is ''
          console.log 'message id was blank'
        else
          TeamraiserEmailService.getSuggestedMessage 'message_id=' + pcSetMessages.messageID
            .then (response) ->
              if response.data.errorResponse
                # TODO
              else
                messageInfo = response.data.getSuggestedMessageResponse.messageInfo
                if messageInfo
                  pcSetMessages.content = messageInfo.messageBody + '<p>My Personal Page: ' + $scope.baseDomain + '/site/TR?fr_id=' + $scope.frId + '&pg=personal&px=' + $scope.consId + '</p>'
                  pcSetMessages.subject = messageInfo.subject
        $scope.emailTabNames.push pcSetMessages

      $scope.sendGAEvent = (event) ->
        _gaq.push(['t2._trackEvent', 'HW PC', 'click', event])

      logUserInt = (subject,body) ->
        ConstituentService.logInteraction 'interaction_type_id=' + $rootScope.interactionTypeId + '&interaction_subject=' + subject + '&interaction_body=' + body
          .then (response) ->
            if response.data.updateConsResponse?.message
              # todo confirmation 
            else
              console.log 'logged interaction failed'

      $scope.sendEmailOpenEmail = (messageID) ->
        angular.forEach $scope.emailTabNames, (message) ->
          if message.messageID is messageID
            emailSubject = message.subject
            emailBody = message.content
            emailBodyClean1 = emailBody.replace(/<p>/g,"");
            emailBodyClean2 = emailBodyClean1.replace(/<\/p>/g,"%0D%0A%0D%0A");
            emailBodyClean3 = emailBodyClean2.replace(/&/g,"%26");
            logUserInt('email',$scope.frId)
            window.location.href = 'mailto:?subject=' + emailSubject + '&body=' + emailBodyClean3
        return

      $scope.copyToClipboard = ->
        text = document.querySelector('.tab-pane.active .heart_sample_message').innerText
        if window.clipboardData and window.clipboardData.setData
          return clipboardData.setData('Text', text)
        else if document.queryCommandSupported and document.queryCommandSupported('copy')
          textarea = document.createElement('textarea')
          textarea.textContent = text
          textarea.style.position = 'fixed'
          document.body.appendChild textarea
          textarea.select()
          try
            alert 'Message copied successfully.'
            return document.execCommand('copy')
          catch ex
            console.warn 'Copy to clipboard failed.', ex
            return false
          finally
            document.body.removeChild textarea
        return

      $scope.sendViaFC = ->
        $location.hash 'send_via_FC'
        $anchorScroll()
        return

      personalizedGreetingEnabledPromise = TeamraiserEventService.getEventDataParameter 'edp_type=boolean&edp_name=F2F_CENTER_TAF_PERSONALIZED_SALUTATION_ENABLED'
        .then (response) ->
          $scope.personalizedSalutationEnabled = response.data.getEventDataParameterResponse.booleanValue is 'true'
          response
      $scope.emailPromises.push personalizedGreetingEnabledPromise

      $scope.loadSuggestedMessage = ->
        suggested_message_id = $scope.emailComposer.suggested_message_id
        if suggested_message_id is ''
          $scope.emailComposer.subject = ''
          setEmailMessageBody()
        else
          TeamraiserEmailService.getSuggestedMessage 'message_id=' + suggested_message_id
            .then (response) ->
              if response.data.errorResponse
                # TODO
              else
                messageInfo = response.data.getSuggestedMessageResponse.messageInfo
                if messageInfo
                  $scope.emailComposer.subject = messageInfo.subject
                  messageBody = messageInfo.messageBody
                  setEmailMessageBody messageBody
                  if messageInfo.layoutId
                    $scope.emailComposer.layout_id = messageInfo.layoutId

      $scope.textEditorToolbar = [
        [
          'h1'
          'h2'
          'h3'
          'p'
          'bold'
          'italics'
          'underline'
        ]
        [
          'ul'
          'ol'
          'justifyLeft'
          'justifyCenter'
          'justifyRight'
          'justifyFull'
          'indent'
          'outdent'
        ]
        [
          'insertImage'
          'insertLink'
          'undo'
          'redo'
        ]
      ]

      $scope.$watchGroup ['emailComposer.subject', 'emailComposer.message_body'], ->
        subject = $scope.emailComposer.subject
        messageBody = getEmailMessageBody()
        cancelDraftPollTimeout = ->
          if $scope.draftPollTimeout
            $timeout.cancel $scope.draftPollTimeout
            delete $scope.draftPollTimeout
        if subject is '' and messageBody is ''
          cancelDraftPollTimeout()
        else
          cancelDraftPollTimeout()
          saveDraft = ->
            # TODO: show saving message to user
            requestData = $httpParamSerializer $scope.emailComposer
            if $scope.emailComposer.message_id is ''
              TeamraiserEmailService.addDraft requestData
                .then (response) ->
                  draftMessage = response.data.addDraftResponse?.message
                  if draftMessage
                    $scope.getMessageCounts true
                    messageId = draftMessage.messageId
                    $scope.messageId = messageId
                    # TODO: add draftId to URL
                    $scope.emailComposer.message_id = messageId
                    # TODO: show saved message to user
            else
              TeamraiserEmailService.updateDraft requestData
                .then (response) ->
                  # TODO: show saved message to user
          $scope.draftPollTimeout = $timeout saveDraft, 3000

      $scope.emailPreview =
        body: ''

      TeamraiserEmailService.getMessageLayouts()
        .then (response) ->
          if response.data.errorResponse
            # TODO
          else
            layouts = response.data.getMessageLayoutsResponse?.layout
            if layouts
              layouts = [layouts] if not angular.isArray layouts
              $scope.stationeryChoices = layouts

      $scope.clearEmailAlerts = ->
        if $scope.sendEmailError
          delete $scope.sendEmailError
        if $scope.sendEmailSuccess
          delete $scope.sendEmailSuccess

      $scope.previewEmail = ->
        $scope.clearEmailAlerts()
        TeamraiserEmailService.previewMessage $httpParamSerializer($scope.emailComposer)
          .then (response) ->
            if response.data.errorResponse
              $scope.sendEmailError = response.data.errorResponse.message
            else if response.data.teamraiserErrorResponse
              # TODO
            else
              messageBody = response.data.getMessagePreviewResponse?.message or ''
              $scope.emailPreview.body = messageBody
              $scope.emailPreviewModal = $uibModal.open
                scope: $scope
                templateUrl: APP_INFO.rootPath + 'dist/heart-walk/html/participant-center/modal/emailPreview.html'
                size: 'lg'

      $scope.selectStationery = ->
        TeamraiserEmailService.previewMessage $httpParamSerializer($scope.emailComposer)
          .then (response) ->
            if response.data.errorResponse
              # TODO
            else if response.data.teamraiserErrorResponse
              # TODO
            else
              $scope.emailPreview.body = response.data.getMessagePreviewResponse?.message or ''

      closeEmailPreviewModal = ->
        $scope.emailPreviewModal.close()

      $scope.cancelEmailPreview = ->
        closeEmailPreviewModal()

      $scope.sendEmail = ->
        closeEmailPreviewModal()
        TeamraiserEmailService.sendMessage $httpParamSerializer($scope.emailComposer)
          .then (response) ->
            window.scrollTo 0, 0
            if response.data.errorResponse
              $scope.sendEmailError = response.data.errorResponse.message
            else if response.data.teamraiserErrorResponse
              # TODO
            else
              # TODO: remove messageType and messageId from URL
              if $scope.messageId
                deleteDraftPromise = TeamraiserEmailService.deleteDraft 'message_id=' + $scope.messageId
                  .then (response) ->
                    $scope.getMessageCounts()
                $scope.emailPromises.push deleteDraftPromise
              else
                $scope.getMessageCounts()
              $scope.getContactCounts()
              $scope.sendEmailSuccess = true
              $scope.resetSelectedContacts()
              setEmailComposerDefaults()

  ]
