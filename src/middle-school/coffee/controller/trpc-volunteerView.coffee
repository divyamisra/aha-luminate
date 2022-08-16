angular.module('trPcControllers').controller 'NgPcVolunteerViewCtrl', [
  '$scope'
  '$rootScope'
  'ZuriService'
  ($scope, $rootScope, ZuriService) ->

    $scope.entryView = ''
    $scope.hourList = [0..23]
    $scope.minuteList = [0..59]
    $scope.volunteerData = []
    $scope.volunteerTotal =
      'hours': '0'
      'minutes': '00'
    $scope.volunteerActivities = []
    $scope.volunteerAdd =
      'date': ''
      'activity': ''
      'hour': ''
      'minute': ''

    $scope.showVolunteerEntry = ->
      $scope.createVolunteerEntryDetail = true
      setTimeout (->
        angular.element('input#volunteer-date').focus()
      ), 0

    $scope.hideVolunteerEntry = ->
      $scope.createVolunteerEntryDetail = false

    $scope.showEntries = ->
      $scope.entryView = @entry.id

    $scope.hideEntries = ->
      $scope.entryView = ''

    getVolunteerActivities = ->
      ZuriService.getVolunteerData 'activity_types',
        failure: (response) ->
        error: (response) ->
        success: (response) ->
          $scope.volunteerActivities = response.data.data
    getVolunteerActivities()

    getVolunteerism = ->
      ZuriService.getVolunteerData $scope.frId + '/' + $scope.consId,
        failure: (response) ->
        error: (response) ->
        success: (response) ->
          if typeof response.data.data != 'undefined'
            if response.data.total_hours > 0
              totalTimeInMinutes = response.data.total_hours
              hours = Math.floor(totalTimeInMinutes / 60)
              minutes = totalTimeInMinutes - (hours * 60)
              minutes = if minutes < 10 then '0' + minutes else minutes
              $scope.volunteerTotal =
                'hours': hours
                'minutes': minutes
              $scope.volunteerData = response.data.data
          angular.forEach $scope.volunteerData, (entry, key) ->
            entry.activity_date = new Date(entry.activity_date)
            entry.hour = Math.floor(entry.hours / 60)
            entry.minute = entry.hours - (entry.hour * 60)
    getVolunteerism()

    $scope.createVolunteerEntry = ->
      ZuriService.createVolunteerData {
        'constituent_id': $scope.consId
        'school_id': $scope.participantRegistration.companyInformation.companyId
        'event_id': $scope.frId
        'event_year': 'fy23'
        'activity_type_id': $scope.volunteerAdd.activity
        'activity_date': $scope.volunteerAdd.date
        'hours': parseInt($scope.volunteerAdd.hour) * 60 + parseInt($scope.volunteerAdd.minute)
      },
        failure: (response) ->
        error: (response) ->
        success: (response) ->
          if response.data.status == 'success'
            $scope.createVolunteerEntryDetail = false
            getVolunteerism()
            $scope.volunteerProcess = response.data

    $scope.saveVolunteerEntry = (evt) ->
      ZuriService.saveVolunteerData @entry.id, {
        'constituent_id': @$parent.entry.constituent_id
        'school_id': @$parent.entry.school_id
        'event_id': @$parent.entry.event_id
        'event_year': @$parent.entry.event_year
        'activity_type_id': @$parent.entry.activity_type_id
        'activity_date': @$parent.entry.activity_date
        'hours': parseInt(@$parent.entry.hour) * 60 + parseInt(@$parent.entry.minute)
      },
        failure: (response) ->
        error: (response) ->
        success: (response) ->
          if response.data.status == 'success'
            $scope.createVolunteerEntryDetail = false
            getVolunteerism()
            $scope.volunteerProcess = response.data

    $scope.deleteVolunteerEntry = (evt) ->
      if confirm('Are you sure you want to delete this entry?')
        ZuriService.deleteVolunteerData @$parent.entry.event_id + '/' + @$parent.entry.constituent_id + '/' + @$parent.entry.id,
          failure: (response) ->
          error: (response) ->
          success: (response) ->
            if response.data.status == 'success'
              $scope.createVolunteerEntryDetail = false
              getVolunteerism()
              $scope.volunteerProcess = response.data
              
    ImagetoPrint = (source) ->
      '<html><head><scri' + 'pt>function step1(){\n' + 'setTimeout(\'step2()\', 10);}\n' + 'function step2(){window.print();window.close()}\n' + '</scri' + 'pt></head><body onload=\'step1()\'>\n' + '<img src=\'' + source + '\' /></body></html>'

    $scope.PrintImage = (source) ->
      Pagelink = 'about:blank'
      pwa = window.open(Pagelink, '_new')
      pwa.document.open()
      pwa.document.write ImagetoPrint(angular.element(source).attr('src'))
      pwa.document.close()
      
  ]
