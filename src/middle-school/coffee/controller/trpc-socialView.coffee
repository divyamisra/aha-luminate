angular.module('trPcControllers').controller 'NgPcSocialViewCtrl', [
  '$scope'
  '$sce'
  '$rootScope'
  'FacebookFundraiserService'
  'BoundlessService'
  'NgPcTeamraiserShortcutURLService'
  ($scope, $sce, $rootScope, FacebookFundraiserService, BoundlessService, NgPcTeamraiserShortcutURLService) ->
    #facebook fundraising
    $rootScope.facebookFundraiserConfirmedStatus = ''
    if $scope.facebookFundraisersEnabled and $rootScope.facebookFundraiserId and $rootScope.facebookFundraiserId isnt ''
      $rootScope.facebookFundraiserConfirmedStatus = 'pending'
      FacebookFundraiserService.confirmFundraiserStatus()
        .then (response) ->
          confirmOrUnlinkFacebookFundraiserResponse = response.data.confirmOrUnlinkFacebookFundraiserResponse
          if typeof response.data.confirmOrUnlinkFacebookFundraiserResponse == 'undefined'
            confirmOrUnlinkFacebookFundraiserResponse = []
            confirmOrUnlinkFacebookFundraiserResponse.active = 'false'
          if confirmOrUnlinkFacebookFundraiserResponse?.active is 'false'
            delete $rootScope.facebookFundraiserId
            $rootScope.facebookFundraiserConfirmedStatus = 'deleted'
          else
            $rootScope.facebookFundraiserConfirmedStatus = 'confirmed'

    $scope.getParticipantShortcut = ->
      getParticipantShortcutPromise = NgPcTeamraiserShortcutURLService.getShortcut()
        .then (response) ->
          if response.data.errorResponse
            # TODO
          else
            shortcutItem = response.data.getShortcutResponse.shortcutItem
            if not shortcutItem
              # TODO
            else
              if shortcutItem.prefix
                shortcutItem.prefix = shortcutItem.prefix
              $scope.participantShortcut = shortcutItem
              if shortcutItem.url
                $scope.personalPageUrl = shortcutItem.url
              else
                $scope.personalPageUrl = shortcutItem.defaultUrl.split('/site/')[0] + '/site/TR?fr_id=' + $scope.frId + '&pg=personal&px=' + $scope.consId
              $scope.personalPageUrlEsc = window.encodeURIComponent($scope.personalPageUrl)
          response
    $scope.getParticipantShortcut()

    $scope.socialEarnedThankYou = 0
    $scope.putSocialMedia = (event, sel) ->
      BoundlessService.putSocialMedia()
        .then (response) ->
          $scope.socialEarnedThankYou = 1

    $scope.socialEarned = -1
    getFinnsMission = ->
      BoundlessService.getBadges $scope.frId + '/' + $scope.consId
      .then (response) ->
        prizes = response.data.prizes
        angular.forEach prizes, (prize) ->
          if prize.label == "Go Social"
            if prize.status != 0
              $scope.socialEarned = 1
            else 
              $scope.socialEarned = 0
    getFinnsMission()
    
    urlPrefix = ''
    if $scope.tablePrefix is 'heartdev'
      urlPrefix = 'load'
    else
      urlPrefix = 'loadaha'
    consId = $scope.consId
    frId = $rootScope.frId
    auth = $rootScope.authToken
    jsession = $rootScope.sessionCookie
    url = 'https://' + urlPrefix + '.boundlessfundraising.com/applications/ahatgr/social/app/ui/#/addsocial/' + consId + '/' + frId + '/' + auth + '/' + jsession + '?source=PCSocial'
    $scope.socialIframeURL = $sce.trustAsResourceUrl url
    return
  ]
