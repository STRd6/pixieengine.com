#= require underscore
#= require backbone
#= require views/paginated
#= require views/filtered
#= require views/people/person
#= require models/people_collection
#= require models/paginated_collection

#= require tmpls/people/header
#= require tmpls/pagination

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.People ||= {}

class Pixie.Views.People.Gallery extends Backbone.View
  el: ".gallery"

  initialize: ->
    @collection = new Pixie.Models.PeopleCollection

    pages = new Pixie.Views.Paginated({ collection: @collection })
    filters = new Pixie.Views.Filtered
      collection: @collection
      filters: ['Featured', 'All']
      activeFilter: 'Featured'

    $(@el).append $ '<div class="items"></div>'
    $(@el).find('.items').before(filters.render().el)

    @collection.bind 'reset', (projects) =>
      $(@el).find('.items').empty()
      $(@el).find('.items').before(pages.render().el)

      $(@el).find('.filter').filter( ->
        $(this).text().toLowerCase() == @filter
      ).takeClass('active')

      projects.each(@addPerson)

      projects.trigger 'afterReset'

  addPerson: (person) =>
    view = new Pixie.Views.People.Person({ model: person, collection: @collection })
    $(@el).find('.items').append(view.render().el)

