angular.module 'ahaLuminateControllers'
  .controller 'CompanyPageCtrl', [
    '$scope'
    '$rootScope'
    '$location'
    '$filter'
    '$timeout'
    '$sce'
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
    ($scope, $rootScope, $location, $filter, $timeout, $sce, $uibModal, APP_INFO, TeamraiserCompanyService, TeamraiserTeamService, TeamraiserParticipantService, BoundlessService, ZuriService, TeamraiserRegistrationService, TeamraiserCompanyPageService, PageContentService) ->
      $scope.companyId = $location.absUrl().split('company_id=')[1].split('&')[0].split('#')[0]
      $rootScope.companyName = ''
      $scope.eventDate = ''
      $scope.totalTeams = ''
      $scope.teamId = ''
      $scope.activity1amt = ''
      $scope.activity2amt = ''
      
      $scope.trustHtml = (html) ->
        return $sce.trustAsHtml(html)
      
      getLocalSponsors = ->
        if $scope.parentCompanyId and $scope.parentCompanyId isnt ''
          PageContentService.getPageContent 'district_heart_challenge_local_sponsors_' + $scope.parentCompanyId
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
      
      BoundlessService.getDistrictRollupTotals $scope.companyId
        .then (response) ->
          if response.data.status isnt 'success'
            $scope.activity2amt = 0
          else
            totals = response.data.totals
            totalChallengesTaken = totals?.total_challenge_taken_students or '0'
            $scope.activity2amt = Number totalChallengesTaken
      
      setCompanyProgress = (amountRaised, goal) ->
        $scope.companyProgress = 
          amountRaised: if amountRaised then Number(amountRaised) else 0
          goal: if goal then Number(goal) else 0
        $scope.companyProgress.amountRaisedFormatted = $filter('currency')($scope.companyProgress.amountRaised / 100, '$').replace '.00', ''
        $scope.companyProgress.goalFormatted = $filter('currency')($scope.companyProgress.goal / 100, '$').replace '.00', ''
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
              if $scope.participantCount.toString().length > 4
                $scope.participantCount = Math.round($scope.participantCount / 1000) + 'K'
              totalTeams = companies[0].teamCount or '0'
              totalTeams = Number totalTeams
              eventId = companies[0].eventId
              amountRaised = companies[0].amountRaised
              goal = companies[0].goal
              name = companies[0].companyName
              coordinatorId = companies[0].coordinatorId
              $rootScope.companyName = name
              setCompanyProgress amountRaised, goal
              
              if coordinatorId and coordinatorId isnt '0' and eventId
                TeamraiserCompanyService.getCoordinatorQuestion coordinatorId, eventId
                  .then (response) ->
                    participantGoal = response.data.coordinator?.participant_goal or '0'
                    participantGoal = participantGoal.replace /,/g, ''
                    if isNaN participantGoal
                      $scope.participantGoal = 0
                    else
                      $scope.participantGoal = Number participantGoal
                    $scope.eventDate = response.data.coordinator?.event_date
                    if totalTeams is 1
                      $scope.teamId = response.data.coordinator?.team_id
      getCompanyTotals()
      
      $scope.companyTeams = {}
      $scope.companyTeamSearch =
        team_name: ''
        ng_team_name: ''
      $scope.teamListSetting =
        sortColumn: 'amountRaised'
        sortAscending: false
        totalNumber: 0
        currentPage: 1
        paginationItemsPerPage: 4
        paginationMaxSize: 4
      setCompanyTeams = (teams, totalNumber) ->
        $scope.companyTeams.teams = teams or []
        totalNumber = totalNumber or 0
        $scope.companyTeamSearch.totalTeams = totalNumber
        if not $scope.companyTeams.totalNumber
          $scope.companyTeams.totalNumber = Number totalNumber
        $scope.teamListSetting.totalNumber = Number totalNumber
        if not $scope.$$phase
          $scope.$apply()
      getCompanyTeams = (teamName) ->
        delete $scope.companyTeamSearch.totalTeams
        TeamraiserTeamService.getTeams 'team_company_id=' + $scope.companyId + '&team_name=' + encodeURIComponent(teamName) + '&list_sort_column=order&list_ascending=true&list_page_size=500',
          error: ->
            setCompanyTeams()
          success: (response) ->
            companyTeams = response.getTeamSearchByInfoResponse?.team
            if not companyTeams
              setCompanyTeams()
            else
              companyTeams = [companyTeams] if not angular.isArray companyTeams
              angular.forEach companyTeams, (companyTeam) ->
                companyTeam.amountRaised = Number companyTeam.amountRaised
                companyTeam.amountRaisedFormatted = $filter('currency')(companyTeam.amountRaised / 100, '$').replace '.00', ''
              totalNumberTeams = response.getTeamSearchByInfoResponse.totalNumberResults
              setCompanyTeams companyTeams, totalNumberTeams
        
        ZuriService.getDistrictTeams $scope.companyId,
          error: (response) ->
            $scope.activity1amt = 0
            $scope.companyTeams.teamMinsActivityMap = []
          success: (response) ->
            totalMinsActivity = response.data.data?.total or '0'
            totalMinsActivity = Number totalMinsActivity
            $scope.activity1amt = totalMinsActivity
            if $scope.activity1amt.toString().length > 4
              $scope.activity1amt = Math.round($scope.activity1amt / 1000) + 'K'
            teamMinsActivityMap = response.data.data?.list or []
            $scope.companyTeams.teamMinsActivityMap = teamMinsActivityMap
      getCompanyTeams '%'
      
      setTeamsMinsActivity = ->
        teams = $scope.companyTeams.teams
        teamMinsActivityMap = $scope.companyTeams.teamMinsActivityMap
        if teams and teams.length > 0 and teamMinsActivityMap
          angular.forEach teams, (team, teamIndex) ->
            minsActivity = 0
            if teamMinsActivityMap.length > 0
              angular.forEach teamMinsActivityMap, (teamMinsActivityData) ->
                if teamMinsActivityData.team_id and Number(teamMinsActivityData.team_id) is Number(team.id)
                  minsActivity = teamMinsActivityData.minutes or 0
            $scope.companyTeams.teams[teamIndex].minsActivity = minsActivity
      setTeamsMinsActivity()
      $scope.$watchGroup ['companyTeams.teams', 'companyTeams.teamMinsActivityMap'], ->
        setTeamsMinsActivity()
      
      $scope.searchCompanyTeams = ->
        $scope.companyTeamSearch.team_name = $scope.companyTeamSearch.ng_team_name
        getCompanyTeams $scope.companyTeamSearch.ng_team_name
        $scope.teamListSetting.sortColumn = 'amountRaised'
        $scope.teamListSetting.sortAscending = false
      
      $scope.orderTeams = (sortColumn) ->
        teams = $scope.companyTeams.teams
        $scope.teamListSetting.sortAscending = !$scope.teamListSetting.sortAscending
        if $scope.teamListSetting.sortColumn isnt sortColumn
          $scope.teamListSetting.sortAscending = false
        $scope.teamListSetting.sortColumn = sortColumn
        $scope.companyTeams.teams = $filter('orderBy') teams, sortColumn, !$scope.teamListSetting.sortAscending
        $scope.teamListSetting.currentPage = 1 
      
      $scope.paginateTeams = (value) ->
        begin = ($scope.teamListSetting.currentPage - 1) * $scope.teamListSetting.paginationItemsPerPage
        end = begin + $scope.teamListSetting.paginationItemsPerPage
        index = $scope.companyTeams.teams.indexOf value
        begin <= index and index < end
      
      $scope.companyParticipantSearch =
        first_name: ''
        ng_first_name: ''
        last_name: ''
        ng_last_name: ''
      $scope.companyParticipants = []
      $scope.participantListSetting =
        sortColumn: 'amountRaised'
        sortAscending: false
        totalNumber: 0
        currentPage: 1
        paginationItemsPerPage: 4
        paginationMaxSize: 4
      setCompanyParticipants = (participants, totalNumber) ->
        $scope.companyParticipants.participants = participants or []
        totalNumber = totalNumber or 0
        $scope.companyParticipantSearch.totalParticipants = totalNumber
        if not $scope.companyParticipants.totalNumber
          $scope.companyParticipants.totalNumber = Number totalNumber
        $scope.participantListSetting.totalNumber = Number totalNumber
        if not $scope.$$phase
          $scope.$apply()
      getCompanyParticipants = (first, last)->
        delete $scope.companyParticipantSearch.totalParticipants
        TeamraiserParticipantService.getParticipants 'team_name=' + encodeURIComponent('%') + '&first_name=' + encodeURIComponent(first) + '&last_name=' + encodeURIComponent(last) + '&list_filter_column=team.company_id&list_filter_text=' + $scope.companyId + '&list_sort_column=total&list_ascending=false&list_page_size=500',
            error: ->
              setCompanyParticipants()
            success: (response) ->
              participants = response.getParticipantsResponse?.participant
              companyParticipants = []
              if not participants
                setCompanyParticipants()
              else
                participants = [participants] if not angular.isArray participants
                angular.forEach participants, (participant) ->
                  if participant.name?.first
                    participant.firstName = participant.name.first
                    participant.lastName = participant.name.last
                    participant.fullName = participant.name.first + ' ' + participant.name.last
                    participant.amountRaised = Number participant.amountRaised
                    participant.amountRaisedFormatted = $filter('currency')(participant.amountRaised / 100, '$').replace '.00', ''
                    if participant.donationUrl
                      participant.donationFormId = participant.donationUrl.split('df_id=')[1].split('&')[0]
                    companyParticipants.push participant
              totalNumberParticipants = response.getParticipantsResponse.totalNumberResults
              setCompanyParticipants companyParticipants, totalNumberParticipants
        ZuriService.getDistrictParticipants $scope.companyId,
          error: (response) ->
            $scope.activity1amt = 0
            $scope.companyParticipants.participantMinsActivityMap = []
          success: (response) ->
            totalMinsActivity = response.data.data?.total or '0'
            totalMinsActivity = Number totalMinsActivity
            participantMinsActivityMap = response.data.data?.list or []
            $scope.companyParticipants.participantMinsActivityMap = participantMinsActivityMap
      getCompanyParticipants '%%', '%'
      
      setParticipantsMinsActivity = ->
        participants = $scope.companyParticipants.participants
        participantMinsActivityMap = $scope.companyParticipants.participantMinsActivityMap
        if participants and participants.length > 0 and participantMinsActivityMap
          angular.forEach participants, (participant, participantIndex) ->
            minsActivity = 0
            if participantMinsActivityMap.length > 0
              angular.forEach participantMinsActivityMap, (participantMinsActivityData) ->
                if participantMinsActivityData.constituent_id and Number(participantMinsActivityData.constituent_id) is Number(participant.consId)
                  minsActivity = participantMinsActivityData.minutes or 0
            $scope.companyParticipants.participants[participantIndex].minsActivity = minsActivity
      setParticipantsMinsActivity()
      $scope.$watchGroup ['companyParticipants.participants', 'companyParticipants.participantMinsActivityMap'], ->
        setParticipantsMinsActivity()
      
      $scope.orderParticipants = (sortColumn) ->
        participants = $scope.companyParticipants.participants
        $scope.participantListSetting.sortAscending = !$scope.participantListSetting.sortAscending
        if $scope.participantListSetting.sortColumn isnt sortColumn
          $scope.participantListSetting.sortAscending = false
        $scope.participantListSetting.sortColumn = sortColumn
        $scope.companyParticipants.participants = $filter('orderBy') participants, sortColumn, !$scope.participantListSetting.sortAscending
        $scope.participantListSetting.currentPage = 1 
      
      $scope.paginateParticipants = (value) ->
        begin = ($scope.participantListSetting.currentPage - 1) * $scope.participantListSetting.paginationItemsPerPage
        end = begin + $scope.participantListSetting.paginationItemsPerPage
        index = $scope.companyParticipants.participants.indexOf value
        begin <= index and index < end
      
      $scope.searchCompanyParticipants = ->
        $scope.companyParticipantSearch.first_name = $scope.companyParticipantSearch.ng_first_name
        $scope.companyParticipantSearch.last_name = $scope.companyParticipantSearch.ng_last_name
        getCompanyParticipants $scope.companyParticipantSearch.ng_first_name, $scope.companyParticipantSearch.ng_last_name
        $scope.participantListSetting.sortColumn = 'amountRaised'
        $scope.participantListSetting.sortAscending = false
      
      if $scope.consId
        TeamraiserRegistrationService.getRegistration
          success: (response) ->
            participantRegistration = response.getRegistrationResponse?.registration
            if participantRegistration
              $scope.participantRegistration = participantRegistration
      
      $scope.companyPagePhoto1 =
        defaultUrl: APP_INFO.rootPath + 'dist/district-heart/image/company-default.jpg'
      
      $scope.editCompanyPhoto1 = ->
        delete $scope.updateCompanyPhoto1Error
        $scope.editCompanyPhoto1Modal = $uibModal.open
          scope: $scope
          templateUrl: APP_INFO.rootPath + 'dist/district-heart/html/modal/editCompanyPhoto1.html'
      
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
  ]