angular.module 'trPcControllers'
  .controller 'NgPcDashboardViewCtrl', [
    '$rootScope'
    '$scope'
    '$sce'
    '$filter'
    '$timeout'
    '$uibModal'
    'APP_INFO'
    'BoundlessService'
    'TeamraiserParticipantService'
    'TeamraiserParticipantPageService'
    'NgPcTeamraiserRegistrationService'
    'NgPcTeamraiserProgressService'
    'NgPcTeamraiserTeamService'
    'NgPcTeamraiserGiftService'
    'NgPcContactService'
    'NgPcTeamraiserShortcutURLService'
    'NgPcInteractionService'
    'NgPcTeamraiserCompanyService'
    'NgPcTeamraiserSchoolService'
    'NgPcConstituentService'
    'NgPcSurveyService'
    'FacebookFundraiserService'
    'ZuriService'
    ($rootScope, $scope, $sce, $filter, $timeout, $uibModal, APP_INFO, BoundlessService, TeamraiserParticipantService, TeamraiserParticipantPageService, NgPcTeamraiserRegistrationService, NgPcTeamraiserProgressService, NgPcTeamraiserTeamService, NgPcTeamraiserGiftService, NgPcContactService, NgPcTeamraiserShortcutURLService, NgPcInteractionService, NgPcTeamraiserCompanyService, NgPcTeamraiserSchoolService, NgPcConstituentService, NgPcSurveyService, FacebookFundraiserService, ZuriService) ->
      $scope.dashboardPromises = []
      $scope.eventDate = ''
      $scope.moneyDueDate = ''
      $scope.schoolStudentGoal = ''
      $scope.schoolStudentReg = ''
      $scope.schoolStudentRegOnline = ''
      $scope.notifyName = ''
      $scope.notifyEmail = ''
      $scope.studentsPledgedTotal = ''
      $scope.activity1amt = ''
      $scope.activity2amt = ''
      $scope.activity3amt = ''
      $scope.schoolBadges = ''
      $scope.companyProgress = []
      $scope.companyId = $scope.participantRegistration.companyInformation.companyId
      theDate = new Date
      $scope.yearsList = [1..(theDate.getFullYear()-1978)] # 0 - 50
      
      $dataRoot = angular.element '[data-embed-root]'

      #setup social iframe
      urlPrefix = ''
      if $scope.tablePrefix is 'heartdev' or $scope.tablePrefix is 'heartnew'
        urlPrefix = 'load'
      else
        urlPrefix = 'loadprod'
      url = 'https://' + urlPrefix + '.boundlessfundraising.com/applications/ahatgr/social/app/ui/#/addsocial/' + $scope.consId + '/' + $scope.frId + '/' + $rootScope.authToken + '/' + $rootScope.sessionCookie + '?source=PCSocial'
      $scope.socialIframeURL = $sce.trustAsResourceUrl url

      if $scope.participantRegistration.companyInformation?.isCompanyCoordinator is 'true'
        BoundlessService.checkOOTDashboard $scope.frId + '/' + $scope.consId
        .then (response) ->
          $rootScope.hasOOTDashboard = response.data.coordinatorHasDashboard
          if $rootScope.hasOOTDashboard
            BoundlessService.getSchoolBadges $scope.frId + '/' + $scope.participantRegistration.companyInformation.companyId
            .then (response) ->
              $scope.schoolBadgesRegistrations = response.data.registration_badges
              $scope.schoolBadgesFundraising = response.data.fundraising_badges
              $scope.companyInfo.participantCount = response.data.students_registered
              $scope.companyProgress.goal = response.data.goal
              $scope.companyProgress.raised = response.data.total_amount
              $scope.companyProgress.raisedFormatted = $filter('currency')(response.data.total_amount, '$').replace(".00","")
              if $scope.companyProgress.goal isnt 0
                $scope.companyProgress.percent = Math.ceil(($scope.companyProgress.raised / $scope.companyProgress.goal) * 100)
                if $scope.companyProgress.percent > 100
                  $scope.companyProgress.percent = 100
        , (response) ->
          # TODO
      else
        $rootScope.hasOOTDashboard = true
      
      if $scope.participantRegistration.lastPC2Login is '0'
        if $scope.participantRegistration.companyInformation?.isCompanyCoordinator isnt 'true'
          $scope.firstLoginModal = $uibModal.open
            scope: $scope
            templateUrl: APP_INFO.rootPath + 'dist/middle-school/html/participant-center/modal/firstLogin.html'

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
                    participant.amountRaisedFormatted = $filter('currency')(participant.amountRaised / 100, '$').replace(".00","")
                    if participant.donationUrl
                      participant.donationFormId = participant.donationUrl.split('df_id=')[1].split('&')[0]
                    companyParticipants.push participant
                    totalFundraisers++
              setCompanyParticipants companyParticipants, totalNumberParticipants, totalFundraisers
      getCompanyParticipants()
      
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
                participantProgress.raisedFormatted = if participantProgress.raised then $filter('currency')(participantProgress.raised / 100, '$').replace(".00","") else '$0'
                participantProgress.goal = Number participantProgress.goal
                participantProgress.goalFormatted = if participantProgress.goal then $filter('currency')(participantProgress.goal / 100, '$').replace(".00","") else '$0'
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
                  teamProgress.raisedFormatted = if teamProgress.raised then $filter('currency')(teamProgress.raised / 100, '$').replace(".00","") else '$0'
                  teamProgress.goal = Number teamProgress.goal
                  teamProgress.goalFormatted = if teamProgress.goal then $filter('currency')(teamProgress.goal / 100, '$').replace(".00","") else '$0'
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
                  companyProgress.raisedFormatted = if companyProgress.raised then $filter('currency')(companyProgress.raised / 100, '$').replace(".00","") else '$0'
                  companyProgress.goal = Number companyProgress.goal
                  companyProgress.goalFormatted = if companyProgress.goal then $filter('currency')(companyProgress.goal / 100, '$').replace(".00","") else '$0'
                  companyProgress.percent = 0
                  if companyProgress.goal isnt 0
                    companyProgress.percent = Math.ceil((companyProgress.raised / companyProgress.goal) * 100)
                  if companyProgress.percent > 100
                    companyProgress.percent = 100
                  companyProgress.schoolYears = $scope.companyProgress?.schoolYears
                  companyProgress.schoolChallenge = $scope.companyProgress?.schoolChallenge
                  companyProgress.schoolChallengeLevel = $scope.companyProgress?.schoolChallengeLevel
                  $scope.companyProgress = companyProgress
            response
            getSchoolInformation()
        $scope.dashboardPromises.push fundraisingProgressPromise
        
      $scope.refreshFundraisingProgress()
      
      if $scope.prev1FrId
        NgPcTeamraiserProgressService.getProgress $scope.prev1FrId
          .then (response) ->
            if response.data.errorResponse
              angular.noop()
            else
              participantPrevProgress = response.data.getParticipantProgressResponse.personalProgress
              if not participantPrevProgress
                angular.noop()
              else
                participantPrevProgress.raised = Number participantPrevProgress.raised
                participantPrevProgress.raisedFormatted = if participantPrevProgress.raised then $filter('currency')(participantPrevProgress.raised / 100, '$').replace(".00","") else '$0'
                $scope.participantPrevProgress = participantPrevProgress
      
      $scope.emailChallenge = {}
      setEmailSampleText = ->
        sampleText = 'I\'ve made a commitment to raise money to keep hearts beating. I need your help because more money ' +
        'raised means more moms, dads, brothers, aunts and babies\' lives saved. Even the smallest donation can make a big difference.\n\n' +
        'Please make a donation and support me today!\n\n' +
        'Thank you in advance for your generosity,\n' +
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
            size: 'lg'
            templateUrl: APP_INFO.rootPath + 'dist/middle-school/html/participant-center/modal/editCoordinatorMessage.html'

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

      $scope.feedbackMessage =
        text: ''
        errorMessage: null
        message: ''
      ###
      feedbackSurveyParams = ($dataRoot.data 'feedback-survey').split ','
	
      $scope.postFeedbackMessage = ->
        $scope.postFeedbackMessageModal = $uibModal.open
          scope: $scope
          templateUrl: APP_INFO.rootPath + 'dist/middle-school/html/participant-center/modal/postFeedbackMessage.html'

      $scope.cancelPostFeedbackMessage = ->
        $scope.postFeedbackMessageModal.close()

      $scope.saveFeedbackMessage = ->
        NgPcSurveyService.submitSurvey 'survey_id=' + feedbackSurveyParams[0] + '&question_'+feedbackSurveyParams[1] + '=' + $scope.consId + '&question_'+feedbackSurveyParams[2] + '=' + $scope.eventInfo.name + '&question_'+feedbackSurveyParams[3] + '=' + ($scope.feedbackMessage?.text or '')
          .then (response) ->
            if response.data.submitSurveyResponse?.success == 'true'
              $scope.feedbackMessage.message = response.data.submitSurveyResponse?.thankYouPageContent
            else
              $scope.feedbackMessage.errorMessage = 'There was an error processing your feedback.'
              $scope.feedbackMessage.message = 'Please try again later.'
      ###
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
          templateUrl: APP_INFO.rootPath + 'dist/middle-school/html/participant-center/modal/editParticipantGoal.html'

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
          templateUrl: APP_INFO.rootPath + 'dist/middle-school/html/participant-center/modal/editTeamGoal.html'

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
          templateUrl: APP_INFO.rootPath + 'dist/middle-school/html/participant-center/modal/editSchoolGoal.html'

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

      $scope.schoolPlanInfo = {}
      $scope.showSchoolPlan = ->
        $scope.showSchoolPlanModal = $uibModal.open
          scope: $scope
          size: 'lg'
          templateUrl: APP_INFO.rootPath + 'dist/middle-school/html/participant-center/modal/viewSchoolPlan.html'

      $scope.cancelShowSchoolPlan = ->
        $scope.showSchoolPlanModal.close()
          
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
                $scope.personalPageUrlEsc = window.encodeURIComponent($scope.personalPageUrl)
            response
        $scope.dashboardPromises.push getParticipantShortcutPromise
      $scope.getParticipantShortcut()

      $scope.personalUrlInfo = {}

      $scope.editPersonalUrl = ->
        delete $scope.personalUrlInfo.errorMessage
        $scope.personalUrlInfo.updatedShortcut = $scope.participantShortcut.text or ''
        $scope.editPersonalUrlModal = $uibModal.open
          scope: $scope
          templateUrl: APP_INFO.rootPath + 'dist/middle-school/html/participant-center/modal/editParticipantUrl.html'

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
        #$scope.getTeamShortcut()

        $scope.teamUrlInfo = {}

        $scope.editTeamUrl = ->
          delete $scope.teamUrlInfo.errorMessage
          $scope.teamUrlInfo.updatedShortcut = $scope.teamShortcut.text or ''
          $scope.editTeamUrlModal = $uibModal.open
            scope: $scope
            templateUrl: APP_INFO.rootPath + 'dist/middle-school/html/participant-center/modal/editTeamUrl.html'

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
            templateUrl: APP_INFO.rootPath + 'dist/middle-school/html/participant-center/modal/editCompanyUrl.html'

        $scope.editCompanyUrlFirst = ->
          delete $scope.companyUrlInfo.errorMessage
          $scope.companyUrlInfo.updatedShortcut = $scope.companyShortcut.text or ''
          $scope.editCompanyUrlModal = $uibModal.open
            scope: $scope
            templateUrl: APP_INFO.rootPath + 'dist/middle-school/html/participant-center/modal/firstLoginCoord.html'

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

      ###
      $scope.prizes = []
      BoundlessService.getBadges $scope.frId + '/' + $scope.consId
        .then (response) ->
          prizes = response.data.prizes
          angular.forEach prizes, (prize) ->
            $scope.prizes.push
              id: prize.id
              label: prize.label
              sku: prize.sku
              status: prize.status
              earned: prize.earned_datetime
              earned_image_url: prize.earned_image_url
              non_earned_image_url: prize.non_earned_image_url
        , (response) ->
          # TODO
        $scope.personalChallenge = {}
      ###
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
        "1": "Think Positive - Write down something you're grateful for every day."
        "2": "Choose Kindness - Complete an act of kindness each day."
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

      $scope.schoolPlan = []
      ZuriService.getSchoolDetail '&school_id=' + $scope.participantRegistration.companyInformation.companyId + '&EventId=' + $scope.frId,
        failure: (response) ->
        error: (response) ->
        success: (response) ->
          if response.data.company[0] != "" and response.data.company[0] != null
            $scope.schoolPlan = response.data.company[0]
            $scope.hideAmount = $scope.schoolPlan.HideAmountRaised
            $scope.notifyName = $scope.schoolPlan.YMDName
            $scope.notifyEmail = $scope.schoolPlan.YMDEmail
            $scope.unconfirmedAmountRaised = $scope.schoolPlan.OfflineUnconfirmedRevenue
            $scope.highestGift = $scope.schoolPlan.HighestRecordedRaised
            $scope.top25school = $scope.schoolPlan.IsTop25School
            $scope.highestRaisedAmount = $scope.schoolPlan.HRR
            $scope.highestRaisedYear = $scope.schoolPlan.HRRYear

            if $scope.schoolPlan.EventStartDate != '0000-00-00'
              $scope.schoolPlan.EventStartDate = new Date($scope.schoolPlan.EventStartDate.replace(/-/g, "/") + ' 00:01')
            if $scope.schoolPlan.EventEndDate != '0000-00-00'
              $scope.schoolPlan.EventEndDate = new Date($scope.schoolPlan.EventEndDate.replace(/-/g, "/") + ' 00:01')
            if $scope.schoolPlan.DonationDueDate != '0000-00-00'
              $scope.schoolPlan.DonationDueDate = new Date($scope.schoolPlan.DonationDueDate.replace(/-/g, "/") + ' 00:01')
            if $scope.schoolPlan.KickOffDate != '0000-00-00'
              $scope.schoolPlan.KickOffDate = new Date($scope.schoolPlan.KickOffDate.replace(/-/g, "/") + ' 00:01')
            $scope.coordinatorPoints = JSON.parse($scope.schoolPlan.PointsDetail)
          else
            $rootScope.hideGifts = "N"	      
	
      $scope.putSchoolPlan = (event, sel) ->
        school = @schoolPlan
        if sel == 'ParticipatingNextYear' or sel == 'MaterialsNeeded'
          schoolParams = '&field_id=' + sel + '&value=' + $scope.schoolPlan[sel] + '&type=dropdown'
          ZuriService.schoolPlanData '&method=UpdateSchoolPlan&CompanyId=' + $scope.participantRegistration.companyInformation.companyId + '&EventId=' + $scope.frId + schoolParams,
            failure: (response) ->
            error: (response) ->
            success: (response) ->
        else
          if event.currentTarget.id == 'school_goal'
            $scope.schoolGoalInfo.goal = event.currentTarget.value
            $scope.updateSchoolGoal()
            $scope.getSchoolPlan()
          else
            switch event.currentTarget.type
              when 'date'
                schoolParams = '&field_id=' + event.currentTarget.id + '&value=' + event.currentTarget.value + '&type=' + event.currentTarget.type
              when 'checkbox'
                schoolParams = '&field_id=' + event.currentTarget.id + '&value=' + $scope.schoolPlan[event.currentTarget.id] + '&type=' + event.currentTarget.type
              when 'dropdown'
                schoolParams = '&field_id=' + event.currentTarget.id + '&value=' + event.currentTarget.value + '&type=' + event.currentTarget.type
              else
                schoolParams = '&field_id=' + event.currentTarget.id + '&value=' + school[event.currentTarget.id] + '&type=' + event.currentTarget.type
            ZuriService.schoolPlanData '&method=UpdateSchoolPlan&CompanyId=' + $scope.participantRegistration.companyInformation.companyId + '&EventId=' + $scope.frId + schoolParams,
              failure: (response) ->
              error: (response) ->
              success: (response) ->

      $scope.showMaterialTypes = ->
        $scope.showMaterialTypesModal = $uibModal.open
          scope: $scope
          size: 'lg'
          templateUrl: APP_INFO.rootPath + 'dist/middle-school/html/participant-center/modal/viewMaterialTypes.html'

      $scope.cancelShowMaterialsTypes = ->
        $scope.showMaterialTypesModal.close()
	
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

      interactionMoveMoreId = $dataRoot.data 'move-more-flag-id'

      $scope.moveMoreFlag =
        text: ''
        errorMessage: null
        successMessage: false
        message: ''
        interactionId: ''

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

      refreshFinnsMission = ->
        $scope.prizes = []
        $scope.coordinatorBadges = []
        $scope.prizesEarned = 0
        $rootScope.has_bonus = 0
        BoundlessService.getBadges $scope.frId + '/' + $scope.consId
        .then (response) ->
          prizes = response.data.prizes
          $rootScope.has_bonus = response.data.has_bonus
          final_url = ''
          angular.forEach prizes, (prize) ->
            if prize.mission_url_type == 'Donate' 
              final_url = 'Donation2?df_id=' + $scope.eventInfo.donationFormId + "&FR_ID=" + $scope.frId + "&PROXY_TYPE=20&PROXY_ID=" + $scope.consId
            if prize.mission_url_type == 'Personal' 
              final_url = 'TR?fr_id=' + $scope.frId + '&pg=personal&px=' + $scope.consId
            if prize.mission_url_type == 'Tab' 
              final_url = $scope.baseUrl + prize.mission_url
            if prize.mission_url_type == 'URL' 
              final_url = prize.mission_url
            if prize.mission_url_type == 'Quiz' 
              if $scope.tablePrefix == 'heartdev'
                final_url = 'https://tools.heart.org/aha_ahc23_dev/quiz/show/' + prize.mission_url + '?event_id=' + $scope.frId + '&user_id=' + $scope.consId + '&name=' + $scope.consNameFirst
              if $scope.tablePrefix == 'heartnew'
                final_url = 'https://tools.heart.org/aha_ahc23_testing/quiz/show/' + prize.mission_url + '?event_id=' + $scope.frId + '&user_id=' + $scope.consId + '&name=' + $scope.consNameFirst
              if $scope.tablePrefix == 'heart'
                final_url = 'https://tools.heart.org/aha_ahc23/quiz/show/' + prize.mission_url + '?event_id=' + $scope.frId + '&user_id=' + $scope.consId + '&name=' + $scope.consNameFirst
            if prize.mission_url_type == 'Modal' and prize.mission_url == 'app' 
              final_url = 'showMobileApp()'
            if prize.status != 0
              earned_status = 'Earned'
              hover_msg = prize.earned_hover
            else 
              earned_status = 'Unearned'
              hover_msg = prize.unearned_hover
            aria_label = prize.label + ": " + earned_status + " - " + hover_msg
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
              hover_msg: hover_msg
              aria_label: aria_label

            if prize.id == 3 or prize.id == 6 or prize.id == 9 or prize.id == 10
              if prize.id == 3
                prize.label = 'Made a Donation'
              if prize.id == 6
                prize.label = 'Sent Kickoff Email'
              if prize.id == 9
                prize.label = 'Mobile App User'
              if prize.id == 10
                prize.label = 'Updated Coordinator Page'
              $scope.coordinatorBadges.push
                id: prize.id
                status: prize.status
                label: prize.label
                earned_image_url: prize.earned_image_url
                not_earned_image_url: prize.non_earned_image_url
                aria_label: aria_label
              
            if prize.status != 0
              $scope.prizesEarned++
            
        , (response) ->
          # TODO
      refreshFinnsMission()

      $scope.showMobileApp = ->
        $scope.viewMobileApp = $uibModal.open
          scope: $scope
          templateUrl: APP_INFO.rootPath + 'dist/middle-school/html/participant-center/modal/viewMobileApp.html'

      $scope.cancelMobileApp = ->
        $scope.viewMobileApp.close()
        
      $scope.mouseover = (prize, xPos, yPos, sel, offset) ->
        document.getElementById("tRct").style.fill = "#800971"
        document.getElementById("tRct").x.baseVal.value = xPos
        document.getElementById("tRct").y.baseVal.value = yPos

        jQuery("#tTip div").attr("aria-label",$scope.prizes[prize].hover_msg).html($scope.prizes[prize].hover_msg)
        document.getElementById("tTip").setAttribute('x',xPos)
        document.getElementById("tTip").setAttribute('y',yPos)

        document.getElementById("tTri").setAttribute('points',(parseInt(xPos)+53+parseInt(offset)) + ' ' + (parseInt(yPos)+60) + ' ' + (parseInt(xPos)+62+parseInt(offset)) + ' ' + (parseInt(yPos)+60) + ' ' + (parseInt(xPos)+58+parseInt(offset)) + ' ' + (parseInt(yPos)+66))

      $scope.mouseout = ->
        document.getElementById("tRct").x.baseVal.value = -99999
        jQuery("#tTip div").html("")
        document.getElementById("tTri").setAttribute('points','0 0 0 0 0 0')


      $scope.mouseoverm = (prize, xPos, yPos, sel, offset) ->
        document.getElementById("tRctm").style.fill = "#800971"
        document.getElementById("tRctm").x.baseVal.value = xPos
        document.getElementById("tRctm").y.baseVal.value = yPos

        jQuery("#tTipm div").attr("aria-label",$scope.prizes[prize].hover_msg).html($scope.prizes[prize].hover_msg)
        document.getElementById("tTipm").setAttribute('x',xPos)
        document.getElementById("tTipm").setAttribute('y',yPos)

        document.getElementById("tTrim").setAttribute('points', (parseInt(xPos) + 83 + parseInt(offset)) + ' ' + (parseInt(yPos) + 100) + ' ' + (parseInt(xPos) + 97 + parseInt(offset)) + ' ' + (parseInt(yPos) + 100) + ' ' + (parseInt(xPos) + 92 + parseInt(offset)) + ' ' + (parseInt(yPos) + 106))

      $scope.mouseoutm = ->
        document.getElementById("tRctm").x.baseVal.value = -99999
        jQuery("#tTipm div").html("")
        document.getElementById("tTrim").setAttribute('points','0 0 0 0 0 0')

      $scope.personalPagePhoto1 = 
        defaultUrl: APP_INFO.rootPath + 'dist/middle-school/image/fy22/personal-default.jpg'

      $scope.editPersonalPhoto1 = ->
        delete $scope.updatePersonalPhoto1Error
        $scope.editPersonalPhoto1Modal = $uibModal.open
          scope: $scope
          templateUrl: APP_INFO.rootPath + 'dist/middle-school/html/modal/editPersonalPhoto1.html'
      
      $scope.closePersonalPhoto1Modal = ->
        delete $scope.updatePersonalPhoto1Error
        $scope.editPersonalPhoto1Modal.close()
      
      $scope.cancelEditPersonalPhoto1 = ->
        $scope.closePersonalPhoto1Modal()
      
      $scope.deletePersonalPhoto1 = (e) ->
        if e
          e.preventDefault()
        angular.element('.js--delete-personal-photo-1-form').submit()
        false
      
      window.trPageEdit =
        uploadPhotoError: (response) ->
          errorResponse = response.errorResponse
          photoNumber = errorResponse.photoNumber
          errorCode = errorResponse.code
          errorMessage = errorResponse.message
          
          if errorCode is '5'
            window.location = luminateExtend.global.path.secure + 'UserLogin?NEXTURL=' + encodeURIComponent('TR?fr_id=' + $scope.frId + '&pg=personal&px=' + $scope.participantId)
          else
            if photoNumber is '1'
              $scope.updatePersonalPhoto1Error =
                message: errorMessage
            if not $scope.$$phase
              $scope.$apply()
        uploadPhotoSuccess: (response) ->
          delete $scope.updatePersonalPhoto1Error
          if not $scope.$$phase
            $scope.$apply()
          BoundlessService.logPersonalPageUpdated()
          successResponse = response.successResponse
          photoNumber = successResponse.photoNumber
          
          TeamraiserParticipantPageService.getPersonalPhotos
            error: (response) ->
              # TODO
            success: (response) ->
              photoItems = response.getPersonalPhotosResponse?.photoItem
              if photoItems
                photoItems = [photoItems] if not angular.isArray photoItems
                angular.forEach photoItems, (photoItem) ->
                  photoUrl = photoItem.customUrl
                  photoCaption = photoItem.caption
                  if not photoCaption or not angular.isString(photoCaption)
                    photoCaption = ''
                  if photoItem.id is '1'
                    $scope.personalPagePhoto1.customUrl = photoUrl
                    $scope.personalPagePhoto1.caption = photoCaption
              if not $scope.$$phase
                $scope.$apply()
              $scope.closePersonalPhoto1Modal()

      TeamraiserParticipantPageService.getPersonalPhotos
        error: (response) ->
        success: (response) ->
          photoItems = if (ref7 = response.getPersonalPhotosResponse) != null then ref7.photoItem else undefined
          if photoItems
            if !angular.isArray(photoItems)
              photoItems = [ photoItems ]
            angular.forEach photoItems, (photoItem) ->
              photoUrl = photoItem.customUrl
              photoCaption = photoItem.caption
              if !photoCaption or !angular.isString(photoCaption)
                photoCaption = ''
              if photoItem.id == '1'
                $scope.personalPagePhoto1.customUrl = photoUrl
                $scope.personalPagePhoto1.caption = photoCaption

      $scope.personalPageContent =
        mode: 'view'
        serial: new Date().getTime()
        textEditorToolbar: [
          [
            'bold'
            'italics'
            'underline'
          ]
          [
            'ul'
            'ol'
          ]
          [
            'insertImage'
            'insertLink'
          ]
          [
            'undo'
            'redo'
          ]
        ]

      TeamraiserParticipantPageService.getPersonalPageInfo
        error: (response) ->
          # TODO
        success: (response) ->
          $scope.personalPageInfo  = response.getPersonalPageResponse;
          $scope.personalPageContent.rich_text = $scope.personalPageInfo.personalPage.richText
          $scope.personalPageContent.ng_rich_text = $scope.personalPageInfo.personalPage.richText
            
          richText = $scope.personalPageContent.ng_rich_text
          $richText = jQuery '<div />',
            html: richText
          richText = $richText.html()
          richText = richText.replace(/<strong>/g, '<b>').replace(/<strong /g, '<b ').replace /<\/strong>/g, '</b>'
          .replace(/<em>/g, '<i>').replace(/<em /g, '<i ').replace /<\/em>/g, '</i>'
          $scope.personalPageContent.ng_rich_text = richText 
          if not $scope.$$phase
            $scope.$apply()
      
      $scope.editPersonalPageContent = ->
        richText = $scope.personalPageContent.ng_rich_text
        $richText = jQuery '<div />',
          html: richText
        richText = $richText.html()
        richText = richText.replace(/<strong>/g, '<b>').replace(/<strong /g, '<b ').replace /<\/strong>/g, '</b>'
        .replace(/<em>/g, '<i>').replace(/<em /g, '<i ').replace /<\/em>/g, '</i>'
        $scope.personalPageContent.ng_rich_text = richText
        $scope.personalPageContent.mode = 'edit'
        $timeout ->
          angular.element('[ta-bind][contenteditable]').focus()
        , 500
      
      $scope.resetPersonalPageContent = ->
        $scope.personalPageContent.ng_rich_text = $scope.personalPageContent.rich_text
        $scope.personalPageContent.mode = 'view'
      
      $scope.savePersonalPageContent = (isRetry) ->
        richText = $scope.personalPageContent.ng_rich_text
        $richText = jQuery '<div />', 
          html: richText
        richText = $richText.html()
        richText = richText.replace /<\/?[A-Z]+.*?>/g, (m) ->
          m.toLowerCase()
        .replace(/<font>/g, '<span>').replace(/<font /g, '<span ').replace /<\/font>/g, '</span>'
        .replace(/<b>/g, '<strong>').replace(/<b /g, '<strong ').replace /<\/b>/g, '</strong>'
        .replace(/<i>/g, '<em>').replace(/<i /g, '<em ').replace /<\/i>/g, '</em>'
        .replace(/<u>/g, '<span style="text-decoration: underline;">').replace(/<u /g, '<span style="text-decoration: underline;" ').replace /<\/u>/g, '</span>'
        .replace /[\u00A0-\u9999\&]/gm, (i) ->
          '&#' + i.charCodeAt(0) + ';'
        .replace /&#38;/g, '&'
        .replace /<!--[\s\S]*?-->/g, ''
        TeamraiserParticipantPageService.updatePersonalPageInfo 'rich_text=' + encodeURIComponent(richText),
          error: ->
            # TODO
          success: (response) ->
            if response.teamraiserErrorResponse
              errorCode = response.teamraiserErrorResponse.code
              if errorCode is '2647' and not isRetry
                $scope.personalPageContent.ng_rich_text = response.teamraiserErrorResponse.body
                $scope.savePageContent true
            else
              isSuccess = response.updatePersonalPageResponse?.success is 'true'
              if not isSuccess
                # TODO
              else
                $scope.personalPageContent.rich_text = richText
                $scope.personalPageContent.ng_rich_text = richText
                $scope.personalPageContent.mode = 'view'
                BoundlessService.logPersonalPageUpdated()
                if not $scope.$$phase
                  $scope.$apply()
  ]
