namespace "Pixie.Models", (Models) ->
  class Models.QueryString extends Backbone.Model
    defaults:
      page: 1

    queryString: =>
      output = "?"

      for key, value of @attributes
        separator = if output is '?' then '' else '&'

        output += "#{separator}#{key}=#{value}"

      output
