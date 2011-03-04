jQuery.fn.serializeObject = () ->
  arrayData = this.serializeArray()
  objectData = {}

  $.each arrayData, () ->
    if objectData[this.name]
      unless objectData[this.name].push
        objectData[this.name] = [objectData[this.name]]

      objectData[this.name].push(this.value || '')
    else
      objectData[this.name] = this.value || ''

  return objectData;
