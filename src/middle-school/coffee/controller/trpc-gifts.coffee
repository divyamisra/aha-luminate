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
          templateUrl: APP_INFO.rootPath + 'dist/middle-school/html/participant-center/modal/viewPrize.html'

      $scope.cancelShowPrize = ->
        $scope.viewPrizeModal.close()

      getRandomID = ->
        return Math.floor((Math.random()*3)+1);

      defaultStandardGifts = BoundlessService.defaultStandardGifts()
      
      $scope.standardGifts = []

      $scope.getGifts = ->
        angular.forEach defaultStandardGifts, (gift, key) ->
          status = 0
          lastItem = 0
          $scope.standardGifts.push
            prize_label: gift.name
            prize_sku: gift.id
            prize_video: gift.video
            prize_status: status
            lastItem: lastItem
            randomID: getRandomID()
            prize_level: gift.level
            msg_earned: gift.msg_earned
            msg_unearned: gift.msg_unearned 
      $scope.getGifts()
]
