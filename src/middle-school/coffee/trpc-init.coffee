angular.module 'trPcApp', [
  'ngRoute'
  'ngCsv'
  'textAngular'
  'trPcControllers'
  'ngAria'
]

angular.module 'trPcControllers', []

angular.module 'trPcApp'
  .constant 'NG_PC_APP_INFO', 
    version: '0.1.0'
    rootPath: do ->
      rootPath = ''
      devBranch = luminateExtend.global.devBranch
      if devBranch and devBranch isnt ''
        rootPath = '../' + devBranch + '/aha-luminate/'
      else
        rootPath = '../aha-luminate/'
      rootPath
    programKey: 'middle-school'

angular.module 'trPcApp'
  .run [
    '$rootScope'
    'NG_PC_APP_INFO'
    ($rootScope, NG_PC_APP_INFO) ->
      # get data from embed container
      $embedRoot = angular.element '[data-embed-root]'
      $rootScope.prev1FrId = $embedRoot.data('prev-one-fr-id') or ''
      $rootScope.prev2FrId = $embedRoot.data('prev-two-fr-id') or ''
      $rootScope.consName = $embedRoot.data('cons-name') or ''
      studentRegGoal = $embedRoot.data('student-reg-goal') or '0'
      if isNaN studentRegGoal
        studentRegGoal = 0
      else
        studentRegGoal = Number studentRegGoal
      $rootScope.studentRegGoal = studentRegGoal
  ]

angular.element(document).ready ->
  if not angular.element(document).injector()
    angular.bootstrap document, [
      'trPcApp'
    ]