#= require coffee-script
#= require corelib

#TODO require PixieCanvas
$ ->
  $("code.run").each ->
    # Assume it's a PixieCanvas example
    codeElement = $(this)

    code = codeElement.text()

    compiledJs = CoffeeScript.compile source, bare: true

    canvas = $("<canvas width=200 height=150/>").pixieCanvas()

    codeElement.after(canvas)

    eval compiledJs
