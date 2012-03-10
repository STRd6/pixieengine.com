namespace "Pixie.Models", (Models) ->
  class Models.Autocomplete extends Backbone.Model
    defaults:
      suggestions: ["$", "_", "pixieCanvas", "times", "first", "last", "each", "map", "indexOf", "includes"]
