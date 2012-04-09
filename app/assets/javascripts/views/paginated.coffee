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
        @$('.spinner_container').fadeIn(150)

      @collection.bind 'afterReset', =>
        @$('.spinner_container').fadeOut(150)

        @render()

        if @collection.pageInfo().next
          @el.css('visibility: visible')
        else
          @el.css('visibility: hidden')

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

      pages = $.tmpl('tmpls/pagination', @collection.pageInfo())

      @el.html(pages)

      return @

