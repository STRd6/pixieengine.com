window.createSoundEditor = (options, file) ->
  {panel} = options
  {contents, path} = file.attributes

  # Assume that the path ends in .sfs, and chop to just the file name
  basePath = path.substring(0, path.length - 4)

  soundEditor = $("<div />")

  soundEditor.append $("<embed width='640' height='480' src='/flash/sfxr.swf' flashvars='embeddedMode=1&soundData=#{encodeURIComponent(contents)}&baseFilePath=#{encodeURIComponent(basePath)}&#{sessionFlashVars}' quality='high' pluginspage='http://www.adobe.com/go/getflashplayer' align='top' play='true' loop='true' scale='showall' wmode='opaque' devicefont='false' bgcolor='#ffffff' name='as3sfxr' menu='true' allowfullscreen='false' allowscriptaccess='sameDomain' salign='' type='application/x-shockwave-flash' />")

  soundEditor.bind 'save', ->
    data = JSON.parse(soundEditor.find('embed').get(0).getSaveData())

    sfsFileData = data.files[0].contents_base64

    file.set
      contents: sfsFileData

    # Save .sfs
    saveFile
      contents_base64: sfsFileData
      path: data.files[0].path
      success: ->
        soundEditor.trigger "clean"

    # Save .wav
    saveFile
      contents_base64: data.files[1].contents_base64
      path: data.files[1].path

  # Need to clear out any old stuff
  panel.empty().append(soundEditor)

  return soundEditor
