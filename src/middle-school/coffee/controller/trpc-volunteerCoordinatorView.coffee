angular.module('trPcControllers').controller 'NgPcVolunteerCoordinatorViewCtrl', [
  '$scope'
  '$rootScope'
  '$uibModal'
  'ZuriService'
  'APP_INFO'
  '$filter'
  ($scope, $rootScope, $uibModal, ZuriService, APP_INFO, $filter) ->

    $scope.entryView = ''
    $scope.volunteerCoordinatorData = []
    $scope.volunteerLoadPending = false
    $scope.volunteerTotal =
      'hours': '0'
      'minutes': '00'
    $scope.volunteerActivities = []

    getVolunteerActivities = ->
      ZuriService.getVolunteerData 'activity_types',
        failure: (response) ->
        error: (response) ->
        success: (response) ->
          $scope.volunteerActivities = response.data.data
    getVolunteerActivities()

    getVolunteerism = ->
      $scope.volunteerLoadPending = true
      $scope.volunteerCoordinatorData = []
      $scope.volunteerCoordinatorTotal =
        'hours': '0'
        'minutes': '00'
      total_hours = 0
      ZuriService.getVolunteerAdminData $scope.participantRegistration.companyInformation.companyId,
        failure: (response) ->
        error: (response) ->
        success: (response) ->
          $scope.volunteerLoadPending = false
          if typeof response.data.data != 'undefined'
            $scope.volunteerCoordinatorData = response.data.data
          angular.forEach $scope.volunteerCoordinatorData, (entry, key) ->
            date = new Date(entry.activity_date)
            entry.activity_date = new Date(date.toLocaleString('en-US', { timeZone: "UTC" }))
            entry.original_activity_date = entry.activity_date
            entry.hour = Math.floor(entry.hours / 60)
            entry.minute = entry.hours - (entry.hour * 60)
            total_hours = total_hours + entry.orig_hours
          totalTimeInMinutes = total_hours
          hours = Math.floor(totalTimeInMinutes / 60)
          minutes = totalTimeInMinutes - (hours * 60)
          minutes = if minutes < 10 then '0' + minutes else minutes
          $scope.volunteerTotal =
            'hours': hours
            'minutes': minutes
          $filter('orderBy')($scope.volunteerCoordinatorData, 'StudentFirstName', false)
    getVolunteerism()

    $scope.viewVolunteerActivities = ->
      $scope.viewVolunteerActivitiesModal = $uibModal.open
        scope: $scope
        templateUrl: APP_INFO.rootPath + 'dist/middle-school/html/participant-center/modal/viewVolunteerActivities.html'
      setTimeout (->
        jQuery('.non-collapsing').on 'click', (e) ->
          window.open jQuery(this).attr('href')
        jQuery('.non-collapsing').on 'keydown', (e) ->
          if e.which == 13
            e.preventDefault()
            window.open jQuery(this).attr('href')
      ), 1500
  
    $scope.cancelViewVolunteerActivities = ->
      $scope.viewVolunteerActivitiesModal.close()
      
    $scope.volunteerAdminData = []
    $scope.showVolunteerAdminReport = ->
      $scope.volunteerAdminReportPending = true
      $scope.showVolunteerAdminReportModal = $uibModal.open
        scope: $scope
        templateUrl: APP_INFO.rootPath + 'dist/middle-school/html/participant-center/modal/viewVolunteerAdminReport.html'
      $scope.volunteerAdminReportData()

    $scope.cancelShowVolunteerAdminReport = ->
      $scope.showVolunteerAdminReportModal.close()

    $scope.volunteerAdminReportData = ->
      volunteerAdminData = []
      ZuriService.getVolunteerAdminData $scope.participantRegistration.companyInformation.companyId,
        failure: (response) ->
        error: (response) ->
        success: (response) ->
          if typeof response.data.data != 'undefined'
            $scope.volunteerAdminData = response.data.data
            angular.forEach $scope.volunteerAdminData, (entry, entryIndex) ->
              volunteerAdminData[entryIndex] = entry
            $scope.volunteerAdminReportList = volunteerAdminData
          $scope.volunteerAdminReportPending = false
  
    $scope.volunteerDetail =
      'sortColumn': ''
      'sortAscending': false
    $scope.orderVolunteerDetail = (sortColumn) ->
      $scope.volunteerDetail.sortAscending = !$scope.volunteerDetail.sortAscending
      if $scope.volunteerDetail.sortColumn != sortColumn
        $scope.volunteerDetail.sortAscending = false
      $scope.volunteerDetail.sortColumn = sortColumn
      orderBy = $filter('orderBy')
      $scope.volunteerCoordinatorData = orderBy($scope.volunteerCoordinatorData, sortColumn, !$scope.volunteerDetail.sortAscending)
          
  ]
