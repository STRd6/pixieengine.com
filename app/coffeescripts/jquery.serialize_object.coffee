jQuery.fn.serializeObject = () ->
  arrayData = this.serializeArray()
  objectData = {}

  $.each arrayData, () ->
    if this.value?
      value = this.value
    else
      value = ''

    if objectData[this.name]?
      unless objectData[this.name].push
        objectData[this.name] = [objectData[this.name]]

      objectData[this.name].push value
    else
      objectData[this.name] = value

  return objectData
