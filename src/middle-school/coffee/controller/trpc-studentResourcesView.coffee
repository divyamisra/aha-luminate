angular.module 'trPcControllers'
  .controller 'NgPcStudentResourcesViewCtrl', [
    '$scope'
    'PageBuilderService'
    ($scope, PageBuilderService) ->
      PageBuilderService.getPageContent 'reus_ym_ahc_student_resources', ''
        .then (response) ->
          pageContent = response.data
          if pageContent
            $scope.pageContent = pageContent
            #call masonry
            jQuery.getScript '../ym-files/packery.pkgd.min.js', ->
              jQuery.getScript '../ym-files/imagesloaded.min.js', ->
                $container2 = jQuery('.middleschool')
                $container2.imagesLoaded ->
                  $container2.packery itemSelector: '.box', gutter: 1
                  return
                return
              return
]
