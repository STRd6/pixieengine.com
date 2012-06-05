#= require views/paginated
#= require views/filtered
#= require views/searchable
#= require views/people/person
#= require models/people_collection
#= require models/paginated_collection

#= require pixie/view

#= require templates/people/header
#= require templates/pagination

namespace "Pixie.Views.People", (People) ->
  {Models, Views} = Pixie

  class People.Gallery extends Pixie.View
    el: ".gallery"

    initialize: ->
      super

      @collection = new Models.PeopleCollection

      pages = new Views.Paginated({ collection: @collection })
      filters = new Views.Filtered
        collection: @collection
        filters: ['Featured', 'All']
        activeFilter: 'Featured'

      searchable = new Views.Searchable
        collection: @collection

      @el.append $ '<div class="items"></div>'
      @$('.items').before(filters.render().el)
      @$('.items').before(searchable.render().el)

      @collection.bind 'reset', (projects) =>
        @$('.items').empty()
        @$('.items').before(pages.render().el)

        @$('.filter').filter( ->
          $(this).text().toLowerCase() == @filter
        ).takeClass('active')

        projects.each(@addPerson)

        projects.trigger 'afterReset'

    addPerson: (person) =>
      view = new People.Person({ model: person, collection: @collection })
      @$('.items').append(view.render().el)

