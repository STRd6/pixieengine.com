#= require models/paginated_collection
#= require models/sprite

namespace "Pixie.Models", (Models) ->
  class Models.SpritesCollection extends Models.PaginatedCollection
    model: Models.Sprite

    pageInfo: =>
      _.extend(super(), {owner_id: @params.get('owner_id')})

    filterTagged: (tag) =>
      @params.set
        page: 1
        tagged: tag

    url: ->
      '/sprites'
