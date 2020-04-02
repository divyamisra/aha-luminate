appDependencies = [
  'ngSanitize'
  'ngTouch'
  'angular.filter'
  'ui.bootstrap'
  'ahaLuminateControllers'
  'ngAria'
]

angular.forEach ['textAngular'], (appDependency) ->
  try
    angular.module appDependency
    appDependencies.push appDependency
  catch error

angular.module 'ahaLuminateApp', appDependencies

angular.module 'ahaLuminateControllers', []

angular.module 'ahaLuminateApp'
  .constant 'APP_INFO',
    version: '1.0.0'
    rootPath: do ->
      rootPath = ''
      devBranch = luminateExtend.global.devBranch
      if devBranch and devBranch isnt ''
        rootPath = '../' + devBranch + '/aha-luminate/'
      else
        rootPath = '../aha-luminate/'
      rootPath
    programKey: 'ym-primary'

angular.module 'ahaLuminateApp'
  .run [
    '$rootScope'
    '$sce'
    'APP_INFO'
    ($rootScope, $sce, APP_INFO) ->
      $rootScope.eventType = 'ym-primary'
      $rootScope.tablePrefix = luminateExtend.global.tablePrefix
      $rootScope.nonSecureDomain = luminateExtend.global.path.nonsecure.split('/site/')[0] + '/'
      $rootScope.secureDomain = luminateExtend.global.path.secure.split('/site/')[0] + '/'
      $rootScope.teamraiserAPIPath = $sce.trustAsResourceUrl luminateExtend.global.path.secure + 'CRTeamraiserAPI'
      
      # get data from root element
      $dataRoot = angular.element '[data-aha-luminate-root]'
      $rootScope.frId = $dataRoot.data('fr-id') if $dataRoot.data('fr-id') isnt ''
      $rootScope.consId = $dataRoot.data('cons-id') if $dataRoot.data('cons-id') isnt ''
      $rootScope.apiKey = $dataRoot.data('api-key') if $dataRoot.data('api-key') isnt ''
      $rootScope.authToken = $dataRoot.data('auth-token') if $dataRoot.data('auth-token') isnt ''
      $rootScope.sessionCookie = $dataRoot.data('session-cookie') if $dataRoot.data('session-cookie') isnt ''
      $rootScope.dev_branch = $dataRoot.data('dev-branch') if $dataRoot.data('dev-branch') isnt ''
      $rootScope.facebookFundraisersEnabled = $dataRoot.data('facebook-fundraisers-enabled') is 'TRUE'
      $rootScope.facebookFundraiserId = $dataRoot.data('facebook-fundraiser-id') if $dataRoot.data('facebook-fundraiser-id') isnt ''
  ]

angular.element(document).ready ->
  appModules = [
    'ahaLuminateApp'
  ]

  try
    angular.module 'trPcApp'
    appModules.push 'trPcApp'
  catch error

  angular.bootstrap document, appModules
