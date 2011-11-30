#= require underscore
#= require backbone
#= require tmpls/pagination

window.Pixie ||= {}
Pixie.Views ||= {}

class Pixie.Views.Paginated extends Backbone.View
  className: 'pagination'
  tagName: 'nav'

  initialize: ->
    self = @

    @collection.bind 'fetching', ->
      $(self.el).find('.spinner').show()

    @collection.bind 'afterReset', ->
      $(self.el).find('.spinner').hide()
      self.updatePagination()

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
    pages = $.tmpl('pagination', @collection.pageInfo())

    $(@el).html(pages)
