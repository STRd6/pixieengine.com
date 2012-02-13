window.createEditor = (ui) ->
  panel = $(ui.panel)
  tab = $(ui.tab)
  data = panel.data()
  data.panel = panel

  {contents, id, path} = window.currentFile.attributes

  form =
    """
      <form accept-charset="UTF-8" action="/projects/#{id}/save_file.json" method="post">
        <input name="path" type="hidden" value="#{path}">
        <textarea name="contents" style="display:none;">#{contents}</textarea>
      </form>
    """

  data.panel.append(form)

  {type, language} = window.currentFile.attributes

  if type is "documentation" or type is "tutorial"
    # These just open up info tabs
    return {
      cssClass: type
    }
  else
    editor = ("create#{type.capitalize()}Editor".constantize())(data, window.currentFile)

  if editor
    # Currently these events can be either backbone or jQuery events,
    # so be sure to bind in a way that works with either.
    # TODO: Only use backbone events
    editor.bind 'clean', ->
      tab.parent().removeClass("unsaved")
    editor.bind 'change', ->
      tab.parent().addClass("unsaved")
    editor.bind 'dirty', ->
      tab.parent().addClass("unsaved")

    cssClass: "#{language} #{type}"
    doSave: () ->
      editor.trigger('save')
