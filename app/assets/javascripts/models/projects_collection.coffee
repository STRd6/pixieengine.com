#= require underscore
#= require backbone
#= require models/paginated_collection
#= require models/project

window.Pixie ||= {}
Pixie.Backbone ||= {}
Pixie.Backbone.Projects.Collection ||= {}

class Pixie.Backbone.Projects.Collection extends Pixie.Backbone.PaginatedCollection
  model: Pixie.Backbone.Project

  parse: (data) =>
    Pixie.Backbone.PaginatedCollection.prototype.parse.call(@, data)

  url: ->
    '/people/projects'

