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
    _.extend(info, {owner_id: @owner_id})

    return info

  parse: (data) =>
    {@owner_id} = data

    @params.id = @owner_id

    Pixie.Models.PaginatedCollection.prototype.parse.call(@, data)

  url: ->
    '/people/projects'

