angular.module 'ahaLuminateApp'
  .config [
    '$uibModalProvider'
    ($uibModalProvider) ->
      angular.extend $uibModalProvider.options, 
        windowClass: 'rc-modal show'
  ]
