#= require models/paginated_collection
#= require models/project

namespace "Pixie.Models", (Models) ->
  class Models.ProjectsCollection extends Models.PaginatedCollection
    filterPages: (filter) =>
      @params.set
        page: 1
        filter: filter

    model: Models.Project

    pageInfo: =>
      _.extend(super(), {owner_id: @params.get('owner_id')})

    parse: (data) ->
      super(data)

    url: ->
      '/projects'
