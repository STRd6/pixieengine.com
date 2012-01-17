# require ./entity

namespace "Pixie.Editor.Tile.Models", (exports) ->

  class exports.EntityList extends Backbone.Collection
    model: exports.Entity

    findByUUID: (uuid) ->
      @models.select (entity) ->
        entity.get("uuid") == uuid
      .first()

    toJSON: ->
      @models.eachWithObject {}, (entity, cache) ->
        cache[entity.get("uuid")] =
          src: entity.get "src" # Image to display in map
          properties: {} # TODO All the entity props go here
