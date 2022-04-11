angular.module 'ahaLuminateControllers'
  .controller 'SchoolSearchCtrl', [
    '$scope'
    'SchoolSearchService'
    ($scope, SchoolSearchService) ->
      # on init - last param true = get events by location on load; false = do nothing on load
      SchoolSearchService.init $scope, 'YM Kids Heart Challenge 2022', (location.protocol is 'https:')
      # SchoolSearchService.init $scope, 'YM Kids Heart Challenge', false
  ]
