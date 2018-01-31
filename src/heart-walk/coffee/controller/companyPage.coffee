angular.module 'ahaLuminateControllers'
  .controller 'CompanyPageCtrl', [
    '$scope'
    '$location'
    '$filter'
    '$timeout'
    'TeamraiserCompanyService'
    'TeamraiserTeamService'
    'TeamraiserParticipantService'
    ($scope, $location, $filter, $timeout, TeamraiserCompanyService, TeamraiserTeamService, TeamraiserParticipantService) ->
      $scope.companyId = $location.absUrl().split('company_id=')[1].split('&')[0].split('#')[0]
      $scope.currentCompany = null

      $defaultCompanyHierarchy = angular.element '.js--default-company-hierarchy'
      $childCompanyAmounts = $defaultCompanyHierarchy.find('.trr-td p.righted')
      totalCompanyAmountRaised = 0
      angular.forEach $childCompanyAmounts, (childCompanyAmount) ->
        amountRaised = angular.element(childCompanyAmount).text()
        if amountRaised
          amountRaised = amountRaised.replace('$', '').replace(/,/g, '')
          amountRaised = Number(amountRaised) * 100
          totalCompanyAmountRaised += amountRaised

      $defaultCompanySummary = angular.element '.js--default-company-summary'
      companyGiftCount = $defaultCompanySummary.find('.company-tally-container--gift-count .company-tally-ammount').text()
      if companyGiftCount is ''
        companyGiftCount = '0'
      $scope.companyProgress =
        numDonations: companyGiftCount

      setCompanyFundraisingProgress = (amountRaised, goal) ->
        $scope.companyProgress.amountRaised = amountRaised or 0
        $scope.companyProgress.amountRaised = Number $scope.companyProgress.amountRaised
        $scope.companyProgress.amountRaisedFormatted = $filter('currency')($scope.companyProgress.amountRaised / 100, '$', 0)
        $scope.companyProgress.goal = goal or 0
        $scope.companyProgress.goal = Number $scope.companyProgress.goal
        $scope.companyProgress.goalFormatted = $filter('currency')($scope.companyProgress.goal / 100, '$', 0)
        $scope.companyProgress.percent = 2
        $timeout ->
          percent = $scope.companyProgress.percent
          if $scope.companyProgress.goal isnt 0
            percent = Math.ceil(($scope.companyProgress.amountRaised / $scope.companyProgress.goal) * 100)
          if percent < 2
            percent = 2
          if percent > 98
            percent = 98
          $scope.companyProgress.percent = percent
          if not $scope.$$phase
            $scope.$apply()
        , 500
        if not $scope.$$phase
          $scope.$apply()

      TeamraiserCompanyService.getCompanies 'company_id=' + $scope.companyId,
        error: ->
          setCompanyFundraisingProgress()
        success: (response) ->
          companyInfo = response.getCompaniesResponse?.company
          if not companyInfo?
            setCompanyFundraisingProgress()
          else
            $scope.currentCompany = companyInfo
            setCompanyFundraisingProgress totalCompanyAmountRaised, companyInfo.goal

      $scope.sortList = (participants, sortProp) ->
        if participants and participants.length
          orderBy = $filter 'orderBy'
          participants = orderBy participants, sortProp
          participants
        else
          []

      $childCompanyLinks = $defaultCompanyHierarchy.find('.trr-td a')
      $scope.childCompanies = []
      $scope.companyPath = [];
      $scope.companyDepth = 0;
      angular.forEach $childCompanyLinks, (childCompanyLink) ->
        childCompanyUrl = angular.element(childCompanyLink).attr('href')
        childCompanyName = angular.element(childCompanyLink).text()
        depth=parseInt(childCompanyLink.parentElement.style.paddingLeft) / 10;
        if isNaN depth
          depth=0;
        while ( $scope.companyPath.length and $scope.companyPath.length >= depth)
          $scope.companyPath.pop()
        $scope.companyPath.push childCompanyName
        if childCompanyUrl.indexOf('company_id=') isnt -1
          $scope.childCompanies.push
            id: childCompanyUrl.split('company_id=')[1].split('&')[0]
            name: childCompanyName
            sort: $scope.companyPath.join("+")
            depth: depth
        $scope.companyDepth = depth
        
      $scope.childCompanies = $scope.sortList $scope.childCompanies, 'sort'
      numCompanies = $scope.childCompanies.length + 1

      $scope.companyTeamSearch =
        team_name: ''
      $scope.companyTeams =
        isOpen: true
        page: 1

      setCompanyTeams = (teams, totalNumber) ->
        $scope.companyTeams.teams = teams or []
        totalNumber = totalNumber or 0
        $scope.companyTeams.totalNumber = Number totalNumber
        if not $scope.$$phase
          $scope.$apply()

      $scope.childCompanyTeams =
        companies: []

      addChildCompanyTeams = (companyIndex, companyId, companyName, teams, totalNumber, depth) ->
        pageNumber = $scope.childCompanyTeams.companies[companyIndex]?.page or 0
        $scope.childCompanyTeams.companies[companyIndex] =
          isOpen: true
          page: pageNumber
          companyIndex: companyIndex
          companyId: companyId or ''
          companyName: companyName or ''
          teams: teams or []
          depth: depth or ''
        totalNumber = totalNumber or 0
        $scope.childCompanyTeams.companies[companyIndex].totalNumber = Number totalNumber
        if not $scope.$$phase
          $scope.$apply()

      setCompanyNumTeams = (numTeams) ->
        if not $scope.companyProgress.numTeams
          $scope.companyProgress.numTeams = numTeams or 0
        if not $scope.$$phase
          $scope.$apply()

      $scope.getCompanyTeamLists = ->
        numCompaniesTeamRequestComplete = 0
        numTeams = 0
        $scope.getCompanyTeams = ->
          # TODO: scroll to top of list
          pageNumber = $scope.companyTeams.page - 1
          TeamraiserTeamService.getTeams 'team_company_id=' + $scope.companyId + '&team_name=' + $scope.companyTeamSearch.team_name + '&list_sort_column=team_name&list_ascending=true&list_page_size=5&list_page_offset=' + pageNumber,
            error: ->
              setCompanyTeams()
              numCompaniesTeamRequestComplete++
              if numCompaniesTeamRequestComplete is numCompanies
                setCompanyNumTeams numTeams
            success: (response) ->
              setCompanyTeams()
              companyTeams = response.getTeamSearchByInfoResponse?.team
              if companyTeams?
                companyTeams = [companyTeams] if not angular.isArray companyTeams
                angular.forEach companyTeams, (companyTeam) ->
                  companyTeam.amountRaised = Number companyTeam.amountRaised
                  companyTeam.amountRaisedFormatted = $filter('currency')(companyTeam.amountRaised / 100, '$', 0)
                  companyTeam.name = companyTeam.name.replace(/&amp;/g, '&')
                  joinTeamURL = companyTeam.joinTeamURL
                  if joinTeamURL?
                    companyTeam.joinTeamURL = joinTeamURL.split('/site/')[1]
                totalNumberTeams = response.getTeamSearchByInfoResponse.totalNumberResults
                setCompanyTeams companyTeams, totalNumberTeams
                numTeams += Number totalNumberTeams
              numCompaniesTeamRequestComplete++
              if numCompaniesTeamRequestComplete is numCompanies
                setCompanyNumTeams numTeams
        $scope.getCompanyTeams()

        $scope.getChildCompanyTeams = (childCompanyIndex) ->
          # TODO: scroll to top of list
          childCompany = $scope.childCompanies[childCompanyIndex]
          childCompanyId = childCompany.id
          childCompanyName = childCompany.name
          depth = childCompany.depth
          pageNumber = $scope.childCompanyTeams.companies[childCompanyIndex]?.page
          if not pageNumber
            pageNumber = 0
          else
            pageNumber--
          TeamraiserTeamService.getTeams 'team_company_id=' + childCompanyId + '&team_name=' + $scope.companyTeamSearch.team_name + '&list_sort_column=team_name&list_ascending=true&list_page_size=5&list_page_offset=' + pageNumber,
            error: ->
              addChildCompanyTeams childCompanyIndex, childCompanyId, childCompanyName, [], 0, depth
              numCompaniesTeamRequestComplete++
              if numCompaniesTeamRequestComplete is numCompanies
                setCompanyNumTeams numTeams
            success: (response) ->
              companyTeams = response.getTeamSearchByInfoResponse?.team
              if not companyTeams?
                addChildCompanyTeams childCompanyIndex, childCompanyId, childCompanyName, [], 0, depth
              else
                companyTeams = [companyTeams] if not angular.isArray companyTeams
                angular.forEach companyTeams, (companyTeam) ->
                  companyTeam.amountRaised = Number companyTeam.amountRaised
                  companyTeam.amountRaisedFormatted = $filter('currency')(companyTeam.amountRaised / 100, '$', 0)
                  companyTeam.name = companyTeam.name.replace(/&amp;/g, '&')
                  joinTeamURL = companyTeam.joinTeamURL
                  if joinTeamURL?
                    companyTeam.joinTeamURL = joinTeamURL.split('/site/')[1]
                totalNumberTeams = response.getTeamSearchByInfoResponse.totalNumberResults
                addChildCompanyTeams childCompanyIndex, childCompanyId, childCompanyName, companyTeams, totalNumberTeams, depth
                numTeams += Number totalNumberTeams
              numCompaniesTeamRequestComplete++
              if numCompaniesTeamRequestComplete is numCompanies
                setCompanyNumTeams numTeams
        angular.forEach $scope.childCompanies, (childCompany, childCompanyIndex) ->
          $scope.getChildCompanyTeams childCompanyIndex
      $scope.getCompanyTeamLists()

      $scope.searchCompanyTeams = (companyTeamSearch) ->
        $scope.companyTeamSearch.team_name = companyTeamSearch?.team_name or ''
        $scope.companyTeams.isOpen = true
        $scope.companyTeams.page = 1
        angular.forEach $scope.childCompanyTeams.companies, (company, companyIndex) ->
          $scope.childCompanyTeams.companies[companyIndex].isOpen = true
          $scope.childCompanyTeams.companies[companyIndex].page = 1
        $scope.getCompanyTeamLists()

      $scope.companyParticipantSearch =
        participant_name: ''

      $scope.companyParticipants =
        isOpen: true
        page: 1

      $scope.setParticipantsFullName = (participants) ->
        i = 0
        while i < participants.length
          participants[i].name.full = participants[i].name.first + ' ' + participants[i].name.last
          i++
        participants

      setCompanyParticipants = (participants, totalNumber) ->
        participants = $scope.sortList(participants, ['name.first', 'name.last'])
        participants = $scope.setParticipantsFullName participants
        $scope.companyParticipants.participants = []
        $scope.companyParticipants.participantsList = participants
        totalNumber = participants.length
        $scope.companyParticipants.totalNumber = Number totalNumber
        $scope.paginateCompanyParticipants null
        tallyParticipants $scope.companyParticipants.totalNumber, 'parent'
        if not $scope.$$phase
          $scope.$apply()

      $scope.childCompanyParticipants =
        companies: []

      numChildComp = 0
      addChildCompanyParticipants = (companyIndex, companyId, companyName, participants, depth) ->
        numChildComp++
        pageNumber = $scope.childCompanyParticipants.companies[companyIndex]?.page or 0
        participants = $scope.sortList(participants, ['name.first', 'name.last'])
        participants = $scope.setParticipantsFullName participants
        totalNumber = participants.length
        $scope.childCompanyParticipants.companies[companyIndex] =
          isOpen: true
          isLoaded: true
          page: pageNumber
          companyIndex: companyIndex
          companyId: companyId or ''
          companyName: companyName or ''
          participants: []
          participantsList: participants or []
          depth: depth or ""
        $scope.childCompanyParticipants.companies[companyIndex].totalNumber = Number totalNumber
        if numChildComp is $scope.childCompanies.length
          tallyParticipants $scope.childCompanyParticipants.companies[companyIndex].totalNumber, 'child', true
        else
          tallyParticipants $scope.childCompanyParticipants.companies[companyIndex].totalNumber, 'child', false
        $scope.paginateCompanyParticipants companyIndex
        if not $scope.$$phase
          $scope.$apply()

      if $scope.childCompanies.length is 0
        $scope.companyProgress.numParticipants = 0

      totalParticipants = 0
      tallyParticipants = (num, type, set) ->
        num = Number num
        totalParticipants += num
        if $scope.childCompanies.length is 0 and type is 'parent'
          setCompanyNumParticipants totalParticipants
        if set is true
          setCompanyNumParticipants totalParticipants
      setCompanyNumParticipants = (numParticipants) ->
        numParticipants = Number numParticipants
        $scope.companyProgress.numParticipants = numParticipants
        if not $scope.$$phase
          $scope.$apply()

      initCompanyParticipantLists = ->
        TeamraiserCompanyService.getCompanyTree $scope.companyId, $scope.childCompanies,
          success: (company) ->
            if company.companyId and company.companyId is $scope.companyId
              $scope.currentCompany = company
              $scope.companyProgress.amountRaisedFormatted = company.amountRaisedFormatted
            $scope.getCompanyParticipantLists()
            
      $scope.getCompanyParticipantLists = ->
        numCompaniesParticipantRequestComplete = 0

        $scope.getCompanyParticipants = ->
          # TODO: scroll to top of list
          companyParticipants = $scope.companyParticipants
          if companyParticipants and companyParticipants.isLoaded
            $scope.paginateCompanyParticipants null
            return
          $scope.companyParticipants.isLoaded = true

          individualParticipants = []
          getCompanyParticipantsList = ->
            TeamraiserParticipantService.getParticipants 'team_name=' + encodeURIComponent('%%%') + '&list_filter_column=team.company_id&list_filter_text=' + $scope.companyId + '&list_page_size=500',
              error: ->
                companyParticipants = individualParticipants
                setCompanyParticipants companyParticipants
                numCompaniesParticipantRequestComplete++
              success: (response) ->
                participants = response.getParticipantsResponse?.participant
                if not participants?
                  participants = []
                participants = [participants] if not angular.isArray participants
                participants = participants.concat(individualParticipants)
                companyParticipants = []
                angular.forEach participants, (participant) ->
                  if participant.name?.first
                    participant.amountRaised = Number participant.amountRaised
                    participant.amountRaisedFormatted = $filter('currency')(participant.amountRaised / 100, '$', 0)
                    donationUrl = participant.donationUrl
                    if donationUrl?
                      participant.donationUrl = donationUrl.split('/site/')[1]
                    companyParticipants.push participant
                setCompanyParticipants companyParticipants
                numCompaniesParticipantRequestComplete++

          getParticipantsList = ->
            # Get individual participants
            TeamraiserParticipantService.getParticipants 'first_name=' + encodeURIComponent('%%%') + '&list_filter_column=reg.company_id&list_filter_text=' + $scope.companyId + '&list_page_size=500',
              error: ->
                getCompanyParticipantsList()
              success: (response) ->
                participants = response.getParticipantsResponse?.participant
                if not participants?
                  # Do nothing
                else
                  participants = [participants] if not angular.isArray participants
                  i = 0
                  while i < participants.length
                    participants[i].individualParticipant = 'true'
                    i++
                  individualParticipants = participants
                getCompanyParticipantsList()
            return
          getParticipantsList()

        $scope.getCompanyParticipants()

        $scope.getChildCompanyParticipants = (childCompanyIndex) ->
          # TODO: scroll to top of list
          childCompany = $scope.childCompanies[childCompanyIndex]
          childCompanyId = childCompany.id
          childCompanyName = childCompany.name
          depth = childCompany.depth

          companyParticipants = $scope.childCompanyParticipants.companies[childCompanyIndex]
          if companyParticipants and companyParticipants.isLoaded
            $scope.paginateCompanyParticipants childCompanyIndex
            return

          individualParticipants = []
          getChildCompanyParticipantsList = ->
            TeamraiserParticipantService.getParticipants 'team_name=' + encodeURIComponent('%%%') + '&list_filter_column=team.company_id&list_filter_text=' + childCompanyId + '&list_page_size=500',
            error: ->
              companyParticipants = individualParticipants
              addChildCompanyParticipants childCompanyIndex, childCompanyId, childCompanyName, companyParticipants, depth
              numCompaniesParticipantRequestComplete++
            success: (response) ->
              participants = response.getParticipantsResponse?.participant
              if not participants?
                participants = []
              participants = [participants] if not angular.isArray participants
              participants = participants.concat(individualParticipants)
              companyParticipants = []
              angular.forEach participants, (participant) ->
                if participant.name?.first
                  participant.amountRaised = Number participant.amountRaised
                  participant.amountRaisedFormatted = $filter('currency')(participant.amountRaised / 100, '$', 0)
                  donationUrl = participant.donationUrl
                  if donationUrl?
                    participant.donationUrl = donationUrl.split('/site/')[1]
                  companyParticipants.push participant
              addChildCompanyParticipants childCompanyIndex, childCompanyId, childCompanyName, companyParticipants, depth
              numCompaniesParticipantRequestComplete++

          getParticipantsList = ->
            # Get individual participants
            TeamraiserParticipantService.getParticipants 'first_name=' + encodeURIComponent('%%%') + '&list_filter_column=reg.company_id&list_filter_text=' + childCompanyId + '&list_page_size=500',
              error: ->
                getChildCompanyParticipantsList()
              success: (response) ->
                participants = response.getParticipantsResponse?.participant
                if not participants?
                  # Do nothing
                else
                  participants = [participants] if not angular.isArray participants
                  i = 0
                  while i < participants.length
                    participants[i].individualParticipant = 'true'
                    i++
                  individualParticipants = participants
                getChildCompanyParticipantsList()
            return
          getParticipantsList()

        angular.forEach $scope.childCompanies, (childCompany, childCompanyIndex) ->
          $scope.getChildCompanyParticipants childCompanyIndex

      initCompanyParticipantLists()

      $scope.filterParticipants = (participants) ->
        filter = $filter 'filter'
        firstName = $scope.companyParticipantSearch.participant_name
        lastName = ''
        if $scope.companyParticipantSearch.participant_name.indexOf(' ') isnt -1
          firstName = $scope.companyParticipantSearch.participant_name.split(' ')[0].trim()
          lastName = $scope.companyParticipantSearch.participant_name.split(' ')[1].trim()
        if participants.length
          if firstName.length and lastName.length
            participants = filter participants, name: {first: firstName}
            participants = filter participants, name: {last: lastName}
          else if firstName.length
            participants = filter participants, name: {full: firstName}
        participants

      $scope.paginateCompanyParticipants = (companyIndex) ->
        pageSize = 5
        participants = []
        if !companyIndex?
          companyParticipants = $scope.companyParticipants
        else
          companyParticipants = $scope.childCompanyParticipants.companies[companyIndex]
        currentPage = companyParticipants.page
        if currentPage > 0
          currentPage--
        participantsList = $scope.filterParticipants companyParticipants.participantsList
        i = 0
        while i < participantsList.length
          if i >= pageSize * currentPage and i < pageSize * (currentPage + 1)
            participants.push participantsList[i]
          i++
        if !companyIndex?
          $scope.companyParticipants.participants = participants
          $scope.companyParticipants.totalNumber = participantsList.length
        else
          $scope.childCompanyParticipants.companies[companyIndex].participants = participants
          $scope.childCompanyParticipants.companies[companyIndex].totalNumber = participantsList.length
        return

      $scope.searchCompanyParticipants = (companyParticipantSearch) ->
        $scope.companyParticipantSearch.participant_name = companyParticipantSearch?.participant_name or ''
        $scope.companyParticipants.isOpen = true
        $scope.companyParticipants.page = 1
        angular.forEach $scope.childCompanyParticipants.companies, (company, companyIndex) ->
          $scope.childCompanyParticipants.companies[companyIndex].isOpen = true
          $scope.childCompanyParticipants.companies[companyIndex].page = 1
        $scope.getCompanyParticipantLists()
  ]
