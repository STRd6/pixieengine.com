Pixel = (I={}) ->
  {x, y, color, oldColor, changed} = I

  color ||= Color(0, 0, 0, 0)
  oldColor ||= Color(0, 0, 0, 0)

  return {
    __proto__: Pixel::
    changed
    color
    oldColor
    x
    y
  }

Pixel:: =
  color: (newColor, blendMode="additive") ->
    if arguments.length >= 1
      @oldColor = @color
      newColor = Color(newColor)

      @color = ColorUtil[blendMode](@oldColor, newColor)

      @changed(this)

      return this
    else
      return @color

  toString: ->
    "[Pixel: " + [@x, @y].join(",") + "]"

# These are the changed observers, move back into main editor
pixelChanged = (pixel) ->
  {x, y, color, oldColor} = pixel

  xPos = x * I.pixelWidth
  yPos = y * I.pixelHeight

  layerCanvas.clearRect(xPos, yPos, I.pixelWidth, I.pixelHeight)
  layerCanvas.fillStyle = color.toString()
  layerCanvas.fillRect(xPos, yPos, I.pixelWidth, I.pixelHeight)

  # TODO: Switch this to actions and command pattern
  undoStack.add(pixel, {pixel: pixel, oldColor: oldColor, newColor: color}) unless skipUndo
