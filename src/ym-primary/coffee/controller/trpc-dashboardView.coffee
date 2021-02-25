angular.module 'trPcControllers'
  .controller 'NgPcDashboardViewCtrl', [
    '$rootScope'
    '$scope'
    '$location'
    '$filter'
    '$timeout'
    '$uibModal'
    '$sce'
    'APP_INFO'
    'ZuriService'
    'BoundlessService'
    'TeamraiserParticipantService'
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
    ($rootScope, $scope, $location, $filter, $timeout, $uibModal, $sce, APP_INFO, ZuriService, BoundlessService, TeamraiserParticipantService, NgPcTeamraiserRegistrationService, NgPcTeamraiserProgressService, NgPcTeamraiserTeamService, NgPcTeamraiserSchoolService, NgPcTeamraiserGiftService, NgPcContactService, NgPcTeamraiserShortcutURLService, NgPcInteractionService, NgPcTeamraiserCompanyService, FacebookFundraiserService) ->
      $scope.dashboardPromises = []
      domain = $location.absUrl().split('/site/')[0]
      $scope.studentsPledgedTotal = ''
      $scope.activity1amt = ''
      $scope.activity2amt = ''
      $scope.activity3amt = ''
      $scope.companyId = $scope.participantRegistration.companyInformation.companyId
      theDate = new Date
      $scope.yearsList = [1..(theDate.getFullYear()-1978)] # 0 - 50
      $scope.schoolChallenges = []
      $scope.companyProgress = []
      $rootScope.hideGifts = "Y"
      $scope.topClassRaised = []
      $scope.topClassStudents = []
      $scope.topGradeRaised = []
      $scope.topGradeStudents = []
      $scope.topCompanySteps = []
      
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
        BoundlessService.checkOOTDashboard $scope.frId + '/' + $scope.consId
        .then (response) ->
          $rootScope.hasOOTDashboard = response.data.coordinatorHasDashboard
        , (response) ->
          # TODO
      else
        $rootScope.hasOOTDashboard = true

      #school years, challenge and level update
      $scope.schoolInfo = {}
      $scope.schoolChallengeInfo = {}
      $scope.schoolChallengeLevelInfo = {}
      $scope.companyProgress.schoolYears = 0
      $scope.companyProgress.schoolChallenge = ''
      $scope.companyProgress.schoolChallengeLevel = ''
            
      getSchoolInformation = ->
        ZuriService.getSchoolData $scope.participantRegistration.companyInformation.companyId,
          failure: (response) ->
          error: (response) ->
          success: (response) ->
            if typeof response.data.data != 'undefined'
              if response.data.data.length > 0
                angular.forEach response.data.data, (meta, key) ->
                  if meta.name == 'years-participated'
                    $scope.companyProgress.schoolYears = meta.value
                  if meta.name == 'school-challenge'
                    $scope.companyProgress.schoolChallenge = meta.value
                  if meta.name == 'school-goal'
                    $scope.companyProgress.schoolChallengeLevel = meta.value
                amt = $scope.participantProgress.raised / 100
                if amt >= Number(($scope.companyProgress.schoolChallengeLevel).replace('$', '').replace(/,/g, '')) and $scope.companyProgress.schoolChallenge != "No School Challenge"
                  # check if student badge already added
                  schoolChallengeAdded = false
                  angular.forEach $scope.schoolChallenges, (schoolChallenge, schoolChallengeIndex) ->
                    if schoolChallenge.id == "student"
                      schoolChallengeAdded = true
                  if not schoolChallengeAdded
                    $scope.schoolChallenges.push
                      id: 'student'
                      label: 'Individual Challenge Completed'
                      earned: true

      participantsString = ''
      $scope.companyParticipants = {}
      setCompanyParticipants = (participants, totalNumber, totalFundraisers) ->
        $scope.companyParticipants.participants = participants or []
        totalNumber = totalNumber or 0
        $scope.companyParticipants.totalNumber = Number totalNumber
        $scope.companyParticipants.totalFundraisers = Number totalFundraisers
        if not $scope.$$phase
          $scope.$apply()
        if participants and participants.length > 0
          angular.forEach participants, (participant, participantIndex) ->
            participantsString += '{name: "' + participant.name.first + ' ' + participant.name.last + '", raised: "' + participant.amountRaisedFormatted + '"}'
            if participantIndex < (participants.length - 1)
              participantsString += ', '
          companyParticipantsString = '{participants: [' + participantsString + '], totalNumber: ' + participants.length + '}'
          angular.element('.ym-school-animation iframe')[0].contentWindow.postMessage companyParticipantsString, domain
          angular.element('.ym-school-animation iframe').on 'load', ->
            angular.element('.ym-school-animation iframe')[0].contentWindow.postMessage companyParticipantsString, domain

      getCompanyParticipants = ->
        TeamraiserParticipantService.getParticipants 'team_name=' + encodeURIComponent('%') + '&first_name=' + encodeURIComponent('%%') + '&last_name=' + encodeURIComponent('%') + '&list_filter_column=team.company_id&list_filter_text=' + $scope.participantRegistration.companyInformation.companyId + '&list_sort_column=total&list_ascending=false&list_page_size=500',
            error: ->
              setCompanyParticipants()
            success: (response) ->
              participants = response.getParticipantsResponse?.participant
              companyParticipants = []
              totalNumberParticipants = response.getParticipantsResponse?.totalNumberResults or '0'
              totalFundraisers = 0
              if participants
                participants = [participants] if not angular.isArray participants
                angular.forEach participants, (participant) ->
                  participant.amountRaised = Number participant.amountRaised
                  if participant.name?.first and participant.amountRaised > 0
                    participant.firstName = participant.name.first
                    participant.lastName = participant.name.last || ""
                    participant.name.last =  participant.lastName.substring(0, 1) + '.'
                    participant.fullName = participant.name.first + ' ' + participant.name.last
                    participant.amountRaisedFormatted = $filter('currency')(participant.amountRaised / 100, '$')
                    if participant.donationUrl
                      participant.donationFormId = participant.donationUrl.split('df_id=')[1].split('&')[0]
                    companyParticipants.push participant
                    totalFundraisers++
              setCompanyParticipants companyParticipants, totalNumberParticipants, totalFundraisers
      getCompanyParticipants()
      
      url = 'PageServer?pagename=ym_khc_school_animation&pgwrap=n'
      if $scope.protocol is 'https:'
        url = 'S' + url
      $scope.schoolAnimationURL = $sce.trustAsResourceUrl(url)
      
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
                participantProgress.raisedFormatted = if participantProgress.raised then $filter('currency')(participantProgress.raised / 100, '$') else '$0.00'
                participantProgress.goal = Number participantProgress.goal
                participantProgress.goalFormatted = if participantProgress.goal then $filter('currency')(participantProgress.goal / 100, '$') else '$0.00'
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
                  teamProgress.raisedFormatted = if teamProgress.raised then $filter('currency')(teamProgress.raised / 100, '$') else '$0.00'
                  teamProgress.goal = Number teamProgress.goal
                  teamProgress.goalFormatted = if teamProgress.goal then $filter('currency')(teamProgress.goal / 100, '$') else '$0.00'
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
                  companyProgress.raisedFormatted = if companyProgress.raised then $filter('currency')(companyProgress.raised / 100, '$') else '$0.00'
                  companyProgress.goal = Number companyProgress.goal
                  companyProgress.goalFormatted = if companyProgress.goal then $filter('currency')(companyProgress.goal / 100, '$') else '$0.00'
                  companyProgress.percent = 0
                  if companyProgress.goal isnt 0
                    companyProgress.percent = Math.ceil((companyProgress.raised / companyProgress.goal) * 100)
                  if companyProgress.percent > 100
                    companyProgress.percent = 100
                  companyProgress.schoolYears = $scope.companyProgress?.schoolYears
                  companyProgress.schoolChallenge = $scope.companyProgress?.schoolChallenge
                  companyProgress.schoolChallengeLevel = $scope.companyProgress?.schoolChallengeLevel
                  $scope.companyProgress = companyProgress
                  if companyProgress.raised >= companyProgress.goal 
                    $scope.schoolChallenges.push
                      id: 'school'
                      label: 'School Challenge Completed'
                      earned: true
            response
        $scope.dashboardPromises.push fundraisingProgressPromise
        getSchoolInformation()
      $scope.refreshFundraisingProgress()

      interactionMoveMoreId = $dataRoot.data 'move-more-flag-id'

      $scope.moveMoreFlag =
        text: ''
        errorMessage: null
        successMessage: false
        message: ''
        interactionId: ''

      mm_current_mission_completed_header = "Congratulations, " + $scope.consNameFirst + "!"
      mm_current_mission_title = "You've completed all of Finn's Missions!"
      mm_current_mission_message = "You unlocked the secret code & your prize: a medal for your Heart Hero avatar! Visit your avatar to add your new, cool medal bling."
      
      $scope.getMoveMoreFlag = ->
        NgPcInteractionService.getUserInteractions 'interaction_type_id=' + interactionMoveMoreId + '&cons_id=' + $scope.consId + '&list_page_size=1'
          .then (response) ->
            $scope.moveMoreFlag.text = ''
            $scope.moveMoreFlag.interactionId = ''
            if not response.data.errorResponse
              interactions = response.data.getUserInteractionsResponse?.interaction
              if interactions
                interactions = [interactions] if not angular.isArray interactions
                if interactions.length > 0
                  interaction = interactions[0]
                  if interaction.note?.text == "true"
                     $scope.moveMoreFlag.text = true
                  else
                     $scope.moveMoreFlag.text = false
                  $scope.moveMoreFlag.interactionId = interaction.interactionId or ''
                  if $scope.moveMoreFlag.text
                    jQuery.each $scope.prizes, (item, key) ->
                      if key.sku == "BDG-9"
                        key.status = 1
                        key.earned = Date()
                    $scope.prizesEarned = $scope.prizesEarned + 1
                    if $scope.prizesEarned == $scope.prizes.length
                      $scope.current_mission_completed_header = mm_current_mission_completed_header
                      $scope.current_mission_title = mm_current_mission_title
                      $scope.current_mission_message = mm_current_mission_message

      $scope.updateMoveMoreFlag = ->
        if $scope.moveMoreFlag.interactionId is ''
          NgPcInteractionService.logInteraction 'interaction_type_id=' + interactionMoveMoreId + '&cons_id=' + $scope.consId + '&interaction_subject=' + $scope.participantRegistration.companyInformation.companyId + '&interaction_body=' + $scope.moveMoreFlag.message
              .then (response) ->
                if response.data.updateConsResponse?.message
                  $scope.moveMoreFlag.successMessage = true
                  jQuery.each $scope.prizes, (item, key) ->
                    if key.sku == "BDG-9"
                      if $scope.moveMoreFlag.message
                        key.status = 1
                        key.earned = Date()
                        $scope.prizesEarned = $scope.prizesEarned + 1
                      else 
                        key.status = 0
                        key.earned = ''
                        $scope.prizesEarned = $scope.prizesEarned - 1

                  if $scope.prizesEarned == $scope.prizes.length
                    $scope.current_mission_completed_header = mm_current_mission_completed_header
                    $scope.current_mission_title = mm_current_mission_title
                    $scope.current_mission_message = mm_current_mission_message
                else
                  $scope.moveMoreFlag.errorMessage = 'There was an error processing your update. Please try again later.'
        else
          NgPcInteractionService.updateInteraction 'interaction_id=' + $scope.moveMoreFlag.interactionId + '&cons_id=' + $scope.consId + '&interaction_subject=' + $scope.participantRegistration.companyInformation.companyId + '&interaction_body=' + $scope.moveMoreFlag.message
            .then (response) ->
              if response.data.errorResponse
                $scope.moveMoreFlag.errorMessage = 'There was an error processing your update. Please try again later.'
              else
                $scope.moveMoreFlag.successMessage = true
                jQuery.each $scope.prizes, (item, key) ->
                  if key.sku == "BDG-9"
                    if $scope.moveMoreFlag.message
                      key.status = 1
                      key.earned = Date()
                      $scope.prizesEarned = $scope.prizesEarned + 1
                    else 
                      key.status = 0
                      key.earned = ''
                      $scope.prizesEarned = $scope.prizesEarned - 1
                if $scope.prizesEarned == $scope.prizes.length
                  $scope.current_mission_completed_header = mm_current_mission_completed_header
                  $scope.current_mission_title = mm_current_mission_title
                  $scope.current_mission_message = mm_current_mission_message

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
          $scope.coordinatorMessage.original = $scope.coordinatorMessage.text
          if $scope.coordinatorMessage.text == ''
            $scope.coordinatorMessage.text = 'Don\'t forget to complete Finn\'s Mission!'
          $scope.editCoordinatorMessageModal = $uibModal.open
            scope: $scope
            templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/modal/editCoordinatorMessage.html'

        $scope.cancelEditCoordinatorMessage = ->
          $scope.coordinatorMessage.text = $scope.coordinatorMessage.original
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
                  gift.giftAmountFormatted = $filter('currency') gift.giftAmount / 100, '$'
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
          $scope.updatedPersonalChallenge.id = 0
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
              if id is '0' or id == ''
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
        "1": "Be Grateful"
        "2": "Be Active"
        "3": "Drink Water"
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
      $rootScope.has_bonus = 0
      $scope.current_mission_completed_count = ''
      $scope.current_mission_completed_header = ''
      $scope.current_mission_action = ''
      $scope.current_mission_title = ''
      $scope.current_mission_message = ''
      BoundlessService.getBadges $scope.frId + '/' + $scope.consId
      .then (response) ->
        prizes = response.data.prizes
        $scope.current_mission_completed_count = response.data.current_mission_completed_count
        $scope.current_mission_completed_header = response.data.current_mission_completed_header
        $scope.current_mission_action = response.data.current_mission_action
        $scope.current_mission_title = response.data.current_mission_title
        $scope.current_mission_message = response.data.current_mission_message
        $rootScope.has_bonus = response.data.has_bonus
        final_url = ''
        angular.forEach prizes, (prize) ->
          if prize.mission_url_type == 'Donate' 
            final_url = 'Donation2?df_id=' + $scope.eventInfo.donationFormId + "&FR_ID=" + $scope.frId + "&PROXY_TYPE=20&PROXY_ID=" + $scope.consId
          if prize.mission_url_type == 'Tab' 
            final_url = $scope.baseUrl + prize.mission_url
          if prize.mission_url_type == 'URL' 
            final_url = prize.mission_url
          if prize.mission_url_type == 'Quiz' 
            if $scope.tablePrefix == 'heartdev'
              final_url = 'https://tools.heart.org/aha_ym21_dev/quiz/show/' + prize.mission_url + '?event_id=' + $scope.frId + '&user_id=' + $scope.consId + '&name=' + $scope.consNameFirst
            if $scope.tablePrefix == 'heartnew'
              final_url = 'https://tools.heart.org/aha_ym21_testing/quiz/show/' + prize.mission_url + '?event_id=' + $scope.frId + '&user_id=' + $scope.consId + '&name=' + $scope.consNameFirst
            if $scope.tablePrefix == 'heart'
              final_url = 'https://tools.heart.org/aha_ym21/quiz/show/' + prize.mission_url + '?event_id=' + $scope.frId + '&user_id=' + $scope.consId + '&name=' + $scope.consNameFirst
          if prize.mission_url_type == 'Modal' and prize.mission_url == 'app' 
            final_url = 'showMobileApp()'
          $scope.prizes.push
            id: prize.id
            label: prize.label
            sku: prize.sku
            status: prize.status
            earned: prize.earned_datetime
            completed_label: prize.completed_label
            mission_url: prize.mission_url
            mission_url_type: prize.mission_url_type
            earned_image_url: prize.earned_image_url
            not_earned_image_url: prize.non_earned_image_url
            locked_image_url: prize.locked_image_url
            final_url: final_url

          if prize.status == 1
            $scope.prizesEarned++
        $scope.getMoveMoreFlag()
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
        ZuriService.getAvatar $scope.frId + '/' + $scope.consId,
          failure: (response) ->
            # TODO
          error: (response) ->
            # TODO
          success: (response) ->
            if response.data.student.student_id isnt null and typeof response.data.student.avatar_url isnt 'undefined'
              avatarURL = response.data.student.avatar_url
              if avatarURL.indexOf('default/monster') > 0
                avatarURL = ""
            else
                avatarURL = ""
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
          url = 'https://khc.staging.ootqa.org'
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
          compfnd = false
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
              $rootScope.hideGifts = schoolDataRows[i][schoolDataHeaders.HG]
              compfnd = true
              break
            i++
          if len == 0 or not compfnd
            $rootScope.hideGifts = "N"

      $scope.showPrize = (sku, label, earned, video) ->
        $scope.prize_sku = sku
        $scope.prize_label = label
        $scope.prize_status = earned
        $scope.prize_video = video
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
                  prize_video: giftPrev.video
                  prize_status: prevstatus
                  lastItem: 1
                  randomID: getRandomID()
                  prize_level: giftPrev.level
                  earned_title: giftPrev.earned_title
                  earned_subtitle1: giftPrev.earned_subtitle1
                  earned_subtitle2: giftPrev.earned_subtitle2
                  earned_subtitle3: giftPrev.earned_subtitle3
              # if items need to be added then only add up to 3 after pushing first one
              if startList == 1 and listCnt <= giftToAdd
                listCnt++
                $scope.upcomingGifts.push
                  prize_label: gift.name
                  prize_sku: gift.id
                  prize_video: gift.video
                  prize_status: status
                  lastItem: lastItem
                  randomID: getRandomID()
                  prize_level: gift.level
                  earned_title: gift.earned_title
                  earned_subtitle1: gift.earned_subtitle1
                  earned_subtitle2: gift.earned_subtitle2
                  earned_subtitle3: gift.earned_subtitle3
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
      
      $scope.updateSchoolYears = ->
        delete $scope.schoolInfo.errorMessage
        newYears = $scope.companyProgress.schoolYears
        if not newYears or newYears is '' or newYears is '0' or isNaN(newYears)
          $scope.schoolInfo.errorMessage = 'Please specify a year greater than 0.'
        else
          updateSchoolYearPromise = ZuriService.updateSchoolData $scope.participantRegistration.companyInformation.companyId + '/years-participated/update?value=' + newYears,
            failure: (response) ->
              $scope.schoolInfo.errorMessage = 'Process failed to save years entered'
            error: (response) ->
              $scope.schoolInfo.errorMessage = 'Error: ' + response.data.message
            success: (response) ->
              $scope.companyProgress.schoolYears = newYears
              #$scope.editSchoolYearsModal.close()
              
      $scope.updateSchoolChallenge = ->
        delete $scope.schoolChallengeInfo.errorMessage
        newChallenge = $scope.companyProgress.schoolChallenge
        if newChallenge is ''
          $scope.schoolChallengeInfo.errorMessage = 'Please select a challenge.'
        else
          updateSchoolChallengePromise = ZuriService.updateSchoolData $scope.participantRegistration.companyInformation.companyId + '/school-challenge/update?value=' + newChallenge,
            failure: (response) ->
              $scope.schoolChallengeInfo.errorMessage = 'Process failed to save challenge entered'
            error: (response) ->
              $scope.schoolChallengeInfo.errorMessage = 'Error: ' + response.data.message
            success: (response) ->
              $scope.companyProgress.schoolChallenge = newChallenge
              #$scope.editSchoolChallengeModal.close()

      $scope.updateSchoolChallengeLevel = ->
        delete $scope.schoolChallengeLevelInfo.errorMessage
        newChallengeLevel = $scope.companyProgress.schoolChallengeLevel
        if newChallengeLevel is ''
          $scope.schoolChallengeLevelInfo.errorMessage = 'Please select a challenge level.'
        else
          updateSchoolChallengeLevelPromise = ZuriService.updateSchoolData $scope.participantRegistration.companyInformation.companyId + '/school-goal/update?value=' + newChallengeLevel,
            failure: (response) ->
              $scope.schoolChallengeLevelInfo.errorMessage = 'Process failed to save challenge level entered'
            error: (response) ->
              $scope.schoolChallengeLevelInfo.errorMessage = 'Error: ' + response.data.message
            success: (response) ->
              $scope.companyProgress.schoolChallengeLevel = newChallengeLevel
              #$scope.editSchoolChallengeLevelModal.close()

      ZuriService.getSchool $scope.companyId,
        error: (response) ->
          $scope.studentsPledgedTotal = 0
          $scope.activity1amt = 0
          $scope.activity2amt = 0
          $scope.activity3amt = 0
        success: (response) ->
          $scope.studentsPledgedTotal = response.data.studentsPledged
          studentsPledgedActivities = response.data.studentsPledgedByActivity
          if studentsPledgedActivities['1']
            $scope.activity1amt = studentsPledgedActivities['1'].count
          else
            $scope.activity1amt = 0
          if studentsPledgedActivities['2']
            $scope.activity2amt = studentsPledgedActivities['2'].count
          else
            $scope.activity2amt = 0
          if studentsPledgedActivities['3']
            $scope.activity3amt = studentsPledgedActivities['3'].count
          else
            $scope.activity3amt = 0

      $scope.showMobileApp = ->
        $scope.viewMobileApp = $uibModal.open
          scope: $scope
          templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/modal/viewMobileApp.html'

      $scope.cancelMobileApp = ->
        $scope.viewMobileApp.close()
        
      getLeaderboards = ->
        BoundlessService.getLeaderboards $scope.companyId
        .then (response) ->
          teachers_raised = response.data.most_dollars_by_teacher
          angular.forEach teachers_raised, (teacher) ->
            grade = teacher.grade_name
            if grade is null
              grade = "N/A"
            $scope.topClassRaised.push
              name: teacher.teacher_name
              grade: grade
              raised: teacher.total | 0
              msg: 'Amount Raised'
          teachers_students = response.data.most_students_by_teacher
          angular.forEach teachers_students, (teacher) ->
            grade = teacher.grade_name
            if grade is null
              grade = "N/A"
            $scope.topClassStudents.push
              name: teacher.teacher_name
              grade: grade
              students: teacher.students | 0
              msg: '# Online Students'
          grade_raised = response.data.most_dollars_by_grade
          angular.forEach grade_raised, (sgrade) ->
            grade = sgrade.grade_name
            if grade is null
              grade = "N/A"
            $scope.topGradeRaised.push
              name: sgrade.teacher_name
              grade: grade
              raised: sgrade.total | 0
              msg: 'Amount Raised'
          grade_students = response.data.most_students_by_grade
          angular.forEach grade_students, (students) ->
            grade = students.grade_name
            if grade is null
              grade = "N/A"
            $scope.topGradeStudents.push
              name: students.teacher_name
              grade: grade
              students: students.students | 0
              msg: '# Students'

      getLeaderboards()
  ]
