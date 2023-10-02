angular.module 'ahaLuminateApp'
  .directive 'ngEnter', ->
    (scope, element, attrs) ->
      element.bind 'keydown keypress', (event) ->
        if event.which == 13
          scope.$apply ->
            scope.$eval attrs.ngEnter
            return
          event.preventDefault()
        return
      return
