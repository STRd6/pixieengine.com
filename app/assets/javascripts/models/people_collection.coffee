#= require underscore
#= require backbone
#= require corelib
#= require models/paginated_collection
#= require models/person

window.Pixie ||= {}
Pixie.Models ||= {}

class Pixie.Models.PeopleCollection extends Pixie.Models.PaginatedCollection
  filterPages: (filter) =>
    # gross
    filter = 'none' if filter == 'all'

    @page = 1
    @params.page = @page
    @params.filter = filter
    @fetch()

  model: Pixie.Models.Person

  parse: (data) =>
    Pixie.Models.PaginatedCollection.prototype.parse.call(@, data)

  url: ->
    '/people'
