$tabs = $('#tabs').tabs
  add: (event, ui) ->
    {name, contents, docSelector, type} = currentFile.attributes
    extension = name.extension()

    iconCss = "#{type} #{extension}"

    if type is 'documentation'
      $(ui.panel).append "<iframe class='no_border' src='/production/projects/#{doc_id}/docs/index.html' width='100%' height='100%'></iframe>"
      $(ui.tab).parent().find('span.lang').addClass(iconCss)
    else if fileData = createEditor(ui)
      $(ui.tab).data('updateSaved', fileData.updateSaved)
      $(ui.tab).data('doSave', fileData.doSave)
      $(ui.tab).parent().find('span.lang').addClass(iconCss)

    window.currentPanel = ui.panel
    $tabs.tabs('select', docSelector)
    $('#tabs ul li a[href="' + docSelector + '"]').click()

  select: (event, ui) ->
    window.currentPanel = ui.panel

    if editor = $(ui.panel).data "editor"
      window.currentComponent = editor

    textEditor = $(ui.panel).data("textEditor")

    setTimeout ->
      textEditor.focus() if textEditor
    , 0

  tabTemplate: '<li><span class="ui-icon ui-icon-close"></span><span class="ui-icon lang"></span><a href="#' + '{href}">#' + '{label}</a></li>'

$("#tabs").on "click", "span.ui-icon-close", ->
  parent = $(this).parent()

  if not parent.hasClass("unsaved") or confirm("You are about to close an unsaved file, continue?")
    index = $('li', $tabs).index(parent)
    $tabs.tabs('remove', index)

$("#tabs").on "click", "span.ui-icon.lang", ->
  parent = $(this).parent()
  index = $('li', $tabs).index(parent)
  $tabs.tabs('select', index)
