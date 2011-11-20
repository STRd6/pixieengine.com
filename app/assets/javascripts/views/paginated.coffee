#= require underscore
#= require backbone

window.Pixie ||= {}
Pixie.Views ||= {}

class Pixie.Views.Paginated extends Backbone.View
  pageEvents:
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

