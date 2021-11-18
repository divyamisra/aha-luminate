angular.module 'ahaLuminateControllers'
  .controller 'MainCtrl', [
    '$rootScope'
    '$scope'
    '$httpParamSerializer'
    'AuthService'
    'CatalogService'
    'TeamraiserRegistrationService'
    '$timeout'
    ($rootScope, $scope, $httpParamSerializer, AuthService, CatalogService, TeamraiserRegistrationService, $timeout) ->
      $dataRoot = angular.element '[data-aha-luminate-root]'
      consId = $dataRoot.data('cons-id') if $dataRoot.data('cons-id') isnt ''
      $scope.protocol = window.location.protocol
      $scope.productList = []
      $scope.cartProductList = []
      $scope.TotalPointsInCart = 0

      getTotalPoints = (save) ->
        $scope.TotalPointsInCart = $scope.cartProductList.map((item) ->
          Number.parseInt item.totalPoints
        ).reduce(((acc, curr) ->
          acc + curr
        ), 0)
        if save
          $scope.saveProductCart()
        $scope.TotalPointsAvailable = $scope.TotalPointsEarned - ($scope.TotalPointsInCart)

      $scope.getSchoolPlan = ->
        CatalogService.schoolPlanData '&method=GetSchoolPlan&CompanyId=' + $scope.participantRegistration.companyInformation.companyId + '&EventId=' + $scope.frId,
          failure: (response) ->
          error: (response) ->
          success: (response) ->
            angular.forEach response.data.company, (school) ->
              $scope.coordinatorPoints = JSON.parse(school.PointsDetail)
              $scope.TotalPointsEarned = school.TotalPointsEarned
              $scope.TotalPointsAvailable = school.TotalPointsEarned

      $scope.getSchoolProducts = ->
        CatalogService.schoolPlanData '&method=GetSchoolProducts&CompanyId=' + $scope.participantRegistration.companyInformation.companyId + '&EventId=' + $scope.frId,
          failure: (response) ->
          error: (response) ->
          success: (response) ->
            $scope.productList = response.data.company['list']
            angular.forEach $scope.productList, (product, index) ->
              $scope.productList[index].detail = response.data.company['detail'].filter((element) ->
                element.productId == product.productId
              )

      $scope.getProductCart = ->
        CatalogService.schoolPlanData '&method=GetProductCart&CompanyId=' + $scope.participantRegistration.companyInformation.companyId,
          failure: (response) ->
          error: (response) ->
          success: (response) ->
            if response.data.company[0] != null
              $scope.cartProductList = JSON.parse(response.data.company[0].cart)
              getTotalPoints(false)

      $scope.saveProductCart = ->
        CatalogService.schoolPlanData '&method=SaveProductCart&CompanyId=' + $scope.participantRegistration.companyInformation.companyId + '&cart=' + angular.toJson($scope.cartProductList),
          failure: (response) ->
          error: (response) ->
          success: (response) ->

      $scope.addProductToCart = (product) ->
        productExistInCart = undefined
        productIdx = product.currentTarget.attributes.productid.value
        sizeExists = product.currentTarget.attributes.sizeexists.value
        quantity = parseInt(angular.element('div.' + productIdx + ' select[name=quantity]').find('option:selected').val())
        if sizeExists == 'true'
          productIdx = angular.element('div.' + productIdx + ' select[name=size]').find('option:selected').val()
        if quantity * product.currentTarget.attributes.points.value <= $scope.TotalPointsAvailable
          productExistInCart = $scope.cartProductList.find((element) ->
            element.productId == productIdx
          )
          if !productExistInCart
            $scope.cartProductList.push
              productId: productIdx
              productName: product.currentTarget.name
              points: parseInt(product.currentTarget.attributes.points.value)
              totalPoints: quantity * product.currentTarget.attributes.points.value
              origNum: quantity
              num: quantity
          else
            productExistInCart.num += quantity
            productExistInCart.origNum = productExistInCart.num
            productExistInCart.totalPoints = product.currentTarget.attributes.points.value * productExistInCart.num
          getTotalPoints true
        else
          alert 'Not enough points available'

      $scope.updateProductInCart = ->
        productExistInCart = undefined
        productIdx = @cartProduct.productId
        quantity = @cartProduct.num
        if quantity * @cartProduct.points <= $scope.TotalPointsAvailable + @cartProduct.totalPoints
          productExistInCart = $scope.cartProductList.find((element) ->
            element.productId == productIdx
          )
          if productExistInCart
            productExistInCart.num = quantity
            productExistInCart.origNum = productExistInCart.num
            productExistInCart.totalPoints = @cartProduct.points * productExistInCart.num
          getTotalPoints true
        else
          @cartProduct.num = @cartProduct.origNum
          alert 'Not enough points available'

      $scope.removeProduct = (product) ->
        $scope.cartProductList = $scope.cartProductList.filter((element) ->
          element.productId != product.currentTarget.attributes.productid.value
        )
        getTotalPoints true      
      
      $scope.headerLoginInfo = 
        user_name: ''
        password: ''
      
      $scope.submitHeaderLogin = ->
        AuthService.login $httpParamSerializer($scope.headerLoginInfo), 
          error: ->
            angular.element('.js--default-header-login-form').submit()
          success: ->
            if not $scope.headerLoginInfo.ng_nexturl or $scope.headerLoginInfo.ng_nexturl is ''
              window.location = $rootScope.secureDomain + 'site/SPageServer?pagename=ym_coordinator_reward_center'
            else
              window.location = $scope.headerLoginInfo.ng_nexturl
      
      if $scope.consId
        TeamraiserRegistrationService.getRegistration
          success: (response) ->
            participantRegistration = response.getRegistrationResponse?.registration
            if participantRegistration
              $rootScope.participantRegistration = participantRegistration
              $scope.getSchoolPlan()
              $scope.getProductCart()
              $scope.getSchoolProducts()
  ]
