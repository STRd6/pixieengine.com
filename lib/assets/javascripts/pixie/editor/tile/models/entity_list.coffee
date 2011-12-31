# require ./entity

namespace "Pixie.Editor.Tile.Models", (exports) ->

  class exports.EntityList extends Backbone.Collection
    model: exports.Entity

    toJSON: ->
      @models.eachWithObject {}, (entity, cache) ->
        cache[entity.get("uuid")] =
          src: entity.get "src" # Image to display in map
          entity: {} # TODO All the entity props go here
