( ($) ->
  $.fn.pixieCanvas = (options) ->
    options ||= {}

    canvas = this.get(0)
    context = undefined

    ###*
    PixieCanvas provides a convenient wrapper for working with Context2d.

    Methods try to be as flexible as possible as to what arguments they take.

    Non-getter methods return `this` for method chaining.

    @name PixieCanvas
    @constructor
    ###
    $canvas = $(canvas).extend
      ###*
      Passes this canvas to the block with the given matrix transformation
      applied. All drawing methods called within the block will draw
      into the canvas with the transformation applied. The transformation
      is removed at the end of the block, even if the block throws an error.

      @name withTransform
      @methodOf PixieCanvas#

      @param {Matrix} matrix
      @param {Function} block

      @returns this
      ###
      withTransform: (matrix, block) ->
        context.save()

        context.transform(
          matrix.a,
          matrix.b,
          matrix.c,
          matrix.d,
          matrix.tx,
          matrix.ty
        )

        try
          block(@)
        finally
          context.restore()

        return @

      ###*
      Clear the canvas (or a portion of it).

      Clear the entire canvas

      <code><pre>
      canvas.clear()
      </pre></code>

      Clear a portion of the canvas

      <code class="run"><pre>
      # Set up: Fill canvas with blue
      canvas.fill("blue")  

      # Clear a portion of the canvas
      canvas.clear
        x: 50
        y: 50
        width: 50
        height: 50
      </pre></code>

      You can also clear the canvas by passing x, y, width height as
      unnamed parameters:

      <code><pre>
      canvas.clear(25, 25, 50, 50)
      </pre></code>

      @name clear
      @methodOf PixieCanvas#

      @param {Number} [x]
      @param {Number} [y]
      @param {Number} [width]
      @param {Number} [height]

      @returns this
      ###
      clear: (x={}, y, width, height) ->
        unless y?
          {x, y, width, height} = x

        x ||= 0
        y ||= 0
        width = canvas.width unless width?
        height = canvas.height unless height?

        context.clearRect(x, y, width, height)

        return @

      ###*
      Fills the entire canvas (or a specified section of it) with
      the given color.

      <code class="run"><pre>
      # Paint the town (entire canvas) red
      canvas.fill "red"

      # Fill a section of the canvas white (#FFF)
      canvas.fill
        x: 50
        y: 50
        width: 50
        height: 50
        color: "#FFF"
      </pre></code>

      @name fill
      @methodOf PixieCanvas#

      @param {Number} [x=0] Optional x position to fill from.
      @param {Number} [y=0]
      @param {Number} [width=canvas.width]
      @param {Number} [height=canvas.height]
      @param {Bounds} [bounds]
      @param {String|Color} [color]

      @returns this
      ###
      fill: (color={}) ->
        unless color.isString?()
          {x, y, width, height, bounds, color} = color

        {x, y, width, height} = bounds if bounds

        x ||= 0
        y ||= 0
        width = canvas.width unless width?
        height = canvas.height unless height?

        @fillColor(color)
        context.fillRect(x, y, width, height)

        return @

      ###*
      A direct map to the Context2d draw image. `GameObject`s
      that implement drawable will have this wrapped up nicely,
      so there is a good chance that you will not have to deal with
      it directly.

      @name drawImage
      @methodOf PixieCanvas#

      @param image
      @param sx
      @param sy
      @param sWidth
      @param sHeight
      @param dx
      @param dy
      @param dWidth
      @param dHeight

      @returns this
      ###
      drawImage: (image, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight) ->
        context.drawImage(image, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight)

        return @

      ###*
      Draws a circle at the specified position with the specified
      radius and color.

      <code class="run"><pre>
      # Draw a large orange circle
      canvas.drawCircle
        radius: 30
        position: Point(100, 75)
        color: "orange"

      # Draw a blue circle with radius 10 at (25, 50)
      # and a red stroke
      canvas.drawCircle
        x: 25
        y: 50
        raduis: 10
        color: "blue"
        stroke:
          color: "red"
          width: 1

      # Create a circle object to set up the next examples
      circle =
        radius: 20
        x: 50
        y: 50

      # Draw a given circle in yellow
      canvas.drawCircle
        circle: circle
        color: "yellow"

      # Draw the circle in green at a different position
      canvas.drawCircle
        circle: circle
        position: Point(25, 75)
        color: "green"

      # Draw an outline circle in purple.
      canvas.drawCircle
        x: 50
        y: 75
        radius: 10
        stroke:
          color: "purple"
          width: 2
      </pre></code>

      @name drawCircle
      @methodOf PixieCanvas#

      @param {Number} [x]
      @param {Number} [y]
      @param {Point} [position]
      @param {Number} [radius]
      @param {Color|String} [color]
      @param {Circle} [circle]

      @returns this
      ###
      drawCircle: ({x, y, radius, position, color, stroke, circle}) ->
        {x, y, radius} = circle if circle
        {x, y} = position if position

        context.beginPath()
        context.arc(x, y, radius, 0, Math.TAU, true)
        context.closePath()

        if color
          @fillColor(color)
          context.fill()

        if stroke
          @strokeColor(stroke.color)
          @lineWidth(stroke.width)
          context.stroke()

        return @

      ###*
      Draws a rectangle at the specified position with given 
      width and height. Optionally takes a position, bounds
      and color argument.

      <code class="run"><pre>
      # Draw a red rectangle using x, y, width and height
      canvas.drawRect
        x: 50
        y: 50
        width: 50
        height: 50
        color: "#F00"

      # Draw a blue rectangle using position, width and height
      # and throw in a stroke for good measure
      canvas.drawRect
        position: Point(0, 0)
        width: 50
        height: 50
        color: "blue"
        stroke:
          color: "orange"
          width: 3

      # Set up a bounds object for the next examples
      bounds =
        x: 100
        y: 0
        width: 100
        height: 100

      # Draw a purple rectangle using bounds
      canvas.drawRect
        bounds: bounds
        color: "green"

      # Draw the outline of the same bounds, but at a different position
      canvas.drawRect
        bounds: bounds
        position: Point(0, 50)
        stroke:
          color: "purple"
          width: 2
      </pre></code>

      @name drawRect
      @methodOf PixieCanvas#

      @param {Number} [x]
      @param {Number} [y]
      @param {Number} [width]
      @param {Number} [height]
      @param {Point} [position]
      @param {Color|String} [color]
      @param {Bounds} [bounds]
      @param {Stroke} [stroke]

      @returns this
      ###
      drawRect: ({x, y, width, height, position, bounds, color, stroke}) ->
        {x, y, width, height} = bounds if bounds
        {x, y} = position if position

        if color
          @fillColor(color)
          context.fillRect(x, y, width, height)

        if stroke
          @strokeColor(stroke.color)
          @lineWidth(stroke.width)
          context.strokeRect(x, y, width, height)

        return @

      ###*
      Draw a line from `start` to `end`.

      <code class="run"><pre>
      # Draw a sweet diagonal
      canvas.drawLine
        start: Point(0, 0)
        end: Point(200, 200)
        color: "purple"

      # Draw another sweet diagonal
      canvas.drawLine
        start: Point(200, 0)
        end: Point(0, 200)
        color: "red"
        width: 6

      # Now draw a sweet horizontal with a direction and a length
      canvas.drawLine
        start: Point(0, 100)
        length: 200
        direction: Point(1, 0)
        color: "orange"

      </pre></code>

      @name drawLine
      @methodOf PixieCanvas#

      @param {Point} start
      @param {Point} [end]
      @param {Number} [width]
      @param {String|Color} [color]

      @returns this
      ###
      drawLine: ({start, end, width, color, direction, length}) ->
        width ||= 3

        if direction
          end = direction.norm(length).add(start)

        @lineWidth(width)
        @strokeColor(color)

        context.beginPath()
        context.moveTo(start.x, start.y)
        context.lineTo(end.x, end.y)
        context.closePath()
        context.stroke()

        return @

      ###*
      @name drawPoly
      @methodOf PixieCanvas#

      @returns this
      ###
      drawPoly: ({points, color, stroke}) ->
        context.beginPath()
        points.each (point, i) ->
          if i == 0
            context.moveTo(point.x, point.y)
          else
            context.lineTo(point.x, point.y)
        context.lineTo points[0].x, points[0].y

        if color
          @fillColor(color)
          context.fill()

        if stroke
          @strokeColor(stroke.color)
          @lineWidth(stroke.width)
          context.stroke()

        return @

      ###*
      Draw a rounded rectangle.

      Adapted from http://js-bits.blogspot.com/2010/07/canvas-rounded-corner-rectangles.html

      @param {Number} [x]
      @param {Number} [y]
      @param {Number} [width]
      @param {Number} [height]
      @param {Number} [radius] Defaults to 5
      @param {Point} [position]
      @param {Color|String} [color]
      @param {Bounds} [bounds]
      @param {Stroke} [stroke]

      @returns this
      ###
      drawRoundRect: ({x, y, width, height, radius, position, bounds, color, stroke}) ->
        radius = 5 unless radius?

        {x, y, width, height} = bounds if bounds
        {x, y} = position if position

        context.beginPath()
        context.moveTo(x + radius, y)
        context.lineTo(x + width - radius, y)
        context.quadraticCurveTo(x + width, y, x + width, y + radius)
        context.lineTo(x + width, y + height - radius)
        context.quadraticCurveTo(x + width, y + height, x + width - radius, y + height)
        context.lineTo(x + radius, y + height)
        context.quadraticCurveTo(x, y + height, x, y + height - radius)
        context.lineTo(x, y + radius)
        context.quadraticCurveTo(x, y, x + radius, y)
        context.closePath()

        if color
          @fillColor(color)
          context.fill()

        if stroke
          @lineWidth(stroke.width)
          @strokeColor(stroke.color)
          context.stroke()

        return @

      ###*
      Draws text on the canvas at the given position, in the given color.
      If no color is given then the previous fill color is used.

      @name drawText
      @methodOf PixieCanvas#

      @param {Number} [x]
      @param {Number} [y]
      @param {String} text
      @param {Point} [position]
      @param {String|Color} [color]
      ###
      drawText: ({x, y, text, position, color}) ->
        {x, y} = position if position

        @fillColor(color)
        context.fillText(text, x, y)

        return @

      ###*
      Centers the given text on the canvas at the given y position. An x position
      or point position can also be given in which case the text is centered at the
      x, y or position value specified.

      @name centerText
      @methodOf PixieCanvas#

      @param {String} text
      @param {Number} [y]
      @param {Number} [x]
      @param {Point} [position]
      @param {String|Color} [color]
      ###
      centerText: ({text, x, y, position, color}) ->
        {x, y} = position if position

        x = canvas.width / 2 unless x?

        textWidth = @measureText(text)

        @fillText {
          text
          color
          x: x - (textWidth) / 2
          y
        }

      fillColor: (color) ->
        if color
          if color.channels
            context.fillStyle = color.toString()
          else
            context.fillStyle = color

          return @
        else
          return context.fillStyle

      strokeColor: (color) ->
        if color
          if color.channels
            context.strokeStyle = color.toString()
          else
            context.strokeStyle = color

          return @
        else
          return context.strokeStyle

      measureText: (text) ->
        context.measureText(text).width

      putImageData: (imageData, x, y) ->
        context.putImageData(imageData, x, y)

        return @

      context: ->
        context

      element: ->
        canvas

    contextAttrAccessor = (attrs...)->
      attrs.each (attr) ->
        $canvas[attr] = (newVal) ->
          if newVal?
            context[attr] = newVal
            return @
          else
            context[attr]

    contextAttrAccessor(
      "font",
      "globalAlpha",
      "globalCompositeOperation",
      "height",
      "lineWidth",
      "textAlign",
      "width",
    ) 

    if canvas?.getContext
      context = canvas.getContext('2d')

      if options.init
        options.init($canvas)

      return $canvas

)(jQuery)
