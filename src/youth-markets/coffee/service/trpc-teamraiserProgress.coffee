angular.module 'trPcApp'
  .factory 'NgPcTeamraiserProgressService', [
    'NgPcLuminateRESTService'
    (NgPcLuminateRESTService) ->
      getProgress: (frId) ->
        requestData = 'method=getParticipantProgress'
        includeFrId = true
        if frId
          requestData += '&fr_id=' + frId
          includeFrId = false
        NgPcLuminateRESTService.teamraiserRequest requestData, false, includeFrId
          .then (response) ->
            response
  ]