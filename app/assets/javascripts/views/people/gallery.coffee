#= require underscore
#= require backbone
#= require views/paginated_view
#= require views/people/person
#= require models/people_collection
#= require models/paginated_collection

#= require tmpls/people/header
#= require tmpls/pagination

window.Pixie ||= {}
Pixie.Views ||= {}
Pixie.Views.People ||= {}

class Pixie.Views.People.Gallery extends Pixie.Views.Paginated
  el: ".people"

  initialize: ->
    self = @

    # merge the superclass paging related events
    @events = _.extend(@pageEvents, @events)
    @delegateEvents()

    @collection = new Pixie.Models.PeopleCollection

    @collection.bind 'fetching', ->
      $(self.el).find('.spinner').show()

    @collection.bind 'reset', (collection) ->
      $(self.el).find('.header').remove()
      $(self.el).find('.pagination').remove()
      $(self.el).append $.tmpl("people/header", self.collection.pageInfo())

      $(self.el).find('.people').remove()
      $(self.el).find('.spinner').hide()
      collection.each(self.addPerson)

      self.updatePagination()

  addPerson: (person) =>
    view = new Pixie.Views.People.PersonView({ model: person, collection: @collection })
    $(@el).append(view.render().el)

  updatePagination: =>
    $(@el).find('.pagination').html $.tmpl('pagination', @collection.pageInfo())

