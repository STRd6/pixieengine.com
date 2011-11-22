#= require underscore
#= require backbone
#= require models/paginated_collection
#= require models/project

window.Pixie ||= {}
Pixie.Models ||= {}

class Pixie.Models.ProjectsCollection extends Pixie.Models.PaginatedCollection
  model: Pixie.Models.Project

  pageInfo: =>
    info = Pixie.Models.PaginatedCollection.prototype.pageInfo.call(@)
    _.extend(info, {owner_id: @params.id})

    return info

  parse: (data) =>
    @params.id = data.owner_id || false

    Pixie.Models.PaginatedCollection.prototype.parse.call(@, data)

  url: ->
    '/people/projects'

