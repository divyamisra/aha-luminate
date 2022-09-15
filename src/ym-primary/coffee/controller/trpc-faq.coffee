angular.module 'trPcControllers'
  .controller 'NgPcFAQViewCtrl', [
    '$scope'
    'PageBuilderService'
    ($scope, PageBuilderService) ->
      PageBuilderService.getPageContent 'reus_ym_khc_student_faq', ''
        .then (response) ->
          pageContent = response.data
          if pageContent
            $scope.pageContent = pageContent
]
