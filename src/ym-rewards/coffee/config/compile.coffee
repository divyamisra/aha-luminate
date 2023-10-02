angular.module 'ahaLuminateApp'
  .config [
    '$compileProvider'
    ($compileProvider) ->
      # workaround for https://github.com/angular/material/issues/10244
      $compileProvider.preAssignBindingsEnabled true
  ]
