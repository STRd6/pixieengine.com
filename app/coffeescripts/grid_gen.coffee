window.GridGen = (options) ->
  options = $.extend {},
    color: "#414141"
    height: 32
    width: 32
  , options

  canvasWidth = options.width
  canvasHeight = options.height
  canvas = $("<canvas width='#{canvasWidth}' height='#{canvasHeight}'></canvas>").get(0)
  context = canvas.getContext("2d")

  context.fillStyle = options.color
  context.fillRect(0, 0, 1, canvasHeight)
  context.fillRect(0, 0, canvasWidth, 1)

  backgroundImage: ->
    "url(#{this.toDataURL()})"

  toDataURL: ->
    canvas.toDataURL("image/png")
