namespace "Pixie.Editor.Tile.Models", (Models) ->

  class Models.Instance extends Backbone.Model
    defaults:
      x: 0
      y: 0
      
    initialize: ->
      @sourceEntity = @get "sourceEntity"

      @set
        src: @sourceEntity.get "src"

    toJSON: ->
      uuid: @sourceEntity.get "uuid"
      x: @get "x"
      y: @get "y"
