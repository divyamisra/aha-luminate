if window.location.href.indexOf('pagename=ym_khc_participant_center') isnt -1
  angular.module 'trPcApp'
    .config [
      '$routeProvider'
      'APP_INFO'
      ($routeProvider, APP_INFO) ->
        $routeProvider
          .when '/load-error', 
            templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/view/loadError.html'
            controller: 'NgPcLoadErrorViewCtrl'
          .when '/dashboard', 
            templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/view/dashboard.html'
            controller: 'NgPcDashboardViewCtrl'
          .when '/dashboard-student', 
            templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/view/dashboard.html'
            controller: 'NgPcDashboardViewCtrl'
          .when '/email', 
            redirectTo: '/email/compose'
          .when '/email/compose/:messageType?/:messageId?', 
            templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/view/emailCompose.html'
            controller: 'NgPcEmailComposeViewCtrl'
          .when '/email/message/:messageType', 
            redirectTo: '/email/message/:messageType/list'
          .when '/email/message/:messageType/list', 
            templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/view/emailMessageList.html'
            controller: 'NgPcEmailMessageListViewCtrl'
          .when '/email/contacts', 
            redirectTo: '/email/contacts/email_rpt_show_all/list'
          .when '/email/contacts/:filter', 
            redirectTo: '/email/contacts/:filter/list'
          .when '/email/contacts/:filter/list', 
            templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/view/emailContactsList.html'
            controller: 'NgPcEmailContactsListViewCtrl'
          .when '/reports', 
            templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/view/reports.html'
            controller: 'NgPcReportsViewCtrl'
          .when '/student-resources', 
            templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/view/studentResources.html'
            controller: 'NgPcStudentResourcesViewCtrl'
          .when '/teacher-resources', 
            templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/view/teacherResources.html'
            controller: 'NgPcTeacherResourcesViewCtrl'
          .when '/social', 
            templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/view/social.html'
            controller: 'NgPcSocialViewCtrl'
          .when '/gifts', 
            templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/view/gifts.html'
            controller: 'NgPcGiftsViewCtrl'
          .when '/faq', 
            templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/view/faq.html'
            controller: 'NgPcFAQViewCtrl'
          .otherwise 
            redirectTo: do ->
              # redirect PC1-style URLs
              $embedRoot = angular.element '[data-embed-root]'
              pcPage = $embedRoot.data('pc-page') if $embedRoot.data('pc-page') isnt ''
              if pcPage is 'mtype'
                '/email/compose'
              else if pcPage is 'abook'
                '/email/contacts/email_rpt_show_all/list'
              else
                '/dashboard'
    ]
  
  angular.module 'trPcApp'
    .run [
      '$rootScope'
      '$location'
      '$route'
      '$uibModal'
      'APP_INFO'
      'NgPcAuthService'
      'NgPcTeamraiserEventService'
      'NgPcTeamraiserRegistrationService'
      'NgPcTeamraiserCompanyService'
      ($rootScope, $location, $route, $uibModal, APP_INFO, NgPcAuthService, NgPcTeamraiserEventService, NgPcTeamraiserRegistrationService, NgPcTeamraiserCompanyService) ->
        $rootScope.$on '$routeChangeStart', ($event, next, current) ->
          # ensure window is scrolled
          window.scrollTo 0, 0
          
          # redirect to a different route
          redirectRoute = (newRoute) ->
            $rootScope.$evalAsync ->
              $location.path newRoute
          
          # avoid race condition with reloading route
          reloadRoute = ->
            if $location.path() not in ['', next.originalPath]
              redirectRoute next.originalPath
            else
              $route.reload()
          
          # prompt logged out users to login
          showLoginModal = ->
            if not $rootScope.loginModal
              $rootScope.loginModal = $uibModal.open 
                scope: $rootScope
                backdrop: 'static'
                templateUrl: APP_INFO.rootPath + 'dist/ym-primary/html/participant-center/modal/login.html'
          
          # load error
          if $rootScope.loadError
            if next.originalPath isnt '/load-error'
              $event.preventDefault()
              redirectRoute '/load-error'
          
          # event config unknown
          else if not $rootScope.teamraiserConfig
            $event.preventDefault()
            NgPcTeamraiserEventService.getConfig()
              .then ->
                if $rootScope.teamraiserConfig is -1
                  $rootScope.loadError = true
                reloadRoute()
          
          # no event config
          else if $rootScope.teamraiserConfig is -1
            $event.preventDefault()
            $rootScope.loadError = true
            reloadRoute()
          
          # event closed
          else if $rootScope.teamraiserConfig.acceptingDonations isnt 'true' and $rootScope.teamraiserConfig.acceptingRegistrations isnt 'true'
            $event.preventDefault()
            window.location = luminateExtend.global.path.secure + 'TR?fr_id=' + $rootScope.frId
          
          # login state unknown
          else if not $rootScope.consId
            $event.preventDefault()
            NgPcAuthService.getLoginState()
              .then ->
                if $rootScope.consId is -1
                  showLoginModal()
                else
                  $route.reload()
          
          # logged out
          else if $rootScope.consId is -1
            $event.preventDefault()
            showLoginModal()
          
          # no auth token
          else if not $rootScope.authToken
            $event.preventDefault()
            NgPcAuthService.getAuthToken()
              .then ->
                reloadRoute()
          
          # registration status unknown
          else if not $rootScope.participantRegistration
            $event.preventDefault()
            NgPcTeamraiserRegistrationService.getRegistration()
              .then ->
                if $rootScope.participantRegistration is -1
                  window.location = luminateExtend.global.path.secure + 'TR?fr_id=' + $rootScope.frId
                else
                  reloadRoute()
          
          # not registered
          else if $rootScope.participantRegistration is -1
            $event.preventDefault()
            window.location = luminateExtend.global.path.secure + 'TR?fr_id=' + $rootScope.frId
          
          # event info unknown
          else if not $rootScope.eventInfo
            $event.preventDefault()
            NgPcTeamraiserEventService.getTeamraiser()
              .then (response) ->
                if $rootScope.eventInfo is -1
                  $rootScope.loadError = true
                reloadRoute()
          
          # no event info
          else if $rootScope.eventInfo is -1
            $event.preventDefault()
            $rootScope.loadError = true
            reloadRoute()
          
          # company info unknown
          else if not $rootScope.companyInfo
            $event.preventDefault()
            NgPcTeamraiserCompanyService.getCompany()
              .then (response) ->
                if $rootScope.companyInfo is -1
                  $rootScope.loadError = true
                reloadRoute()
          
          # no company info
          else if $rootScope.companyInfo is -1
            $event.preventDefault()
            $rootScope.loadError = true
            reloadRoute()
          
          # no load error
          else if next.originalPath is '/load-error'
            $event.preventDefault()
            redirectRoute '/dashboard'
    ]
