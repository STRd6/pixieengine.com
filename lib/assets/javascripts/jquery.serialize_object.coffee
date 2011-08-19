jQuery.fn.serializeObject = () ->
  arrayData = this.serializeArray()
  objectData = {}

  $.each arrayData, () ->
    name = this.name

    if this.value?
      value = this.value
    else
      value = ''

    # Hack for nested objects
    paths = name.split("[").map (e, i) ->
      if i == 0
        e
      else
        e.substr(0, e.length - 1)

    object = objectData

    paths.each (key, i) ->
      if key == paths.last()
        object[key] = value
      else
        object = (object[key] ||= {})

  return objectData
