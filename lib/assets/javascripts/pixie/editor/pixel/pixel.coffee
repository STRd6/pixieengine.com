Pixel = (I={}) ->
  {x, y, color, oldColor, changed} = I

  color ||= Color(0, 0, 0, 0)
  oldColor ||= Color(0, 0, 0, 0)

  self =
    color: (newColor, blendMode="additive") ->
      if arguments.length >= 1
        oldColor = color
        newColor = Color(newColor)

        color = ColorUtil[blendMode](oldColor, newColor)

        changed?(self)

        return self
      else
        return color
    oldColor: ->
      oldColor
    x: x
    y: y

    toString: ->
      "[Pixel: " + [x, y].join(",") + "]"

# Export to pixel editor namespace
Pixie.Editor.Pixel.Pixel = Pixel

