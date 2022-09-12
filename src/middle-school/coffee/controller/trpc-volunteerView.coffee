angular.module('trPcControllers').controller 'NgPcVolunteerViewCtrl', [
  '$scope'
  '$rootScope'
  '$uibModal'
  'ZuriService'
  'APP_INFO'
  '$filter'
  ($scope, $rootScope, $uibModal, ZuriService, APP_INFO, $filter) ->

    $scope.entryView = ''
    $scope.hourList = [0,1,2]
    $scope.minuteList = [0,15,30,45]
    $scope.volunteerData = []
    $scope.volunteerLoadPending = false
    $scope.volunteerTotal =
      'hours': '0'
      'minutes': '00'
    $scope.volunteerActivities = []
    $scope.volunteerAdd =
      'date': new Date()
      'activity': ''
      'hour': '0'
      'minute': 0

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
      $scope.volunteerLoadPending = true
      $scope.volunteerData = []
      $scope.volunteerTotal =
        'hours': '0'
        'minutes': '00'
      ZuriService.getVolunteerData $scope.frId + '/' + $scope.consId,
        failure: (response) ->
        error: (response) ->
        success: (response) ->
          $scope.volunteerLoadPending = false
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
            date = new Date(entry.activity_date)
            entry.activity_date = new Date(date.toLocaleString('en-US', { timeZone: "UTC" }))
            entry.original_activity_date = entry.activity_date
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
        'activity_date': $filter('date')(new Date($scope.volunteerAdd.date), 'yyyy-MM-dd')
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
        'activity_date': $filter('date')(new Date(@$parent.entry.activity_date), 'yyyy-MM-dd')
        'hours': parseInt(@$parent.entry.hour) * 60 + parseInt(@$parent.entry.minute)
      },
        failure: (response) ->
        error: (response) ->
        success: (response) ->
          if response.data.status == 'success'
            $scope.createVolunteerEntryDetail = false
            $scope.entryView = 0
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

    $scope.checkVolunteerMinutes = ->
      if typeof @$parent.entry != 'undefined'
        if @$parent.entry.hour == 2
          @$parent.entry.minute = 0
      if typeof @$parent.$parent.volunteerAdd != 'undefined'
        if @$parent.$parent.volunteerAdd.hour == '2'
          @$parent.$parent.volunteerAdd.minute = 0
  
    $scope.showVolunteerReport = ->
      $scope.volunteerReportPending = true
      $scope.showVolunteerReportModal = $uibModal.open
        scope: $scope
        templateUrl: APP_INFO.rootPath + 'dist/middle-school/html/participant-center/modal/viewVolunteerReport.html'
      $scope.volunteerReportData()

    $scope.cancelShowVolunteerReport = ->
      $scope.showVolunteerReportModal.close()
      
    $scope.viewVolunteerActivities = ->
      $scope.viewVolunteerActivitiesModal = $uibModal.open
        scope: $scope
        templateUrl: APP_INFO.rootPath + 'dist/middle-school/html/participant-center/modal/viewVolunteerActivities.html'

    $scope.cancelViewVolunteerActivities = ->
      $scope.viewVolunteerActivitiesModal.close()
      
    $scope.volunteerReportData = ->
      volunteerData = []
      if $scope.volunteerData and $scope.volunteerData.length > 0
          angular.forEach $scope.volunteerData, (entry, entryIndex) ->
            volunteerData[entryIndex] = {}
            volunteerData[entryIndex].activity_date = $filter('date')(new Date(entry.activity_date), 'yyyy-MM-dd')
            volunteerData[entryIndex].activity = entry.activity_type
            volunteerData[entryIndex].hours = entry.hour + ':' + entry.minute
      $scope.volunteerReportList = volunteerData
      $scope.volunteerReportPending = false
              
    ImagetoPrint = (source) ->
      '<html><head><scri' + 'pt>function step1(){\n' + 'setTimeout(\'step2()\', 10);}\n' + 'function step2(){window.print();window.close()}\n' + '</scri' + 'pt></head><body onload=\'step1()\'>\n' + '<img src=\'' + source + '\' /></body></html>'

    $scope.PrintImage = (source) ->
      Pagelink = 'about:blank'
      pwa = window.open(Pagelink, '_new')
      pwa.document.open()
      pwa.document.write ImagetoPrint(angular.element(source).attr('src'))
      pwa.document.close()
      
  ]
