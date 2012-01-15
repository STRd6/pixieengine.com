window.GridGen = (options) ->
  options = $.extend {},
    color: "rgba(0, 0, 0, 0.3)"
    height: 32
    width: 32
    guide: 5
  , options

  {width, height, guide, color} = options

  canvasWidth = width * guide
  canvasHeight = height * guide
  canvas = $("<canvas width='#{canvasWidth}' height='#{canvasHeight}'></canvas>").get(0)
  context = canvas.getContext("2d")

  context.fillStyle = color

  guide.times (i) ->
    context.fillRect(i * width, 0, 1, canvasHeight)
    context.fillRect(0, i * height, canvasWidth, 1)

  # Draw the strong line
  context.fillRect(0, 0, 1, canvasHeight)
  context.fillRect(0, 0, canvasWidth, 1)

  backgroundImage: ->
    "url(#{this.toDataURL()})"

  toDataURL: ->
    canvas.toDataURL("image/png")
