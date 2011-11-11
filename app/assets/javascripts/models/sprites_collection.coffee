#= require underscore
#= require backbone
#= require models/paginated_collection
#= require models/sprite

window.Pixie ||= {}
Pixie.Backbone ||= {}
Pixie.Backbone.Sprites ||= {}

class Pixie.Backbone.Sprites.Collection extends Pixie.Backbone.PaginatedCollection
  model: Pixie.Backbone.Sprite

  parse: (data) =>
    Pixie.Backbone.PaginatedCollection.prototype.parse.call(@, data)

  url: '/people/sprites'

