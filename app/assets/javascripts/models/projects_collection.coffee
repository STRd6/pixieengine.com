#= require underscore
#= require backbone
#= require models/paginated_collection
#= require models/project

window.Pixie ||= {}
Pixie.Models ||= {}

class Pixie.Models.ProjectsCollection extends Pixie.Models.PaginatedCollection
  filterPages: (filter) =>
    # gross
    filter = 'none' if filter == 'all'

    @page = 1
    @params.page = @page
    @params.filter = filter
    @fetch()

  model: Pixie.Models.Project

  pageInfo: =>
    info = Pixie.Models.PaginatedCollection.prototype.pageInfo.call(@)
    _.extend(info, {owner_id: @params.id})

    return info

  parse: (data) =>
    @params.id = data.owner_id || false

    Pixie.Models.PaginatedCollection.prototype.parse.call(@, data)

  url: ->
    '/projects'

