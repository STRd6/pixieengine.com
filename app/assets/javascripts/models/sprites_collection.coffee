#= require underscore
#= require backbone
#= require models/paginated_collection
#= require models/sprite

namespace "Pixie.Models", (Models) ->
  class Models.SpritesCollection extends Models.PaginatedCollection
    model: Models.Sprite

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

