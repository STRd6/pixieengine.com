window.UndoStack = ->
  undos = []
  redos = []
  empty = true

  last: -> undos[undos.length - 1]

  popUndo: ->
    undo = undos.pop()

    redos.push(undo) if undo

    return undo

  popRedo: ->
    redo = redos.pop()

    undos.push(redo) if redo

    return redo

  next: ->
    last = this.last()
    if !last || !empty
      undos.push({})
      empty = true

      redos = []

  add: (object, data) ->
    last = @last()

    unless last
      @next()
      last = @last()

    if last[object]
      last[object].newColor = data.newColor
    else
      last[object] = data
      empty = false


    return this

  replayData: ->
    replayData = []

    $.each undos, (i, items) ->
      replayData[i] = []
      $.each items, (key, data) ->
        pixel = data.pixel
        replayData[i].push
          x: pixel.x
          y: pixel.y
          color: data.newColor.toString()

    return replayData
