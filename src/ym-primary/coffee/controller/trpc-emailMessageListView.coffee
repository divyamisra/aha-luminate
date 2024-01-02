angular.module 'trPcControllers'
  .controller 'NgPcEmailMessageListViewCtrl', [
    '$scope'
    '$routeParams'
    '$location'
    '$uibModal'
    'APP_INFO'
    'NgPcTeamraiserEmailService'
    'NgPcContactService'
    ($scope, $routeParams, $location, $uibModal, APP_INFO, NgPcTeamraiserEmailService, NgPcContactService) ->
      $scope.messageType = $routeParams.messageType
      
      $scope.emailPromises = []
      
#      $scope.messageCounts = {}
      $scope.emailMessages = 
        page: 1
      $scope.getEmailMessages = ->
        messageTypes = [
          'draft'
          'sentMessage'
        ]
        angular.forEach messageTypes, (messageType) ->
          apiMethod = 'get' + messageType.charAt(0).toUpperCase() + messageType.slice(1) + 's'
          sortColumn = if messageType is 'draft' then 'modify_date' else 'log.date_sent'
          pageSize = if $scope.messageType is messageType then '10' else '1'
          pageNumber = if $scope.messageType is messageType then $scope.emailMessages.page - 1 else 0
          messageListPromise = NgPcTeamraiserEmailService[apiMethod] 'list_sort_column=' + sortColumn + '&list_ascending=false&list_page_size=' + pageSize + '&list_page_offset=' + pageNumber
            .then (response) ->
#              $scope.messageCounts[messageType + 's'] = response.data[apiMethod + 'Response'].totalNumberResults
              if $scope.messageType is messageType
                messageItems = response.data[apiMethod + 'Response'].messageItem
                messageItems = [messageItems] if not angular.isArray messageItems
                $scope.emailMessages.messages = messageItems
                $scope.emailMessages.totalNumber = response.data[apiMethod + 'Response'].totalNumberResults
              response
          $scope.emailPromises.push messageListPromise
      $scope.getEmailMessages()
      
      $scope.contactCounts = {}
      contactFilters = [
        'email_rpt_show_all'
        'email_rpt_show_never_emailed'
        'email_rpt_show_nondonors_followup'
        'email_rpt_show_unthanked_donors'
        'email_rpt_show_donors'
        'email_rpt_show_nondonors'
      ]
      if $scope.participantRegistration.companyInformation?.isCompanyCoordinator is 'true'
        contactFilters.push 'email_rpt_show_company_coordinator_participants'
        contactFilters.push 'email_custom_rpt_show_company_coordinator_new_participants'
        contactFilters.push 'email_custom_rpt_show_company_coordinator_weekly_participants'
        contactFilters.push 'email_custom_rpt_show_company_coordinator_0_dollar_participants'
        contactFilters.push 'email_custom_rpt_show_company_coordinator_250_dollar_participants'
        contactFilters.push 'email_custom_rpt_show_past_company_coordinator_participants'
      angular.forEach contactFilters, (filter) ->
        if filter is 'email_custom_rpt_show_company_coordinator_new_participants' or filter is 'email_custom_rpt_show_company_coordinator_weekly_participants' or filter is 'email_custom_rpt_show_company_coordinator_0_dollar_participants' or filter is 'email_custom_rpt_show_company_coordinator_250_dollar_participants' or filter is 'email_custom_rpt_show_past_company_coordinator_participants'
          $scope.contactCounts[filter] = ''
        else
          # contactCountPromise = NgPcContactService.getTeamraiserAddressBookContacts 'tr_ab_filter=' + filter + '&skip_groups=true&list_page_size=1'
            # .then (response) ->
              # $scope.contactCounts[filter] = response.data.getTeamraiserAddressBookContactsResponse?.totalNumberResults or '0'
              # response
          # $scope.emailPromises.push contactCountPromise
          $scope.contactCounts[filter] = ''
      
      messageTypeNames = 
        draft: 'Drafts'
        sentMessage: 'Sent Messages'
      $scope.messageTypeName = messageTypeNames[$scope.messageType]
      
      $scope.selectMessage = (messageId) ->
        if $scope.messageType is 'draft'
          $location.path '/email/compose/draft/' + messageId
        else
          NgPcTeamraiserEmailService.getSentMessage 'message_id=' + messageId
            .then (response) ->
              if response.data.errorResponse
                # TODO
              else
                messageInfo = response.data.getSentMessageResponse?.messageInfo
                if not messageInfo
                  # TODO
                else
                  recipients = messageInfo.recipient
                  recipients = [recipients] if not angular.isArray recipients
                  messageInfo.recipient = recipients
                  $scope.sentMessage = messageInfo
          $scope.viewSentMessageModal = $uibModal.open 
            scope: $scope
            controller: [
              '$scope'
              ($scope) ->
                angular.element('html').addClass 'ym-modal-is-open'
                $scope.$on 'modal.closing', ->
                  angular.element('html').removeClass 'ym-modal-is-open'
            ]
            templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/modal/viewSentMessage.html'
            size: 'lg'
            windowClass: 'ng-pc-modal ym-modal-full-screen'
          angular.element('html').addClass 'ym-modal-is-open'
      
      closeSentMessageModal = ->
        $scope.viewSentMessageModal.close()
      
      $scope.cancelViewSentMessage = ->
        closeSentMessageModal()
      
      $scope.copySentMessage = (messageId) ->
        closeSentMessageModal()
        $location.path '/email/compose/copy/' + messageId
      
      $scope.deleteMessage = (messageId) ->
        $scope.deleteMessageId = messageId
        $scope.deleteMessageModal = $uibModal.open 
          scope: $scope
          templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/modal/deleteEmailMessage.html'
      
      closeDeleteMessageModal = ->
        delete $scope.deleteMessageId
        $scope.deleteMessageModal.close()
      
      $scope.cancelDeleteMessage = ->
        closeDeleteMessageModal()
      
      $scope.confirmDeleteMessage = ->
        if $scope.messageType is 'draft'
          NgPcTeamraiserEmailService.deleteDraft 'message_id=' + $scope.deleteMessageId
            .then (response) ->
              closeDeleteMessageModal()
              $scope.getEmailMessages()
        else 
          NgPcTeamraiserEmailService.deleteSentMessage 'message_id=' + $scope.deleteMessageId
            .then (response) ->
              closeDeleteMessageModal()
              $scope.getEmailMessages()
  ]