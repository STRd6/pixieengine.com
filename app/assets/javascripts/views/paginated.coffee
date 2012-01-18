#= require underscore
#= require backbone
#= require tmpls/pagination

#= require pixie/view

namespace "Pixie.Views", (Views) ->
  class Views.Paginated extends Pixie.View
    className: 'pagination'
    tagName: 'nav'

    initialize: ->
      super

      @collection.bind 'fetching', =>
        @$('.spinner').show()

      @collection.bind 'afterReset', =>
        @$('.spinner').hide()
        @render()

    events:
      'click a.prev': 'previous'
      'click a.next': 'next'
      'click a.page': 'toPage'

    toPage: (e) =>
      e.preventDefault()
      @collection.toPage($(e.target).data('page'))

    previous: (e) =>
      e.preventDefault()
      @collection.previousPage()

    next: (e) =>
      e.preventDefault()
      @collection.nextPage()

    render: =>
      @el.empty()

      pages = $.tmpl('pagination', @collection.pageInfo())

      @el.html(pages)

      return @

