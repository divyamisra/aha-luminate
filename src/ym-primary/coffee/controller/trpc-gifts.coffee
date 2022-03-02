angular.module 'trPcControllers'
  .controller 'NgPcGiftsViewCtrl', [
    '$scope'
    '$rootScope'
    '$filter'
    '$timeout'
    '$uibModal'
    '$location'
    'APP_INFO'
    'BoundlessService'
    'PageContentService'
    'NgPcTeamraiserProgressService'
    '$sce'
    ($scope, $rootScope, $filter, $timeout, $uibModal, $location, APP_INFO, BoundlessService, PageContentService, NgPcTeamraiserProgressService, $sce) ->

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
      
      $scope.standardGifts = []
      $scope.giftsEarned = 0
      
      BoundlessService.getPrizes $scope.consId
      .then (response) ->
        students = response.data.student
        angular.forEach students, (student) ->
          if student.has_bonus
             giftLevels = BoundlessService.giftLevels_instant()
          else
             giftLevels = BoundlessService.giftLevels_noninstant()
          current_level = if student.current_level != null then student.current_level else '$0'
          prevstatus = 0
          angular.forEach defaultStandardGifts, (gift, key) ->
            if student.has_bonus and (gift.instant == 1 or gift.instant == 2) or !student.has_bonus and (gift.instant == 0 or gift.instant == 2)
              status = 0
              lastItem = 0
              if jQuery.inArray(gift.id,giftLevels[current_level]) isnt -1
                status = 1
                if gift.online_only
                  status = 0
                  jQuery.each student.prizes, (item, key) ->
                    if key.prize_sku.indexOf(gift.id) isnt -1
                      status = 1
                      return false
                    return
              if prevstatus == 1 and status == 0
                $scope.standardGifts[$scope.standardGifts.length-1].lastItem = 1
              $scope.standardGifts.push
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
              prevstatus = status
              if status == 1
                $scope.giftsEarned++

            if $scope.giftStatus == 1
              $scope.standardGifts[$scope.standardGifts.length-1].lastItem = 1
      , (response) ->
        # TODO

      $scope.participantProgress =
        raised: 0
        raisedFormatted: '$0'
        goal: 0
        goalFormatted: '$0'
        percent: 0
      $scope.getParticipantProgress = ->
        fundraisingProgressPromise = NgPcTeamraiserProgressService.getProgress()
          .then (response) ->
            participantProgress = response.data.getParticipantProgressResponse?.personalProgress
            if participantProgress
              participantProgress.raised = Number participantProgress.raised
              participantProgress.raisedFormatted = if participantProgress.raised then $filter('currency')(participantProgress.raised / 100, '$', 0) else '$0'
              participantProgress.goal = Number participantProgress.goal
              participantProgress.goalFormatted = if participantProgress.goal then $filter('currency')(participantProgress.goal / 100, '$', 0) else '$0'
              $scope.participantProgress = participantProgress
            response
      $scope.getParticipantProgress()
]
