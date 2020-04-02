angular.module 'ahaLuminateControllers'
  .controller 'RegistrationTfindCtrl', [
    '$rootScope'
    '$scope'
    'TeamraiserCompanyService'
    'TeamraiserTeamService'
    'SchoolLookupService'
    ($rootScope, $scope, TeamraiserCompanyService, TeamraiserTeamService, SchoolLookupService) ->
      $rootScope.companyName = ''
      regCompanyId = luminateExtend.global.regCompanyId
      setCompanyName = (companyName) ->
        $rootScope.companyName = companyName
        if not $rootScope.$$phase
          $rootScope.$apply()
      #TeamraiserCompanyService.getCompanies 'company_id=' + regCompanyId,
      #  error: ->
      #    # TODO
      #  success: (response) ->
      #    companies = response.getCompaniesResponse.company
      #    if not companies
      #      # TODO
      #    else
      #      companies = [companies] if not angular.isArray companies
      #      companyInfo = companies[0]
      #      setCompanyName companyInfo.companyName
      setCompanyName localStorage.companyName
      
      if not $scope.teamSearch
        $scope.teamSearch = {}
      
      $scope.teamList = {}
      getTeams = ->
        setTeams = (teams = []) ->
          if teams.length is 1
            teamId = teams[0].id
            teamCompanyId = teams[0].companyId
            window.location = luminateExtend.global.path.secure + 'TRR?fr_id=' + teams[0].EventId + '&pg=tfind&fr_tjoin=' + teamId + '&s_frTJoin=' + teamId + '&s_frCompanyId=' + teamCompanyId + '&skip_login_page=true'
          else
            $scope.teamList.teams = teams
            if not $scope.$$phase
              $scope.$apply()
            angular.element('body').removeClass 'hidden'
        TeamraiserTeamService.getTeams 'team_company_id=' + $scope.teamSearch.companyId + '&list_page_size=500&list_sort_column=name',
          error: ->
            setTeams()
          success: (response) ->
            teams = response.getTeamSearchByInfoResponse.team
            if not teams
              setTeams()
            else
              teams = [teams] if not angular.isArray teams
              setTeams teams
      if $scope.teamSearch.companyId and $scope.teamSearch.companyId isnt ''
        getTeams()
      $scope.$watch 'teamSearch.companyId', (newValue) ->
        if newValue and newValue isnt ''
          getTeams()
      
      $scope.submitTfindSearch = ->
        $scope.teamSearch.teamName = $scope.teamSearch.ng_team_name
        
      setCompanyCity = (companyCity) ->
        $rootScope.companyCity = companyCity
        if not $rootScope.$$phase
          $rootScope.$apply()
          
      setCompanyState = (companyState) ->
        $rootScope.companyState = companyState
        if not $rootScope.$$phase
          $rootScope.$apply()
          
      if localStorage.companyCity != undefined
        setCompanyCity localStorage.companyCity
        setCompanyState localStorage.companyState
      
      #
      #SchoolLookupService.getSchoolData()
      #  .then (response) ->
      #    schoolDataRows = response.data.getSchoolSearchDataResponse.schoolData
      #    angular.forEach schoolDataRows, (schoolDataRow, schoolDataRowIndex) ->
      #      if schoolDataRowIndex > 0
      #        if regCompanyId is schoolDataRow[0]
      #          setCompanyCity schoolDataRow[1]
      #          setCompanyState schoolDataRow[2]
      #          return
  ]
