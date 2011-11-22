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
    _.extend(info, {owner_id: @params.id})

    return info

  parse: (data) =>
    @params.id = data.owner_id || false

    Pixie.Models.PaginatedCollection.prototype.parse.call(@, data)

  filterTagged: (tag) =>
    @page = 1

    @params.page = @page
    @params.tagged = tag
    @fetch()

  resetSearch: =>
    @page = 1
    @params.page = @page

    delete @params.tagged

    @fetch()

  url: ->
    '/sprites'

