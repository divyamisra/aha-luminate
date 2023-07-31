angular.module('ahaLuminateApp').filter 'time', ->
  (input) ->
    hours = Math.floor(input / 60)
    minutes = input - (hours * 60)
    minutes = if minutes < 10 then '0' + minutes else minutes
    hours + ' hrs ' + minutes + ' mins'
