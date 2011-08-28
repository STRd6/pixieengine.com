( ($) ->
  $.fn.powerCanvas = (options) ->
    options ||= {}

    canvas = this.get(0)
    context = undefined

    ###*
    * PowerCanvas provides a convenient wrapper for working with Context2d.
    * @name PowerCanvas
    * @constructor
    ###
    $canvas = $(canvas).extend
      ###*
       * Passes this canvas to the block with the given matrix transformation
       * applied. All drawing methods called within the block will draw
       * into the canvas with the transformation applied. The transformation
       * is removed at the end of the block, even if the block throws an error.
       *
       * @name withTransform
       * @methodOf PowerCanvas#
       *
       * @param {Matrix} matrix
       * @param {Function} block
       * @returns this
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
          block(this)
        finally
          context.restore()

        return this

      clear: ->
        context.clearRect(0, 0, canvas.width, canvas.height)

        return this

      clearRect: (x, y, width, height) ->
        context.clearRect(x, y, width, height)

        return this

      context: ->
        context

      element: ->
        canvas

      globalAlpha: (newVal) ->
        if newVal?
          context.globalAlpha = newVal
          return this
        else
          context.globalAlpha

      compositeOperation: (newVal) ->
        if newVal?
          context.globalCompositeOperation = newVal
          return this
        else
          context.globalCompositeOperation

      createLinearGradient: (x0, y0, x1, y1) ->
        context.createLinearGradient(x0, y0, x1, y1)

      createRadialGradient: (x0, y0, r0, x1, y1, r1) ->
        context.createRadialGradient(x0, y0, r0, x1, y1, r1)

      buildRadialGradient: (c1, c2, stops) ->
        gradient = context.createRadialGradient(c1.x, c1.y, c1.radius, c2.x, c2.y, c2.radius)

        for position, color of stops
          gradient.addColorStop(position, color)

        return gradient

      createPattern: (image, repitition) ->
        context.createPattern(image, repitition)

      drawImage: (image, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight) ->
        context.drawImage(image, sx, sy, sWidth, sHeight, dx, dy, dWidth, dHeight)

        return this

      drawLine: (x1, y1, x2, y2, width) ->
        if arguments.length == 3
          width = x2
          x2 = y1.x
          y2 = y1.y
          y1 = x1.y
          x1 = x1.x


        width ||= 3

        context.lineWidth = width
        context.beginPath()
        context.moveTo(x1, y1)
        context.lineTo(x2, y2)
        context.closePath()
        context.stroke()

        return this

      fill: (color) ->
        $canvas.fillColor(color)
        context.fillRect(0, 0, canvas.width, canvas.height)

        return this

      ###*
       * Fills a circle at the specified position with the specified
       * radius and color.
       *
       * @name fillCircle
       * @methodOf PowerCanvas#
       *
       * @param {Number} x
       * @param {Number} y
       * @param {Number} radius
       * @param {Number} color
       * @see PowerCanvas#fillColor
       * @returns this
      ###
      fillCircle: (x, y, radius, color) ->
        $canvas.fillColor(color)
        context.beginPath()
        context.arc(x, y, radius, 0, Math.TAU, true)
        context.closePath()
        context.fill()

        return this

      ###*
       * Fills a rectangle with the current fillColor
       * at the specified position with the specified
       * width and height

       * @name fillRect
       * @methodOf PowerCanvas#
       *
       * @param {Number} x
       * @param {Number} y
       * @param {Number} width
       * @param {Number} height
       * @see PowerCanvas#fillColor
       * @returns this
      ###

      fillRect: (x, y, width, height) ->
        context.fillRect(x, y, width, height)

        return this

      fillShape: (points...) ->
        context.beginPath()
        points.each (point, i) ->
          if i == 0
            context.moveTo(point.x, point.y)
          else
            context.lineTo(point.x, point.y)
        context.lineTo points[0].x, points[0].y
        context.fill()

      ###*
      * Adapted from http://js-bits.blogspot.com/2010/07/canvas-rounded-corner-rectangles.html
      ###

      fillRoundRect: (x, y, width, height, radius, strokeWidth) ->
        radius ||= 5

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

        if strokeWidth
          context.lineWidth = strokeWidth
          context.stroke()

        context.fill()

        return this

      fillText: (text, x, y) ->
        context.fillText(text, x, y)

        return this

      centerText: (text, y) ->
        textWidth = $canvas.measureText(text)

        $canvas.fillText(text, (canvas.width - textWidth) / 2, y)

      fillWrappedText: (text, x, y, width) ->
        tokens = text.split(" ")
        tokens2 = text.split(" ")
        lineHeight = 16

        if $canvas.measureText(text) > width
          if tokens.length % 2 == 0
            tokens2 = tokens.splice(tokens.length / 2, (tokens.length / 2), "")
          else
            tokens2 = tokens.splice(tokens.length / 2 + 1, (tokens.length / 2) + 1, "")

          context.fillText(tokens.join(" "), x, y)
          context.fillText(tokens2.join(" "), x, y + lineHeight)
        else
          context.fillText(tokens.join(" "), x, y + lineHeight)

      fillColor: (color) ->
        if color
          if color.channels
            context.fillStyle = color.toString()
          else
            context.fillStyle = color

          return this
        else
          return context.fillStyle

      font: (font) ->
        if font?
          context.font = font

          return this
        else
          context.font

      measureText: (text) ->
        context.measureText(text).width

      putImageData: (imageData, x, y) ->
        context.putImageData(imageData, x, y)

        return this

      strokeColor: (color) ->
        if color
          if color.channels
            context.strokeStyle = color.toString()
          else
            context.strokeStyle = color

          return this
        else
          return context.strokeStyle

      strokeCircle: (x, y, radius, color) ->
        $canvas.strokeColor(color)
        context.beginPath()
        context.arc(x, y, radius, 0, Math.TAU, true)
        context.closePath()
        context.stroke()

        return this

      strokeRect: (x, y, width, height) ->
        context.strokeRect(x, y, width, height)

        return this

      textAlign: (textAlign) ->
        context.textAlign = textAlign

        return this

      height: ->
        canvas.height

      width: ->
        return canvas.width

    if canvas?.getContext
      context = canvas.getContext('2d')

      if options.init
        options.init($canvas)

      return $canvas

)(jQuery)
