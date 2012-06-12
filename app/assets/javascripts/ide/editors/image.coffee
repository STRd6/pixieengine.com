window.createImageEditor = (options, file) ->
  panel = options.panel
  {contents, mtime, options:editorOptions, path} = file.attributes

  mtime ||= +new Date()

  dataUrl = "/#{railsEnv}/projects/#{projectId}/#{path}?#{mtime}"
  _canvas = null

  editorOptions = $.extend editorOptions,
    frames: 1
    initializer: (canvas) ->
      _canvas = canvas

      if contentsVal = contents
        canvas.fromDataURL(contentsVal)
      else if dataUrl
        canvas.fromDataURL(dataUrl)

      canvas.addAction
        name: "download"
        perform: (canvas) ->
          w = window.open()
          w.document.location = canvas.toDataURL()
        undoable: false

      canvas.addAction
        name: "Save"
        icon: "/assets/icons/database_save.png"
        perform: (canvas) ->
          pixelEditor.trigger('save')

        undoable: false

      canvas.addAction
        name: "Save As"
        icon: "/assets/icons/database_save.png"
        perform: (canvas) ->
          base64Contents = _canvas.toBase64()

          oldFile = tree.getFile(path)

          [fileNames..., extension] = oldFile.name().split('.')

          if title = prompt("Title", fileNames.join('.'))
            filePath = projectConfig.directories["images"]
            fullPath = filePath + "/" + title + ".png"

            # TODO remove global tree reference
            file = tree.add fullPath,
              type: "image"
              contents: "data:image/png;base64," + base64Contents

            openFile file

            saveFile
              contents_base64: base64Contents
              path: fullPath

            closeFile(oldFile)

        undoable: false

  pixelEditor = Pixie.Editor.Pixel.create(editorOptions)

  pixelEditor.bind 'save', ->
    base64Contents = _canvas.toBase64()
    # Update mtime to bust browser image caching
    file.set
      contents: "data:image/png;base64," + base64Contents
      mtime: new Date().getTime()

    saveFile
      contents_base64: base64Contents
      path: path
      success: ->
        pixelEditor.trigger "clean"

  panel.empty().append(pixelEditor)

  return pixelEditor

$.fn.modalPixelEditor = (options) ->
  input = this

  return if input.data('modalPixelEditor')

  previewImage = $ "<img />"
    src: input.val()

  input.after(previewImage).hide().data('modalPixelEditor', true)

  options = $.extend {}, options,
    initializer: (canvas) ->
      _canvas = canvas

      if dataUrl = input.val()
        canvas.fromDataURL(dataUrl)

      canvas.addAction
        name: "Store"
        icon: "/assets/icons/database_save.png"
        perform: (canvas) ->
          imageData = canvas.toDataURL()

          input.val(imageData).trigger('blur')
          previewImage.attr("src", imageData)

          $.modal.close()

          #TODO select props editor
          window.currentComponent = null

        undoable: false

  showEditor = ->
    pixelEditor = Pixie.Editor.Pixel.create(options)

    pixelEditor.modal
      containerCss:
        height: 600
        width: 800
        maxHeight: 600
        maxWidth: 800

    window.currentComponent = pixelEditor

  input.parent().click(showEditor)

  return this
