window.compileDirectory = (directoryPath) ->
  if directory = tree.getDirectory(directoryPath)
    directory.files().map((file) ->
      compileFileNode(file)
    ).join("\n")
  else
    ""

window.compileFileNode = (file) ->
  contents = file.get("contents")
  name = file.name()
  extension = name.extension()

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
  else
    throw "Cannot compile unknown extension: #{ext}"

addWarnings = (element) ->
  element.tipsy
    gravity: 'w'
    trigger: 'manual'
    title: 'tip'

  element.tipsy 'show'
  element.css
    border: '1px solid red'

window.buildProjectCode = ->
  clearErrorMessages()

  srcFiles = tree.getDirectory(projectConfig.directories.source).files()

  compiledCode = srcFiles.map((file) ->
    # Save main for last
    return if file.get('name') is projectConfig.main

    compileFileNode(file)
  ).join("\n")

  libCode = compileDirectory(projectConfig.directories.lib)

  if projectConfig.library
    #TODO Clean up all these special library cases into a singe solid
    # app config / entities bootstrapper
    entitiesCode = ''
  else
    entitiesCode = "App.entities = #{JSON.stringify(window.entities)};"

  if mainName = projectConfig.main
    srcDir = projectConfig.directories.source || 'src'

    main = tree.getFile("#{srcDir}/#{mainName}")

    mainCode = compileFileNode(main)

    if projectConfig.wrapMain
      mainCode = ";$(function(){ #{mainCode} });"

  else
    mainCode = ""

  crammedCode = [appConfigCode(), libCode, compiledCode, entitiesCode, mainCode].join("\n")

appConfigCode = ->
  if projectConfig.library
    ""
  else
    conf = "App = #{JSON.stringify(projectConfig)};"

    [conf].join("\n")

environmentVariables = ->
  "BASE_URL = \"#{projectBaseUrl}\"; MTIME = (+ new Date());\n"

runningAppWindow = null
window.runApp = ->
  runningAppWindow = window.open("", "runApp", "width=#{projectConfig.width},height=#{projectConfig.height}")

  # Pass IDE functions to the running window
  $.extend runningAppWindow, {
    displayRuntimeError
    saveFile # For in game editor modes
  }

  #TODO Detect and halt on compile time errors
  crammedCode = [environmentVariables(), buildProjectCode()].join("\n")

  runCodeInWindow(crammedCode, runningAppWindow)

window.testApp = ->
  clearErrorMessages()

  srcFiles = tree.getDirectory(projectConfig.directories.source).files()

  compiledCode = srcFiles.map((file) ->
    # Skip main
    return if file.get('name') is projectConfig.main

    compileFileNode(file)
  ).join("\n")

  libCode = compileDirectory(projectConfig.directories.lib)
  testLibCode = compileDirectory(projectConfig.directories.test_lib)
  testCode = compileDirectory(projectConfig.directories.test)

  crammedCode = [environmentVariables(), appConfigCode(), libCode, testLibCode, compiledCode].join("\n")
  crammedCode += "var App; App || (App={}); $(function(){ #{testCode} });"

  $("#unit_test_frame").remove()

  iframe = $ '<iframe />'
    height: 480
    id: "unit_test_frame"
    width: 640

  $("#unit_test_window").append(iframe).show()

  # Cram compiled code in iframe
  testCodeInWindow(crammedCode, iframe.get(0).contentWindow)

runCoffeeInGameWindow = (src) ->
  code = compileCode(src, "coffee")

  if code and runningAppWindow
    try
      runningAppWindow.eval(code)
    catch error
      warn? error.message

window.hotSwap = (src, ext) ->
  return unless projectConfig.hotSwap

  code = compileCode(src, ext)

  if code && runningAppWindow
    try
      runningAppWindow.eval(code)
    catch error
      warn? error.message

    try
      runningAppWindow.eval("engine.reload()")
    catch error
      warn? error.message

$ ->
  window.gameConsoleWindow = Pixie.Window
    title: "Game Console"
  .hide()
  .appendTo("body")
  .css
    position: "absolute"
    top: "125px"
    left: "250px"

  console = Pixie.Console(
    evalContext: (code) ->
      runningAppWindow?.eval(code)
  )

  gameConsoleWindow.find(".content").append(console)
