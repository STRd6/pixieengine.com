window.compileDirectory = (directoryPath) ->
  findDirectory(directoryPath).map((file) ->
    compileFileNode(file)
  ).join(";\n")

window.compileFileNode = (file) ->
  {contents, extension} = file.attributes

  $element = $(file.get('docSelector'))

  compileCode(contents, extension, $element)

window.compileCode = (src, ext, $element) ->
  if ext is "js"
    src
  else if ext is "coffee"
    try
      compiledCode = CoffeeScript.compile src, bare: true
    catch error
      if $element
        displayError
          file: $element.data("path")
          fileId: "#" + $element.attr("id")
          message: error.message
      else
        displayError
          message: error.message

    compiledCode
