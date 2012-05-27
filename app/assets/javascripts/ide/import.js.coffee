extractBase64Data = (dataUrl) ->
  dataUrl.substring(dataUrl.indexOf(',') + 1)

$("html").dropImageReader
  matchType: /.*/
  callback: (file, event) ->
    if event.target.readyState is FileReader.DONE
      if file.type.match(/javascript/i)
        path = projectConfig.directories.lib
        type = "text"
        extension = "js"
        language = "javascript"

      else if file.type.match "audio"
        extension = file.name.match(/\.([^\.]*)$/, '')?[1]
        path = projectConfig.directories.sounds
        autoOpen = false

      else if file.type is ""
        extension = file.name.match(/\.([^\.]*)$/, '')?[1]

        if extension is "coffee"
          path = projectConfig.directories.source
          type = "text"
          language = "coffeescript"
        else if extension is "tilemap"
          ;#TODO
        else if extension is "tutorial"
          path = ""
          type = "text"
        else if extension is "json"
          path = ""
          type = "text"
          language = "json"

      else if file.type.match(/image.*/)
        path = projectConfig.directories.images
        type = "image"
        extension = "png"
        autoOpen = false

      if path?
        name = file.name.replace(/\.[^\.]*$/, '')
        contentsBase64 = extractBase64Data(event.target.result)
        saveFile
          contents_base64: contentsBase64
          path: "/#{path}/#{name}.#{extension}"

        contents = Base64.decode(contentsBase64) if type is "text"

        newFileNode
          type: type
          path: "#{path}/#{name}.#{extension}"
          contents: contents
          autoOpen: autoOpen

        notify "'#{name}.#{extension}' successfully imported."
