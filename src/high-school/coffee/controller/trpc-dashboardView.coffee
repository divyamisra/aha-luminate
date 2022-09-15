angular.module 'trPcControllers'
  .controller 'NgPcDashboardViewCtrl', [
    '$rootScope'
    '$scope'
    '$filter'
    '$timeout'
    '$uibModal'
    'APP_INFO'
    'BoundlessService'
    'NgPcTeamraiserRegistrationService'
    'NgPcTeamraiserProgressService'
    'NgPcTeamraiserTeamService'
    'NgPcTeamraiserGiftService'
    'NgPcContactService'
    'NgPcTeamraiserShortcutURLService'
    'NgPcInteractionService'
    'NgPcTeamraiserCompanyService'
    'NgPcTeamraiserSchoolService'
    'FacebookFundraiserService'
    ($rootScope, $scope, $filter, $timeout, $uibModal, APP_INFO, BoundlessService, NgPcTeamraiserRegistrationService, NgPcTeamraiserProgressService, NgPcTeamraiserTeamService, NgPcTeamraiserGiftService, NgPcContactService, NgPcTeamraiserShortcutURLService, NgPcInteractionService, NgPcTeamraiserCompanyService, NgPcTeamraiserSchoolService, FacebookFundraiserService) ->
      $scope.dashboardPromises = []
      
      $dataRoot = angular.element '[data-embed-root]'
      
      if $scope.participantRegistration.lastPC2Login is '0'
        $scope.firstLoginModal = $uibModal.open
          scope: $scope
          templateUrl: APP_INFO.rootPath + 'dist/high-school/html/participant-center/modal/firstLogin.html'
        
        $scope.setPersonalUrlInfo = 
          updatedShortcut: ''
        
        $scope.setPersonalUrl = ->
          delete $scope.setPersonalUrlInfo.errorMessage
          delete $scope.setPersonalUrlInfo.success
          NgPcTeamraiserShortcutURLService.updateShortcut 'text=' + encodeURIComponent($scope.setPersonalUrlInfo.updatedShortcut)
            .then (response) ->
              if response.data.errorResponse
                $scope.setPersonalUrlInfo.errorMessage = response.data.errorResponse.message
              else
                $scope.setPersonalUrlInfo.success = true
                $scope.getParticipantShortcut()
        
        $scope.closeFirstLogin = ->
          $scope.firstLoginModal.close()
      
      # undocumented update_last_pc2_login parameter required to make news feeds work, see bz #67720
      NgPcTeamraiserRegistrationService.updateRegistration 'update_last_pc2_login=true'
        .then ->
          NgPcTeamraiserRegistrationService.getRegistration()
      
      if $scope.participantRegistration.companyInformation?.isCompanyCoordinator isnt 'true' or $scope.location is '/dashboard-student'
        $scope.dashboardProgressType = 'personal'
      else
        $scope.dashboardProgressType = 'company'
      $scope.toggleProgressType = (progressType) ->
        $scope.dashboardProgressType = progressType
      
      $scope.refreshFundraisingProgress = ->
        fundraisingProgressPromise = NgPcTeamraiserProgressService.getProgress()
          .then (response) ->
            if response.data.errorResponse
              # TODO
            else
              participantProgress = response.data.getParticipantProgressResponse.personalProgress
              if not participantProgress
                # TODO
              else
                participantProgress.raised = Number participantProgress.raised
                participantProgress.raisedFormatted = if participantProgress.raised then $filter('currency')(participantProgress.raised / 100, '$', 0) else '$0'
                participantProgress.goal = Number participantProgress.goal
                participantProgress.goalFormatted = if participantProgress.goal then $filter('currency')(participantProgress.goal / 100, '$', 0) else '$0'
                participantProgress.percent = 0
                if participantProgress.goal isnt 0
                  participantProgress.percent = Math.ceil((participantProgress.raised / participantProgress.goal) * 100)
                if participantProgress.percent > 100
                  participantProgress.percent = 100
                $scope.participantProgress = participantProgress
            if $scope.participantRegistration.teamId and $scope.participantRegistration.teamId isnt '-1'
              if response.data.errorResponse
                # TODO
              else
                teamProgress = response.data.getParticipantProgressResponse.teamProgress
                if not teamProgress
                  # TODO
                else
                  teamProgress.raised = Number teamProgress.raised
                  teamProgress.raisedFormatted = if teamProgress.raised then $filter('currency')(teamProgress.raised / 100, '$', 0) else '$0'
                  teamProgress.goal = Number teamProgress.goal
                  teamProgress.goalFormatted = if teamProgress.goal then $filter('currency')(teamProgress.goal / 100, '$', 0) else '$0'
                  teamProgress.percent = 0
                  if teamProgress.goal isnt 0
                    teamProgress.percent = Math.ceil((teamProgress.raised / teamProgress.goal) * 100)
                  if teamProgress.percent > 100
                    teamProgress.percent = 100
                  $scope.teamProgress = teamProgress
            if $scope.participantRegistration.companyInformation and $scope.participantRegistration.companyInformation.companyId and $scope.participantRegistration.companyInformation.companyId isnt -1
              if response.data.errorResponse
                # TODO
              else
                companyProgress = response.data.getParticipantProgressResponse.companyProgress
                if not companyProgress
                  # TODO
                else
                  companyProgress.raised = Number companyProgress.raised
                  companyProgress.raisedFormatted = if companyProgress.raised then $filter('currency')(companyProgress.raised / 100, '$', 0) else '$0'
                  companyProgress.goal = Number companyProgress.goal
                  companyProgress.goalFormatted = if companyProgress.goal then $filter('currency')(companyProgress.goal / 100, '$', 0) else '$0'
                  companyProgress.percent = 0
                  if companyProgress.goal isnt 0
                    companyProgress.percent = Math.ceil((companyProgress.raised / companyProgress.goal) * 100)
                  if companyProgress.percent > 100
                    companyProgress.percent = 100
                  $scope.companyProgress = companyProgress
            response
        $scope.dashboardPromises.push fundraisingProgressPromise
      $scope.refreshFundraisingProgress()
      
      $scope.teamInfo = {}
      if $scope.participantRegistration.teamId and $scope.participantRegistration.teamId isnt '-1'
        teamInfoPromise = NgPcTeamraiserTeamService.getTeam()
          .then (response) ->
            teams = response.data.getTeamSearchByInfoResponse?.team
            if not teams
              $scope.teamInfo.numMembers = '0'
            else
              teams = [teams] if not angular.isArray teams
              if teams.length is 0
                $scope.teamInfo.numMembers = '0'
              else
                team = teams[0]
                $scope.teamInfo = team
        $scope.dashboardPromises.push teamInfoPromise
      
      $scope.emailChallenge = {}
      setEmailSampleText = ->
        sampleText = 'Hello friends! I am excited to be participating in the American Heart Association\'s District Heart Challenge. It is their mission to improve the lives of all Americans, by providing public health education and research. Some of those ways are right here in my own school by passing on a message of healthy eating and physical activity to the kids we see every day!\n\n' + 
        'As I make some personal changes towards heart-health, like logging active minutes and getting my blood pressure checked, I am also raising money. I am trying to hit my fundraising goal'
        if not $scope.personalGoalInfo or not $scope.personalGoalInfo.goal or $scope.personalGoalInfo.goal is ''
          sampleText += '. '
        else
          sampleText += ' of ' + $scope.personalGoalInfo.goal + '. '
        sampleText += 'By making a donation to my fundraising page you support our district, our school and the American Heart Association. No matter the size of your gift - it will make a difference.\n\n' + 
        'Thank You!\n' + 
        $scope.consName + '\n\n' + 
        '***Did you know you might be able to double your gift to the American Heart Association? Ask your employer if you have an Employee Matching Gift program.'
        if $scope.personalPageUrl
          sampleText += '\n\n' + 
          'Visit my personal fundraising page:\n' + 
          $scope.personalPageUrl
        $scope.emailChallenge.sampleText = sampleText
      setEmailSampleText()
      $scope.$watch 'personalGoalInfo.goal', ->
        setEmailSampleText()
      $scope.$watch 'personalPageUrl', ->
        setEmailSampleText()
      
      interactionTypeId = $dataRoot.data 'coordinator-message-id'
      
      $scope.coordinatorMessage =
        text: ''
        errorMessage: null
        successMessage: false
        message: ''
        interactionId: ''
      
      if $scope.participantRegistration.companyInformation?.isCompanyCoordinator isnt 'true' or $scope.location is '/dashboard-student'
        NgPcInteractionService.listInteractions 'interaction_type_id=' + interactionTypeId + '&interaction_subject=' + $scope.participantRegistration.companyInformation.companyId
          .then (response) ->
            $scope.coordinatorMessage.message = ''
            $scope.coordinatorMessage.interactionId = ''
            if not response.data.errorResponse
              interactions = response.data.listInteractionsResponse?.interaction
              if interactions
                interactions = [interactions] if not angular.isArray interactions
                if interactions.length > 0
                  interaction = interactions[0]
                  $scope.coordinatorMessage.message = interaction.note?.text or ''
                  $scope.coordinatorMessage.interactionId = interaction.interactionId or ''
      else
        NgPcInteractionService.getUserInteractions 'interaction_type_id=' + interactionTypeId + '&cons_id=' + $scope.consId + '&list_page_size=1'
          .then (response) ->
            $scope.coordinatorMessage.text = ''
            $scope.coordinatorMessage.interactionId = ''
            if not response.data.errorResponse
              interactions = response.data.getUserInteractionsResponse?.interaction
              if interactions
                interactions = [interactions] if not angular.isArray interactions
                if interactions.length > 0
                  interaction = interactions[0]
                  $scope.coordinatorMessage.text = interaction.note?.text or ''
                  $scope.coordinatorMessage.interactionId = interaction.interactionId or ''
        
        $scope.editCoordinatorMessage = ->
          $scope.editCoordinatorMessageModal = $uibModal.open
            scope: $scope
            templateUrl: APP_INFO.rootPath + 'dist/high-school/html/participant-center/modal/editCoordinatorMessage.html'
        
        $scope.cancelEditCoordinatorMessage = ->
          $scope.editCoordinatorMessageModal.close()
        
        $scope.updateCoordinatorMessage = ->
          if $scope.coordinatorMessage.interactionId is ''
            NgPcInteractionService.logInteraction 'interaction_type_id=' + interactionTypeId + '&cons_id=' + $scope.consId + '&interaction_subject=' + $scope.participantRegistration.companyInformation.companyId + '&interaction_body=' + ($scope.coordinatorMessage?.text or '')
                .then (response) ->
                  if response.data.updateConsResponse?.message
                    $scope.coordinatorMessage.successMessage = true
                    $scope.editCoordinatorMessageModal.close()
                  else
                    $scope.coordinatorMessage.errorMessage = 'There was an error processing your update. Please try again later.'
          else
            NgPcInteractionService.updateInteraction 'interaction_id=' + $scope.coordinatorMessage.interactionId + '&cons_id=' + $scope.consId + '&interaction_subject=' + $scope.participantRegistration.companyInformation.companyId + '&interaction_body=' + ($scope.coordinatorMessage?.text or '')
              .then (response) ->
                if response.data.errorResponse 
                  $scope.coordinatorMessage.errorMessage = 'There was an error processing your update. Please try again later.' 
                else
                  $scope.coordinatorMessage.successMessage = true
                  $scope.editCoordinatorMessageModal.close()
      
      $scope.personalGoalInfo = {}
      
      $scope.editPersonalGoal = ->
        delete $scope.personalGoalInfo.errorMessage
        personalGoal = $scope.participantProgress.goalFormatted.replace '$', ''
        if personalGoal is '' or personalGoal is '0'
          $scope.personalGoalInfo.goal = ''
        else
          $scope.personalGoalInfo.goal = personalGoal
        $scope.editPersonalGoalModal = $uibModal.open
          scope: $scope
          templateUrl: APP_INFO.rootPath + 'dist/high-school/html/participant-center/modal/editParticipantGoal.html'
      
      $scope.cancelEditPersonalGoal = ->
        $scope.editPersonalGoalModal.close()
      
      $scope.updatePersonalGoal = ->
        delete $scope.personalGoalInfo.errorMessage
        newGoal = $scope.personalGoalInfo.goal
        if newGoal
          newGoal = newGoal.replace('$', '').replace /,/g, ''
        if not newGoal or newGoal is '' or newGoal is '0' or isNaN(newGoal)
          $scope.personalGoalInfo.errorMessage = 'Please specify a goal greater than $0.'
        else
          updatePersonalGoalPromise = NgPcTeamraiserRegistrationService.updateRegistration 'goal=' + (newGoal * 100)
            .then (response) ->
              if response.data.errorResponse
                $scope.personalGoalInfo.errorMessage = response.data.errorResponse.message
              else
                $scope.editPersonalGoalModal.close()
                $scope.refreshFundraisingProgress()
              response
          $scope.dashboardPromises.push updatePersonalGoalPromise
      
      $scope.teamGoalInfo = {}
      
      $scope.editTeamGoal = ->
        delete $scope.teamGoalInfo.errorMessage
        teamGoal = $scope.teamProgress.goalFormatted.replace '$', ''
        if teamGoal is '' or teamGoal is '0'
          $scope.teamGoalInfo.goal = ''
        else
          $scope.teamGoalInfo.goal = teamGoal
        $scope.editTeamGoalModal = $uibModal.open
          scope: $scope
          templateUrl: APP_INFO.rootPath + 'dist/high-school/html/participant-center/modal/editTeamGoal.html'
      
      $scope.cancelEditTeamGoal = ->
        $scope.editTeamGoalModal.close()
      
      $scope.updateTeamGoal = ->
        delete $scope.teamGoalInfo.errorMessage
        newGoal = $scope.teamGoalInfo.goal
        if newGoal
          newGoal = newGoal.replace('$', '').replace /,/g, ''
        if not newGoal or newGoal is '' or newGoal is '0' or isNaN(newGoal)
          $scope.teamGoalInfo.errorMessage = 'Please specify a goal greater than $0.'
        else
          updateTeamGoalPromise = NgPcTeamraiserTeamService.updateTeamInformation 'team_goal=' + (newGoal * 100)
            .then (response) ->
              if response.data.errorResponse
                $scope.teamGoalInfo.errorMessage = response.data.errorResponse.message
              else
                $scope.editTeamGoalModal.close()
                $scope.refreshFundraisingProgress()
              response
          $scope.dashboardPromises.push updateTeamGoalPromise
      
      $scope.schoolGoalInfo = {}
      
      $scope.editSchoolGoal = ->
        delete $scope.schoolGoalInfo.errorMessage
        schoolGoal = $scope.companyProgress.goalFormatted.replace '$', ''
        if schoolGoal is '' or schoolGoal is '0'
          $scope.schoolGoalInfo.goal = ''
        else
          $scope.schoolGoalInfo.goal = schoolGoal
        $scope.editSchoolGoalModal = $uibModal.open
          scope: $scope
          templateUrl: APP_INFO.rootPath + 'dist/high-school/html/participant-center/modal/editSchoolGoal.html'
      
      $scope.cancelEditSchoolGoal = ->
        $scope.editSchoolGoalModal.close()
      
      $scope.updateSchoolGoal = ->
        delete $scope.schoolGoalInfo.errorMessage
        newGoal = $scope.schoolGoalInfo.goal
        if newGoal
          newGoal = newGoal.replace('$', '').replace /,/g, ''
        if not newGoal or newGoal is '' or newGoal is '0' or isNaN(newGoal)
          $scope.schoolGoalInfo.errorMessage = 'Please specify a goal greater than $0.'
        else
          updateSchoolGoalPromise = NgPcTeamraiserSchoolService.updateSchoolGoal(newGoal, $scope)
            .then (response) ->
              $scope.editSchoolGoalModal.close()
              $scope.refreshFundraisingProgress()
          $scope.dashboardPromises.push updateSchoolGoalPromise
      
      if $scope.facebookFundraisersEnabled and $rootScope.facebookFundraiserId and $rootScope.facebookFundraiserId isnt ''
        $rootScope.facebookFundraiserConfirmedStatus = 'pending'
        FacebookFundraiserService.confirmFundraiserStatus()
          .then (response) ->
            confirmOrUnlinkFacebookFundraiserResponse = response.data.confirmOrUnlinkFacebookFundraiserResponse
            if confirmOrUnlinkFacebookFundraiserResponse?.active is 'false'
              delete $rootScope.facebookFundraiserId
              $rootScope.facebookFundraiserConfirmedStatus = 'deleted'
            else
              $rootScope.facebookFundraiserConfirmedStatus = 'confirmed'
      
      $scope.participantGifts =
        sortColumn: 'date_recorded'
        sortAscending: false
        page: 1
      $scope.getGifts = ->
        pageNumber = $scope.participantGifts.page - 1
        personalGiftsPromise = NgPcTeamraiserGiftService.getGifts 'list_sort_column=' + $scope.participantGifts.sortColumn + '&list_ascending=' + $scope.participantGifts.sortAscending + '&list_page_size=10&list_page_offset=' + pageNumber
          .then (response) ->
            if response.data.errorResponse
              $scope.participantGifts.gifts = []
              $scope.participantGifts.totalNumber = 0
            else
              gifts = response.data.getGiftsResponse.gift
              if not gifts
                $scope.participantGifts.gifts = []
              else
                gifts = [gifts] if not angular.isArray gifts
                participantGifts = []
                angular.forEach gifts, (gift) ->
                  gift.contact =
                    firstName: gift.name.first
                    lastName: gift.name.last
                    email: gift.email
                  gift.giftAmountFormatted = $filter('currency') gift.giftAmount / 100, '$', 0
                  participantGifts.push gift
                $scope.participantGifts.gifts = participantGifts
              $scope.participantGifts.totalNumber = if response.data.getGiftsResponse.totalNumberResults then Number(response.data.getGiftsResponse.totalNumberResults) else 0
            response
        $scope.dashboardPromises.push personalGiftsPromise
      $scope.getGifts()
      
      $scope.donorContactCounts = {}
      donorContactFilters = [
        'email_rpt_show_nondonors_followup'
        'email_rpt_show_unthanked_donors'
        'email_rpt_show_donors'
      ]
      angular.forEach donorContactFilters, (filter) ->
        donorContactCountPromise = NgPcContactService.getTeamraiserAddressBookContacts 'tr_ab_filter=' + filter + '&skip_groups=true&list_page_size=1'
          .then (response) ->
            totalNumberResults = response.data.getTeamraiserAddressBookContactsResponse?.totalNumberResults
            $scope.donorContactCounts[filter] = if totalNumberResults then Number(totalNumberResults) else 0
            response
        $scope.dashboardPromises.push donorContactCountPromise
      
      if $scope.participantRegistration.aTeamCaptain isnt 'true' and $scope.participantRegistration.companyInformation?.isCompanyCoordinator isnt 'true'
        $scope.dashboardPageType = 'personal'
      else if $scope.participantRegistration.companyInformation?.isCompanyCoordinator isnt 'true'
        $scope.dashboardPageType = 'team'
      else
        $scope.dashboardPageType = 'company'
      $scope.togglePageType = (pageType) ->
        $scope.dashboardPageType = pageType
      
      $scope.getParticipantShortcut = ->
        getParticipantShortcutPromise = NgPcTeamraiserShortcutURLService.getShortcut()
          .then (response) ->
            if response.data.errorResponse
              # TODO
            else
              shortcutItem = response.data.getShortcutResponse.shortcutItem
              if not shortcutItem
                # TODO
              else
                if shortcutItem.prefix
                  shortcutItem.prefix = shortcutItem.prefix
                $scope.participantShortcut = shortcutItem
                if shortcutItem.url
                  $scope.personalPageUrl = shortcutItem.url
                else
                  $scope.personalPageUrl = shortcutItem.defaultUrl.split('/site/')[0] + '/site/TR?fr_id=' + $scope.frId + '&pg=personal&px=' + $scope.consId
            response
        $scope.dashboardPromises.push getParticipantShortcutPromise
      $scope.getParticipantShortcut()
      
      $scope.personalUrlInfo = {}
      
      $scope.editPersonalUrl = ->
        delete $scope.personalUrlInfo.errorMessage
        $scope.personalUrlInfo.updatedShortcut = $scope.participantShortcut.text or ''
        $scope.editPersonalUrlModal = $uibModal.open
          scope: $scope
          templateUrl: APP_INFO.rootPath + 'dist/high-school/html/participant-center/modal/editParticipantUrl.html'
      
      $scope.cancelEditPersonalUrl = ->
       $scope.editPersonalUrlModal.close()
      
      $scope.updatePersonalUrl = ->
        delete $scope.personalUrlInfo.errorMessage
        updatePersonalUrlPromise = NgPcTeamraiserShortcutURLService.updateShortcut 'text=' + encodeURIComponent($scope.personalUrlInfo.updatedShortcut)
          .then (response) ->
            if response.data.errorResponse
              $scope.personalUrlInfo.errorMessage = response.data.errorResponse.message
            else
              $scope.editPersonalUrlModal.close()
              $scope.getParticipantShortcut()
            response
        $scope.dashboardPromises.push updatePersonalUrlPromise
      
      if $scope.participantRegistration.teamId and $scope.participantRegistration.teamId isnt '-1' and $scope.participantRegistration.aTeamCaptain is 'true'
        $scope.getTeamShortcut = ->
          getTeamShortcutPromise = NgPcTeamraiserShortcutURLService.getTeamShortcut()
            .then (response) ->
              if response.data.errorResponse
                # TODO
              else
                shortcutItem = response.data.getTeamShortcutResponse.shortcutItem
                if not shortcutItem
                  # TODO
                else
                  if shortcutItem.prefix
                    shortcutItem.prefix = shortcutItem.prefix
                  $scope.teamShortcut = shortcutItem
                  if shortcutItem.url
                    $scope.teamPageUrl = shortcutItem.url
                  else
                    $scope.teamPageUrl = shortcutItem.defaultUrl.split('/site/')[0] + '/site/TR?fr_id=' + $scope.frId + '&pg=team&team_id=' + $scope.participantRegistration.teamId
              response
          $scope.dashboardPromises.push getTeamShortcutPromise
        $scope.getTeamShortcut()
        
        $scope.teamUrlInfo = {}
        
        $scope.editTeamUrl = ->
          delete $scope.teamUrlInfo.errorMessage
          $scope.teamUrlInfo.updatedShortcut = $scope.teamShortcut.text or ''
          $scope.editTeamUrlModal = $uibModal.open
            scope: $scope
            templateUrl: APP_INFO.rootPath + 'dist/high-school/html/participant-center/modal/editTeamUrl.html'
        
        $scope.cancelEditTeamUrl = ->
         $scope.editTeamUrlModal.close()
        
        $scope.updateTeamUrl = ->
          delete $scope.teamUrlInfo.errorMessage
          updateTeamUrlPromise = NgPcTeamraiserShortcutURLService.updateTeamShortcut 'text=' + encodeURIComponent($scope.teamUrlInfo.updatedShortcut)
            .then (response) ->
              if response.data.errorResponse
                $scope.teamUrlInfo.errorMessage = response.data.errorResponse.message
              else
                $scope.editTeamUrlModal.close()
                $scope.getTeamShortcut()
              response
          $scope.dashboardPromises.push updateTeamUrlPromise
      
      if $scope.participantRegistration.companyInformation and $scope.participantRegistration.companyInformation.companyId and $scope.participantRegistration.companyInformation.companyId isnt -1 and $scope.participantRegistration.companyInformation?.isCompanyCoordinator is 'true'
        $scope.getCompanyShortcut = ->
          getCompanyShortcutPromise = NgPcTeamraiserShortcutURLService.getCompanyShortcut()
            .then (response) ->
              if response.data.errorResponse
                # TODO
              else
                shortcutItem = response.data.getCompanyShortcutResponse?.shortcutItem
                if not shortcutItem
                  # TODO
                else
                  if shortcutItem.prefix
                    shortcutItem.prefix = shortcutItem.prefix
                  $scope.companyShortcut = shortcutItem
                  if shortcutItem.url
                    $scope.companyPageUrl = shortcutItem.url
                  else
                    $scope.companyPageUrl = shortcutItem.defaultUrl.split('/site/')[0] + '/site/TR?fr_id=' + $scope.frId + '&pg=company&company_id=' + $scope.participantRegistration.companyInformation.companyId
              response
          $scope.dashboardPromises.push getCompanyShortcutPromise
        $scope.getCompanyShortcut()
        
        $scope.companyUrlInfo = {}
        
        $scope.editCompanyUrl = ->
          delete $scope.companyUrlInfo.errorMessage
          $scope.companyUrlInfo.updatedShortcut = $scope.companyShortcut.text or ''
          $scope.editCompanyUrlModal = $uibModal.open
            scope: $scope
            templateUrl: APP_INFO.rootPath + 'dist/high-school/html/participant-center/modal/editCompanyUrl.html'
        
        $scope.cancelEditCompanyUrl = ->
         $scope.editCompanyUrlModal.close()
        
        $scope.updateCompanyUrl = ->
          delete $scope.companyUrlInfo.errorMessage
          updateCompanyUrlPromise = NgPcTeamraiserShortcutURLService.updateCompanyShortcut 'text=' + encodeURIComponent($scope.companyUrlInfo.updatedShortcut)
            .then (response) ->
              if response.data.errorResponse
                $scope.companyUrlInfo.errorMessage = response.data.errorResponse.message
              else
                $scope.editCompanyUrlModal.close()
                $scope.getCompanyShortcut()
              response
          $scope.dashboardPromises.push updateCompanyUrlPromise
      
      $scope.prizes = []
      BoundlessService.getBadges $scope.consId
        .then (response) ->
          prizes = response.data.prizes
          angular.forEach prizes, (prize) ->
            $scope.prizes.push
              id: prize.id
              label: prize.label
              sku: prize.sku
              status: prize.status
              earned: prize.earned_datetime
        , (response) ->
          # TODO
  ]