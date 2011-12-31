# require ./instance

namespace "Pixie.Editor.Tile.Models", (Models) ->

  class Models.InstanceList extends Backbone.Collection
    model: Models.Instance
