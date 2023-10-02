angular.module 'ahaLuminateApp'
  .directive 'ngCsv', [
    'CsvDownloadService'
    (CsvDownloadService) ->
      link: (scope, element, attrs) ->
        element.bind 'click', (event) ->
          #CopyImageClipboard.copyImageToClipboard attrs.copyImage
          CsvDownloadService.downloadFile scope.$eval(attrs.ngCsv), attrs.filename, scope.$eval(attrs.csvHeader), scope.$eval(attrs.csvFields) 
          scope.buildCSVPending = 'done'
        return
  ]
