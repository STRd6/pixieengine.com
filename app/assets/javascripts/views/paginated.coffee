#= require underscore
#= require backbone
#= require tmpls/pagination

window.Pixie ||= {}
Pixie.Views ||= {}

class Pixie.Views.Paginated extends Backbone.View
  className: 'pagination'
  tagName: 'nav'

  initialize: ->
    @collection.bind 'fetching', =>
      $(@el).find('.spinner').show()

    @collection.bind 'afterReset', =>
      $(@el).find('.spinner').hide()
      @updatePagination()

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
    return @

  updatePagination: =>
    $(@el).empty()
    pages = $.tmpl('pagination', @collection.pageInfo())

    $(@el).html(pages)
