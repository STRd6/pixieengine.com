#= require underscore
#= require backbone
#= require views/paginated
#= require views/people/person
#= require models/people_collection
#= require models/paginated_collection

#= require tmpls/people/header
#= require tmpls/pagination

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.People ||= {}

class Pixie.Views.People.Gallery extends Pixie.Views.Paginated
  el: ".gallery"

  events:
    'click .filter': 'filterResults'

  initialize: ->
    self = @

    # merge the superclass paging related events
    @events = _.extend(@pageEvents, @events)
    @delegateEvents()

    @collection = new Pixie.Models.PeopleCollection

    @collection.bind 'fetching', ->
      $(self.el).find('.spinner').show()

    @collection.bind 'reset', (people) ->
      $(self.el).find('nav').remove()
      $(self.el).find('.items').remove()
      $(self.el).append $.tmpl("people/header", people.pageInfo())
      $(self.el).find('.filter').filter( ->
        $(this).text().toLowerCase() == self.filter
      ).takeClass('active')

      people.each(self.addPerson)

      self.updatePagination()

  addPerson: (person) =>
    view = new Pixie.Views.People.Person({ model: person, collection: @collection })
    $(@el).find('.items').append(view.render().el)

  filterResults: (e) =>
    @filter = $(e.target).text().toLowerCase()

    @collection.filterPages(@filter)

  updatePagination: =>
    $(@el).find('.pagination').html $.tmpl('pagination', @collection.pageInfo())

