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

    # big hack: In the json editor the browser fired a change event when you
    # tabbed out of a field after it had been saved. I'm not sure exactly why. Probably
    # some internal state on the input element had changed. I hacked this in to prevent
    # the browser from firing change events on the json editor. Instead the json editor
    # only triggers 'dirty' events when its state has changed.
    unless (type is 'json' or type is 'entity')
      editor.bind 'change', (e) ->
        tabParent.addClass("unsaved")

    editor.bind 'dirty', ->
      tabParent.addClass("unsaved")

    cssClass: "#{language} #{type}"
    doSave: () ->
      editor.trigger('save')
