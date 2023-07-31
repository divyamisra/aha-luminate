angular.module 'ahaLuminateControllers'
  .controller 'CompanyPageCtrl', [
    '$scope'
    '$rootScope'
    '$location'
    '$filter'
    '$timeout'
    '$uibModal'
    'APP_INFO'
    'TeamraiserCompanyService'
    'TeamraiserTeamService'
    'TeamraiserParticipantService'
    'BoundlessService'
    'ZuriService'
    'TeamraiserRegistrationService'
    'TeamraiserCompanyPageService'
    'PageContentService'
    '$sce'
    '$http'
    ($scope, $rootScope, $location, $filter, $timeout, $uibModal, APP_INFO, TeamraiserCompanyService, TeamraiserTeamService, TeamraiserParticipantService, BoundlessService, ZuriService, TeamraiserRegistrationService, TeamraiserCompanyPageService, PageContentService, $sce, $http) ->
      $scope.companyId = $location.absUrl().split('company_id=')[1].split('&')[0].split('#')[0]
      $rootScope.companyName = ''
      $scope.totalTeams = ''
      $scope.teamId = ''
      $scope.hideAmount = ''
      $scope.notifyName = ''
      $scope.notifyEmail = ''
      $scope.totalTeams = ''
      $scope.teamId = ''
      $scope.studentsPledgedTotal = ''
      $scope.activity1amt = ''
      $scope.activity2amt = ''
      $scope.activity3amt = ''
      $scope.topClassRaised = []
      $scope.topClassStudents = []
      $scope.schoolChallenge = ''
      $scope.schoolChallengeGoal = 0
      $scope.schoolYears = 0
      $scope.unconfirmedAmountRaised = 0
      $scope.schoolBadgesRegistrations = []
      $scope.schoolBadgesFundraising = []
      
      $scope.trustHtml = (html) ->
        return $sce.trustAsHtml(html)
           
      getLocalSponsors = ->
        if $scope.parentCompanyId and $scope.parentCompanyId isnt ''
          PageContentService.getPageContent 'middle_school_local_sponsors_' + $scope.parentCompanyId
            .then (response) ->
              if response.includes('No data') is true
                $scope.localSponsorShow = false
              else
                img = response.split('/>')[0]
                if img is undefined
                  $scope.localSponsorShow = false
                else
                  alt = img.split('alt="')
                  src = alt[0].split('src="')
                  $scope.localSponsorShow = true
                  $scope.localSponsorImageSrc = src[1].split('"')[0]
                  $scope.localSponsorImageAlt = alt[1].split('"')[0]
      getLocalSponsors()
      $scope.$watch 'parentCompanyId', ->
        getLocalSponsors()

      ZuriService.getSchoolChallenges $scope.companyId,
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

      BoundlessService.getSchoolRollupTotals $scope.companyId
        .then (response) ->
          if response.data.status isnt 'success'
            $scope.totalEmails = 0
          else
            totals = response.data.totals
            totalEmails = totals?.total_online_emails_sent or '0'
            $scope.totalEmails = Number totalEmails
            if $scope.totalEmails .toString().length > 4
              $scope.totalEmails  = Math.round($scope.totalEmails  / 1000) + 'K'
      
      setCompanyProgress = (amountRaised, goal) ->
        $scope.companyProgress = 
          amountRaised: if amountRaised then Number(amountRaised) else 0
          goal: if goal then Number(goal) else 0
        $scope.companyProgress.amountRaisedFormatted = $filter('currency')($scope.companyProgress.amountRaised / 100, '$')
        $scope.companyProgress.goalFormatted = $filter('currency')($scope.companyProgress.goal / 100, '$')
        $scope.companyProgress.percent = 0
        if not $scope.$$phase
          $scope.$apply()
        $timeout ->
          percent = $scope.companyProgress.percent
          if $scope.companyProgress.goal isnt 0
            percent = Math.ceil(($scope.companyProgress.amountRaised / $scope.companyProgress.goal) * 100)
          if percent > 100
            percent = 100
          $scope.companyProgress.percent = percent
          if not $scope.$$phase
            $scope.$apply()
          getBoundlessSchoolData()
        , 500
        
      getCompanyTotals = ->
        TeamraiserCompanyService.getCompanies 'company_id=' + $scope.companyId,
          error: ->
            # TODO
          success: (response) ->
            companies = response.getCompaniesResponse.company
            if not companies
              # TODO
            else
              companies = [companies] if not angular.isArray companies
              participantCount = companies[0].participantCount or '0'
              $scope.participantCount = Number participantCount
              totalTeams = companies[0].teamCount or '0'
              totalTeams = Number totalTeams
              eventId = companies[0].eventId
              amountRaised = companies[0].amountRaised
              goal = companies[0].goal
              name = companies[0].companyName
              coordinatorId = companies[0].coordinatorId
              $rootScope.companyName = name
              setCompanyProgress amountRaised, goal

              ZuriService.getSchoolDetail '&school_id=' + $scope.companyId + '&EventId=' + $scope.frId,
                failure: (response) ->
                error: (response) ->
                success: (response) ->
                  if response.data.company[0] != ""
                    $scope.schoolPlan = response.data.company[0]
                    $scope.hideAmount = $scope.schoolPlan.HideAmountRaised
                    $scope.notifyName = $scope.schoolPlan.YMDName
                    $scope.notifyEmail = $scope.schoolPlan.YMDEmail
                    $scope.unconfirmedAmountRaised = $scope.schoolPlan.OfflineUnconfirmedRevenue
                    $scope.highestGift = $scope.schoolPlan.HighestRecordedRaised
                    $scope.top25school = $scope.schoolPlan.IsTop25School
                    $scope.highestRaisedAmount = $scope.schoolPlan.HRR
                    $scope.highestRaisedYear = $scope.schoolPlan.HRRYear

                    if $scope.schoolPlan.EventStartDate != undefined
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
                      $scope.schoolPlan.EventStartDate = ''
                      $scope.schoolPlan.DonationDueDate = ''
                      $scope.schoolPlan.KickOffDate = ''
                  
              if coordinatorId and coordinatorId isnt '0' and eventId
                TeamraiserCompanyService.getCoordinatorQuestion coordinatorId, eventId
                  .then (response) ->
                    if totalTeams is 1
                      $scope.teamId = response.data.coordinator?.team_id
      getCompanyTotals()
      
      $scope.companyTeams = {}
      setCompanyTeams = (teams, totalNumber) ->
        $scope.companyTeams.teams = teams or []
        totalNumber = totalNumber or 0
        $scope.companyTeams.totalNumber = Number totalNumber
        $scope.totalTeams = totalNumber
        if not $scope.$$phase
          $scope.$apply()
      getCompanyTeams = ->
        TeamraiserTeamService.getTeams 'team_company_id=' + $scope.companyId + '&list_page_size=500',
          error: ->
            setCompanyTeams()
          success: (response) ->
            companyTeams = response.getTeamSearchByInfoResponse.team
            if companyTeams
              companyTeams = [companyTeams] if not angular.isArray companyTeams
              angular.forEach companyTeams, (companyTeam) ->
                companyTeam.amountRaised = Number companyTeam.amountRaised
                companyTeam.amountRaisedFormatted = $filter('currency')(companyTeam.amountRaised / 100, '$')
              totalNumberTeams = response.getTeamSearchByInfoResponse.totalNumberResults
              setCompanyTeams companyTeams, totalNumberTeams
      getCompanyTeams()
      
      $scope.companyParticipants = {}
      setCompanyParticipants = (participants, totalNumber, totalFundraisers) ->
        $scope.companyParticipants.participants = participants or []
        totalNumber = totalNumber or 0
        $scope.companyParticipants.totalNumber = Number totalNumber
        $scope.companyParticipants.totalFundraisers = Number totalFundraisers
        if not $scope.$$phase
          $scope.$apply()
      getCompanyParticipants = ->
        TeamraiserParticipantService.getParticipants 'team_name=' + encodeURIComponent('%') + '&first_name=' + encodeURIComponent('%%') + '&last_name=' + encodeURIComponent('%') + '&list_filter_column=team.company_id&list_filter_text=' + $scope.companyId + '&list_sort_column=total&list_ascending=false&list_page_size=500',
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
                  if participant.name?.first and participant.amountRaised > 1
                    participant.firstName = participant.name.first
                    participant.lastName = participant.name.last || ""
                    participant.name.last = participant.lastName.substring(0, 1) + '.'
                    participant.fullName = participant.name.first + ' ' + participant.name.last
                    participant.amountRaisedFormatted = $filter('currency')(participant.amountRaised / 100, '$')
                    if participant.donationUrl
                      participant.donationFormId = participant.donationUrl.split('df_id=')[1].split('&')[0]
                    companyParticipants.push participant
                    totalFundraisers++
              setCompanyParticipants companyParticipants, totalNumberParticipants, totalFundraisers
      getCompanyParticipants()
      
      if $scope.consId
        TeamraiserRegistrationService.getRegistration
          success: (response) ->
            participantRegistration = response.getRegistrationResponse?.registration
            if participantRegistration
              $scope.participantRegistration = participantRegistration
      
      $scope.companyPagePhoto1 =
        defaultUrl: APP_INFO.rootPath + 'dist/middle-school/image/fy23/company-default.jpg'
      
      $scope.editCompanyPhoto1 = ->
        delete $scope.updateCompanyPhoto1Error
        $scope.editCompanyPhoto1Modal = $uibModal.open
          scope: $scope
          templateUrl: APP_INFO.rootPath + 'dist/middle-school/html/modal/editCompanyPhoto1.html'
      
      $scope.closeCompanyPhoto1Modal = ->
        delete $scope.updateCompanyPhoto1Error
        $scope.editCompanyPhoto1Modal.close()
      
      $scope.cancelEditCompanyPhoto1 = ->
        $scope.closeCompanyPhoto1Modal()
      
      $scope.deleteCompanyPhoto1 = (e) ->
        if e
          e.preventDefault()
        angular.element('.js--delete-company-photo-1-form').submit()
        false
      
      window.trPageEdit =
        uploadPhotoError: (response) ->
          errorResponse = response.errorResponse
          photoNumber = errorResponse.photoNumber
          errorCode = errorResponse.code
          errorMessage = errorResponse.message
          
          if errorCode is '5'
            window.location = luminateExtend.global.path.secure + 'UserLogin?NEXTURL=' + encodeURIComponent('TR?fr_id=' + $scope.frId + '&pg=company&company_id=' + $scope.companyId)
          else
            if photoNumber is '1'
              $scope.updateCompanyPhoto1Error =
                message: errorMessage
            if not $scope.$$phase
              $scope.$apply()
        uploadPhotoSuccess: (response) ->
          delete $scope.updateCompanyPhoto1Error
          if not $scope.$$phase
            $scope.$apply()
          successResponse = response.successResponse
          photoNumber = successResponse.photoNumber
          
          TeamraiserCompanyPageService.getCompanyPhoto
            error: (response) ->
              # TODO
            success: (response) ->
              photoItems = response.getCompanyPhotoResponse?.photoItem
              if photoItems
                photoItems = [photoItems] if not angular.isArray photoItems
                angular.forEach photoItems, (photoItem) ->
                  photoUrl = photoItem.customUrl
                  if photoItem.id is '1'
                    $scope.companyPagePhoto1.customUrl = photoUrl
              if not $scope.$$phase
                $scope.$apply()
              $scope.closeCompanyPhoto1Modal()
      
      $scope.companyPageContent =
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
        rich_text: angular.element('.js--default-page-content').html()
        ng_rich_text: angular.element('.js--default-page-content').html()
      
      $scope.editCompanyPageContent = ->
        richText = $scope.companyPageContent.ng_rich_text
        $richText = jQuery '<div />',
          html: richText
        richText = $richText.html()
        richText = richText.replace(/<strong>/g, '<b>').replace(/<strong /g, '<b ').replace /<\/strong>/g, '</b>'
        .replace(/<em>/g, '<i>').replace(/<em /g, '<i ').replace /<\/em>/g, '</i>'
        $scope.companyPageContent.ng_rich_text = richText
        $scope.companyPageContent.mode = 'edit'
        $timeout ->
          angular.element('[ta-bind][contenteditable]').focus()
        , 100
      
      $scope.resetCompanyPageContent = ->
        $scope.companyPageContent.ng_rich_text = $scope.companyPageContent.rich_text
        $scope.companyPageContent.mode = 'view'
      
      $scope.saveCompanyPageContent = (isRetry) ->
        richText = $scope.companyPageContent.ng_rich_text
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
        TeamraiserCompanyPageService.updateCompanyPageInfo 'rich_text=' + encodeURIComponent(richText),
          error: ->
            # TODO
          success: (response) ->
            if response.teamraiserErrorResponse
              errorCode = response.teamraiserErrorResponse.code
              if errorCode is '2647' and not isRetry
                $scope.companyPageContent.ng_rich_text = response.teamraiserErrorResponse.body
                $scope.savePageContent true
            else
              isSuccess = response.updateCompanyPageResponse?.success is 'true'
              if not isSuccess
                # TODO
              else
                $scope.companyPageContent.rich_text = richText
                $scope.companyPageContent.ng_rich_text = richText
                $scope.companyPageContent.mode = 'view'
                if not $scope.$$phase
                  $scope.$apply()
                  
      ZuriService.getSchoolData $scope.companyId,
        error: (response) ->
          # TO DO
        success: (response) ->
          if response.data.data.length > 0
            angular.forEach response.data.data, (meta, key) ->
              if meta.name == 'years-participated'
                $scope.schoolYears = meta.value
                
      ZuriService.getSchoolData $scope.companyId,
        error: (response) ->
          # TO DO
        success: (response) ->
          if response.data.data.length > 0
            angular.forEach response.data.data, (meta, key) ->
              if meta.name == 'school-challenge'
                $scope.schoolChallenge = meta.value
              if meta.name == 'school-goal'
                $scope.schoolChallengeGoal = meta.value
              if meta.name == 'years-participated'
                $scope.schoolYears = meta.value
      
      getBoundlessSchoolData = () ->
        BoundlessService.getSchoolBadges $scope.frId + '/' + $scope.companyId
        .then (response) ->
          $scope.companyProgress = 
            amountRaised: if response.data.total_amount then Number(response.data.total_amount) else 0
            goal: if response.data.goal then Number(response.data.goal) else 0
          $scope.companyProgress.amountRaisedFormatted = $filter('currency')($scope.companyProgress.amountRaised, '$')
          $scope.companyProgress.goalFormatted = $filter('currency')($scope.companyProgress.goal, '$')
          $scope.companyProgress.percent = 0
          if not $scope.$$phase
            $scope.$apply()
          $timeout ->
            percent = $scope.companyProgress.percent
            if $scope.companyProgress.goal isnt 0
              percent = Math.ceil(($scope.companyProgress.amountRaised / $scope.companyProgress.goal) * 100)
            if percent > 100
              percent = 100
            $scope.companyProgress.percent = percent
            if not $scope.$$phase
              $scope.$apply()

  ]
