#= require templates/pagination

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

    events:
      'click a.previous': 'previous'
      'click a.next': 'next'
      'click a.page': 'toPage'

    toPage: (e) =>
      e.preventDefault()

      return unless (page = $(e.target).data('page'))

      @collection.toPage(page)

    previous: (e) =>
      e.preventDefault()

      return if $(e.currentTarget).parent().is('.disabled')

      @collection.previousPage()

    next: (e) =>
      e.preventDefault()

      return if $(e.currentTarget).parent().is('.disabled')

      @collection.nextPage()

    render: =>
      @el.empty().html $(JST['templates/pagination'](@collection.pageInfo()))

      return @

