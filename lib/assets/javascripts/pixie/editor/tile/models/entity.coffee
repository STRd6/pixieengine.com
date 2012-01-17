namespace "Pixie.Editor.Tile.Models", (Models) ->

  class Models.Entity extends Backbone.Model
    defaults:
      name: "Unnamed Entity"
      width: 32
      heiht: 32
      sprite: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAA5klEQVRYR2NkGGDAOMD2M4w6YDQERkOA6BD4NpXjP7WyLFf2D7i9RDkAZPnh2/8Y9H0rGS5ubieLBjme70Yn2A8kOQDZckpCAGQ5yBO2qkzEO4DaloNCEOQQokKAFpbDooGgA6iZ4GBpB2Q5KP0QFQUgB3zSKCc7wcESKizeQUEPA0RFAcwBlCQ6WHCDPAIDJIUActCR65DREBgNgdEQGA2BQRUC2EpBUAGHtUFCi5oQvQ6Ala44HYBchlNaFKPXgMjmEQwBcptgsCBHb4KhewanA8j1Nbo+5MYHNjOJapRSyzGD0gEAm/Y7MAMUHQMAAAAASUVORK5CYII="

    generateUuid: ->
      Math.uuid(32, 16)

    src: ->
      @get "sprite"

    initialize: ->
      unless @get("uuid")
        @set uuid: @generateUuid()
