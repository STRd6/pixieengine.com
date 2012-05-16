#= require bone_tree

window.tree = new BoneTree.Views.Tree

fileTreeData = JSON.parse($('#code_content').val())

tree.addFromJSON fileTreeData, ''

tree.closeDirectories()

tree.file "Documentation.documentation",
  type: "documentation"

tree.bind 'openFile', (file) ->
  openFile(file)

tree.bind 'rename', (file, newName) ->
  {docSelector, extension, language, name, nodeType, path, type} = file.attributes

  openedTab = $('#tabs ul li a[href="' + docSelector + '"]').parent()

  # Abort if unsaved
  if openedTab.is(".unsaved")
    notify "Save #{file.nameWithExtension()} before renaming"
    return
  else
    openedTab.find(".ui-icon-close").click()

  oldExtension = file.previous('extension')
  oldExtension = "." + oldExtension if oldExtension isnt ""

  # this works because we are secretly inside a change event
  oldName = file.previous('name') + oldExtension

  # TODO: This is broken for files whose names are a subset of the prior path
  # ex. boobaz/boo
  newPath = path.replace(oldName, newName)
  oldPath = path

  # docSelector will be auto-updated when opening files, so I think no need to set here
  file.set
    path: newPath
    _path: newPath # TODO: Find out why there is an _path

  postData =
    path: oldPath
    new_path: newPath
    format: 'json'
    message: $(".actions .status .message").val()

  $.post "/projects/#{projectId}/rename_file", postData, -> # Assuming success
  notify "Renamed #{oldName} => #{newName}"

  # Close and reopen file if open
  if openedTab.length
    openFile(file)

tree.bind 'remove', (file) ->
  notify "Removing #{file.nameWithExtension()}..."

  docSelector = file.get('docSelector')

  # Close the tab if open
  $('#tabs ul li a[href="' + docSelector + '"]').parent().find(".ui-icon-close").click()

  path = file.get('path')
  message = $(".actions .status .message").val()

  postData =
    path: path
    format: 'json'
    message: message

  successCallback = (data) ->
    notify "#{file.nameWithExtension()} removed!"

  $.post "/projects/#{projectId}/remove_file", postData, successCallback

$('.sidebar').append(tree.render().$el)
