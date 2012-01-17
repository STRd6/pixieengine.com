namespace "Pixie.Editor.Tile.Models", (Models) ->

  class Models.Instance extends Backbone.Model
    defaults:
      x: 0
      y: 0
      properties: {}

    initialize: ->
      @sourceEntity = @get "sourceEntity"

      @set
        src: @sourceEntity.src()

    toJSON: ->
      uuid: @sourceEntity.get "uuid"
      x: @get "x"
      y: @get "y"
      properties: @get "properties"
