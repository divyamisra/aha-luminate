angular.module 'ahaLuminateApp'
  .directive 'ngCapitalize', ->
    (scope, element, attrs) ->
      element.bind 'blur', (el) ->
        if el.currentTarget.value and !scope['cap-' + el.currentTarget.name]
          scope['cap-' + el.currentTarget.name] = true
          arr = el.currentTarget.value.split('')
          arr[0] = arr[0].toUpperCase()
          el.currentTarget.value = arr.join('')
