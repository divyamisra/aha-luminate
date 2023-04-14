angular.module 'trPcApp', [
  'ngRoute'
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
    programKey: 'ym-primary'

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
      $rootScope.consNameFirst = $embedRoot.data('cons-first-name') or ''
      $rootScope.consNameLast = $embedRoot.data('cons-last-name') or ''
      studentRegGoal = $embedRoot.data('student-reg-goal') or '0'
      if isNaN studentRegGoal
        studentRegGoal = 0
      else
        studentRegGoal = Number studentRegGoal
      $rootScope.studentRegGoal = studentRegGoal
      $rootScope.challengeTaken = $embedRoot.data('challenge-taken') if $embedRoot.data('challenge-taken') isnt ''
      AmountRaised = $embedRoot.data('dollars') or '0'
      $rootScope.AmountRaised = Number((AmountRaised).replace('$', '').replace(/,/g, ''))
      
      $rootScope.usePcEmail = $embedRoot.data('use-pc-email') or ''
  ]

angular.element(document).ready ->
  setTimeout ->
    if not angular.element(document).injector()
      angular.bootstrap document, [
        'trPcApp'
      ]
  ,1000
