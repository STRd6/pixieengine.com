#= require underscore
#= require backbone
#= require corelib
#= require models/paginated_collection
#= require models/person

namespace "Pixie.Models", (Models) ->
  class Models.PeopleCollection extends Models.PaginatedCollection
    filterPages: (filter) =>
      # gross
      filter = 'none' if filter == 'all'

      @page = 1
      @params.page = @page
      @params.filter = filter
      @fetch()

    model: Models.Person

    parse: (data) =>
      super

    url: ->
      '/people'
