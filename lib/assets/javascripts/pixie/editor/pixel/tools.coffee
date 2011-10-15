# All the default editor tools for the pixel editor

# Old school namespacing. Stuck with it until Sprockets supports exports
window.Pixie ||= {}
Pixie.Editor ||= {}
Pixie.Editor.Pixel ||= {}

Pixie.Editor.Pixel.tools = (($) ->
  # Import tools and actions from other files
  {
    config: {
      IMAGE_DIR
      DEBUG
    }
  } = Pixie.Editor.Pixel

  colorNeighbors = (color) ->
    this.color(color)
    $.each this.canvas.getNeighbors(this.x, this.y), (i, neighbor) ->
      neighbor?.color(color)

  erase = (pixel, opacity) ->
    inverseOpacity = (1 - opacity)
    pixelColor = pixel.color()

    pixel.color(Color(pixelColor.toString(), pixelColor.a * inverseOpacity), false, "replace")

  floodFill = (e, newColor, pixel) ->
    originalColor = this.color()
    return if newColor.equal(originalColor)

    q = []
    pixel.color(newColor)
    q.push(pixel)

    canvas = this.canvas

    while(q.length)
      pixel = q.pop()

      neighbors = canvas.getNeighbors(pixel.x, pixel.y)

      $.each neighbors, (index, neighbor) ->
        if neighbor?.color().equal(originalColor)
          neighbor.color(newColor)
          q.push(neighbor)

    return

  line = (canvas, color, p0, p1) ->
    {x:x0, y:y0} = p0
    {x:x1, y:y1} = p1

    dx = (x1 - x0).abs()
    dy = (y1 - y0).abs()
    sx = (x1 - x0).sign()
    sy = (y1 - y0).sign()
    err = dx - dy

    canvas.getPixel(x0, y0).color(color)

    while !(x0 == x1 and y0 == y1)
      e2 = 2 * err

      if e2 > -dy
        err -= dy
        x0 += sx

      if e2 < dx
        err += dx
        y0 += sy

      canvas.getPixel(x0, y0).color(color)

  pencilTool = ( ->
    lastPosition = Point(0, 0)

    cursor: "url(" + IMAGE_DIR + "pencil.png) 4 14, default"
    hotkeys: ['p', '1']
    mousedown: (e, color) ->
      currentPosition = Point(@x, @y)

      if e.shiftKey
        line(@canvas, color, lastPosition, currentPosition)
      else
        @color(color)

      lastPosition = currentPosition
    mouseenter: (e, color) ->
      currentPosition = Point(@x, @y)
      line(@canvas, color, lastPosition, currentPosition)
      lastPosition = currentPosition
  )()

  return tools =
    pencil: pencilTool

    mirror_pencil:
      cursor: "url(" + IMAGE_DIR + "mirror_pencil.png) 8 14, default"
      hotkeys: ['m']
      mousedown: (e, color) ->
        mirrorCoordinate = @canvas.width() - @x - 1
        @color(color)
        @canvas.getPixel(mirrorCoordinate, @y).color(color)
      mouseenter: (e, color) ->
        mirrorCoordinate = @canvas.width() - @x - 1
        @color(color)
        @canvas.getPixel(mirrorCoordinate, @y).color(color)
    brush:
      cursor: "url(" + IMAGE_DIR + "brush.png) 4 14, default"
      hotkeys: ['b', '2']
      mousedown: (e, color) ->
        colorNeighbors.call(this, color)
      mouseenter: (e, color) ->
        colorNeighbors.call(this, color)
    dropper:
      cursor: "url(" + IMAGE_DIR + "dropper.png) 13 13, default"
      hotkeys: ['i', '3']
      mousedown: (e) ->
        @canvas.color(@color())
        @canvas.setTool(tools.pencil) unless e.shiftKey
    eraser:
      cursor: "url(" + IMAGE_DIR + "eraser.png) 4 11, default"
      hotkeys: ['e', '4']
      mousedown: (e, color, pixel) ->
        erase(pixel, color.a)
      mouseenter: (e, color, pixel) ->
        erase(pixel, color.a)
    fill:
      cursor: "url(" + IMAGE_DIR + "fill.png) 12 13, default"
      hotkeys: ['f', '5']
      mousedown: floodFill
      mouseenter: floodFill
)(jQuery)
