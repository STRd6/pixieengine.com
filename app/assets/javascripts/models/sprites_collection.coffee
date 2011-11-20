#= require underscore
#= require backbone
#= require models/paginated_collection
#= require models/sprite

window.Pixie ||= {}
Pixie.Models ||= {}

class Pixie.Models.SpritesCollection extends Pixie.Models.PaginatedCollection
  model: Pixie.Models.Sprite

  parse: (data) =>
    Pixie.Models.PaginatedCollection.prototype.parse.call(@, data)

  url: '/people/sprites'

