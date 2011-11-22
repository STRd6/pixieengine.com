#= require underscore
#= require backbone
#= require models/paginated_collection
#= require models/sprite

window.Pixie ||= {}
Pixie.Models ||= {}

class Pixie.Models.SpritesCollection extends Pixie.Models.PaginatedCollection
  model: Pixie.Models.Sprite

  pageInfo: =>
    info = Pixie.Models.PaginatedCollection.prototype.pageInfo.call(@)
    _.extend(info, {owner_id: @owner_id})

    return info

  parse: (data) =>
    @owner_id = data.owner_id?

    @params.id = @owner_id

    Pixie.Models.PaginatedCollection.prototype.parse.call(@, data)

  filterTagged: (tag) =>
    @page = 1
    @tagged = tag

    @params.page = @page
    @params.tagged = @tagged
    @fetch()

  url: ->
    '/sprites'

