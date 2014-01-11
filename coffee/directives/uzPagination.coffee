timeTracker.directive 'uzPagination', ($window) ->

  MIN_SIZE = 4

  return {
    restrict: 'E'
    template: "<pagination class='pagination-small'" +
                          "boundary-links='true'" +
                          "total-items='totalItems'" +
                          "page='page'" +
                          "items-per-page='itemsPerPage'" +
                          "max-size='maxSize'" +
                          "previous-text='&lsaquo;'" +
                          "next-text='&rsaquo;'" +
                          "first-text='&laquo;'" +
                          "last-text='&raquo;'></pagination>"

    scope:
      page:         '='
      totalItems:   '='
      itemsPerPage: '='

    link: (scope, element, attrs) ->

      # Limit number for pagination size.
      scope.maxSize = 1

      arrowWidth = null

      # calculate pagination bar's size.
      calculateSize = () ->
        alist = element.find('a')
        if alist.length <= MIN_SIZE then return
        arrowWidth = arrowWidth or ($(alist[0]).outerWidth(true) + $(alist[1]).outerWidth(true)) * 2
        buttonWidth = 0
        wlist = for a in alist then $(a).outerWidth(true)
        buttonWidth = Math.max.apply({}, wlist)
        scope.maxSize = Math.floor((element.outerWidth() - arrowWidth) / buttonWidth)
        scope.maxSize = 1 if scope.maxSize < 1

      # resize pagination bar
      scope.$watch 'page', calculateSize
      scope.$watch 'totalItems', calculateSize
      angular.element($window).on 'resize', () ->
        scope.$apply calculateSize
  }
