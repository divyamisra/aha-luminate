angular.module 'trPcControllers'
  .controller 'NgPcTeacherResourcesViewCtrl', [
    '$scope'
    'PageBuilderService'
    '$sce'
    ($scope, PageBuilderService, $sce) ->
      $scope.trustHtml = (html) ->
        return $sce.trustAsHtml(html)
      PageBuilderService.getPageContent 'reus_ym_khc_teacher_resources', 'tab=middleschool'
        .then (response) ->
          pageContent = response.data
          if pageContent
            $scope.pageContent = pageContent
]
