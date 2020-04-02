angular.module 'trPcApp'
  .factory 'RichTextService', [
    '$rootScope'
    ($rootScope) ->
      richTextToPlainText: (richText) ->
        $tempElem = jQuery('<div>' + richText + '</div>')
        $tempElem.find('*').each (wildcardElemIndex, wildcardElem) ->
          jQuery(wildcardElem).html jQuery(wildcardElem).html().replace(/(?:\r\n|\r|\n)/g, ' ')
        $tempElem.find('ul, ol').each (orderedListIndex, orderedList) ->
          jQuery(orderedList).find('li').each (listItemIndex, listItem) ->
            listItemPrepend = '* '
            listItemAppend = ''
            if jQuery(listItem).is 'ol li'
              listItemPrepend = (listItemIndex + 1) + '. '
            if jQuery(listItem).next('li').length > 0
              listItemAppend = '\n'
            jQuery(listItem).html(listItemPrepend + jQuery(listItem).html() + listItemAppend)
        $tempElem.find('p, ul, ol').each (blockLevelElemIndex, blockLevelElem) ->
          blockLevelElemAppend = ''
          if jQuery(blockLevelElem).next('*').length > 0
            blockLevelElemAppend = '\n\n'
          jQuery(blockLevelElem).html(jQuery(blockLevelElem).html() + blockLevelElemAppend)
        jQuery.trim $tempElem.text()
  ]