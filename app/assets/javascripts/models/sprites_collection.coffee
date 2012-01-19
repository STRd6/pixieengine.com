#= require underscore
#= require backbone
#= require models/paginated_collection
#= require models/sprite

window.Pixie ||= {}
Pixie.Models ||= {}

class Pixie.Models.SpritesCollection extends Pixie.Models.PaginatedCollection
  model: Pixie.Models.Sprite

  pageInfo: =>
    info = super()
    _.extend(info, {owner_id: @params.id})

    return info

  parse: (data) =>
    @params.id = data.owner_id || false

    super(data)

  filterTagged: (tag) =>
    @page = 1

    @params.tagged = tag

    @fetch

  url: ->
    '/sprites'

