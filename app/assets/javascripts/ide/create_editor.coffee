window.createEditor = (ui) ->
  panel = $(ui.panel)
  tab = $(ui.tab)
  data = panel.data()
  data.panel = panel

  {language, type} = window.currentFile.attributes

  editor = ("create#{type.capitalize()}Editor".constantize())(data, window.currentFile)

  if editor
    tabParent = tab.parent()
    # Currently these events can be either backbone or jQuery events,
    # so be sure to bind in a way that works with either.
    # TODO: Only use backbone events
    editor.bind 'clean', ->
      tabParent.removeClass("unsaved")
    editor.bind 'change', ->
      tabParent.addClass("unsaved")
    editor.bind 'dirty', ->
      tabParent.addClass("unsaved")

    cssClass: "#{language} #{type}"
    doSave: () ->
      editor.trigger('save')
