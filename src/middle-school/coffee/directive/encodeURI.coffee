angular.module 'ahaLuminateApp'
  .filter 'urlEncode', ->
    return window.encodeURIComponent
