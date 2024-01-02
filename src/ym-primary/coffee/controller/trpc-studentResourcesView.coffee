angular.module 'trPcControllers'
  .controller 'NgPcStudentResourcesViewCtrl', [
    '$scope'
    'PageBuilderService'
    ($scope, PageBuilderService) ->
      PageBuilderService.getPageContent 'reus_ym_khc_student_resources', ''
        .then (response) ->
          pageContent = response.data
          if pageContent
            $scope.pageContent = pageContent
            
            setTimeout (->
              jQuery('.selschool').removeClass 'selected'
              jQuery('[sel="elementary"]').addClass 'selected'
              $container1 = jQuery('.elementary')
              $container1.imagesLoaded ->
                $container1.masonry itemSelector: '.box'
                return
            ), 500
]
