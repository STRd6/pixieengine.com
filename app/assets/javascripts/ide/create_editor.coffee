window.createEditor = (ui) ->
  panel = $(ui.panel)
  tab = $(ui.tab)
  data = panel.data()
  data.panel = panel
  {type, lang} = data

  if type == "text"
    editor = createTextEditor data

  else if type == "json"
    editor = createJsonEditor data

  else if type == "entity"
    editor = createEntityEditor data

  else if type == "image"
    editor = createPixelEditor data

  else if type == "animation"
    editor = createAnimationEditor data

  else if type == "tilemap"
    editor = createTileEditor data

  else if type == "sound"
    editor = createSoundEditor data

  else if type == "documentation" || type == "tutorial"
    # These just open up info tabs
    return {
      cssClass: type
    }

  if editor
    editor.bind 'clean', ->
      tab.parent().removeClass("unsaved")
    editor.bind 'change dirty', ->
      tab.parent().addClass("unsaved")

    cssClass: lang
    doSave: () ->
      editor.trigger('save')
