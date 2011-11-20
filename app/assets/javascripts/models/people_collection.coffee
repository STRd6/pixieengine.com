#= require underscore
#= require backbone
#= require models/paginated_collection
#= require models/person

window.Pixie ||= {}
Pixie.Models ||= {}

class Pixie.Models.PeopleCollection extends Pixie.Models.PaginatedCollection
  model: Pixie.Models.Person

  parse: (data) =>
    Pixie.Models.PaginatedCollection.prototype.parse.call(@, data)

  url: ->
    '/people'
