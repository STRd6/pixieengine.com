namespace "Pixie", (Pixie) ->
  Pixie.params = ->
    location.search.split("?").last().split("&").eachWithObject {}, (item, obj) ->
      [key, val] = item.split '='

      obj[key] = val unless key is ''
