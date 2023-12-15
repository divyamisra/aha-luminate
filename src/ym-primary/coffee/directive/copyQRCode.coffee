angular.module 'ahaLuminateApp'
  .directive 'copyQrcode', ->
    (scope, element, attrs) ->
      element.bind 'click', (event) ->
        #CopyImageClipboard.copyImageToClipboard attrs.copyImage
        canvas = angular.element('#qrcode canvas').get(0)
        img = document.createElement('img')
        img.src = canvas.toDataURL()
        div = document.createElement('div')
        div.contentEditable = true
        div.appendChild img
        angular.element('#qrcode').append div
        div.focus()
        window.getSelection().selectAllChildren div
        document.execCommand 'Copy'
        angular.element(div).remove()
        element.html 'Copied!'
        angular.element('.clipboard-copy').remove()
        element.after '<div class="clipboard-copy text-center small" role="alert" aria-atomic="true">QR Code copied to clipboard</div>'
      return
