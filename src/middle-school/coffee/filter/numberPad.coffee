angular.module('ahaLuminateApp').filter 'numpad', ->
  (input) ->
    if input < 10 then '0' + input else input
