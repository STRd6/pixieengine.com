namespace "Pixie.Editor.Tile.Models", (Models) ->

  class Models.Entity extends Backbone.Model
    defaults:
      name: "Unnamed Entity"
      width: 32
      height: 32

    generateUuid: ->
      Math.uuid(32, 16)

    src: =>
      if sprite = @get("sprite")
        if sprite.lastIndexOf("data:image/", 0) is 0
          sprite
        else
          "/production/projects/#{projectId}/images/#{sprite}.png"
      else
        #TODO Use width, height and color
        "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAAMUlEQVRYR+3QwQ0AAAgCMdh/aHULPyW5P2mTzPW2OkCAAAECBAgQIECAAAECBAh8CyywJyABJlvz9gAAAABJRU5ErkJggg=="

    initialize: ->
      # if spriteName has been set explicitly make sure
      # our entity default doesn't override it.
      if @get('spriteName')
        @set
          sprite: null

      unless @get("uuid")
        @set uuid: @generateUuid()
