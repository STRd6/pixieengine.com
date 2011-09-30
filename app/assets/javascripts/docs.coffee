#= require coffee-script
#= require corelib
#= require pixie_canvas

$ ->
  $("code.run").each ->
    # Assume it's a PixieCanvas example
    codeElement = $(this)

    source = codeElement.text()

    compiledJs = CoffeeScript.compile source, bare: true

    canvas = $("<canvas width=200 height=150/>").pixieCanvas()

    codeElement.after(canvas)

    eval compiledJs
