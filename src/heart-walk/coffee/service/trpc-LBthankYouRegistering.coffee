angular.module 'trPcApp'
  .factory 'ThankYouRegService', [
    '$rootScope'
    '$q'
    ($rootScope, $q) ->
      getThankYou: ->
        useDeffered = ->
          deferred = $q.defer()
          deferred.resolve $rootScope.LBthankYou
          deferred.promise
        if $rootScope.participantRegistration.lastPC2Login is '0'
          $rootScope.LBthankYou = 1
          useDeffered()
        else
          $rootScope.LBthankYou = -1
          useDeffered()
  ]
