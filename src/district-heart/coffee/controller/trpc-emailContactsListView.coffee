angular.module 'trPcControllers'
  .controller 'NgPcEmailContactsListViewCtrl', [
    '$rootScope'
    '$scope'
    '$window'
    '$routeParams'
    '$location'
    '$timeout'
    '$httpParamSerializer'
    '$uibModal'
    'APP_INFO'
    'NgPcTeamraiserEmailService'
    'NgPcContactService'
    'NgPcTeamraiserCompanyService'
    'NgPcTeamraiserReportsService'
    ($rootScope, $scope, $window, $routeParams, $location, $timeout, $httpParamSerializer, $uibModal, APP_INFO, NgPcTeamraiserEmailService, NgPcContactService, NgPcTeamraiserCompanyService, NgPcTeamraiserReportsService) ->
      $scope.filter = $routeParams.filter
      
      $scope.emailPromises = []
      
      $scope.messageCounts = {}
      messageTypes = [
        'draft'
        'sentMessage'
      ]
      angular.forEach messageTypes, (messageType) ->
        apiMethod = 'get' + messageType.charAt(0).toUpperCase() + messageType.slice(1) + 's'
        messageCountPromise = NgPcTeamraiserEmailService[apiMethod] 'list_page_size=1'
          .then (response) ->
            $scope.messageCounts[messageType + 's'] = response.data[apiMethod + 'Response'].totalNumberResults
            response
        $scope.emailPromises.push messageCountPromise
      
      $scope.focusPanel = ->
        $elem = angular.element '.contacts-list__actions-selected .btn'
        if $elem.length is 0
          $timeout $scope.focusPanel, 500
        else
          $elem[0].focus()
        false
      $scope.focusPanel()
      
      getContactString = (contact) ->
        contactData = ''
        if contact?.firstName
          contactData += contact.firstName
        if contact?.lastName
          if contactData isnt ''
            contactData += ' '
          contactData += contact.lastName
        if contact?.email
          if contactData isnt ''
            contactData += ' '
          contactData += '<' + contact.email + '>'
        contactData
      
      isContactSelected = (contact) ->
        contactData = getContactString contact
        contactIndex = $rootScope.selectedContacts.contacts.indexOf contactData
        contactIndex isnt -1
      
      countContactSelected = (contacts) ->
        count = 0
        angular.forEach contacts, (contact) ->
          if contact?.selected
            count = count + 1
        count
      
      isAllContactsSelected = () ->
        $scope.addressBookContacts.allContacts.length is countContactSelected $scope.addressBookContacts.allContacts
      
      $scope.contactCounts = {}
      contactFilters = [
        'email_rpt_show_all'
        'email_rpt_show_never_emailed'
        'email_rpt_show_nondonors_followup'
        'email_rpt_show_unthanked_donors'
        'email_rpt_show_donors'
        'email_rpt_show_nondonors'
      ]
      if $scope.participantRegistration.aTeamCaptain is 'true'
        contactFilters.push 'email_rpt_show_teammates'
        contactFilters.push 'email_rpt_show_nonteammates'
      if $scope.participantRegistration.companyInformation?.isCompanyCoordinator is 'true'
        contactFilters.push 'email_rpt_show_company_coordinator_captains'
        contactFilters.push 'email_rpt_show_company_coordinator_participants'
        contactFilters.push 'email_custom_rpt_show_past_company_coordinator_participants'
      $scope.addressBookContacts = 
        page: 1
        allContactsSelected: false
      angular.forEach contactFilters, (filter) ->
        if filter is $scope.filter
          $scope.getContacts = ->
            pageNumber = $scope.addressBookContacts.page - 1
            if filter is 'email_custom_rpt_show_past_company_coordinator_participants'
              if $scope.participantRegistration.companyInformation?.isCompanyCoordinator isnt 'true'
                # TODO
              else if not $scope.prevFrId or $scope.prevFrId is ''
                # TODO
              else
                NgPcTeamraiserCompanyService.getCompanies 'fr_id=' + $scope.prevFrId + '&company_name=' + encodeURIComponent('org_for_company_id=' + $scope.participantRegistration.companyInformation.companyId)
                  .then (response) ->
                    companies = response.data.getCompaniesResponse?.company
                    if companies
                      companies = [companies] if not angular.isArray companies
                      previousCompany = companies[0]
                      previousCompanyId = previousCompany.companyId
                      NgPcTeamraiserReportsService.getDistrictDetailReport $scope.prevFrId, previousCompanyId
                        .then (response) ->
                          previousParticipants = []
                          totalNumberResults = 0
                          reportHtml = response.data.getDistrictDetailReport?.report
                          if reportHtml and reportHtml.indexOf('<p>No results</p>') is -1
                            $reportTable = angular.element('<div>' + reportHtml + '</div>').find 'table'
                            if $reportTable.length > 0
                              $reportTableRows = $reportTable.find 'tr'
                              if $reportTableRows.length > 0
                                angular.forEach $reportTableRows, (reportTableRow, reportTableRowIndex) ->
                                  totalNumberResults++
                                  if reportTableRowIndex >= pageNumber * 10
                                    $reportTableRow = angular.element reportTableRow
                                    consId = jQuery.trim $reportTableRow.find('td').eq(7).text()
                                    firstName = jQuery.trim $reportTableRow.find('td').eq(8).text()
                                    lastName = jQuery.trim $reportTableRow.find('td').eq(9).text()
                                    email = jQuery.trim $reportTableRow.find('td').eq(10).text()
                                    if previousParticipants.length < 10
                                      contact =
                                        firstName: firstName
                                        lastName: lastName
                                        email: email
                                      previousParticipants.push contact
                          $scope.addressBookContacts.contacts = previousParticipants
                          $scope.addressBookContacts.totalNumber = totalNumberResults
            else
              contactsPromise = NgPcContactService.getTeamraiserAddressBookContacts 'tr_ab_filter=' + filter + '&skip_groups=true&list_page_size=10&list_page_offset=' + pageNumber
                .then (response) ->
                  $scope.contactCounts[filter] = $scope.addressBookContacts.totalNumber = response.data.getTeamraiserAddressBookContactsResponse.totalNumberResults
                  addressBookContacts = response.data.getTeamraiserAddressBookContactsResponse.addressBookContact
                  addressBookContacts = [addressBookContacts] if not angular.isArray addressBookContacts
                  contacts = []
                  angular.forEach addressBookContacts, (contact) ->
                    if contact
                      contact.selected = isContactSelected contact
                      contacts.push contact
                  $scope.addressBookContacts.contacts = contacts
                  response
              $scope.emailPromises.push contactsPromise
          $scope.getContacts()
          $scope.getAllContacts = ->
            if not $scope.addressBookContacts.getAllPage
              $scope.addressBookContacts.allContacts = []
              $scope.addressBookContacts.getAllPage = 0
            pageNumber = $scope.addressBookContacts.getAllPage
            if filter is 'email_custom_rpt_show_past_company_coordinator_participants'
              if $scope.participantRegistration.companyInformation?.isCompanyCoordinator isnt 'true'
                # TODO
              else if not $scope.prevFrId or $scope.prevFrId is ''
                # TODO
              else
                NgPcTeamraiserCompanyService.getCompanies 'fr_id=' + $scope.prevFrId + '&company_name=' + encodeURIComponent('org_for_company_id=' + $scope.participantRegistration.companyInformation.companyId)
                  .then (response) ->
                    companies = response.data.getCompaniesResponse?.company
                    if companies
                      companies = [companies] if not angular.isArray companies
                      previousCompany = companies[0]
                      previousCompanyId = previousCompany.companyId
                      NgPcTeamraiserReportsService.getDistrictDetailReport $scope.prevFrId, previousCompanyId
                        .then (response) ->
                          previousParticipants = []
                          totalNumberResults = 0
                          reportHtml = response.data.getDistrictDetailReport?.report
                          if reportHtml and reportHtml.indexOf('<p>No results</p>') is -1
                            $reportTable = angular.element('<div>' + reportHtml + '</div>').find 'table'
                            if $reportTable.length > 0
                              $reportTableRows = $reportTable.find 'tr'
                              if $reportTableRows.length > 0
                                angular.forEach $reportTableRows, (reportTableRow) ->
                                  totalNumberResults++
                                  $reportTableRow = angular.element reportTableRow
                                  consId = jQuery.trim $reportTableRow.find('td').eq(7).text()
                                  firstName = jQuery.trim $reportTableRow.find('td').eq(8).text()
                                  lastName = jQuery.trim $reportTableRow.find('td').eq(9).text()
                                  email = jQuery.trim $reportTableRow.find('td').eq(10).text()
                                  contact =
                                    firstName: firstName
                                    lastName: lastName
                                    email: email
                                  previousParticipants.push contact
                          $scope.addressBookContacts.allContacts = previousParticipants
                          delete $scope.addressBookContacts.getAllPage
                          $scope.addressBookContacts.contacts = previousParticipants
                          $scope.addressBookContacts.totalNumber = totalNumberResults
            else
              allContactsPromise = NgPcContactService.getTeamraiserAddressBookContacts 'tr_ab_filter=' + filter + '&skip_groups=true&list_page_size=200&list_page_offset=' + pageNumber
                .then (response) ->
                  totalNumber = response.data.getTeamraiserAddressBookContactsResponse.totalNumberResults
                  addressBookContacts = response.data.getTeamraiserAddressBookContactsResponse.addressBookContact
                  addressBookContacts = [addressBookContacts] if not angular.isArray addressBookContacts
                  contacts = []
                  angular.forEach addressBookContacts, (contact) ->
                    if contact
                      contact.selected = isContactSelected contact
                      $scope.addressBookContacts.allContacts.push contact
                  if $scope.addressBookContacts.allContacts.length < totalNumber
                    $scope.addressBookContacts.getAllPage = $scope.addressBookContacts.getAllPage + 1
                    $scope.getAllContacts()
                  else
                    delete $scope.addressBookContacts.getAllPage
                    $scope.addressBookContacts.allContactsSelected = isAllContactsSelected()
                    response
              $scope.emailPromises.push allContactsPromise
          $scope.getAllContacts()
        else
          if filter is 'email_custom_rpt_show_past_company_coordinator_participants'
            $scope.contactCounts[filter] = ''
          else
            contactCountPromise = NgPcContactService.getTeamraiserAddressBookContacts 'tr_ab_filter=' + filter + '&skip_groups=true&list_page_size=1'
              .then (response) ->
                $scope.contactCounts[filter] = response.data.getTeamraiserAddressBookContactsResponse?.totalNumberResults or '0'
                response
            $scope.emailPromises.push contactCountPromise
      
      filterNames = 
        email_rpt_show_all: 'All Contacts'
        email_rpt_show_never_emailed: 'Never Emailed'
        email_rpt_show_nondonors_followup: 'Needs Follow-Up'
        email_rpt_show_unthanked_donors: 'Unthanked Donors'
        email_rpt_show_donors: 'Donors'
        email_rpt_show_nondonors: 'Non-Donors'
        email_rpt_show_teammates: 'Teammates'
        email_rpt_show_nonteammates: 'Non-Teammates'
        email_rpt_show_company_coordinator_captains: 'District Team Champions'
        email_rpt_show_company_coordinator_participants: 'District Participants'
        email_custom_rpt_show_past_company_coordinator_participants: 'Past District Participants'
      
      $scope.filterName = filterNames[$scope.filter]
      
      $scope.clearAllContactAlerts = ->
        $scope.clearAddContactAlerts()
        $scope.clearImportContactsAlerts()
        $scope.clearEditContactAlerts()
        $scope.clearDeleteContactAlerts()
      
      $scope.clearAddContactAlerts = ->
        if $scope.addContactError
          delete $scope.addContactError
        if $scope.addContactSuccess
          delete $scope.addContactSuccess
      
      $scope.resetNewContact = ->
        $scope.newContact =
          first_name: ''
          last_name: ''
          email: ''
      
      $scope.addContact = ->
        $scope.clearAllContactAlerts()
        $scope.resetNewContact()
        $scope.addContactModal = $uibModal.open 
          scope: $scope
          templateUrl: APP_INFO.rootPath + 'dist/district-heart/html/participant-center/modal/addContact.html'
      
      closeAddContactModal = ->
        $scope.addContactModal.close()
      
      $scope.cancelAddContact = ->
        $scope.clearAddContactAlerts()
        closeAddContactModal()
      
      $scope.addNewContact = ->
        $scope.clearAddContactAlerts()
        if not $scope.newContact.email or $scope.newContact.email is ''
          # TODO
        else
          addContactPromise = NgPcContactService.addAddressBookContact $httpParamSerializer($scope.newContact)
            .then (response) ->
              if response.data.errorResponse
                $scope.addContactError = response.data.errorResponse.message
              else
                $scope.addContactSuccess = ''
                closeAddContactModal()
                $scope.getContacts()
                $scope.getAllContacts()
              response
          $scope.emailPromises.push addContactPromise
      
      $scope.clearImportContactsAlerts = ->
        if $scope.importContactsError
          delete $scope.importContactsError
        if $scope.importContactsSuccess
          delete $scope.importContactsSuccess
      
      $scope.resetImportContacts = ->
        $scope.contactImport = 
          step: 'choose-type'
          import_type: ''
          jobEvents: [
            {
              message: '1. Waiting for your consent ...'
            }
          ]
          contactsToAdd: []
      
      $scope.importContacts = ->
        $scope.clearAllContactAlerts()
        $scope.resetImportContacts()
        $scope.importContactsModal = $uibModal.open 
          scope: $scope
          templateUrl: APP_INFO.rootPath + 'dist/district-heart/html/participant-center/modal/importContacts.html'
      
      closeImportContactsModal = ->
        $scope.importContactsModal.close()
      
      $scope.cancelImportContacts = ->
        $scope.clearImportContactsAlerts()
        closeImportContactsModal()
      
      $scope.chooseImportContactType = ->
        importType = $scope.contactImport.import_type
        if not importType or importType is ''
          # TODO: error message
        else
          if importType is 'csv'
            $scope.contactImport.step = 'csv-upload'
          else
            $scope.contactImport.step = 'online-consent'
            $window.open APP_INFO.rootPath + 'dist/district-heart/html/participant-center/popup/address-book-import.html?import_source=' + $scope.contactImport.import_type, 'startimport', 'location=no,menubar=no,toolbar=no,height=400'
            false
      
      window.trPcContactImport = 
        buildAddressBookImport: (importJobId) ->
          NgPcContactService.getAddressBookImportJobStatus 'import_job_id=' + importJobId
            .then (response) ->
              if response.data.errorResponse
                # TODO
              else
                jobStatus = response.data.getAddressBookImportJobStatusResponse?.jobStatus
                if not jobStatus
                  # TODO
                else
                  if jobStatus is 'PENDING' or jobStatus is 'FAILURE'
                    events = response.data.getAddressBookImportJobStatusResponse.events?.event
                    if not events
                      $scope.updateImportJobEvents()
                    else
                      events = [events] if not angular.isArray events
                      jobEvents = []
                      angular.forEach events, (event) ->
                        jobEvents.push 
                          message: event
                      $scope.updateImportJobEvents jobEvents
                    if jobStatus is 'PENDING'
                      trPcContactImport.buildAddressBookImport importJobId
                  else if jobStatus is 'SUCCESS'
                    NgPcContactService.getAddressBookImportContacts 'import_job_id=' + importJobId
                      .then (response) ->
                        if response.data.errorResponse
                          # TODO
                        else
                          contacts = response.data.getAddressBookImportContactsResponse?.contact
                          if not contacts
                            $scope.setContactsAvailableForImport()
                          else
                            contacts = [contacts] if not angular.isArray contacts
                            contactsAvailableForImport = []
                            angular.forEach contacts, (contact) ->
                              if contact
                                firstName = contact.firstName
                                lastName = contact.lastName
                                email = contact.email
                                if firstName and not angular.isString firstName
                                  delete contact.firstName
                                  firstName = undefined
                                if lastName and not angular.isString lastName
                                  delete contact.lastName
                                if email and not angular.isString email
                                  delete contact.email
                                  email = undefined
                                if firstName or email
                                  contactsAvailableForImport.push contact
                            $scope.setContactsAvailableForImport contactsAvailableForImport
      
      $scope.updateImportJobEvents = (jobEvents) ->
        if jobEvents and jobEvents.length isnt 0
          $scope.contactImport.jobEvents = jobEvents
        if not $scope.$$phase
          $scope.$apply()
      
      $scope.setContactsAvailableForImport = (contactsAvailableForImport) ->
        $scope.contactImport.step = 'contacts-available-for-import'
        $scope.contactsAvailableForImport = contactsAvailableForImport or []
        if not $scope.$$phase
          $scope.$apply()
      
      $scope.selectAllContactsToAdd = ($event) ->
        if $event
          $event.preventDefault()
        contactsAvailableForImport = []
        $scope.contactImport.contactsToAdd = []
        angular.forEach $scope.contactsAvailableForImport, (contactAvailableForImport) ->
          contactAvailableForImport.selected = true
          contactsAvailableForImport.push contactAvailableForImport
          contactData = ''
          if contactAvailableForImport.firstName
            contactData += '"' + contactAvailableForImport.firstName + '"'
          contactData += ', '
          if contactAvailableForImport.lastName
            contactData += '"' + contactAvailableForImport.lastName + '"'
          contactData += ', '
          if contactAvailableForImport.email
            contactData += '"' + contactAvailableForImport.email + '"'
          $scope.contactImport.contactsToAdd.push contactData
        $scope.contactsAvailableForImport = contactsAvailableForImport
      
      $scope.deselectAllContactsToAdd = ($event) ->
        if $event
          $event.preventDefault()
        contactsAvailableForImport = []
        angular.forEach $scope.contactsAvailableForImport, (contactAvailableForImport) ->
          contactAvailableForImport.selected = false
          contactsAvailableForImport.push contactAvailableForImport
        $scope.contactsAvailableForImport = contactsAvailableForImport
        $scope.contactImport.contactsToAdd = []
      
      $scope.toggleContactToAdd = (contact) ->
        contactData = ''
        if contact.firstName
          contactData += '"' + contact.firstName + '"'
        contactData += ', '
        if contact.lastName
          contactData += '"' + contact.lastName + '"'
        contactData += ', '
        if contact.email
          contactData += '"' + contact.email + '"'
        contactToAddIndex = $scope.contactImport.contactsToAdd.indexOf contactData
        if contactToAddIndex is -1
          $scope.contactImport.contactsToAdd.push contactData
        else
          $scope.contactImport.contactsToAdd.splice contactToAddIndex, 1
        angular.forEach $scope.contactsAvailableForImport, (contactAvailableForImport) ->
          contactAvailableForImportData = ''
          if contactAvailableForImport.firstName
            contactAvailableForImportData += '"' + contactAvailableForImport.firstName + '"'
          contactAvailableForImportData += ', '
          if contactAvailableForImport.lastName
            contactAvailableForImportData += '"' + contactAvailableForImport.lastName + '"'
          contactAvailableForImportData += ', '
          if contactAvailableForImport.email
            contactAvailableForImportData += '"' + contactAvailableForImport.email + '"'
          if contactData is contactAvailableForImportData
            contactAvailableForImport.selected = contactToAddIndex is -1
      
      $scope.chooseContactsToImport = ->
        $scope.clearImportContactsAlerts()
        if $scope.contactImport.contactsToAdd.length is 0
          $scope.importContactsError = 'You must select at least one contact to continue this process.'
        else
          NgPcContactService.importAddressBookContacts 'contacts_to_add=' + encodeURIComponent($scope.contactImport.contactsToAdd.join('\n'))
            .then (response) ->
              if response.data.errorResponse
                $scope.importContactsError = response.data.errorResponse.message
              else
                errorContacts = response.data.importAddressBookContactsResponse?.errorContact
                if errorContacts
                  errorContacts = [errorContacts] if not angular.isArray errorContacts
                potentialDuplicateContacts = response.data.importAddressBookContactsResponse?.potentialDuplicateContact
                if potentialDuplicateContacts
                  potentialDuplicateContacts = [potentialDuplicateContacts] if not angular.isArray potentialDuplicateContacts
                duplicateContacts = response.data.importAddressBookContactsResponse?.duplicateContact
                if duplicateContacts
                  duplicateContacts = [duplicateContacts] if not angular.isArray duplicateContacts
                savedContacts = response.data.importAddressBookContactsResponse?.savedContact
                if savedContacts
                  savedContacts = [savedContacts] if not angular.isArray savedContacts
                # TODO: handle errorContacts, potentialDuplicateContacts, and duplicateContacts
                $scope.importContactsSuccess = true
                closeImportContactsModal()
                $scope.getContacts()
                $scope.getAllContacts()
      
      $scope.uploadContactsCSV = ->
        angular.element('.js--import-contacts-csv-form').submit()
        false
      
      $scope.handleContactsCSV = (csvIframe) ->
        csvIframeContent = jQuery(csvIframe).contents().text()
        if csvIframeContent
          csvIframeJSON = jQuery.parseJSON csvIframeContent
          if csvIframeJSON.errorResponse
            # TODO
          else
            confidenceLevel = csvIframeJSON.parseCsvContactsResponse?.confidenceLevel
            # TODO: confidenceLevel
            proposedMapping = csvIframeJSON.parseCsvContactsResponse?.proposedMapping
            if proposedMapping
              firstNameColumnIndex = Number proposedMapping.firstNameColumnIndex
              lastNameColumnIndex = Number proposedMapping.lastNameColumnIndex
              emailColumnIndex = Number proposedMapping.emailColumnIndex
              csvDataRows = csvIframeJSON.parseCsvContactsResponse?.csvDataRows?.csvDataRow
              if not csvDataRows
                # TODO
              else
                csvDataRows = [csvDataRows] if not angular.isArray csvDataRows
                contactsAvailableForImport = []
                angular.forEach csvDataRows, (csvDataRow) ->
                  if csvDataRow
                    csvValue = csvDataRow.csvValue
                    firstName = csvValue[firstNameColumnIndex]
                    lastName = csvValue[lastNameColumnIndex]
                    email = csvValue[emailColumnIndex]
                    contact =
                      firstName: firstName
                      lastName: lastName
                      email: email
                    if firstName and not angular.isString firstName
                      delete contact.firstName
                      firstName = undefined
                    if lastName and not angular.isString lastName
                      delete contact.lastName
                    if email and not angular.isString email
                      delete contact.email
                      email = undefined
                    if firstName or email
                      contactsAvailableForImport.push contact
                $scope.setContactsAvailableForImport contactsAvailableForImport
      
      $scope.resetSelectedContacts = ->
        $rootScope.selectedContacts = 
          contacts: []
      if not $rootScope.selectedContacts?.contacts
        $scope.resetSelectedContacts()
      
      $scope.toggleContact = (contact) ->
        contactData = getContactString contact
        contactIndex = $rootScope.selectedContacts.contacts.indexOf contactData
        if contactIndex is -1
          $rootScope.selectedContacts.contacts.push contactData
        else
          $rootScope.selectedContacts.contacts.splice contactIndex, 1
        angular.forEach $scope.addressBookContacts.allContacts, (aContact) ->
          if contactData is getContactString aContact
            aContact.selected = contactIndex is -1
        angular.forEach $scope.addressBookContacts.contacts, (aContact) ->
          if contactData is getContactString aContact
            aContact.selected = contactIndex is -1
        $scope.addressBookContacts.allContactsSelected = isAllContactsSelected()
        $scope.addressBookContacts.allContactsSelected
      
      $scope.toggleAllContacts = ->
        selected = not $scope.addressBookContacts.allContactsSelected
        angular.forEach $scope.addressBookContacts.contacts, (contact) ->
          contact.selected = selected
        angular.forEach $scope.addressBookContacts.allContacts, (contact) ->
          contact.selected = selected
          if selected isnt isContactSelected contact
            $scope.toggleContact contact
        $scope.addressBookContacts.allContactsSelected = selected
        $scope.addressBookContacts.allContactsSelected
      
      $scope.clearEditContactAlerts = ->
        if $scope.editContactError
          delete $scope.editContactError
        if $scope.editContactSuccess
          delete $scope.editContactSuccess
      
      $scope.selectContact = (contact) ->
        $scope.clearAllContactAlerts()
        $scope.selectedContact = contact
        $scope.updatedContact = 
          contact_id: $scope.selectedContact.id
          first_name: $scope.selectedContact.firstName
          last_name: $scope.selectedContact.lastName
          email: $scope.selectedContact.email
        $scope.editContactModal = $uibModal.open
          scope: $scope
          templateUrl: APP_INFO.rootPath + 'dist/district-heart/html/participant-center/modal/editContact.html'
      
      closeEditContactModal = ->
        $scope.editContactModal.close()
      
      $scope.cancelEditContact = ->
        delete $scope.selectedContact
        $scope.clearEditContactAlerts()
        closeEditContactModal()
      
      $scope.saveUpdatedContact = ->
        $scope.clearEditContactAlerts()
        if not $scope.selectedContact
          # TODO
        else
          updateContactPromise = NgPcContactService.updateTeamraiserAddressBookContact $httpParamSerializer($scope.updatedContact)
            .then (response) ->
              if response.data.errorResponse
                $scope.editContactError = response.data.errorResponse.message
              else
                $scope.editContactSuccess = ''
                closeEditContactModal()
                window.scrollTo 0, 0
                # TODO: update selected contacts
                $scope.getContacts()
                $scope.getAllContacts()
              response
          $scope.emailPromises.push updateContactPromise
      
      $scope.clearDeleteContactAlerts = ->
        if $scope.deleteContactError
          delete $scope.deleteContactError
        if $scope.deleteContactSuccess
          delete $scope.deleteContactSuccess
      
      $scope.deleteContact = (contactId) ->
        $scope.clearAllContactAlerts()
        $scope.deleteContactId = contactId
        $scope.deleteContactModal = $uibModal.open 
          scope: $scope
          templateUrl: APP_INFO.rootPath + 'dist/district-heart/html/participant-center/modal/deleteContact.html'
      
      closeDeleteContactModal = ->
        delete $scope.deleteContactId
        $scope.deleteContactModal.close()
      
      $scope.cancelDeleteContact = ->
        closeDeleteContactModal()
      
      $scope.confirmDeleteContact = ->
        if not $scope.deleteContactId
          # TODO
        else
          deleteContactPromise = NgPcContactService.deleteTeamraiserAddressBookContacts 'contact_ids=' + $scope.deleteContactId
            .then (response) ->
              if response.data.errorResponse
                $scope.deleteContactError = response.data.errorResponse.message
              else
                $scope.deleteContactSuccess = ''
              closeDeleteContactModal()
              window.scrollTo 0, 0
              # TODO: update selected contacts
              $scope.getContacts()
              $scope.getAllContacts()
              response
          $scope.emailPromises.push deleteContactPromise
      
      $scope.emailSelectedContacts = ->
        $location.path '/email/compose'
  ]