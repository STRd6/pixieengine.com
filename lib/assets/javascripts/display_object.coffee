window.DisplayObject = (I) ->
  $.reverseMerge I,
    alpha: 1
    transform: Matrix()

  self = Core(I).extend
    draw: (canvas) ->
      if I.sprite
        canvas.withTransform I.transform, (canvas) ->
          canvas.globalAlpha I.alpha
          I.sprite.draw(canvas, 0, 0)

    drawOutline: (canvas) ->
      canvas.withTransform I.transform, (canvas) ->
        canvas.strokeRect(0, 0, I.width, I.height)

    move: (delta) ->
      I.transform = Matrix.translation(delta.x, delta.y).concat(I.transform)

    opacify: (amount) ->
      I.alpha = (I.alpha + amount).clamp(0, 1)

    pointWithin: (point) ->
      p = I.transform.inverse().transformPoint(point)

      return (0 <= p.x <= I.width) && (0 <= p.y <= I.height)

    registrationPoint: ->
      Point(I.width/2, I.height/2)

    rotate: (angle) ->
      I.transform = I.transform.rotate(angle, self.registrationPoint())

    scale: (amount) ->
      I.transform = I.transform.scale(1 + amount, 1 + amount, self.registrationPoint())

    transparentize: (amount) ->
      I.alpha = (I.alpha - amount).clamp(0, 1)

  self.attrAccessor "transform", "id"

  self
