angular.module 'trPcControllers'
  .controller 'NgPcDashboardViewCtrl', [
    '$rootScope'
    '$scope'
    '$filter'
    '$timeout'
    '$uibModal'
    'APP_INFO'
    'ZuriService'
    'BoundlessService'
    'NgPcTeamraiserRegistrationService'
    'NgPcTeamraiserProgressService'
    'NgPcTeamraiserTeamService'
    'NgPcTeamraiserSchoolService'
    'NgPcTeamraiserGiftService'
    'NgPcContactService'
    'NgPcTeamraiserShortcutURLService'
    'NgPcInteractionService'
    'NgPcTeamraiserCompanyService'
    'FacebookFundraiserService'
    ($rootScope, $scope, $filter, $timeout, $uibModal, APP_INFO, ZuriService, BoundlessService, NgPcTeamraiserRegistrationService, NgPcTeamraiserProgressService, NgPcTeamraiserTeamService, NgPcTeamraiserSchoolService, NgPcTeamraiserGiftService, NgPcContactService, NgPcTeamraiserShortcutURLService, NgPcInteractionService, NgPcTeamraiserCompanyService, FacebookFundraiserService) ->
      $scope.dashboardPromises = []

      $dataRoot = angular.element '[data-embed-root]'

      if $scope.participantRegistration.lastPC2Login is '0'
        if $scope.participantRegistration.companyInformation?.isCompanyCoordinator isnt 'true'
          $scope.firstLoginModal = $uibModal.open
            scope: $scope
            templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/modal/firstLogin.html'

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

      if $scope.participantRegistration.companyInformation?.isCompanyCoordinator is 'true'
        BoundlessService.checkOOTDashboard $scope.consId
        .then (response) ->
          $rootScope.hasOOTDashboard = response.data.coordinatorHasDashboard
        , (response) ->
          # TODO

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
            templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/modal/editCoordinatorMessage.html'

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
          templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/modal/editParticipantGoal.html'

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
          templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/modal/editTeamGoal.html'

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
          templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/modal/editSchoolGoal.html'

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

      if $scope.participantRegistration.companyInformation?.isCompanyCoordinator isnt 'true'
        $scope.dashboardPageType = 'personal'
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
          templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/modal/editParticipantUrl.html'

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
            templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/modal/editTeamUrl.html'

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

        $scope.companyUrlInfo = {}

        $scope.editCompanyUrl = ->
          delete $scope.companyUrlInfo.errorMessage
          $scope.companyUrlInfo.updatedShortcut = $scope.companyShortcut.text or ''
          $scope.editCompanyUrlModal = $uibModal.open
            scope: $scope
            templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/modal/editCompanyUrl.html'

        $scope.editCompanyUrlFirst = ->
          delete $scope.companyUrlInfo.errorMessage
          $scope.companyUrlInfo.updatedShortcut = $scope.companyShortcut.text or ''
          $scope.editCompanyUrlModal = $uibModal.open
            scope: $scope
            templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/modal/firstLoginCoord.html'

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
                    if $scope.participantRegistration.lastPC2Login is '0'
                      $scope.editCompanyUrlFirst()
              response
          $scope.dashboardPromises.push getCompanyShortcutPromise
        $scope.getCompanyShortcut()

      $scope.personalChallenge = {}
      $scope.updatedPersonalChallenge = {}
      setPersonalChallenge = (id, name = '', numCompleted = 0, completedToday = false) ->
        if id is null or id is ''
          id = '-1'
        if id is '-1' and $scope.challengeTaken and $scope.challengeTaken isnt ''
          if $scope.challengeTaken.indexOf('1. ') isnt -1
            id = '1'
            name = $scope.challengeTaken.split('1. ')[1]
          else if $scope.challengeTaken.indexOf('2. ') isnt -1
            id = '2'
            name = $scope.challengeTaken.split('2. ')[1]
          else if $scope.challengeTaken.indexOf('3. ') isnt -1
            id = '3'
            name = $scope.challengeTaken.split('3. ')[1]
        $scope.personalChallenge.id = id
        $scope.personalChallenge.name = name
        $scope.personalChallenge.numCompleted = numCompleted
        $scope.personalChallenge.completedToday = completedToday
        if id is '-1'
          $scope.updatedPersonalChallenge.id = ''
        else
          $scope.updatedPersonalChallenge.id = id
        if not $scope.$$phase
          $scope.$apply()

      errorCount = 0
      getStudentChallenge = ->
        if not $scope.personalChallenge
          $scope.personalChallenge = {}
        $scope.personalChallenge.updatePending = true
        $scope.personalChallenge.loadPending = true
        ZuriService.getStudent $scope.frId + '/' + $scope.consId,
          failure: (response) ->
            # if challenge not found - wait 3 secs and try again 10 times max
            if errorCount < 10 and response.status is 404
              errorCount++
              setTimeout getStudentChallenge, 3000
            delete $scope.personalChallenge.updatePending
            setPersonalChallenge()
          error: (response) ->
            delete $scope.personalChallenge.updatePending
            setPersonalChallenge()
          success: (response) ->
            personalChallenges = response.data.challenges
            if not personalChallenges
              setPersonalChallenge()
            else
              delete $scope.personalChallenge.updatePending
              $scope.personalChallenge.loadPending = false
              id = personalChallenges.current
              if id is '0'
                setPersonalChallenge()
              else
                numCompleted = if personalChallenges.completed then Number(personalChallenges.completed) else 0
                setPersonalChallenge id, personalChallenges.text, numCompleted, personalChallenges.completedToday
      getStudentChallenge()

      $scope.challenges = []
      # ZuriService.getChallenges $scope.frId + '/' + $scope.consId,
        # failure: (response) ->
          # TODO
        # error: (response) ->
          # TODO
        # success: (response) ->
          # challenges = response.data.challenges
          # angular.forEach challenges, (challenge, challengeIndex) ->
            # $scope.challenges.push
              # id: challengeIndex
              # name: challenge
      challengeOptions =
        "1": "Be Ready"
        "2": "Move More"
        "3": "Be Kind"
      angular.forEach challengeOptions, (challenge, challengeIndex) ->
        $scope.challenges.push
          id: challengeIndex
          name: challenge

      $scope.updateChallenge = ->
        if not $scope.personalChallenge
          $scope.personalChallenge = {}
        $scope.personalChallenge.updatePending = true
        ZuriService.updateChallenge $scope.frId + '/' + $scope.consId + '?challenge=' + $scope.updatedPersonalChallenge.id,
          failure: (response) ->
            # TODO
            delete $scope.personalChallenge.updatePending
          success: (response) ->
            delete $scope.personalChallenge.updatePending
            getStudentChallenge()

      $scope.updateDayChallenge = (challengeid) ->
        if not $scope.personalChallenge
          $scope.personalChallenge = {}
        $scope.personalChallenge.updatePending = true
        ZuriService.updateChallenge $scope.frId + '/' + $scope.consId + '?challenge=' + challengeid,
          failure: (response) ->
            # TODO
            delete $scope.personalChallenge.updatePending
          success: (response) ->
            delete $scope.personalChallenge.updatePending
            getStudentChallenge()

      $scope.logChallenge = ->
        if not $scope.personalChallenge
          $scope.personalChallenge = {}
        $scope.personalChallenge.updatePending = true
        ZuriService.logChallenge $scope.frId + '/' + $scope.consId + '/' + $scope.personalChallenge.id,
          failure: (response) ->
            # TODO
            delete $scope.personalChallenge.updatePending
          success: (response) ->
            delete $scope.personalChallenge.updatePending
            getStudentChallenge()

      $scope.prizes = []
      $scope.prizesEarned = 0
      $scope.has_bonus = 0
      BoundlessService.getBadges $scope.consId
      .then (response) ->
        prizes = response.data.prizes
        $scope.has_bonus = response.data.has_bonus
        angular.forEach prizes, (prize) ->
          $scope.prizes.push
            id: prize.id
            label: prize.label
            sku: prize.sku
            status: prize.status
            earned: prize.earned_datetime
            completed_label: prize.completed_label
            not_completed_label: prize.not_completed_label
            not_completed_url: prize.not_completed_url
            url_type: prize.url_type
          if prize.status == 1
            $scope.prizesEarned++
      , (response) ->
        # TODO

      initCarousel = ->
        owl = jQuery '.owl-carousel'
        owl.owlCarousel
          mouseDrag: false
          nav: true
          loop: true
          responsive:
            0:
              items: 2
              stagePadding: 30
              margin : 15
            480:
              items: 3
              stagePadding: 30
              margin: 15
            768:
              items: 5
              margin: 30
              stagePadding: 60
            1024:
              items: 7
              margin: 30
              stagePadding: 60
          navText: [
            '<span class="fa fa-chevron-left" hidden aria-hidden="true" />',
            '<span class="fa fa-chevron-right" hidden aria-hidden="true" />'
          ]
          addClassActive: true
          onInitialized: (event) ->
            angular.element('.owl-carousel').find('.owl-item').attr 'aria-selected', 'false'
            angular.element('.owl-carousel').find('.owl-item').attr 'role', 'listitem'
            angular.element('.owl-carousel').find('.owl-item.active').attr 'aria-selected', 'true'
            angular.element('.owl-carousel').find('.owl-prev').attr('role', 'button').attr 'title', 'Previous'
            angular.element('.owl-carousel').find('.owl-next').attr('role', 'button').attr 'title', 'Next'
            angular.element('.owl-item, .owl-prev, .owl-next').attr 'tabindex', '0'
            jQuery(document).on 'keydown', (e) ->
              $focusedElement = jQuery(document.activeElement)
              if e.which is 13
                if $focusedElement.is '.owl-next'
                  owl.trigger 'next.owl.carousel'
                if $focusedElement.is '.owl-prev'
                  owl.trigger 'prev.owl.carousel'
            return
          onChange: ->
            angular.element('.owl-carousel').find('.owl-item').attr 'aria-selected', 'false'
            angular.element('.owl-carousel').find('.owl-item.active').attr 'aria-selected', 'true'
            angular.element('.owl-item.active').attr 'tabindex', '0'
      $timeout initCarousel, 1000

      $scope.personalInfo = {}
      $scope.personalInfo.avatar = ''
      $scope.getPersonalAvatar = ->
        ZuriService.getAvatar $scope.consId,
          failure: (response) ->
            # TODO
          error: (response) ->
            # TODO
          success: (response) ->
            if response.data.student.student_id isnt null and typeof response.data.student.avatar_url isnt 'undefined'
              avatarURL = response.data.student.avatar_url
            else
              if $rootScope.tablePrefix is 'heartdev'
                avatarURL = 'https://hearttools.heart.org/aha_ym20_dev/virtualworld/img/avatar-charger.png'
              else if $rootScope.tablePrefix is 'heartnew'
                avatarURL = 'https://hearttools.heart.org/aha_ym20_testing/virtualworld/img/avatar-charger.png'
              else
                avatarURL = 'https://hearttools.heart.org/aha_ym20/virtualworld/img/avatar-charger.png'
            $scope.personalInfo.avatar = avatarURL
      $scope.getPersonalAvatar()

      $scope.heroPopup = false
      $scope.heartHeros = heroPopup: ->
        $scope.heroPopup = true
        WAIT_TIME = 10000
        POP_TIME = 3000
        NUM_POPS = 3
        i = 0
        pop_timer = ''
        doPopup = ->
          popup_container = angular.element('.launch-builder-popup')
          if i is NUM_POPS
            clearInterval(pop_timer)
          else
            popup_container.addClass 'pop'
            i++
          setTimeout (->
            popup_container.removeClass 'pop'
            return
          ), POP_TIME
          return
        pop_timer = setInterval(doPopup, WAIT_TIME)
        return
      $scope.heartHeros.heroPopup()

      $scope.monsterEdit = ->
        url = ''
        if $rootScope.tablePrefix is 'heartdev'
          url = 'https://khc.staging.ootqa.org'
        else if $rootScope.tablePrefix is 'heartnew'
          url = 'https://khc.dev.ootqa.org'
        else
          url = 'https://kidsheartchallenge.heart.org'
        window.open url + '/student/login/' + $scope.authToken + '/' + $scope.sessionCookie

      NgPcTeamraiserCompanyService.getSchoolDates()
        .then (response) ->
          schoolDataRows = response.data.getSchoolDatesResponse.schoolData
          schoolDataHeaders = {}
          schoolDates = {}
          angular.forEach schoolDataRows[0], (schoolDataHeader, schoolDataHeaderIndex) ->
            schoolDataHeaders[schoolDataHeader] = schoolDataHeaderIndex
          i = 0
          len = schoolDataRows.length
          while i < len
            if $rootScope.companyInfo.companyId is schoolDataRows[i][schoolDataHeaders.CID]
              $scope.eventDate = schoolDataRows[i][schoolDataHeaders.ED]
              $scope.moneyDueDate = schoolDataRows[i][schoolDataHeaders.MDD]
              $scope.schoolStudentGoal = schoolDataRows[i][schoolDataHeaders.PG]
              $scope.schoolStudentReg = schoolDataRows[i][schoolDataHeaders.TR]
              $scope.schoolStudentRegOnline = schoolDataRows[i][schoolDataHeaders.RO]
              $scope.notifyName = schoolDataRows[i][schoolDataHeaders.YMDN]
              $scope.notifyEmail = schoolDataRows[i][schoolDataHeaders.YMDE]
              break
            i++
      $scope.showPrize = (sku, label, earned) ->
        $scope.prize_sku = sku
        $scope.prize_label = label
        $scope.prize_status = earned
        $scope.viewPrizeModal = $uibModal.open
          scope: $scope
          templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/modal/viewPrize.html'

      $scope.cancelShowPrize = ->
        $scope.viewPrizeModal.close()

      getRandomID = ->
        return Math.floor((Math.random()*3)+1);

      defaultStandardGifts = BoundlessService.defaultStandardGifts()

      $scope.upcomingGifts = []
      $scope.giftsEarned = 0
      $scope.totalGifts = 0

      BoundlessService.getPrizes $scope.consId
      .then (response) ->
        students = response.data.student
        angular.forEach students, (student) ->
          if student.has_bonus
             giftLevels = BoundlessService.giftLevels_instant()
          else
             giftLevels = BoundlessService.giftLevels_noninstant()
          current_level = if student.current_level != null then student.current_level else '$0'
          #get total number of gifts student can get
          giftsInList = 0
          angular.forEach defaultStandardGifts, (gift, key) ->
            if student.has_bonus and (gift.instant == 1 or gift.instant == 2) or !student.has_bonus and (gift.instant == 0 or gift.instant == 2)
              if gift.online_only
                jQuery.each student.prizes, (item, key) ->
                  if key.prize_sku.indexOf(gift.id) isnt -1
                    giftsInList++
                    return false
                  return
              if !gift.online_only
                giftsInList++

          prevstatus = -1
          startList = 0
          listCnt = 1
          giftPrev = ""
          giftToAdd = 3 # after adding first one - add 3 more
          angular.forEach defaultStandardGifts, (gift, key) ->
            if student.has_bonus and (gift.instant == 1 or gift.instant == 2) or !student.has_bonus and (gift.instant == 0 or gift.instant == 2)
              status = 0
              lastItem = 0
              if jQuery.inArray(gift.id,giftLevels[current_level]) isnt -1
                status = 1
                if gift.online_only
                  status = 0
                  jQuery.each student.prizes, (item, key) ->
                    if key.prize_sku.indexOf(gift.id) > -1
                      status = 1
                      return false
                    return

              # if nothing has been earned yet
              if prevstatus == -1 and status == 0 and $scope.giftsEarned == 0
                startList = 1
                giftToAdd = 4 # need to add next 4 to list
              # if prev item is the last item earned then add and start pusing in items
              if prevstatus == 1 and status == 0 and startList == 0
                startList = 1
                $scope.upcomingGifts.push
                  prize_label: giftPrev.name
                  prize_sku: giftPrev.id
                  prize_status: prevstatus
                  lastItem: 1
                  randomID: getRandomID()
                  prize_level: giftPrev.level
                  earned_title: giftPrev.earned_title
                  earned_subtitle1: giftPrev.earned_subtitle1
                  earned_subtitle2: giftPrev.earned_subtitle2
              # if items need to be added then only add up to 3 after pushing first one
              if startList == 1 and listCnt <= giftToAdd
                listCnt++
                $scope.upcomingGifts.push
                  prize_label: gift.name
                  prize_sku: gift.id
                  prize_status: status
                  lastItem: lastItem
                  randomID: getRandomID()
                  prize_level: gift.level
                  earned_title: gift.earned_title
                  earned_subtitle1: gift.earned_subtitle1
                  earned_subtitle2: gift.earned_subtitle2
                $scope.giftStatus = status
              giftPrev = gift
              prevstatus = status
              # add last 4 no matter what
              if $scope.totalGifts >= giftsInList - 5 and status == 1 and startList == 0
                startList = 1
                giftToAdd = 4
              $scope.totalGifts++
              if status == 1
                $scope.giftsEarned++

      , (response) ->
        # TODO
      $scope.schoolYearsInfo = {}

      if $scope.participantRegistration.companyInformation?.isCompanyCoordinator is 'true'
        ZuriService.getSchoolYears $scope.participantRegistration.companyInformation.companyId,
          failure: (response) ->
            $scope.companyProgress.schoolYears = 0
          error: (response) ->
            $scope.companyProgress.schoolYears = 0
          success: (response) ->
            if response.data.value isnt null
              $scope.companyProgress.schoolYears = response.data.value
            else
              $scope.companyProgress.schoolYears = 0

      $scope.editSchoolYears = ->
        delete $scope.schoolYearsInfo.errorMessage
        schoolYears = $scope.companyProgress.schoolYears
        if schoolYears is '' or schoolYears is '0'
          $scope.schoolYearsInfo.years = ''
        else
          $scope.schoolYearsInfo.years = schoolYears
        $scope.editSchoolYearsModal = $uibModal.open
          scope: $scope
          templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/modal/editSchoolYears.html'

      $scope.cancelEditSchoolYears = ->
        $scope.editSchoolYearsModal.close()

      $scope.updateSchoolYears = ->
        delete $scope.schoolYearsInfo.errorMessage
        newYears = $scope.schoolYearsInfo.years
        if not newYears or newYears is '' or newYears is '0' or isNaN(newYears)
          $scope.schoolYearsInfo.errorMessage = 'Please specify a year greater than 0.'
        else
          updateSchoolYearPromise = ZuriService.updateSchoolYears $scope.participantRegistration.companyInformation.companyId + '/years-participated/update?value=' + newYears,
            failure: (response) ->
              $scope.schoolYearsInfo.errorMessage = 'Process failed to save years entered'
            error: (response) ->
              $scope.schoolYearsInfo.errorMessage = 'Error: ' + response.data.message
            success: (response) ->
              $scope.companyProgress.schoolYears = newYears
              $scope.editSchoolYearsModal.close()

      $scope.showMobileApp = ->
        $scope.viewMobileApp = $uibModal.open
          scope: $scope
          templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/modal/viewMobileApp.html'

      $scope.cancelMobileApp = ->
        $scope.viewMobileApp.close()
  ]
