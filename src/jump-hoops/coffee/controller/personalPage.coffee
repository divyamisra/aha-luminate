angular.module 'ahaLuminateControllers'
  .controller 'PersonalPageCtrl', [
    '$scope'
    '$rootScope'
    '$location'
    '$filter'
    '$timeout'
    'TeamraiserParticipantService'
    'TeamraiserCompanyService'
    'ZuriService'
    ($scope, $rootScope, $location, $filter, $timeout, TeamraiserParticipantService, TeamraiserCompanyService, ZuriService) ->
      $dataRoot = angular.element '[data-aha-luminate-root]'
      $scope.participantId = $location.absUrl().split('px=')[1].split('&')[0]
      $scope.companyId = $dataRoot.data('company-id') if $dataRoot.data('company-id') isnt ''
      $scope.teamId = $dataRoot.data('team-id') if $dataRoot.data('team-id') isnt ''
      $scope.eventDate =''
      $rootScope.numTeams = ''
      $scope.challengeId = ''
      $scope.challengeName = ''
      $scope.challengeCompleted = ''

      ZuriService.getZooStudent '1163033/438147777',
        success: (response) ->
          $scope.challengeId = response.data.challenges.current
          $scope.challengeName = response.data.challenges.current
          $scope.challengeCompleted = response.data.challenges.completed

        error: (response) ->
          $scope.challengeName = null

      TeamraiserCompanyService.getCompanies 'company_id=' + $scope.companyId, 
        success: (response) ->
          coordinatorId = response.getCompaniesResponse?.company.coordinatorId
          eventId = response.getCompaniesResponse?.company.eventId
          $rootScope.numTeams = response.getCompaniesResponse.company.teamCount

          TeamraiserCompanyService.getCoordinatorQuestion coordinatorId, eventId
            .then (response) ->
              $scope.eventDate = response.data.coordinator.event_date
        
      setParticipantProgress = (amountRaised, goal) ->
        $scope.personalProgress = 
          amountRaised: amountRaised or 0
          goal: goal or 0
        $scope.personalProgress.amountRaisedFormatted = $filter('currency')($scope.personalProgress.amountRaised / 100, '$').replace '.00', ''
        $scope.personalProgress.goalFormatted = $filter('currency')($scope.personalProgress.goal / 100, '$').replace '.00', ''
        if $scope.personalProgress.goal is 0
          $scope.personalProgress.rawPercent = 0
        else
          rawPercent = Math.ceil(($scope.personalProgress.amountRaised / $scope.personalProgress.goal) * 100)
          if rawPercent > 100
            rawPercent = 100
          $scope.personalProgress.rawPercent = rawPercent
        $scope.personalProgress.percent = 0
        if not $scope.$$phase
          $scope.$apply()
        $timeout ->
          percent = $scope.personalProgress.percent
          if $scope.personalProgress.goal isnt 0
            percent = Math.ceil(($scope.personalProgress.amountRaised / $scope.personalProgress.goal) * 100)
          if percent > 100
            percent = 100
          else if percent < 2
            percent = 2
          $scope.personalProgress.percent = percent
          if not $scope.$$phase
            $scope.$apply()
        , 500

      TeamraiserParticipantService.getParticipants 'fr_id=' + $scope.frId + '&first_name=' + encodeURIComponent('%%') + '&last_name=' + encodeURIComponent('%') + '&list_filter_column=reg.cons_id&list_filter_text=' + $scope.participantId, 
        error: ->
          setParticipantProgress()
        success: (response) ->
          participantInfo = response.getParticipantsResponse?.participant
          if not participantInfo
            setParticipantProgress()
          else
            setParticipantProgress Number(participantInfo.amountRaised), Number(participantInfo.goal)

      $scope.personalDonors = 
        page: 1
      $defaultResponsivePersonalDonors = angular.element '.js--personal-donors .team-honor-list-row'
      if $defaultResponsivePersonalDonors and $defaultResponsivePersonalDonors.length isnt 0
        if $defaultResponsivePersonalDonors.length is 1 and $defaultResponsivePersonalDonors.eq(0).find('.team-honor-list-name').length is 0
          $scope.personalDonors.donors = []
          $scope.personalDonors.totalNumber = 0
        else
          angular.forEach $defaultResponsivePersonalDonors, (personalDonor, personalDonorIndex) ->
            donorName = angular.element(personalDonor).find('.team-honor-list-name').text()
            donorAmount = angular.element(personalDonor).find('.team-honor-list-value').text()
            if not donorAmount or donorAmount.indexOf('$') is -1
              donorAmount = -1
            else
              donorAmount = Number(donorAmount.replace('$', '').replace(/,/g, '')) * 100
            if not $scope.personalDonors.donors
              $scope.personalDonors.donors = []
            $scope.personalDonors.donors.push 
              name: donorName
              amount: donorAmount
              amountFormatted: if donorAmount is -1 then '' else $filter('currency')(donorAmount / 100, '$').replace '.00', ''
          $scope.personalDonors.totalNumber = $defaultResponsivePersonalDonors.length
      else
        $defaultPersonalDonors = angular.element '.js--personal-donors .scrollContent p'
        if not $defaultPersonalDonors or $defaultPersonalDonors.length is 0
          $scope.personalDonors.donors = []
          $scope.personalDonors.totalNumber = 0
        else
          angular.forEach $defaultPersonalDonors, (personalDonor, personalDonorIndex) ->
            donorName = jQuery.trim angular.element(personalDonor).html().split('<')[0]
            donorAmount = jQuery.trim angular.element(personalDonor).html().split('>')[1]
            if not donorAmount or donorAmount.indexOf('$') is -1
              donorAmount = -1
            else
              donorAmount = Number(donorAmount.replace('$', '').replace(/,/g, '')) * 100
            if not $scope.personalDonors.donors
              $scope.personalDonors.donors = []
            $scope.personalDonors.donors.push 
              name: donorName
              amount: donorAmount
              amountFormatted: if donorAmount is -1 then '' else $filter('currency')(donorAmount / 100, '$').replace '.00', ''
          $scope.personalDonors.totalNumber = $defaultPersonalDonors.length
  ]